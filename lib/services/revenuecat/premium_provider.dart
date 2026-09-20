import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'entitlement_state.dart';
import 'revenuecat_service.dart';
import 'trimly_offerings.dart';

final premiumProvider = NotifierProvider<PremiumController, EntitlementState>(
  PremiumController.new,
);

class PremiumController extends Notifier<EntitlementState> {
  @override
  EntitlementState build() {
    final updates = RevenueCatService.instance.entitlementUpdates.listen(
      (nextState) => state = nextState,
    );
    ref.onDispose(updates.cancel);
    return RevenueCatService.instance.currentState;
  }

  Future<TrimlyOfferings?> getOfferings() =>
      RevenueCatService.instance.fetchOfferings();

  Future<PurchaseResultStatus> purchase(TrimlyPlan plan) =>
      RevenueCatService.instance.purchase(plan);

  Future<RestoreResultStatus> restore() =>
      RevenueCatService.instance.restorePurchases();
}
