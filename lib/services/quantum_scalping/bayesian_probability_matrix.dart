import 'dart:math';
import '../../core/utils/logger.dart';
import 'quantum_state_analyzer.dart';
import 'temporal_flux_detector.dart';
import 'smart_money_tracker.dart';
import 'chaos_volatility_engine.dart';

/// 🎲 Bayesian Probability Matrix
/// يحسب احتمالات النجاح باستخدام نظرية بايز
class BayesianProbabilityMatrix {
  /// حساب احتمال النجاح باستخدام نظرية بايز
  /// P(Success | Signals) = P(Signals | Success) × P(Success) / P(Signals)
  static BayesianProbability calculate({
    required QuantumState quantumState,
    required TemporalFlux temporalFlux,
    required SmartMoneyFlow smartMoneyFlow,
    required ChaosAnalysis chaosAnalysis,
  }) {
    AppLogger.info('🎲 Calculating Bayesian probabilities...');

    // 1. حساب Prior Probability (الاحتمال المسبق)
    final priorProbability = _calculatePriorProbability(quantumState);

    // 2. حساب Likelihood (احتمال الإشارات عند النجاح)
    final likelihood = _calculateLikelihood(
      quantumState,
      temporalFlux,
      smartMoneyFlow,
      chaosAnalysis,
    );

    // 3. حساب Evidence (احتمال الإشارات)
    final evidence = _calculateEvidence(
      quantumState,
      temporalFlux,
      smartMoneyFlow,
      chaosAnalysis,
    );

    // 4. حساب Posterior Probability (الاحتمال اللاحق)
    final posteriorProbability = _calculatePosteriorProbability(
      priorProbability,
      likelihood,
      evidence,
    );

    // 5. حساب Expected Return
    final expectedReturn = _calculateExpectedReturn(
      posteriorProbability,
      temporalFlux,
      smartMoneyFlow,
    );

    // 6. حساب Risk/Reward
    final riskRewardRatio = _calculateRiskRewardRatio(
      posteriorProbability,
      chaosAnalysis,
    );

    // 7. حساب Optimal Position Size (Kelly Criterion)
    final optimalPositionSize = _calculateKellyCriterion(
      posteriorProbability,
      riskRewardRatio,
    );

    // 8. حساب Confidence Level
    final confidenceLevel = _calculateConfidenceLevel(
      posteriorProbability,
      likelihood,
      evidence,
    );

    final probability = BayesianProbability(
      priorProbability: priorProbability,
      likelihood: likelihood,
      evidence: evidence,
      posteriorProbability: posteriorProbability,
      expectedReturn: expectedReturn,
      riskRewardRatio: riskRewardRatio,
      optimalPositionSize: optimalPositionSize,
      confidenceLevel: confidenceLevel,
      timestamp: DateTime.now(),
    );

    AppLogger.success(
      '✅ Success Probability: ${(posteriorProbability * 100).toStringAsFixed(1)}% '
      '(R/R: 1:${riskRewardRatio.toStringAsFixed(2)})',
    );

    return probability;
  }

  /// حساب Prior Probability (الاحتمال المسبق)
  /// بناءً على الحالة الكمومية
  static double _calculatePriorProbability(QuantumState quantumState) {
    // نستخدم احتمال الحالة المهيمنة
    final state = quantumState.dominantState.toString().split('.').last;
    if (state == 'bullish') {
      return quantumState.bullishProbability;
    } else if (state == 'bearish') {
      return quantumState.bearishProbability;
    } else {
      return quantumState.neutralProbability;
    }
  }

  /// حساب Likelihood (احتمال الإشارات عند النجاح)
  static double _calculateLikelihood(
    QuantumState quantumState,
    TemporalFlux temporalFlux,
    SmartMoneyFlow smartMoneyFlow,
    ChaosAnalysis chaosAnalysis,
  ) {
    double score = 0.0;

    // 1. Quantum State Likelihood
    if (quantumState.isStrong) {
      score += 0.25;
    }

    // 2. Temporal Flux Likelihood
    if (temporalFlux.isStrong && temporalFlux.hasBreakoutPotential) {
      score += 0.25;
    }

    // 3. Smart Money Likelihood
    if (smartMoneyFlow.isActive && smartMoneyFlow.hasWhales) {
      score += 0.25;
    }

    // 4. Chaos Analysis Likelihood
    if (!chaosAnalysis.isChaotic && !chaosAnalysis.isHighRisk) {
      score += 0.25;
    }

    return min(score, 0.95); // Max 95%
  }

  /// حساب Evidence (احتمال الإشارات)
  static double _calculateEvidence(
    QuantumState quantumState,
    TemporalFlux temporalFlux,
    SmartMoneyFlow smartMoneyFlow,
    ChaosAnalysis chaosAnalysis,
  ) {
    // Evidence = weighted average of all signals
    final weights = [0.3, 0.25, 0.25, 0.2];
    final signals = [
      quantumState.confidence,
      temporalFlux.fluxStrength,
      smartMoneyFlow.smartMoneyStrength,
      1 - chaosAnalysis.riskLevel,
    ];

    double evidence = 0.0;
    for (int i = 0; i < weights.length; i++) {
      evidence += weights[i] * signals[i];
    }

    return max(0.1, evidence); // تجنب القسمة على صفر
  }

