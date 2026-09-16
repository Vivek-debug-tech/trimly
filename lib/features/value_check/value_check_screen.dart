import 'package:flutter/material.dart';
import 'package:trimly/core/enums/currency.dart';
import 'package:trimly/features/shared/demo_data.dart';
import 'package:trimly/features/shared/trimly_components.dart';

class ValueCheckScreen extends StatelessWidget {
  const ValueCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subscriptions = demoSubscriptions(currency: Currency.inr);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Value Check',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'Review what is worth keeping, reviewing, or cutting.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: subscriptions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final subscription = subscriptions[index];
                    final status = subscription.decisionStatus;
                    return AnimatedScale(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      scale: 1,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () => Navigator.of(context).pushNamed(
                            '/value-check-details',
                            arguments: subscription,
                          ),
                          child: TrimlyCard(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              subscription.name,
                                              style: Theme.of(context).textTheme.titleMedium,
                                            ),
                                          ),
                                          StatusBadge(status: status),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        subscription.category,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          CurrencyAmount(
                                            amount: subscription.price,
                                            currency: Currency.values.firstWhere(
                                              (item) => item.name == subscription.currency,
                                              orElse: () => Currency.inr,
                                            ),
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '/ ${subscription.billingCycle.name}',
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEAF2F3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.chevron_right),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
