import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trimly/core/utils/currency_formatter.dart';
import 'package:trimly/domain/models/subscription.dart';
import 'package:trimly/features/shared/trimly_components.dart';
import 'package:trimly/services/user_settings/user_settings_provider.dart';

class ValueCheckDetailsScreen extends ConsumerWidget {
  const ValueCheckDetailsScreen({
    super.key,
    required this.subscription,
  });

  final Subscription subscription;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(userSettingsProvider);
    final renewalDate =
        '${subscription.nextRenewalDate.day}/${subscription.nextRenewalDate.month}/${subscription.nextRenewalDate.year}';

    return settingsAsync.when(
      data: (settings) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7F7),
          appBar: AppBar(
            title: const Text('Value Check'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TrimlyCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.fact_check_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subscription.name,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                subscription.category,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 10),
                              StatusBadge(status: subscription.decisionStatus),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TrimlyCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Decision details',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _DetailRow(
                          label: 'Recommendation',
                          value: subscription.decisionStatus.name,
                        ),
                        _DetailRow(
                          label: 'Price',
                          value: CurrencyFormatter.format(subscription.price, settings.currency),
                        ),
                        _DetailRow(
                          label: 'Billing',
                          value: subscription.billingCycle.name,
                        ),
                        _DetailRow(
                          label: 'Next renewal',
                          value: renewalDate,
                        ),
                        if (subscription.usageFrequency != null)
                          _DetailRow(
                            label: 'Usage',
                            value: subscription.usageFrequency!.name,
                          ),
                        if (subscription.importance != null)
                          _DetailRow(
                            label: 'Importance',
                            value: subscription.importance!.name,
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
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Unable to load settings: $error')),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
