import '../models/optimizer_models.dart';
import '../models/subscription.dart';
import 'monthly_savings_calculator.dart';

class OptimizerService {
  OptimizerService({MonthlySavingsCalculator? savingsCalculator})
      : _savingsCalculator =
            savingsCalculator ?? const MonthlySavingsCalculator();

  final MonthlySavingsCalculator _savingsCalculator;

  OptimizerResult optimize({
    required List<Subscription> subscriptions,
    required double target,
    int alternativeLimit = 3,
  }) {
    if (target < 0) {
      return OptimizerResult(
        target: target,
        hasValidPlan: false,
        recommendedPlan: null,
        alternatives: const [],
        explanation: 'The savings target cannot be negative.',
        eligibleCandidateCount: 0,
      );
    }

    final candidates = subscriptions
        .where(isOptimizerCandidate)
        .where((subscription) => subscription.impactScore != null)
        .map((subscription) {
          final monthlySavings = _savingsCalculator.calculate(subscription);
          return monthlySavings == null
              ? null
              : _Candidate(subscription, monthlySavings);
        })
        .whereType<_Candidate>()
        .toList()
      ..sort((first, second) => first.subscription.id.compareTo(
            second.subscription.id,
          ));

    final plans = <OptimizerPlan>[];
    final subsetCount = 1 << candidates.length;
    for (var mask = 0; mask < subsetCount; mask++) {
      final selected = <_Candidate>[];
      for (var index = 0; index < candidates.length; index++) {
        if ((mask & (1 << index)) != 0) {
          selected.add(candidates[index]);
        }
      }

      final monthlySavings = selected.fold<double>(
        0,
        (total, candidate) => total + candidate.monthlySavings,
      );
      if (monthlySavings < target) {
        continue;
      }

      final totalImpactScore = selected.fold<double>(
        0,
        (total, candidate) => total + candidate.subscription.impactScore!,
      );
      final selectedSubscriptions = selected
          .map((candidate) => candidate.subscription)
          .toList(growable: false);
      plans.add(
        OptimizerPlan(
          selectedSubscriptions: selectedSubscriptions,
          target: target,
          monthlySavings: monthlySavings,
          totalImpactScore: totalImpactScore,
          overshoot: monthlySavings - target,
          explanation: OptimizerExplanation(
            summary:
                'Reaches the savings target while minimizing cancellation impact.',
            selectedSubscriptionNames: selectedSubscriptions
                .map((subscription) => subscription.name)
                .toList(growable: false),
          ),
        ),
      );
    }

    plans.sort(_comparePlans);
    final recommendedPlan = plans.isEmpty ? null : plans.first;
    final alternatives = recommendedPlan == null || alternativeLimit <= 0
        ? <OptimizerPlan>[]
        : plans.skip(1).take(alternativeLimit).toList(growable: false);

    return OptimizerResult(
      target: target,
      hasValidPlan: recommendedPlan != null,
      recommendedPlan: recommendedPlan,
      alternatives: alternatives,
      explanation: recommendedPlan == null
          ? 'The savings target cannot be reached with eligible subscriptions.'
          : 'Trimly selected the valid plan with the lowest total impact.',
      eligibleCandidateCount: candidates.length,
    );
  }

  int _comparePlans(OptimizerPlan first, OptimizerPlan second) {
    final impactComparison =
        first.totalImpactScore.compareTo(second.totalImpactScore);
    if (impactComparison != 0) {
      return impactComparison;
    }

    final cancellationComparison =
        first.cancellationCount.compareTo(second.cancellationCount);
    if (cancellationComparison != 0) {
      return cancellationComparison;
    }

    final overshootComparison = first.overshoot.compareTo(second.overshoot);
    if (overshootComparison != 0) {
      return overshootComparison;
    }

    return first.signature.compareTo(second.signature);
  }
}

class _Candidate {
  const _Candidate(this.subscription, this.monthlySavings);

  final Subscription subscription;
  final double monthlySavings;
}

class NaiveBaselineService {
  NaiveBaselineService({MonthlySavingsCalculator? savingsCalculator})
      : _savingsCalculator =
            savingsCalculator ?? const MonthlySavingsCalculator();

  final MonthlySavingsCalculator _savingsCalculator;

  NaiveBaselineResult recommend({
    required List<Subscription> subscriptions,
    required double target,
  }) {
    if (target < 0) {
      return NaiveBaselineResult(
        target: target,
        hasValidPlan: false,
        selectedSubscriptions: const [],
        monthlySavings: 0,
        explanation: 'The savings target cannot be negative.',
      );
    }

    final candidates = subscriptions
        .map((subscription) {
          final monthlySavings = _savingsCalculator.calculate(subscription);
          return monthlySavings == null
              ? null
              : _BaselineCandidate(subscription, monthlySavings);
        })
        .whereType<_BaselineCandidate>()
        .toList()
      ..sort((first, second) {
        final savingsComparison =
            second.monthlySavings.compareTo(first.monthlySavings);
        return savingsComparison == 0
            ? first.subscription.id.compareTo(second.subscription.id)
            : savingsComparison;
      });

    final selected = <Subscription>[];
    var monthlySavings = 0.0;
    for (final candidate in candidates) {
      if (monthlySavings >= target) {
        break;
      }
      selected.add(candidate.subscription);
      monthlySavings += candidate.monthlySavings;
    }

    final hasValidPlan = monthlySavings >= target;
    return NaiveBaselineResult(
      target: target,
      hasValidPlan: hasValidPlan,
      selectedSubscriptions: selected,
      monthlySavings: monthlySavings,
      explanation: hasValidPlan
          ? 'Selected the most expensive valid subscriptions first.'
          : 'The savings target cannot be reached with valid savings values.',
    );
  }
}

// Kept local to this file so the baseline remains independent of impact data.
class _BaselineCandidate {
  const _BaselineCandidate(this.subscription, this.monthlySavings);

  final Subscription subscription;
  final double monthlySavings;
}
