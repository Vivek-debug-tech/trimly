import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'entitlement_state.dart';
import 'revenuecat_service.dart';

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
}
