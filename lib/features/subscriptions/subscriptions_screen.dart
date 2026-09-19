import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trimly/features/shared/demo_data.dart';
import 'package:trimly/features/shared/trimly_components.dart';
import 'package:trimly/services/user_settings/user_settings_provider.dart';

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(userSettingsProvider);

    return settingsAsync.when(
      data: (settings) {
        final subscriptions = demoSubscriptions(currency: settings.currency);

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7F7),
          body: SafeArea(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              itemCount: subscriptions.length + 1,
              separatorBuilder: (_, index) => SizedBox(
                height: index == 0 ? 18 : 12,
              ),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subscriptions',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${subscriptions.length} active subscriptions',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  );
                }

                final subscription = subscriptions[index - 1];
                return SubscriptionSummaryCard(
                  subscription: subscription,
                  currency: settings.currency,
                );
              },
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
