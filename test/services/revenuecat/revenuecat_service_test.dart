// ignore_for_file: deprecated_member_use
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:trimly/services/revenuecat/entitlement_state.dart';
import 'package:trimly/services/revenuecat/purchases_interface.dart';
import 'package:trimly/services/revenuecat/revenuecat_service.dart';
import 'package:trimly/services/revenuecat/trimly_offerings.dart';

class MockCustomerInfo extends Fake implements CustomerInfo {
  MockCustomerInfo(this.isActive);
  final bool isActive;
  @override
  EntitlementInfos get entitlements => MockEntitlementInfos(isActive);
}

class MockEntitlementInfos extends Fake implements EntitlementInfos {
  MockEntitlementInfos(this.isActive);
  final bool isActive;
  @override
  Map<String, EntitlementInfo> get all => {
        if (isActive) 'trimly_pro': MockEntitlementInfo(true),
      };
}

class MockEntitlementInfo extends Fake implements EntitlementInfo {
  MockEntitlementInfo(this.isActive);
  @override
  final bool isActive;
}

class MockOfferings extends Fake implements Offerings {
  MockOfferings({this.current});
  @override
  final Offering? current;
}

class MockOffering extends Fake implements Offering {
  MockOffering({
    this.monthly,
    this.annual,
    this.lifetime,
    required this.availablePackages,
  });
  @override
  final Package? monthly;
  @override
  final Package? annual;
  @override
  final Package? lifetime;
  @override
  final List<Package> availablePackages;
}

class MockStoreProduct extends Fake implements StoreProduct {
  MockStoreProduct(this.priceString);
  @override
  final String priceString;
}

class MockPackage extends Fake implements Package {
  MockPackage(this.identifier, this.priceStr);
  final String priceStr;
  @override
  final String identifier;
  @override
  StoreProduct get storeProduct => MockStoreProduct(priceStr);
}

class MockPurchaseResult extends Fake implements PurchaseResult {
  MockPurchaseResult(this.customerInfo);
  @override
  final CustomerInfo customerInfo;
}

class FakePurchases implements PurchasesInterface {
  final _listeners = <void Function(CustomerInfo)>[];
  CustomerInfo? mockCustomerInfo;
  Offerings? mockOfferings;
  Exception? purchaseException;
  Exception? restoreException;
  Package? capturedPurchasePackage;

  @override
  Future<void> configure(PurchasesConfiguration configuration) async {}

  @override
  void addCustomerInfoUpdateListener(void Function(CustomerInfo) listener) {
    _listeners.add(listener);
  }

  @override
  void removeCustomerInfoUpdateListener(void Function(CustomerInfo) listener) {
    _listeners.remove(listener);
  }

  @override
  Future<CustomerInfo> getCustomerInfo() async {
    return mockCustomerInfo!;
  }

  @override
  Future<Offerings> getOfferings() async {
    return mockOfferings!;
  }

  @override
  Future<PurchaseResult> purchasePackage(Package package) async {
    capturedPurchasePackage = package;
    if (purchaseException != null) throw purchaseException!;
    return MockPurchaseResult(mockCustomerInfo!);
  }

  @override
  Future<CustomerInfo> restorePurchases() async {
    if (restoreException != null) throw restoreException!;
    return mockCustomerInfo!;
  }
}

