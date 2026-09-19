class RevenueCatConfig {
  const RevenueCatConfig._();

  static const publicApiKey = String.fromEnvironment(
    'REVENUECAT_PUBLIC_API_KEY',
  );

  static bool get isConfigured => publicApiKey.isNotEmpty;
}
