import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trimly/app/theme/app_theme.dart';
import 'package:trimly/core/enums/country.dart';
import 'package:trimly/domain/models/user_settings.dart';
import 'package:trimly/features/shared/trimly_components.dart';
import 'package:trimly/services/user_settings/user_settings_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  Country selectedCountry = Country.india;

  @override
  Widget build(BuildContext context) {
    final userSettingsAsync = ref.watch(userSettingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F7),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: userSettingsAsync.when(
                data: (settings) {
                  selectedCountry = settings.country;
                  final defaultCurrency = selectedCountry.defaultCurrency;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            Text(
                              'Set your country',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Trimly uses one active currency for your account.',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 26),
                            SizedBox(
                              height: 280,
                              child: GridView.builder(
                                itemCount: Country.values.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 1.45,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                ),
                                itemBuilder: (context, index) {
                                  final country = Country.values[index];
                                  final isSelected = country == selectedCountry;
                                  return InkWell(
                                    onTap: () => setState(() => selectedCountry = country),
                                    borderRadius: BorderRadius.circular(18),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        color: isSelected
                                            ? AppTheme.deepTeal.withValues(alpha: 0.08)
                                            : Colors.white,
                                        border: Border.all(
                                          color: isSelected
                                              ? AppTheme.deepTeal
                                              : const Color(0xFFE4ECEE),
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            country.displayName,
                                            style: Theme.of(context).textTheme.titleMedium,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            country.defaultCurrency.name.toUpperCase(),
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: AppTheme.brushedSteel,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 18),
                            TrimlyCard(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Selected currency',
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          defaultCurrency.name.toUpperCase(),
                                          style: Theme.of(context).textTheme.titleLarge,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.amberGold.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      'Locked after onboarding',
                                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        color: AppTheme.deepTeal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: TrimlyButton(
                                label: 'Continue',
                                onPressed: () async {
                                  final settings = UserSettings(
                                    country: selectedCountry,
                                    currency: selectedCountry.defaultCurrency,
                                  );
                                  await ref.read(userSettingsProvider.notifier).setSettings(settings);
                                  if (context.mounted) {
                                    Navigator.of(context).pushReplacementNamed('/home');
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Unable to load user settings: $error'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
