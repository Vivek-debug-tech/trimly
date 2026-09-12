import 'package:hive/hive.dart';

import '../../core/enums/billing_cycle.dart';
import '../../core/enums/decision_status.dart';
import '../../core/enums/importance.dart';
import '../../core/enums/savings_action.dart';
import '../../core/enums/usage_frequency.dart';
import '../../domain/models/subscription.dart';

class HiveAdapters {
  const HiveAdapters._();

  static void register() {
    if (!Hive.isAdapterRegistered(UsageFrequencyAdapter().typeId)) {
      Hive.registerAdapter(UsageFrequencyAdapter());
    }
    if (!Hive.isAdapterRegistered(ImportanceAdapter().typeId)) {
      Hive.registerAdapter(ImportanceAdapter());
    }
    if (!Hive.isAdapterRegistered(DecisionStatusAdapter().typeId)) {
      Hive.registerAdapter(DecisionStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(BillingCycleAdapter().typeId)) {
      Hive.registerAdapter(BillingCycleAdapter());
    }
    if (!Hive.isAdapterRegistered(SavingsActionAdapter().typeId)) {
      Hive.registerAdapter(SavingsActionAdapter());
    }
    if (!Hive.isAdapterRegistered(SubscriptionAdapter().typeId)) {
      Hive.registerAdapter(SubscriptionAdapter());
    }
  }
}
