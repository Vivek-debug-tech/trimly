import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trimly/core/enums/country.dart';
import 'package:trimly/core/enums/currency.dart';
import 'package:trimly/domain/models/user_settings.dart';
import 'package:trimly/features/optimizer/optimizer_screen.dart';
import 'package:trimly/services/revenuecat/premium_provider.dart';
import 'package:trimly/services/revenuecat/entitlement_state.dart';
import 'package:trimly/services/user_settings/user_settings_provider.dart';

class MockPremiumController extends PremiumController {
  MockPremiumController(this.initialState);
  final EntitlementState initialState;
  @override
  EntitlementState build() => initialState;
}

class MockUserSettingsController extends UserSettingsController {
  @override
  Future<UserSettings> build() async => const UserSettings(country: Country.unitedStates, currency: Currency.usd);
}

class TestOptimizerWrapper extends StatelessWidget {
  const TestOptimizerWrapper({super.key, required this.premiumController});
  final MockPremiumController premiumController;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        premiumProvider.overrideWith(() => premiumController),
        userSettingsProvider.overrideWith(MockUserSettingsController.new),
      ],
      child: MaterialApp(
        routes: {
          '/paywall': (context) =>
              const Scaffold(body: Text('MOCK PAYWALL UI')),
        },
        home: const OptimizerScreen(),
      ),
    );
  }
}

void main() {
  group('Optimizer Gate Tests', () {
    testWidgets(
      'Free users attempting to access Trimly Recommendation are routed to Paywall',
      (tester) async {
        final controller = MockPremiumController(const EntitlementState.free());
        await tester.pumpWidget(
          TestOptimizerWrapper(premiumController: controller),
        );
        await tester.pumpAndSettle();

        // Obvious Guess should be visible for Free initially
        expect(find.text('Obvious Guess'), findsOneWidget);

        await tester.tap(find.text('Reveal Trimly recommendation'));
        await tester.pumpAndSettle();

        // User routed to PAYWALL rather than revealing Recommendation
        expect(find.text('MOCK PAYWALL UI'), findsOneWidget);
      },
    );

    testWidgets(
      'Pro users bypass gate and view Trimly Recommendation directly',
      (tester) async {
        final controller = MockPremiumController(const EntitlementState.pro());
        await tester.pumpWidget(
          TestOptimizerWrapper(premiumController: controller),
        );
        await tester.pumpAndSettle();

        expect(find.text('Obvious Guess'), findsOneWidget);

        await tester.tap(find.text('Reveal Trimly recommendation'));
        await tester.pumpAndSettle();

        // User sees full Trimly Recommendation, Paywall route IS NOT executed
        expect(find.text('Trimly recommends'), findsOneWidget);
        expect(find.text('MOCK PAYWALL UI'), findsNothing);
      },
    );
  });
}
