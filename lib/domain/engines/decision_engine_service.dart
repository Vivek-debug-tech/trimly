import '../../core/enums/decision_status.dart';
import '../../core/enums/importance.dart';
import '../../core/enums/usage_frequency.dart';
import '../models/subscription.dart';

class DecisionEngineResult {
  const DecisionEngineResult({
    required this.impactScore,
    required this.decisionStatus,
  });

  final double? impactScore;
  final DecisionStatus decisionStatus;
}

class DecisionEngineService {
  const DecisionEngineService();

  static const double usageWeight = 0.40;
  static const double importanceWeight = 0.60;
  static const double keepThreshold = 0.70;
  static const double reviewThreshold = 0.40;

  DecisionEngineResult evaluateSubscription(Subscription subscription) {
    return evaluate(
      usageFrequency: subscription.usageFrequency,
      importance: subscription.importance,
    );
  }

  DecisionEngineResult evaluate({
    required UsageFrequency? usageFrequency,
    required Importance? importance,
  }) {
    if (usageFrequency == null || importance == null) {
      return const DecisionEngineResult(
        impactScore: null,
        decisionStatus: DecisionStatus.notEnoughInfo,
      );
    }

    final impactScore =
        usageWeight * normalizeUsage(usageFrequency) +
        importanceWeight * normalizeImportance(importance);

    return DecisionEngineResult(
      impactScore: impactScore,
      decisionStatus: classify(impactScore),
    );
  }

  double normalizeUsage(UsageFrequency usageFrequency) {
    return switch (usageFrequency) {
      UsageFrequency.daily => 1.0,
      UsageFrequency.severalPerWeek => 0.8,
      UsageFrequency.weekly => 0.6,
      UsageFrequency.monthly => 0.4,
      UsageFrequency.rarely => 0.2,
      UsageFrequency.never => 0.0,
    };
  }

  double normalizeImportance(Importance importance) {
    return switch (importance) {
      Importance.high => 1.0,
      Importance.medium => 0.5,
      Importance.low => 0.0,
    };
  }

  DecisionStatus classify(double impactScore) {
    if (impactScore >= keepThreshold) {
      return DecisionStatus.keep;
    }
    if (impactScore >= reviewThreshold) {
      return DecisionStatus.review;
    }
    return DecisionStatus.cut;
  }
}