void main() {
  test('uses the configured Trimly Pro entitlement identifier', () {
    expect(RevenueCatConstants.proEntitlementId, 'trimly_pro');
  });

  group('EntitlementMapper', () {
    test('no pro entitlement produces free state', () {
      final state = EntitlementMapper.fromProEntitlementActive(false);

      expect(state.status, EntitlementStatus.free);
      expect(state.isPro, isFalse);
    });

    test('active pro entitlement produces pro state', () {
      final state = EntitlementMapper.fromProEntitlementActive(true);

      expect(state.status, EntitlementStatus.pro);
      expect(state.isPro, isTrue);
    });

    test('inactive pro entitlement produces free state', () {
      final state = EntitlementMapper.fromProEntitlementActive(false);

      expect(state.status, EntitlementStatus.free);
      expect(state.isPro, isFalse);
    });

    test('deterministic repeated entitlement mapping', () {
      final statuses = [
        EntitlementMapper.fromProEntitlementActive(true).status,
        EntitlementMapper.fromProEntitlementActive(false).status,
        EntitlementMapper.fromProEntitlementActive(true).status,
      ];

      expect(statuses, [
        EntitlementStatus.pro,
        EntitlementStatus.free,
        EntitlementStatus.pro,
      ]);
    });

    test('other active entitlements do not grant Pro', () {
      final customerInfo = MockCustomerInfo(false);
      final state = EntitlementMapper.fromCustomerInfo(customerInfo);

      expect(state.status, EntitlementStatus.free);
      expect(state.isPro, isFalse);
    });

    test('initialization error does not grant Pro and yields safe error state', () async {
      final service = RevenueCatService(apiKey: '');
      final state = await service.initialize();
      expect(state.status, EntitlementStatus.error);
      expect(state.isPro, isFalse);
      expect(state.errorMessage, isNotNull);
      service.dispose();
    });
  });

  group('EntitlementState', () {
    test('starts in loading state', () {
      const state = EntitlementState.loading();

      expect(state.status, EntitlementStatus.loading);
      expect(state.isPro, isFalse);
      expect(state.errorMessage, isNull);
    });
  });

  group('RevenueCatService Operations', () {
    late FakePurchases fakePurchases;

    setUp(() {
      fakePurchases = FakePurchases();
    });

    test('fetchOfferings maps current offering to TrimlyOfferings safely', () async {
      final monthlyPkg = MockPackage('monthly_pkg', '1.99');
      final yearlyPkg = MockPackage('yearly_pkg', '19.99');
      final lifetimePkg = MockPackage('lifetime_pkg', '49.99');

      fakePurchases.mockOfferings = MockOfferings(
        current: MockOffering(
          monthly: monthlyPkg,
          annual: yearlyPkg,
          lifetime: lifetimePkg,
          availablePackages: [monthlyPkg, yearlyPkg, lifetimePkg],
        ),
      );

      final service = RevenueCatService(apiKey: 'test', purchases: fakePurchases);
      fakePurchases.mockCustomerInfo = MockCustomerInfo(false);
      await service.initialize();

      final offerings = await service.fetchOfferings();
      expect(offerings, isNotNull);
      expect(offerings!.monthly?.plan, TrimlyPlan.monthly);
      expect(offerings.monthly?.priceString, '1.99');

      expect(offerings.yearly?.plan, TrimlyPlan.yearly);
      expect(offerings.yearly?.priceString, '19.99');

      expect(offerings.lifetime?.plan, TrimlyPlan.lifetime);
      expect(offerings.lifetime?.priceString, '49.99');

      service.dispose();
    });

    test('missing packages map to null Trimly plans securely', () async {
      fakePurchases.mockOfferings = MockOfferings(
        current: MockOffering(
          monthly: null,
          annual: null,
          lifetime: null,
          availablePackages: [],
        ),
      );

      final service = RevenueCatService(apiKey: 'test', purchases: fakePurchases);
      fakePurchases.mockCustomerInfo = MockCustomerInfo(false);
      await service.initialize();

      final offerings = await service.fetchOfferings();
      expect(offerings!.monthly, isNull);
      expect(offerings. yearly, isNull);
      expect(offerings.lifetime, isNull);

      service.dispose();
    });

    test('purchase evaluates correctly to success and maps to SOT immediately', () async {
      final monthlyPkg = MockPackage('monthly_pkg', '1.99');
      fakePurchases.mockOfferings = MockOfferings(
        current: MockOffering(
          monthly: monthlyPkg,
          annual: null,
          lifetime: null,
          availablePackages: [monthlyPkg],
        ),
      );

      fakePurchases.mockCustomerInfo = MockCustomerInfo(false);
      final service = RevenueCatService(apiKey: 'test', purchases: fakePurchases);
      await service.initialize();

      // Prerequisite caching operation
      await service.fetchOfferings();

      fakePurchases.mockCustomerInfo = MockCustomerInfo(true); // Grant Pro!
      final status = await service.purchase(TrimlyPlan.monthly);

      expect(status, PurchaseResultStatus.success);
      expect(service.currentState.isPro, isTrue); // Directly mutated the internal state properly

      service.dispose();
    });

    test('purchase verifies TrimlyPlan maps to target RevenueCat wrapper properly', () async {
      final monthlyPkg = MockPackage('monthly_pkg', '1.99');
      final yearlyPkg = MockPackage('yearly_pkg', '19.99');
      final lifetimePkg = MockPackage('lifetime_pkg', '49.99');

      fakePurchases.mockOfferings = MockOfferings(
        current: MockOffering(
          monthly: monthlyPkg,
          annual: yearlyPkg,
          lifetime: lifetimePkg,
          availablePackages: [monthlyPkg, yearlyPkg, lifetimePkg],
        ),
      );

      final service = RevenueCatService(apiKey: 'test', purchases: fakePurchases);
      fakePurchases.mockCustomerInfo = MockCustomerInfo(true);
      await service.initialize();
      await service.fetchOfferings();

      await service.purchase(TrimlyPlan.monthly);
      expect(fakePurchases.capturedPurchasePackage, monthlyPkg);

      await service.purchase(TrimlyPlan.yearly);
      expect(fakePurchases.capturedPurchasePackage, yearlyPkg);

      await service.purchase(TrimlyPlan.lifetime);
      expect(fakePurchases.capturedPurchasePackage, lifetimePkg);

      service.dispose();
    });

    test('purchase safely relays cancellation status identically without crashing', () async {
       final monthlyPkg = MockPackage('monthly_pkg', '1.99');
      fakePurchases.mockOfferings = MockOfferings(
        current: MockOffering(
          monthly: monthlyPkg,
          annual: null,
          lifetime: null,
          availablePackages: [monthlyPkg],
        ),
      );

      fakePurchases.mockCustomerInfo = MockCustomerInfo(false);
      fakePurchases.purchaseException = PlatformException(
        code: '1', // PurchasesErrorCode.purchaseCancelledError is 1
        message: 'Cancelled',
      );

      final service = RevenueCatService(apiKey: 'test', purchases: fakePurchases);
      await service.initialize();
      await service.fetchOfferings();

      final status = await service.purchase(TrimlyPlan.monthly);

      expect(status, PurchaseResultStatus.cancelled);
      expect(service.currentState.isPro, isFalse);

      service.dispose();
    });

    test('purchase captures explicit hard errors safely', () async {
       final monthlyPkg = MockPackage('monthly_pkg', '1.99');
      fakePurchases.mockOfferings = MockOfferings(
        current: MockOffering(
          monthly: monthlyPkg,
          annual: null,
          lifetime: null,
          availablePackages: [monthlyPkg],
        ),
      );

      fakePurchases.mockCustomerInfo = MockCustomerInfo(false);
      fakePurchases.purchaseException = Exception('Unexpected Hard Crash');

      final service = RevenueCatService(apiKey: 'test', purchases: fakePurchases);
      await service.initialize();
      await service.fetchOfferings();

      final status = await service.purchase(TrimlyPlan.monthly);

      expect(status, PurchaseResultStatus.error);

      service.dispose();
    });

    test('restore processes CustomerInfo immediately yielding success', () async {
      fakePurchases.mockCustomerInfo = MockCustomerInfo(false);
      final service = RevenueCatService(apiKey: 'test', purchases: fakePurchases);
      await service.initialize();

      expect(service.currentState.isPro, isFalse);

      fakePurchases.mockCustomerInfo = MockCustomerInfo(true);
      final status = await service.restorePurchases();

      expect(status, RestoreResultStatus.success);
      expect(service.currentState.isPro, isTrue);

      service.dispose();
    });

    test('restore smoothly catches explicit network errors', () async {
      fakePurchases.mockCustomerInfo = MockCustomerInfo(false);
      final service = RevenueCatService(apiKey: 'test', purchases: fakePurchases);
      await service.initialize();

      fakePurchases.restoreException = Exception('No Connection');
      final status = await service.restorePurchases();

      expect(status, RestoreResultStatus.error);
      expect(service.currentState.isPro, isFalse);

      service.dispose();
    });
  });
}
