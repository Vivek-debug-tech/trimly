import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trimly/core/enums/currency.dart';
import 'package:trimly/core/utils/currency_formatter.dart';
import 'package:trimly/domain/engines/optimizer_service.dart';
import 'package:trimly/domain/models/optimizer_models.dart';
import 'package:trimly/features/shared/demo_data.dart';
import 'package:trimly/features/shared/trimly_components.dart';
import 'package:trimly/services/revenuecat/premium_provider.dart';
import 'package:trimly/services/user_settings/user_settings_provider.dart';

class OptimizerScreen extends ConsumerStatefulWidget {
  const OptimizerScreen({super.key});

  @override
  ConsumerState<OptimizerScreen> createState() => _OptimizerScreenState();
}

class _OptimizerScreenState extends ConsumerState<OptimizerScreen> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(userSettingsProvider);
    final entState = ref.watch(premiumProvider);

    return settingsAsync.when(
      data: (settings) {
        final subscriptions = demoSubscriptions(currency: settings.currency);
        final optimizerResult = OptimizerService().optimize(
          subscriptions: subscriptions,
          target: demoSavingsTarget,
        );
        final recommendedPlan = optimizerResult.recommendedPlan;
        final recommendedNames = recommendedPlan?.explanation.selectedSubscriptionNames ?? const [];
        final recommendedSaving = recommendedPlan?.monthlySavings ?? 0.0;
        final naiveResult = NaiveBaselineService().recommend(
          subscriptions: subscriptions,
          target: demoSavingsTarget,
        );

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7F7),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Optimizer',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Focus on the recommendation that reaches your target with the lowest impact.',
                          style: Theme.of(context).textTheme.bodyLarge,
                          softWrap: true,
                        ),
                        const SizedBox(height: 18),
                        TrimlyCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Savings target',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                CurrencyFormatter.format(optimizerResult.target, settings.currency),
                                style: Theme.of(context).textTheme.headlineLarge,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: _revealed
                              ? _buildRecommendationCard(
                                  context,
                                  recommendedSaving,
                                  recommendedNames,
                                  optimizerResult.explanation,
                                  settings.currency,
                                )
                              : _buildObviousGuessCard(
                                  context,
                                  naiveResult,
                                  settings.currency,
                                ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: TrimlyButton(
                            label: _revealed
                                ? 'Hide recommendation'
                                : 'Reveal Trimly recommendation',
                            onPressed: () {
                              if (!entState.isPro && !_revealed) {
                                Navigator.of(context).pushNamed('/paywall');
                                return;
                              }
                              setState(() => _revealed = !_revealed);
                            },
                          ),
                        ),
                        const SizedBox(height: 18),
                        SectionHeader(title: 'Alternatives'),
                        const SizedBox(height: 12),
                        ...optimizerResult.alternatives.map(
                          (alt) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: TrimlyCard(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      alt.explanation.selectedSubscriptionNames.join(' + '),
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(alt.monthlySavings, settings.currency),
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Unable to load optimizer: $error')),
    );
  }

  Widget _buildObviousGuessCard(
    BuildContext context,
    NaiveBaselineResult result,
    Currency currency,
  ) {
    final label = result.hasValidPlan
        ? result.selectedSubscriptions.map((item) => item.name).join(' + ')
        : 'No valid baseline plan';

    return Container(
      key: const ValueKey('obvious_guess'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4ECEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Obvious Guess',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF607578),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              Text(
                CurrencyFormatter.format(result.monthlySavings, currency),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    double value,
    List<String> selectedNames,
    String explanation,
    Currency currency,
  ) {
    final planLabel = selectedNames.isEmpty ? 'No eligible savings plan' : selectedNames.join(' + ');

    return AnimatedContainer(
      key: const ValueKey('trimly_recommendation'),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF006064).withValues(alpha: 0.12),
            const Color(0xFFFFB300).withValues(alpha: 0.10),
            Colors.white,
          ],
        ),
        border: Border.all(color: const Color(0xFF006064).withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trimly recommends',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF006064),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            planLabel,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(
            explanation,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Savings achieved',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                CurrencyFormatter.format(value, currency),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
