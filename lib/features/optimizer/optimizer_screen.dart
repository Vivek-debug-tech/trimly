import 'package:flutter/material.dart';
import 'package:trimly/core/enums/currency.dart';
import 'package:trimly/core/utils/currency_formatter.dart';
import 'package:trimly/features/shared/demo_data.dart';
import 'package:trimly/features/shared/trimly_components.dart';

class OptimizerScreen extends StatefulWidget {
  const OptimizerScreen({super.key});

  @override
  State<OptimizerScreen> createState() => _OptimizerScreenState();
}

class _OptimizerScreenState extends State<OptimizerScreen> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final subscriptions = demoSubscriptions(currency: Currency.inr);
    const target = 2500.0;
    const obviousGuess = 2499.0;
    const trimlyRecommendation = 2800.0;

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
                            CurrencyFormatter.format(target, Currency.inr),
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
                          ? _buildRecommendationCard(context, trimlyRecommendation, subscriptions)
                          : _buildObviousGuessCard(context, obviousGuess),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: TrimlyButton(
                        label: _revealed ? 'Hide recommendation' : 'Reveal Trimly recommendation',
                        onPressed: () => setState(() => _revealed = !_revealed),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SectionHeader(title: 'Alternatives'),
                    const SizedBox(height: 12),
                    ...[
                      ('Netflix + Canva', 2200.0),
                      ('Spotify + Canva', 1800.0),
                      ('Cancel all review items', 2600.0),
                    ].map(
                      (alt) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TrimlyCard(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  alt.$1,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              Text(
                                CurrencyFormatter.format(alt.$2, Currency.inr),
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
  }

  Widget _buildObviousGuessCard(BuildContext context, double value) {
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
                  'Cancel Gym',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    decoration: TextDecoration.lineThrough,
                    decorationThickness: 2,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              Text(
                CurrencyFormatter.format(value, Currency.inr),
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
    List<dynamic> subscriptions,
  ) {
    final blur = Container(
      color: Colors.white.withValues(alpha: 0.16),
    );

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
      child: Stack(
        children: [
          Positioned.fill(child: blur),
          Column(
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
                'Keep Gym. Cancel Netflix + Canva.',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                'Gym is used daily and marked essential. Netflix and Canva have lower impact.',
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
                    CurrencyFormatter.format(value, Currency.inr),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
