import 'package:trimly/core/enums/decision_status.dart';
import 'package:trimly/domain/models/subscription.dart';

class OptimizerExplanation {
  const OptimizerExplanation({
    required this.summary,
    required this.selectedSubscriptionNames,
  });

  final String summary;
  final List<String> selectedSubscriptionNames;
}

class OptimizerPlan {
  OptimizerPlan({
    required List<Subscription> selectedSubscriptions,
    required this.target,
    required this.monthlySavings,
    required this.totalImpactScore,
    required this.overshoot,
    required this.explanation,
  }) : selectedSubscriptions = List.unmodifiable(selectedSubscriptions);

  final List<Subscription> selectedSubscriptions;
  final double target;
  final double monthlySavings;
  final double totalImpactScore;
  final double overshoot;
  final OptimizerExplanation explanation;

  double get annualizedSavings => monthlySavings * 12;

  int get cancellationCount => selectedSubscriptions.length;

  String get signature => selectedSubscriptions.map((item) => item.id).join('|');
}

class OptimizerResult {
  OptimizerResult({
    required this.target,
    required this.hasValidPlan,
    required this.recommendedPlan,
    required List<OptimizerPlan> alternatives,
    required this.explanation,
    required this.eligibleCandidateCount,
  }) : alternatives = List.unmodifiable(alternatives);

  final double target;
  final bool hasValidPlan;
  final OptimizerPlan? recommendedPlan;
  final List<OptimizerPlan> alternatives;
  final String explanation;
  final int eligibleCandidateCount;
}

class NaiveBaselineResult {
  NaiveBaselineResult({
    required this.target,
    required this.hasValidPlan,
    required List<Subscription> selectedSubscriptions,
    required this.monthlySavings,
    required this.explanation,
  }) : selectedSubscriptions = List.unmodifiable(selectedSubscriptions);

  final double target;
  final bool hasValidPlan;
  final List<Subscription> selectedSubscriptions;
  final double monthlySavings;
  final String explanation;

  double get annualizedSavings => monthlySavings * 12;

  double get overshoot => monthlySavings - target;

  int get cancellationCount => selectedSubscriptions.length;
}

bool isOptimizerCandidate(Subscription subscription) {
  return subscription.decisionStatus == DecisionStatus.review ||
      subscription.decisionStatus == DecisionStatus.cut;
}
