import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trimly/core/utils/currency_formatter.dart';
import 'package:trimly/domain/engines/optimizer_service.dart';
import 'package:trimly/features/shared/demo_data.dart';
import 'package:trimly/features/shared/trimly_components.dart';
import 'package:trimly/services/user_settings/user_settings_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(userSettingsProvider);

    return settingsAsync.when(
      data: (settings) {
        final subscriptions = demoSubscriptions(currency: settings.currency);
        final amount = subscriptions.fold<double>(
          0,
          (total, subscription) => total + subscription.price,
        );
        final optimizerResult = OptimizerService().optimize(
          subscriptions: subscriptions,
          target: demoSavingsTarget,
        );
        final representativeStatus = subscriptions.first.decisionStatus;
        final recommendationText = optimizerResult.recommendedPlan != null
            ? optimizerResult.recommendedPlan!.explanation.selectedSubscriptionNames
                .join(', ')
            : optimizerResult.explanation;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trimly',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You are probably paying for things you forgot about.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        softWrap: true,
                      ),
                      const SizedBox(height: 22),
                      TrimlyCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monthly spend',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: const Color(0xFF607578)),
                            ),
                            const SizedBox(height: 12),
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOutCubic,
                              tween: Tween<double>(begin: 0, end: amount),
                              builder: (context, value, child) {
                                return Text(
                                  CurrencyFormatter.format(value, settings.currency),
                                  style: Theme.of(context).textTheme.headlineLarge,
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                StatusBadge(status: representativeStatus),
                                Text(
                                  '${subscriptions.length} active subscriptions',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      SectionHeader(
                        title: 'Renewal',
                        action: TextButton(
                          onPressed: () => Navigator.of(context).pushNamed('/renewal-radar'),
                          child: const Text('View all'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final subscription = subscriptions[index % subscriptions.length];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        scale: 1,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () => Navigator.of(context).pushNamed(
                              '/renewal-details',
                              arguments: subscription,
                            ),
                            child: SubscriptionSummaryCard(
                              subscription: subscription,
                              currency: settings.currency,
                              trailing: const Icon(Icons.chevron_right),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: 3,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Action',
                      action: TextButton(
                        onPressed: () => Navigator.of(context).pushNamed('/optimizer'),
                        child: const Text('Open optimizer'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TrimlyCard(
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Trimly recommendation',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  recommendationText,
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
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
