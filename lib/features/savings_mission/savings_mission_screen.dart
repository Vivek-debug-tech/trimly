import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trimly/core/enums/currency.dart';
import 'package:trimly/core/utils/currency_formatter.dart';
import 'package:trimly/domain/engines/optimizer_service.dart';
import 'package:trimly/features/shared/trimly_components.dart';
import 'package:trimly/services/subscriptions/subscription_provider.dart';
import 'package:trimly/services/user_settings/savings_target_provider.dart';
import 'package:trimly/services/user_settings/user_settings_provider.dart';

class SavingsMissionScreen extends ConsumerWidget {
  const SavingsMissionScreen({super.key});

  Future<void> _editTarget(BuildContext context, WidgetRef ref, double currentTarget, Currency currency) async {
    final controller = TextEditingController(text: currentTarget.toStringAsFixed(0));
    final newTarget = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Target'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Monthly Savings Target',
            prefixText: currency.symbol,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value > 0 && !value.isNaN) {
                Navigator.of(ctx).pop(value);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newTarget != null && newTarget > 0) {
      ref.read(savingsTargetProvider.notifier).setTarget(newTarget);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(userSettingsProvider);
    final targetAsync = ref.watch(savingsTargetProvider);
    final subscriptions = ref.watch(subscriptionProvider);

    return settingsAsync.when(
      data: (settings) => targetAsync.when(
        data: (target) {
          final optimizerResult = OptimizerService().optimize(
            subscriptions: subscriptions,
            target: target,
          );
          final saved = optimizerResult.recommendedPlan?.monthlySavings ?? 0.0;
          final planNames =
              optimizerResult
                  .recommendedPlan
                  ?.explanation
                  .selectedSubscriptionNames ??
              const [];
          final percent = target <= 0 ? 0.0 : (saved / target).clamp(0.0, 1.0);

          return Scaffold(
            backgroundColor: const Color(0xFFF5F7F7),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Savings Mission',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 12),
                    TrimlyCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Target',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 16),
                                onPressed: () => _editTarget(context, ref, target, settings.currency),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            CurrencyFormatter.format(target, settings.currency),
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: percent,
                                    minHeight: 12,
                                    backgroundColor: const Color(0xFFEAF2F3),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Color(0xFF006064),
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                CurrencyFormatter.format(
                                  saved,
                                  settings.currency,
                                ),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '${(percent * 100).round()}%',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Recommended plan',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    TrimlyCard(
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome_outlined),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subscriptions.isEmpty
                                      ? 'No subscriptions to optimize. Add subscriptions to get started.'
                                      : (planNames.isEmpty
                                          ? 'No eligible plan found yet.'
                                          : planNames.join(' + ')),
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Savings: ${CurrencyFormatter.format(saved, settings.currency)}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, stack) => Scaffold(body: Center(child: Text('Unable to load target: $error'))),
      ),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(body: Center(child: Text('Unable to load settings: $error'))),
    );
  }
}
