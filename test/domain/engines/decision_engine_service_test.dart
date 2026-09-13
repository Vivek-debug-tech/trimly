import 'package:flutter_test/flutter_test.dart';

import 'package:trimly/core/enums/billing_cycle.dart';
import 'package:trimly/core/enums/decision_status.dart';
import 'package:trimly/core/enums/importance.dart';
import 'package:trimly/core/enums/usage_frequency.dart';
import 'package:trimly/domain/engines/decision_engine_service.dart';
import 'package:trimly/domain/models/subscription.dart';

void main() {
  const service = DecisionEngineService();

  group('usage normalization', () {
    test('maps every usage value to its fixed absolute value', () {
      expect(service.normalizeUsage(UsageFrequency.daily), 1.0);
      expect(service.normalizeUsage(UsageFrequency.severalPerWeek), 0.8);
      expect(service.normalizeUsage(UsageFrequency.weekly), 0.6);
      expect(service.normalizeUsage(UsageFrequency.monthly), 0.4);
      expect(service.normalizeUsage(UsageFrequency.rarely), 0.2);
      expect(service.normalizeUsage(UsageFrequency.never), 0.0);
    });
  });

  group('importance normalization', () {
    test('maps every importance value to its fixed absolute value', () {
      expect(service.normalizeImportance(Importance.high), 1.0);
      expect(service.normalizeImportance(Importance.medium), 0.5);
      expect(service.normalizeImportance(Importance.low), 0.0);
    });
  });

  group('impact score formula', () {
    test('daily and high produces 1.0', () {
      final result = service.evaluate(
        usageFrequency: UsageFrequency.daily,
        importance: Importance.high,
      );

      expect(result.impactScore, 1.0);
      expect(result.decisionStatus, DecisionStatus.keep);
    });

    test('never and low produces 0.0', () {
      final result = service.evaluate(
        usageFrequency: UsageFrequency.never,
        importance: Importance.low,
      );

      expect(result.impactScore, 0.0);
      expect(result.decisionStatus, DecisionStatus.cut);
    });

    test('weekly and medium produces 0.54', () {
      final result = service.evaluate(
        usageFrequency: UsageFrequency.weekly,
        importance: Importance.medium,
      );

      expect(result.impactScore, closeTo(0.54, 0.0000001));
      expect(result.decisionStatus, DecisionStatus.review);
    });
  });

  group('classification thresholds', () {
    test('classifies values around 0.40', () {
      expect(service.classify(0.399999), DecisionStatus.cut);
      expect(service.classify(0.40), DecisionStatus.review);
      expect(service.classify(0.400001), DecisionStatus.review);
    });

    test('classifies values around 0.70', () {
      expect(service.classify(0.699999), DecisionStatus.review);
      expect(service.classify(0.70), DecisionStatus.keep);
      expect(service.classify(0.700001), DecisionStatus.keep);
    });
  });

  group('missing data', () {
    test('null usage and valid importance produce not enough info', () {
      final result = service.evaluate(
        usageFrequency: null,
        importance: Importance.high,
      );

      expect(result.impactScore, isNull);
      expect(result.decisionStatus, DecisionStatus.notEnoughInfo);
    });

    test('valid usage and null importance produce not enough info', () {
      final result = service.evaluate(
        usageFrequency: UsageFrequency.daily,
        importance: null,
      );

      expect(result.impactScore, isNull);
      expect(result.decisionStatus, DecisionStatus.notEnoughInfo);
    });

    test('null usage and null importance produce not enough info', () {
      final result = service.evaluate(
        usageFrequency: null,
        importance: null,
      );

      expect(result.impactScore, isNull);
      expect(result.decisionStatus, DecisionStatus.notEnoughInfo);
    });
  });

  group('cost independence', () {
    test('price and post-trial price do not affect the score', () {
      final lowCost = makeSubscription(price: 1.0, postTrialPrice: 2.0);
      final highCost = makeSubscription(price: 999.0, postTrialPrice: 1999.0);

      final lowCostResult = service.evaluateSubscription(lowCost);
      final highCostResult = service.evaluateSubscription(highCost);

      expect(highCostResult.impactScore, lowCostResult.impactScore);
      expect(highCostResult.decisionStatus, lowCostResult.decisionStatus);
    });
  });
}

Subscription makeSubscription({
  required double price,
  required double postTrialPrice,
}) {
  final now = DateTime.utc(2026, 9, 12);
  return Subscription(
    id: 'subscription',
    name: 'Example',
    category: 'Entertainment',
    price: price,
    currency: 'USD',
    billingCycle: BillingCycle.monthly,
    nextRenewalDate: DateTime.utc(2026, 10, 12),
    postTrialPrice: postTrialPrice,
    usageFrequency: UsageFrequency.weekly,
    importance: Importance.medium,
    decisionStatus: DecisionStatus.notEnoughInfo,
    createdAt: now,
    updatedAt: now,
  );
}
