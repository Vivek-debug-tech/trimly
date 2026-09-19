import 'dart:async';

import 'package:purchases_flutter/purchases_flutter.dart';

import 'entitlement_state.dart';
import 'revenuecat_config.dart';

class RevenueCatConstants {
  const RevenueCatConstants._();

  static const proEntitlementId = 'pro';
}

class EntitlementMapper {
  const EntitlementMapper._();

  static EntitlementState fromProEntitlementActive(bool isActive) {
    return isActive
        ? const EntitlementState.pro()
        : const EntitlementState.free();
  }

  static EntitlementState fromCustomerInfo(CustomerInfo customerInfo) {
    final proEntitlement =
        customerInfo.entitlements.all[RevenueCatConstants.proEntitlementId];
    return fromProEntitlementActive(proEntitlement?.isActive == true);
  }
}

class RevenueCatService {
  RevenueCatService({String? apiKey}) : _apiKey = apiKey;

  static final instance = RevenueCatService();

  final String? _apiKey;
  final _entitlementController = StreamController<EntitlementState>.broadcast();
  Future<EntitlementState>? _initialization;
  EntitlementState _currentState = const EntitlementState.loading();
  bool _listenerRegistered = false;

  EntitlementState get currentState => _currentState;

  Stream<EntitlementState> get entitlementUpdates =>
      _entitlementController.stream;

  Future<EntitlementState> initialize() {
    return _initialization ??= _initialize();
  }

  Future<EntitlementState> _initialize() async {
    _publish(const EntitlementState.loading());

    final apiKey = _apiKey ?? RevenueCatConfig.publicApiKey;
    if (apiKey.isEmpty) {
      return _publishError(
        'RevenueCat is not configured. Provide a public SDK key at build time.',
      );
    }

    try {
      await Purchases.configure(PurchasesConfiguration(apiKey));
      Purchases.addCustomerInfoUpdateListener(_handleCustomerInfoUpdate);
      _listenerRegistered = true;

      final customerInfo = await Purchases.getCustomerInfo();
      final state = EntitlementMapper.fromCustomerInfo(customerInfo);
      _publish(state);
      return state;
    } catch (_) {
      return _publishError('RevenueCat could not be initialized.');
    }
  }

  void _handleCustomerInfoUpdate(CustomerInfo customerInfo) {
    _publish(EntitlementMapper.fromCustomerInfo(customerInfo));
  }

  EntitlementState _publish(EntitlementState state) {
    _currentState = state;
    if (!_entitlementController.isClosed) {
      _entitlementController.add(state);
    }
    return state;
  }

  EntitlementState _publishError(String message) {
    return _publish(EntitlementState.error(message));
  }

  void dispose() {
    if (_listenerRegistered) {
      Purchases.removeCustomerInfoUpdateListener(_handleCustomerInfoUpdate);
      _listenerRegistered = false;
    }
    _entitlementController.close();
  }
}
