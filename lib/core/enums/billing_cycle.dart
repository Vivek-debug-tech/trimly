import 'package:hive/hive.dart';

part 'billing_cycle.g.dart';

@HiveType(typeId: 3)
enum BillingCycle {
  @HiveField(0)
  weekly,
  @HiveField(1)
  monthly,
  @HiveField(2)
  quarterly,
  @HiveField(3)
  yearly,
}
