import '../../core/enums/billing_cycle.dart';
import '../models/subscription.dart';

class MonthlySavingsCalculator {
  const MonthlySavingsCalculator();

  double? calculate(Subscription subscription) {
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
