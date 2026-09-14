import 'package:flutter_test/flutter_test.dart';

import 'package:trimly/core/enums/billing_cycle.dart';
import 'package:trimly/core/enums/decision_status.dart';
import 'package:trimly/core/enums/importance.dart';
import 'package:trimly/core/enums/usage_frequency.dart';
import 'package:trimly/domain/engines/monthly_savings_calculator.dart';
import 'package:trimly/domain/engines/optimizer_service.dart';
import 'package:trimly/domain/models/subscription.dart';

void main() {
  const calculator = MonthlySavingsCalculator();
  final optimizer = OptimizerService(savingsCalculator: calculator);
  final baseline = NaiveBaselineService(savingsCalculator: calculator);

  group('monthly-equivalent savings', () {
    test('normalizes weekly billing', () {
      expect(
        calculator.calculate(
          subscription(price: 25, billingCycle: BillingCycle.weekly),
        ),
        100,
      );
    });

    test('normalizes monthly billing', () {
      expect(calculator.calculate(subscription(price: 100)), 100);
    });

    test('normalizes quarterly billing', () {
      expect(
        calculator.calculate(
          subscription(price: 300, billingCycle: BillingCycle.quarterly),
        ),
        100,
      );
    });

    test('normalizes yearly billing', () {
      expect(
        calculator.calculate(
          subscription(price: 1200, billingCycle: BillingCycle.yearly),
        ),
        100,
      );
    });
  });

  group('trial savings', () {
    test('uses postTrialPrice and ignores current trial price', () {
      final trial = subscription(
        price: 0,
        postTrialPrice: 499,
        trialEndDate: DateTime.utc(2026, 10, 1),
      );

      expect(calculator.calculate(trial), 499);
    });

    test('excludes a trial without postTrialPrice', () {
      final result = optimizer.optimize(
        subscriptions: [
          subscription(
            id: 'trial',
            price: 0,
            postTrialPrice: null,
            trialEndDate: DateTime.utc(2026, 10, 1),
          ),
        ],
        target: 1,
      );

      expect(result.hasValidPlan, isFalse);
      expect(result.eligibleCandidateCount, 0);
    });
  });

  group('candidate filtering', () {
    test('excludes KEEP and NOT ENOUGH INFO', () {
      final result = optimizer.optimize(
        subscriptions: [
          subscription(id: 'keep', decisionStatus: DecisionStatus.keep),
          subscription(
            id: 'unknown',
            decisionStatus: DecisionStatus.notEnoughInfo,
          ),
        ],
        target: 1,
      );

      expect(result.hasValidPlan, isFalse);
      expect(result.eligibleCandidateCount, 0);
    });

    test('includes REVIEW and CUT', () {
      final result = optimizer.optimize(
        subscriptions: [
          subscription(id: 'review', price: 50),
          subscription(id: 'cut', price: 50, decisionStatus: DecisionStatus.cut),
        ],
        target: 100,
      );

      expect(result.hasValidPlan, isTrue);
      expect(result.eligibleCandidateCount, 2);
      expect(result.recommendedPlan!.cancellationCount, 2);
    });

    test('excludes eligible subscriptions with null impactScore', () {
      final result = optimizer.optimize(
        subscriptions: [
          subscription(id: 'null-impact', impactScore: null),
        ],
        target: 1,
      );

      expect(result.hasValidPlan, isFalse);
      expect(result.eligibleCandidateCount, 0);
    });
  });

  group('target constraints', () {
    test('accepts an exact target', () {
      final result = optimizer.optimize(
        subscriptions: [subscription(price: 100)],
        target: 100,
      );

      expect(result.recommendedPlan!.monthlySavings, 100);
      expect(result.recommendedPlan!.overshoot, 0);
    });

    test('accepts a plan above the target', () {
      final result = optimizer.optimize(
        subscriptions: [subscription(price: 125)],
        target: 100,
      );

      expect(result.recommendedPlan!.monthlySavings, 125);
      expect(result.recommendedPlan!.overshoot, 25);
    });

    test('rejects a below-target plan', () {
      final result = optimizer.optimize(
        subscriptions: [subscription(price: 99)],
        target: 100,
      );

      expect(result.hasValidPlan, isFalse);
    });

    test('reports an impossible target', () {
      final result = optimizer.optimize(
        subscriptions: [subscription(price: 99)],
        target: 100,
      );

      expect(result.recommendedPlan, isNull);
      expect(result.alternatives, isEmpty);
    });

    test('returns an empty valid plan for target zero', () {
      final result = optimizer.optimize(
        subscriptions: [subscription(price: 100)],
        target: 0,
      );

      expect(result.hasValidPlan, isTrue);
      expect(result.recommendedPlan!.selectedSubscriptions, isEmpty);
      expect(result.recommendedPlan!.totalImpactScore, 0);
    });

    test('rejects a negative target', () {
      final result = optimizer.optimize(subscriptions: const [], target: -1);

      expect(result.hasValidPlan, isFalse);
    });
  });

  group('optimization ranking', () {
    test('selects the valid plan with lowest total impact', () {
      final result = optimizer.optimize(
        subscriptions: [
          subscription(id: 'expensive', price: 100, impactScore: 0.9),
          subscription(id: 'low-a', price: 60, impactScore: 0.1),
          subscription(id: 'low-b', price: 40, impactScore: 0.1),
        ],
        target: 100,
      );

      expect(result.recommendedPlan!.signature, 'low-a|low-b');
      expect(result.recommendedPlan!.totalImpactScore, 0.2);
    });

    test('uses fewer cancellations for an equal-impact tie', () {
      final result = optimizer.optimize(
        subscriptions: [
          subscription(id: 'single', price: 100, impactScore: 0.2),
          subscription(id: 'part-a', price: 50, impactScore: 0.1),
          subscription(id: 'part-b', price: 50, impactScore: 0.1),
        ],
        target: 100,
      );

      expect(result.recommendedPlan!.signature, 'single');
    });

    test('uses lower overshoot after impact and count tie', () {
      final result = optimizer.optimize(
        subscriptions: [
          subscription(id: 'a', price: 60, impactScore: 0.15),
          subscription(id: 'b', price: 50, impactScore: 0.1),
          subscription(id: 'c', price: 55, impactScore: 0.15),
        ],
        target: 100,
      );

      expect(result.recommendedPlan!.signature, 'b|c');
      expect(result.recommendedPlan!.overshoot, 5);
    });

    test('uses stable ID signature as the final tie-break', () {
      final result = optimizer.optimize(
        subscriptions: [
          subscription(id: 'z', price: 50, impactScore: 0.25),
          subscription(id: 'a', price: 50, impactScore: 0.25),
          subscription(id: 'y', price: 50, impactScore: 0.25),
          subscription(id: 'b', price: 50, impactScore: 0.25),
        ],
        target: 100,
      );

      expect(result.recommendedPlan!.signature, 'a|b');
    });
  });

  group('naive baseline', () {
    test('selects the most expensive valid subscription first', () {
      final result = baseline.recommend(
        subscriptions: [
          subscription(id: 'cheap', price: 100),
          subscription(id: 'expensive', price: 200),
        ],
        target: 200,
      );

      expect(result.selectedSubscriptions.map((item) => item.id), ['expensive']);
    });

    test('can select KEEP subscriptions', () {
      final result = baseline.recommend(
        subscriptions: [
          subscription(
            id: 'keep',
            price: 200,
            decisionStatus: DecisionStatus.keep,
          ),
        ],
        target: 200,
      );

      expect(result.selectedSubscriptions.single.id, 'keep');
    });

    test('uses cost only, not impact, usage, or importance', () {
      final result = baseline.recommend(
        subscriptions: [
          subscription(
            id: 'expensive',
            price: 200,
            impactScore: 1.0,
            usageFrequency: UsageFrequency.daily,
            importance: Importance.high,
          ),
          subscription(
            id: 'cheap',
            price: 100,
            impactScore: 0.0,
            usageFrequency: UsageFrequency.never,
            importance: Importance.low,
          ),
        ],
        target: 200,
      );

      expect(result.selectedSubscriptions.single.id, 'expensive');
    });
  });

  group('alternatives and determinism', () {
    test('returns unique valid alternatives in deterministic order', () {
      final result = optimizer.optimize(
        subscriptions: [
          subscription(id: 'a', price: 60, impactScore: 0.2),
          subscription(id: 'b', price: 60, impactScore: 0.3),
          subscription(id: 'c', price: 40, impactScore: 0.3),
        ],
        target: 100,
        alternativeLimit: 5,
      );

      final plans = [result.recommendedPlan!, ...result.alternatives];
      expect(plans.every((plan) => plan.monthlySavings >= 100), isTrue);
      expect(plans.map((plan) => plan.signature).toSet(), hasLength(plans.length));
      expect(result.alternatives, isNotEmpty);
    });

    test('does not vary with input order', () {
      final items = [
        subscription(id: 'b', price: 50, impactScore: 0.2),
        subscription(id: 'a', price: 50, impactScore: 0.2),
      ];
      final first = optimizer.optimize(subscriptions: items, target: 50);
      final second = optimizer.optimize(
        subscriptions: items.reversed.toList(),
        target: 50,
      );

      expect(first.recommendedPlan!.signature, second.recommendedPlan!.signature);
    });
  });
}

Subscription subscription({
  String id = 'subscription',
  double price = 100,
  double? postTrialPrice,
  DateTime? trialEndDate,
  BillingCycle billingCycle = BillingCycle.monthly,
  DecisionStatus decisionStatus = DecisionStatus.review,
  double? impactScore = 0.5,
  UsageFrequency? usageFrequency = UsageFrequency.weekly,
  Importance? importance = Importance.medium,
}) {
  final now = DateTime.utc(2026, 9, 14);
  return Subscription(
    id: id,
    name: id,
    category: 'Test',
    price: price,
    currency: 'INR',
    billingCycle: billingCycle,
    nextRenewalDate: DateTime.utc(2026, 10, 14),
    trialEndDate: trialEndDate,
    postTrialPrice: postTrialPrice,
    usageFrequency: usageFrequency,
    importance: importance,
    impactScore: impactScore,
    decisionStatus: decisionStatus,
    createdAt: now,
    updatedAt: now,
  );
}
