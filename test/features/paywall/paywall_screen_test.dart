import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trimly/features/paywall/paywall_screen.dart';
import 'package:trimly/services/revenuecat/premium_provider.dart';
import 'package:trimly/services/revenuecat/trimly_offerings.dart';
import 'package:trimly/services/revenuecat/entitlement_state.dart';

class MockPremiumController extends PremiumController {
  MockPremiumController(this.initialState, {this.mockOfferings});

  final EntitlementState initialState;
  TrimlyOfferings? mockOfferings;
  TrimlyPlan? purchasedPlan;
  bool restoreCalled = false;
  PurchaseResultStatus purchaseStatus = PurchaseResultStatus.success;
  RestoreResultStatus restoreStatus = RestoreResultStatus.success;

  @override
  EntitlementState build() => initialState;

  @override
  Future<TrimlyOfferings?> getOfferings() async => mockOfferings;

  @override
  Future<PurchaseResultStatus> purchase(TrimlyPlan plan) async {
    purchasedPlan = plan;
    return purchaseStatus;
  }

  @override
  Future<RestoreResultStatus> restore() async {
    restoreCalled = true;
    return restoreStatus;
  }

  void mockUpdateState(EntitlementState next) {
    state = next;
  }
}

class TestPaywallWrapper extends StatelessWidget {
  const TestPaywallWrapper({super.key, required this.controller});
  final MockPremiumController controller;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [premiumProvider.overrideWith(() => controller)],
      child: const MaterialApp(home: PaywallScreen()),
    );
  }
}

