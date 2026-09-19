import 'package:trimly/core/enums/billing_cycle.dart';
import 'package:trimly/core/enums/currency.dart';
import 'package:trimly/core/enums/decision_status.dart';
import 'package:trimly/core/enums/importance.dart';
import 'package:trimly/core/enums/usage_frequency.dart';
import 'package:trimly/domain/models/subscription.dart';

const demoSavingsTarget = 2500.0;

List<Subscription> demoSubscriptions({Currency currency = Currency.inr}) {
  final now = DateTime.now();
  return [
    Subscription(
      id: 'gym',
      name: 'Gym Membership',
      category: 'Health & Fitness',
      price: 2999,
      currency: currency.name,
      billingCycle: BillingCycle.yearly,
      nextRenewalDate: now.add(const Duration(days: 27)),
      trialEndDate: null,
      postTrialPrice: null,
      usageFrequency: UsageFrequency.daily,
      importance: Importance.high,
      impactScore: 1.0,
      decisionStatus: DecisionStatus.keep,
      createdAt: now.subtract(const Duration(days: 28)),
      updatedAt: now,
    ),
    Subscription(
      id: 'netflix',
      name: 'Netflix',
      category: 'Entertainment',
      price: 649,
      currency: currency.name,
      billingCycle: BillingCycle.monthly,
      nextRenewalDate: now.add(const Duration(days: 9)),
      trialEndDate: null,
      postTrialPrice: null,
      usageFrequency: UsageFrequency.weekly,
      importance: Importance.medium,
      impactScore: 0.65,
      decisionStatus: DecisionStatus.review,
      createdAt: now.subtract(const Duration(days: 52)),
      updatedAt: now,
    ),
    Subscription(
      id: 'canva',
      name: 'Canva Pro',
      category: 'Design',
      price: 499,
      currency: currency.name,
      billingCycle: BillingCycle.monthly,
      nextRenewalDate: now.add(const Duration(days: 13)),
      trialEndDate: null,
      postTrialPrice: null,
      usageFrequency: UsageFrequency.monthly,
      importance: Importance.low,
      impactScore: 0.35,
      decisionStatus: DecisionStatus.cut,
      createdAt: now.subtract(const Duration(days: 44)),
      updatedAt: now,
    ),
    Subscription(
      id: 'spotify',
      name: 'Spotify',
      category: 'Music',
      price: 299,
      currency: currency.name,
      billingCycle: BillingCycle.monthly,
      nextRenewalDate: now.add(const Duration(days: 41)),
      trialEndDate: null,
      postTrialPrice: null,
      usageFrequency: UsageFrequency.daily,
      importance: Importance.medium,
      impactScore: 0.7,
      decisionStatus: DecisionStatus.review,
      createdAt: now.subtract(const Duration(days: 60)),
      updatedAt: now,
    ),
    Subscription(
      id: 'notion',
      name: 'Notion',
      category: 'Productivity',
      price: 799,
      currency: currency.name,
      billingCycle: BillingCycle.monthly,
      nextRenewalDate: now.add(const Duration(days: 58)),
      trialEndDate: now.add(const Duration(days: 12)),
      postTrialPrice: 999,
      usageFrequency: UsageFrequency.daily,
      importance: Importance.high,
      impactScore: 0.9,
      decisionStatus: DecisionStatus.keep,
      createdAt: now.subtract(const Duration(days: 70)),
      updatedAt: now,
    ),
  ];
}