  /// حساب Posterior Probability (الاحتمال اللاحق)
  /// P(Success | Signals) = P(Signals | Success) × P(Success) / P(Signals)
  static double _calculatePosteriorProbability(
    double prior,
    double likelihood,
    double evidence,
  ) {
    final posterior = (likelihood * prior) / evidence;
    return max(0.0, min(1.0, posterior));
  }

  /// حساب Expected Return (العائد المتوقع)
  static double _calculateExpectedReturn(
    double probability,
    TemporalFlux temporalFlux,
    SmartMoneyFlow smartMoneyFlow,
  ) {
    // Expected Return = Probability × Average Win - (1 - Probability) × Average Loss

    // تقدير متوسط الربح بناءً على الزخم
    final avgWin = 15 + (temporalFlux.momentum.abs() * 5);

    // تقدير متوسط الخسارة (أقل من الربح)
    final avgLoss = 10.0;

    final expectedReturn =
        (probability * avgWin) - ((1 - probability) * avgLoss);

    return expectedReturn; // بالنقاط (pips)
  }

  /// حساب Risk/Reward Ratio
  static double _calculateRiskRewardRatio(
    double probability,
    ChaosAnalysis chaosAnalysis,
  ) {
    // كلما زاد الاحتمال، نستطيع أخذ R/R أعلى
    // كلما قل الخطر، نستطيع أخذ R/R أعلى

    final baseRatio = 2.0;
    final probabilityBonus = (probability - 0.5) * 4; // 0-2
    final riskPenalty = chaosAnalysis.riskLevel * 1.5; // 0-1.5

    final ratio = baseRatio + probabilityBonus - riskPenalty;

    return max(1.0, min(5.0, ratio)); // Min 1:1, Max 1:5
  }

  /// حساب Optimal Position Size (Kelly Criterion)
  /// Kelly% = (p × b - q) / b
  /// p = احتمال الربح
  /// q = احتمال الخسارة (1 - p)
  /// b = نسبة الربح/الخسارة (R/R ratio)
  static double _calculateKellyCriterion(
    double probability,
    double riskRewardRatio,
  ) {
    final p = probability;
    final q = 1 - probability;
    final b = riskRewardRatio;

    final kelly = (p * b - q) / b;

    // نستخدم Half Kelly للأمان
    final halfKelly = kelly / 2;

    // Clamp between 0% and 25% (never risk more than 25%)
    return max(0.0, min(0.25, halfKelly));
  }

  /// حساب Confidence Level
  static double _calculateConfidenceLevel(
    double posteriorProbability,
    double likelihood,
    double evidence,
  ) {
    // الثقة = دالة من الاحتمال اللاحق، الـ likelihood، والـ evidence
    final confidence =
        (posteriorProbability * 0.5) + (likelihood * 0.3) + (evidence * 0.2);

    return min(confidence, 1.0);
  }
}

/// 🎲 Bayesian Probability Model
class BayesianProbability {
  final double priorProbability; // 0-1
  final double likelihood; // 0-1
  final double evidence; // 0-1
  final double posteriorProbability; // 0-1 (احتمال النجاح)
  final double expectedReturn; // بالنقاط (pips)
  final double riskRewardRatio; // 1-5
  final double optimalPositionSize; // 0-0.25 (0-25%)
  final double confidenceLevel; // 0-1
  final DateTime timestamp;

  BayesianProbability({
    required this.priorProbability,
    required this.likelihood,
    required this.evidence,
    required this.posteriorProbability,
    required this.expectedReturn,
    required this.riskRewardRatio,
    required this.optimalPositionSize,
    required this.confidenceLevel,
    required this.timestamp,
  });

  /// هل الصفقة ممتازة؟
  bool get isExcellentTrade =>
      posteriorProbability > 0.75 && riskRewardRatio > 2.5;

  /// هل الصفقة جيدة؟
  bool get isGoodTrade => posteriorProbability > 0.65 && riskRewardRatio > 2.0;

  /// هل الصفقة مقبولة؟
  bool get isAcceptableTrade =>
      posteriorProbability > 0.55 && riskRewardRatio > 1.5;

  /// هل يجب رفض الصفقة؟
  bool get shouldRejectTrade =>
      posteriorProbability < 0.55 || riskRewardRatio < 1.5;

  /// تقييم الصفقة
  TradeQuality get tradeQuality {
    if (isExcellentTrade) return TradeQuality.excellent;
    if (isGoodTrade) return TradeQuality.good;
    if (isAcceptableTrade) return TradeQuality.acceptable;
    return TradeQuality.poor;
  }

  @override
  String toString() {
    return 'BayesianProbability('
        'prior: ${(priorProbability * 100).toStringAsFixed(1)}%, '
        'likelihood: ${(likelihood * 100).toStringAsFixed(1)}%, '
        'evidence: ${(evidence * 100).toStringAsFixed(1)}%, '
        'posterior: ${(posteriorProbability * 100).toStringAsFixed(1)}%, '
        'expectedReturn: ${expectedReturn.toStringAsFixed(1)} pips, '
        'R/R: 1:${riskRewardRatio.toStringAsFixed(2)}, '
        'positionSize: ${(optimalPositionSize * 100).toStringAsFixed(1)}%, '
        'confidence: ${(confidenceLevel * 100).toStringAsFixed(1)}%, '
        'quality: ${tradeQuality.name}'
        ')';
  }
}

/// جودة الصفقة
enum TradeQuality {
  excellent,
  good,
  acceptable,
  poor,
}
