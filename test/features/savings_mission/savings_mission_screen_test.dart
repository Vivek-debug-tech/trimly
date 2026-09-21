import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trimly/features/savings_mission/savings_mission_screen.dart';
import 'package:trimly/services/user_settings/savings_target_provider.dart';
import 'package:trimly/services/subscriptions/subscription_provider.dart';
import 'package:trimly/domain/models/subscription.dart';
import 'package:trimly/domain/models/user_settings.dart';
import 'package:trimly/services/user_settings/user_settings_provider.dart';
import 'package:trimly/core/enums/country.dart';
import 'package:trimly/core/enums/currency.dart';

class MockUserSettingsController extends UserSettingsController {
  @override
  Future<UserSettings> build() async => const UserSettings(country: Country.unitedStates, currency: Currency.usd);
}

class MockSavingsTargetController extends SavingsTargetController {
  MockSavingsTargetController(this.currentValue);
  double currentValue;
  @override
  Future<double> build() async => currentValue;

  @override
  Future<void> setTarget(double value) async {
    currentValue = value;
    state = AsyncValue.data(value);
  }
}

class MockSubscriptionController extends SubscriptionController {
  MockSubscriptionController(this.mockData);
  final List<Subscription> mockData;
  @override
  List<Subscription> build() => mockData;
}

class TestWrapper extends StatelessWidget {
  const TestWrapper({super.key, required this.target, required this.subs});
  final double target;
  final List<Subscription> subs;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        userSettingsProvider.overrideWith(MockUserSettingsController.new),
        savingsTargetProvider.overrideWith(() => MockSavingsTargetController(target)),
        subscriptionProvider.overrideWith(() => MockSubscriptionController(subs)),
      ],
      child: const MaterialApp(
        home: SavingsMissionScreen(),
      ),
    );
  }
}

void main() {
  group('SavingsMissionScreen Tests', () {
    testWidgets('Empty subscription state displays gracefully', (tester) async {
      await tester.pumpWidget(const TestWrapper(target: 2500.0, subs: []));
      await tester.pumpAndSettle();

      expect(find.text('No subscriptions to optimize. Add subscriptions to get started.'), findsOneWidget);
    });

    testWidgets('Changing target modifies state and UI updates nicely', (tester) async {
      await tester.pumpWidget(const TestWrapper(target: 2500.0, subs: []));
      await tester.pumpAndSettle();

      expect(find.text('\$2,500.00'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '3000');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('\$3,000.00'), findsOneWidget);
    });
  });
}
