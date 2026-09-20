// ignore_for_file: deprecated_member_use
import 'package:purchases_flutter/purchases_flutter.dart';

abstract class PurchasesInterface {
  Future<void> configure(PurchasesConfiguration configuration);
  void addCustomerInfoUpdateListener(void Function(CustomerInfo) listener);
  void removeCustomerInfoUpdateListener(void Function(CustomerInfo) listener);
  Future<CustomerInfo> getCustomerInfo();
  
  Future<Offerings> getOfferings();
  Future<PurchaseResult> purchasePackage(Package package);
  Future<CustomerInfo> restorePurchases();
}

class DefaultPurchases implements PurchasesInterface {
  const DefaultPurchases();
  
  @override
  Future<void> configure(PurchasesConfiguration configuration) => Purchases.configure(configuration);
  
  @override
  void addCustomerInfoUpdateListener(void Function(CustomerInfo) listener) => Purchases.addCustomerInfoUpdateListener(listener);
  
  @override
  void removeCustomerInfoUpdateListener(void Function(CustomerInfo) listener) => Purchases.removeCustomerInfoUpdateListener(listener);
  
  @override
  Future<CustomerInfo> getCustomerInfo() => Purchases.getCustomerInfo();
  
  @override
  Future<Offerings> getOfferings() => Purchases.getOfferings();
  
  @override
  Future<PurchaseResult> purchasePackage(Package package) => Purchases.purchasePackage(package);
  
  @override
  Future<CustomerInfo> restorePurchases() => Purchases.restorePurchases();
}
