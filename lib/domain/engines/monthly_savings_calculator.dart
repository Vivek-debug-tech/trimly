import '../../core/enums/billing_cycle.dart';
import '../models/subscription.dart';

class MonthlySavingsCalculator {
  const MonthlySavingsCalculator();

  static const supportedCurrency = 'INR';

  double? calculate(Subscription subscription) {
    if (subscription.currency != supportedCurrency) {
      return null;
    }

    final savingsBasis = subscription.trialEndDate != null
        ? subscription.postTrialPrice
        : subscription.price;

    if (savingsBasis == null || savingsBasis < 0) {
      return null;
    }

    return switch (subscription.billingCycle) {
      BillingCycle.weekly => savingsBasis / 0.25,
      BillingCycle.monthly => savingsBasis,
      BillingCycle.quarterly => savingsBasis / 3,
      BillingCycle.yearly => savingsBasis / 12,
    };
  }
}
