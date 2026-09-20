enum TrimlyPlan { monthly, yearly, lifetime }

enum PurchaseResultStatus { success, cancelled, error }

enum RestoreResultStatus { success, error }

class TrimlyPackage {
  const TrimlyPackage({
    required this.plan,
    required this.priceString,
  });

  final TrimlyPlan plan;
  final String priceString;
}

class TrimlyOfferings {
  const TrimlyOfferings({
    this.monthly,
    this.yearly,
    this.lifetime,
  });

  final TrimlyPackage? monthly;
  final TrimlyPackage? yearly;
  final TrimlyPackage? lifetime;
}
