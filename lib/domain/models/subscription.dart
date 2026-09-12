import 'package:hive/hive.dart';

import '../../core/enums/billing_cycle.dart';
import '../../core/enums/decision_status.dart';
import '../../core/enums/importance.dart';
import '../../core/enums/usage_frequency.dart';

part 'subscription.g.dart';

@HiveType(typeId: 10)
class Subscription {
  Subscription({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.currency,
    required this.billingCycle,
    required this.nextRenewalDate,
    this.trialEndDate,
    this.postTrialPrice,
    this.usageFrequency,
    this.importance,
    this.impactScore,
    required this.decisionStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final String currency;

  @HiveField(5)
  final BillingCycle billingCycle;

  @HiveField(6)
  final DateTime nextRenewalDate;

  @HiveField(7)
  final DateTime? trialEndDate;

  @HiveField(8)
  final double? postTrialPrice;

  @HiveField(9)
  final UsageFrequency? usageFrequency;

  @HiveField(10)
  final Importance? importance;

  @HiveField(11)
  final double? impactScore;

  @HiveField(12)
  final DecisionStatus decisionStatus;

  @HiveField(13)
  final DateTime createdAt;

  @HiveField(14)
  final DateTime updatedAt;
}