void main() {
  group('PaywallScreen', () {
    testWidgets('already-Pro behavior closes instantly', (tester) async {
      final controller = MockPremiumController(const EntitlementState.pro());
      await tester.pumpWidget(TestPaywallWrapper(controller: controller));
      await tester.pumpAndSettle();

      // Because it pops instantly, the PaywallScreen should not be in the hierarchy anymore.
      expect(find.byType(PaywallScreen), findsNothing);
    });

    testWidgets('offerings failure shows retry state', (tester) async {
      final controller = MockPremiumController(
        const EntitlementState.free(),
        mockOfferings: null,
      );
      await tester.pumpWidget(TestPaywallWrapper(controller: controller));
      await tester.pumpAndSettle();

      expect(find.text('Plans unavailable'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('loads offerings and displays Monthly/Yearly/Lifetime', (
      tester,
    ) async {
      final controller = MockPremiumController(
        const EntitlementState.free(),
        mockOfferings: const TrimlyOfferings(
          monthly: TrimlyPackage(
            plan: TrimlyPlan.monthly,
            priceString: '\$1.99',
          ),
          yearly: TrimlyPackage(
            plan: TrimlyPlan.yearly,
            priceString: '\$19.99',
          ),
          lifetime: TrimlyPackage(
            plan: TrimlyPlan.lifetime,
            priceString: '\$49.99',
          ),
        ),
      );

      await tester.pumpWidget(TestPaywallWrapper(controller: controller));
      expect(
        find.byType(CircularProgressIndicator),
        findsOneWidget,
      ); // Loading state

      await tester.pumpAndSettle();

      expect(find.text('\$1.99'), findsOneWidget);
      expect(find.text('\$19.99'), findsOneWidget);
      expect(find.text('\$49.99'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Yearly'), findsOneWidget);
      expect(find.text('Lifetime'), findsOneWidget);
    });

    testWidgets(
      'plan selection changes local UI state but does not grant Pro',
      (tester) async {
        final controller = MockPremiumController(
          const EntitlementState.free(),
          mockOfferings: const TrimlyOfferings(
            monthly: TrimlyPackage(
              plan: TrimlyPlan.monthly,
              priceString: '\$1.99',
            ),
          ),
        );

        await tester.pumpWidget(TestPaywallWrapper(controller: controller));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Monthly'));
        await tester.pumpAndSettle();

        // UI remains active (Pro is not granted arbitrarily)
        expect(find.byType(PaywallScreen), findsOneWidget);
        expect(controller.state.isPro, isFalse);
      },
    );

    testWidgets(
      'purchase invokes correct TrimlyPlan and does not grant local Pro until reactive update',
      (tester) async {
        final controller = MockPremiumController(
          const EntitlementState.free(),
          mockOfferings: const TrimlyOfferings(
            monthly: TrimlyPackage(
              plan: TrimlyPlan.monthly,
              priceString: '\$1.99',
            ),
          ),
        );

        await tester.pumpWidget(TestPaywallWrapper(controller: controller));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Monthly'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Purchase'));
        await tester.pumpAndSettle();

        expect(controller.purchasedPlan, TrimlyPlan.monthly);

        // Pro is not granted by UI locally
        expect(controller.state.isPro, isFalse);
        expect(find.byType(PaywallScreen), findsOneWidget);

        // Reactive grant occurs via CustomerInfo returning:
        controller.mockUpdateState(const EntitlementState.pro());
        await tester.pumpAndSettle();

        // Modal dismissed natively because of reactive EntitlementState override
        expect(find.byType(PaywallScreen), findsNothing);
      },
    );

    testWidgets('purchase cancellation leaves user Free', (tester) async {
      final controller = MockPremiumController(
        const EntitlementState.free(),
        mockOfferings: const TrimlyOfferings(
          yearly: TrimlyPackage(
            plan: TrimlyPlan.yearly,
            priceString: '\$19.99',
          ),
        ),
      );
      controller.purchaseStatus = PurchaseResultStatus.cancelled;

      await tester.pumpWidget(TestPaywallWrapper(controller: controller));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Purchase'));
      await tester.pumpAndSettle();

      expect(controller.state.isPro, isFalse);
      expect(find.byType(PaywallScreen), findsOneWidget);
    });

    testWidgets('purchase failure shows snackbar and leaves user Free', (
      tester,
    ) async {
      final controller = MockPremiumController(
        const EntitlementState.free(),
        mockOfferings: const TrimlyOfferings(
          yearly: TrimlyPackage(
            plan: TrimlyPlan.yearly,
            priceString: '\$19.99',
          ),
        ),
      );
      controller.purchaseStatus = PurchaseResultStatus.error;

      await tester.pumpWidget(TestPaywallWrapper(controller: controller));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Purchase'));
      await tester.pumpAndSettle();

      expect(
        find.text('An error occurred with your purchase. Please try again.'),
        findsOneWidget,
      );
      expect(controller.state.isPro, isFalse);
    });

    testWidgets('restore invocation triggers restore and reacts safely', (
      tester,
    ) async {
      final controller = MockPremiumController(
        const EntitlementState.free(),
        mockOfferings: const TrimlyOfferings(
          yearly: TrimlyPackage(
            plan: TrimlyPlan.yearly,
            priceString: '\$19.99',
          ),
        ),
      );

      await tester.pumpWidget(TestPaywallWrapper(controller: controller));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Restore Purchases'));
      await tester.pumpAndSettle();

      expect(controller.restoreCalled, isTrue);
      // Wait for implicit reactive SOT unlock:
      controller.mockUpdateState(const EntitlementState.pro());
      await tester.pumpAndSettle();

      expect(find.byType(PaywallScreen), findsNothing);
    });

    testWidgets('restore failure shows non-fatal localized error', (
      tester,
    ) async {
      final controller = MockPremiumController(
        const EntitlementState.free(),
        mockOfferings: const TrimlyOfferings(
          yearly: TrimlyPackage(
            plan: TrimlyPlan.yearly,
            priceString: '\$19.99',
          ),
        ),
      );
      controller.restoreStatus = RestoreResultStatus.error;

      await tester.pumpWidget(TestPaywallWrapper(controller: controller));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Restore Purchases'));
      await tester.pumpAndSettle();

      expect(find.text('Failed to restore purchases.'), findsOneWidget);
    });
  });
}
