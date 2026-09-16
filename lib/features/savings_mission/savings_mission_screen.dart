import 'package:flutter/material.dart';
import 'package:trimly/core/enums/currency.dart';
import 'package:trimly/core/utils/currency_formatter.dart';
import 'package:trimly/features/shared/trimly_components.dart';

class SavingsMissionScreen extends StatelessWidget {
  const SavingsMissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const target = 2500.0;
    const saved = 1600.0;
    final percent = (saved / target).clamp(0.0, 1.0);

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
                    Text(
                      'Target',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyFormatter.format(target, Currency.inr),
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
                              valueColor: const AlwaysStoppedAnimation<Color>(
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
                          CurrencyFormatter.format(saved, Currency.inr),
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
                            'Keep Gym. Cancel Netflix + Canva.',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Savings: ${CurrencyFormatter.format(1600, Currency.inr)}',
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
  }
}
