// ignore_for_file: deprecated_member_use
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'entitlement_state.dart';
import 'purchases_interface.dart';
import 'revenuecat_config.dart';
import 'trimly_offerings.dart';

class RevenueCatConstants {
  const RevenueCatConstants._();

  static const proEntitlementId = 'trimly_pro';
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
  RevenueCatService({String? apiKey, PurchasesInterface? purchases})
      : _apiKey = apiKey,
        _purchases = purchases ?? const DefaultPurchases();

  static final instance = RevenueCatService();

  final String? _apiKey;
  final PurchasesInterface _purchases;
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
      await _purchases.configure(PurchasesConfiguration(apiKey));
      _purchases.addCustomerInfoUpdateListener(_handleCustomerInfoUpdate);
      _listenerRegistered = true;

      final customerInfo = await _purchases.getCustomerInfo();
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
      _purchases.removeCustomerInfoUpdateListener(_handleCustomerInfoUpdate);
      _listenerRegistered = false;
    }
    _entitlementController.close();
  }

  Package? _monthlyCache;
  Package? _yearlyCache;
  Package? _lifetimeCache;

  void _clearCache() {
    _monthlyCache = null;
    _yearlyCache = null;
    _lifetimeCache = null;
  }

  Future<TrimlyOfferings?> fetchOfferings() async {
    try {
      final offerings = await _purchases.getOfferings();
      final current = offerings.current;
      if (current == null) {
        _clearCache();
        return null;
      }

      Package? findPackage(String id) {
        try {
          return current.availablePackages.firstWhere(
            (p) => p.identifier == id,
          );
        } catch (_) {
          return null;
        }
      }

      _monthlyCache = findPackage('monthly') ?? current.monthly;
      _yearlyCache = findPackage('yearly') ?? current.annual;
      _lifetimeCache = findPackage('lifetime') ?? current.lifetime;

      TrimlyPackage? mapPackage(Package? pkg, TrimlyPlan plan) {
        if (pkg == null) return null;
        return TrimlyPackage(
          plan: plan,
          priceString: pkg.storeProduct.priceString,
        );
      }

      return TrimlyOfferings(
        monthly: mapPackage(_monthlyCache, TrimlyPlan.monthly),
        yearly: mapPackage(_yearlyCache, TrimlyPlan.yearly),
        lifetime: mapPackage(_lifetimeCache, TrimlyPlan.lifetime),
      );
    } catch (_) {
      _clearCache();
      return null;
    }
  }

  Future<PurchaseResultStatus> purchase(TrimlyPlan plan) async {
    final Package? target = switch (plan) {
      TrimlyPlan.monthly => _monthlyCache,
      TrimlyPlan.yearly => _yearlyCache,
      TrimlyPlan.lifetime => _lifetimeCache,
    };

    if (target == null) return PurchaseResultStatus.error;

    try {
      final purchaseResult = await _purchases.purchasePackage(target);
      _handleCustomerInfoUpdate(purchaseResult.customerInfo);
      return PurchaseResultStatus.success;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        return PurchaseResultStatus.cancelled;
      }
      return PurchaseResultStatus.error;
    } catch (_) {
      return PurchaseResultStatus.error;
    }
  }

  Future<RestoreResultStatus> restorePurchases() async {
    try {
      final customerInfo = await _purchases.restorePurchases();
      _handleCustomerInfoUpdate(customerInfo);
      return RestoreResultStatus.success;
    } catch (_) {
      return RestoreResultStatus.error;
    }
  }
}
