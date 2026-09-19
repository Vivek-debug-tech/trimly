import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trimly/core/utils/currency_formatter.dart';
import 'package:trimly/features/shared/demo_data.dart';
import 'package:trimly/features/shared/trimly_components.dart';
import 'package:trimly/services/user_settings/user_settings_provider.dart';

class TrialsScreen extends ConsumerWidget {
  const TrialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(userSettingsProvider);

    return settingsAsync.when(
      data: (settings) {
        final subscriptions = demoSubscriptions(currency: settings.currency);
        final filtered = subscriptions.where((s) => s.trialEndDate != null).toList();

        return Scaffold(
          appBar: AppBar(title: const Text('Trials')),
          backgroundColor: const Color(0xFFF5F7F7),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  return TrimlyCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Trial ends ${item.trialEndDate!.day}/${item.trialEndDate!.month}/${item.trialEndDate!.year}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Current charge: ${CurrencyFormatter.format(item.price, settings.currency)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.postTrialPrice == null
                              ? 'Post-trial charge: unavailable'
                              : 'Post-trial charge: ${CurrencyFormatter.format(item.postTrialPrice!, settings.currency)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
