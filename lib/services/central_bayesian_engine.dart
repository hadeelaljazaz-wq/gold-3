// 🎯 Central Bayesian Engine - Unified Bayesian Analysis for All Trading Engines
// محرك بايزي مركزي يخدم جميع محركات التداول

import 'dart:math' as math;
import '../core/utils/logger.dart';
import '../models/candle.dart';

// ══════════════════════════════════════════════════════════════════
// CENTRAL BAYESIAN ENGINE
// ══════════════════════════════════════════════════════════════════

class CentralBayesianEngine {
  /// تحليل بايزي شامل
  ///
  /// **نظرية بايز:**
  /// P(Success | Signals) = P(Signals | Success) × P(Success) / P(Signals)
  ///
  /// **Parameters:**
  /// - [signalStrength]: قوة الإشارة (0-1)
  /// - [trendStrength]: قوة الاتجاه (-1 إلى 1)
  /// - [momentum]: الزخم (-1 إلى 1)
  /// - [volatility]: التقلب (0-1)
  /// - [volumeProfile]: حجم التداول (0-1)
  /// - [timeframeAlignment]: توافق الأطر الزمنية (0-1)
  /// - [structureQuality]: جودة البنية السعرية (0-1)
  /// - [chaosRiskLevel]: مستوى المخاطرة من Chaos (0-1)
  ///
  /// **Returns:** BayesianAnalysis
  static BayesianAnalysis analyze({
    required double signalStrength,
    required double trendStrength,
    required double momentum,
    required double volatility,
    required double volumeProfile,
    required double timeframeAlignment,
    required double structureQuality,
    required double chaosRiskLevel,
    String? signalDirection, // 'BUY' or 'SELL'
  }) {
    AppLogger.info('🎯 Starting Central Bayesian Analysis...');

    // ══════════════════════════════════════════════════════════════════
    // STEP 1: حساب Prior Probability (الاحتمال المسبق)
    // ══════════════════════════════════════════════════════════════════

    final priorProbability = _calculatePrior(
      trendStrength,
      momentum,
      signalDirection,
    );

    // ══════════════════════════════════════════════════════════════════
    // STEP 2: حساب Likelihood (احتمال الإشارات عند النجاح)
    // ══════════════════════════════════════════════════════════════════

    final likelihood = _calculateLikelihood(
      signalStrength: signalStrength,
      trendStrength: trendStrength,
      momentum: momentum,
      volumeProfile: volumeProfile,
      timeframeAlignment: timeframeAlignment,
      structureQuality: structureQuality,
      chaosRiskLevel: chaosRiskLevel,
    );

    // ══════════════════════════════════════════════════════════════════
    // STEP 3: حساب Evidence (احتمال الإشارات)
    // ══════════════════════════════════════════════════════════════════

    final evidence = _calculateEvidence(
      signalStrength,
      trendStrength,
      momentum,
      volatility,
      volumeProfile,
      timeframeAlignment,
      structureQuality,
      chaosRiskLevel,
    );

    // ══════════════════════════════════════════════════════════════════
    // STEP 4: حساب Posterior Probability (الاحتمال اللاحق)
    // ══════════════════════════════════════════════════════════════════

    final posteriorProbability = _calculatePosterior(
      priorProbability,
      likelihood,
      evidence,
    );

    // ══════════════════════════════════════════════════════════════════
    // STEP 5: حساب Expected Return
    // ══════════════════════════════════════════════════════════════════

    final expectedReturn = _calculateExpectedReturn(
      posteriorProbability,
      trendStrength,
      momentum,
      volatility,
    );

    // ══════════════════════════════════════════════════════════════════
    // STEP 6: حساب Risk/Reward Ratio
    // ══════════════════════════════════════════════════════════════════

    final riskRewardRatio = _calculateRiskReward(
      posteriorProbability,
      chaosRiskLevel,
      volatility,
      trendStrength,
    );

    // ══════════════════════════════════════════════════════════════════
    // STEP 7: حساب Confidence Level
    // ══════════════════════════════════════════════════════════════════

    final confidenceLevel = _calculateConfidence(
      posteriorProbability,
      likelihood,
      evidence,
      signalStrength,
      timeframeAlignment,
    );

    // ══════════════════════════════════════════════════════════════════
    // STEP 8: تحديد Trade Quality
    // ══════════════════════════════════════════════════════════════════

    final tradeQuality = _determineTradeQuality(
      posteriorProbability,
      riskRewardRatio,
      chaosRiskLevel,
      confidenceLevel,
    );

    final analysis = BayesianAnalysis(
      priorProbability: priorProbability,
      likelihood: likelihood,
      evidence: evidence,
      posteriorProbability: posteriorProbability,
      expectedReturn: expectedReturn,
      riskRewardRatio: riskRewardRatio,
      confidenceLevel: confidenceLevel,
      tradeQuality: tradeQuality,
      timestamp: DateTime.now(),
    );

    AppLogger.success(
      '✅ Bayesian Analysis Complete: '
      'P(Success) = ${(posteriorProbability * 100).toStringAsFixed(1)}%, '
      'R/R = 1:${riskRewardRatio.toStringAsFixed(2)}, '
      'Quality = ${tradeQuality.name}',
    );

    return analysis;
  }

  /// حساب Prior Probability من الاتجاه والزخم
  static double _calculatePrior(
    double trendStrength,
    double momentum,
    String? signalDirection,
  ) {
    // Base prior: 50% (neutral)
    double prior = 0.50;

    // تعديل بناءً على الاتجاه
    if (signalDirection != null) {
      final trendAlignment =
          signalDirection == 'BUY' ? trendStrength : -trendStrength;

      // إذا كان الاتجاه يوافق الإشارة، نزيد Prior
      if (trendAlignment > 0) {
        prior += trendAlignment * 0.25; // حتى 75%
      } else {
        prior += trendAlignment * 0.15; // حتى 35%
      }
    } else {
      // استخدام القيمة المطلقة
      prior += trendStrength.abs() * 0.15;
    }

    // تعديل بناءً على الزخم
    prior += momentum.abs() * 0.10;

    return prior.clamp(0.30, 0.80);
  }

  /// حساب Likelihood
  static double _calculateLikelihood({
    required double signalStrength,
    required double trendStrength,
    required double momentum,
    required double volumeProfile,
    required double timeframeAlignment,
    required double structureQuality,
    required double chaosRiskLevel,
  }) {
    double score = 0.0;

    // 1. Signal Strength (25%)
    score += signalStrength * 0.25;

    // 2. Trend & Momentum Alignment (20%)
    final trendMomentumAlignment = (trendStrength.abs() + momentum.abs()) / 2;
    score += trendMomentumAlignment * 0.20;

    // 3. Volume Confirmation (15%)
    score += volumeProfile * 0.15;

    // 4. Multi-Timeframe Alignment (15%)
    score += timeframeAlignment * 0.15;

    // 5. Structure Quality (15%)
    score += structureQuality * 0.15;

    // 6. Low Chaos Risk (10%)
    score += (1 - chaosRiskLevel) * 0.10;

    return math.min(score, 0.95); // Max 95%
  }

  /// حساب Evidence
  static double _calculateEvidence(
    double signalStrength,
    double trendStrength,
    double momentum,
    double volatility,
    double volumeProfile,
    double timeframeAlignment,
    double structureQuality,
    double chaosRiskLevel,
  ) {
    // Weighted average of all signals
    final weights = [0.20, 0.15, 0.15, 0.10, 0.15, 0.15, 0.10];
    final signals = [
      signalStrength,
      trendStrength.abs(),
      momentum.abs(),
      1 - volatility, // تقلب منخفض = evidence أقوى
      volumeProfile,
      timeframeAlignment,
      1 - chaosRiskLevel,
    ];

    double evidence = 0.0;
    for (int i = 0; i < weights.length; i++) {
      evidence += weights[i] * signals[i];
    }

    return math.max(0.10, evidence); // Minimum 10% لتجنب قسمة على صفر
  }

  /// حساب Posterior Probability
  /// P(Success | Signals) = P(Signals | Success) × P(Success) / P(Signals)
  static double _calculatePosterior(
    double prior,
    double likelihood,
    double evidence,
  ) {
    final posterior = (likelihood * prior) / evidence;
    return posterior.clamp(0.0, 1.0);
  }

  /// حساب Expected Return (بالنقاط)
  static double _calculateExpectedReturn(
    double probability,
    double trendStrength,
    double momentum,
    double volatility,
  ) {
    // Average Win بناءً على قوة الاتجاه والزخم
    final trendFactor = trendStrength.abs() * 10; // 0-10 نقاط
    final momentumFactor = momentum.abs() * 5; // 0-5 نقاط
    final volatilityFactor =
        volatility * 10; // 0-10 نقاط (تقلب عالي = حركة أكبر)

    final avgWin = 15 + trendFactor + momentumFactor + volatilityFactor;

    // Average Loss
    const avgLoss = 10.0;

    // Expected Return = P(win) × AvgWin - P(loss) × AvgLoss
    final expectedReturn =
        (probability * avgWin) - ((1 - probability) * avgLoss);

    return expectedReturn;
  }

  /// حساب Risk/Reward Ratio
  static double _calculateRiskReward(
    double probability,
    double chaosRiskLevel,
    double volatility,
    double trendStrength,
  ) {
    // Base R/R
    double baseRatio = 2.0;

    // Probability bonus: كلما زاد الاحتمال، نستطيع استهداف R/R أعلى
    final probabilityBonus = (probability - 0.5) * 4; // -2 to +2

    // Chaos penalty: خطر عالي = R/R أقل
    final chaosPenalty = chaosRiskLevel * 1.5; // 0 to 1.5

    // Trend bonus: اتجاه قوي = R/R أعلى
    final trendBonus = trendStrength.abs() * 1.0; // 0 to 1

    // Volatility adjustment: تقلب عالي = يمكن استهداف R/R أعلى
    final volatilityBonus = volatility * 0.5; // 0 to 0.5

    final ratio = baseRatio +
        probabilityBonus -
        chaosPenalty +
        trendBonus +
        volatilityBonus;

    return math.max(1.0, math.min(5.0, ratio)); // 1:1 to 1:5
  }

  /// حساب Confidence Level
  static double _calculateConfidence(
    double posteriorProbability,
    double likelihood,
    double evidence,
    double signalStrength,
    double timeframeAlignment,
  ) {
    // مزيج من العوامل
    double confidence = 0.0;

    confidence += posteriorProbability * 0.40; // 40%
    confidence += likelihood * 0.25; // 25%
    confidence += evidence * 0.15; // 15%
    confidence += signalStrength * 0.10; // 10%
    confidence += timeframeAlignment * 0.10; // 10%

    return confidence.clamp(0.0, 1.0);
  }

  /// تحديد Trade Quality
  static BayesianTradeQuality _determineTradeQuality(
    double posteriorProbability,
    double riskRewardRatio,
    double chaosRiskLevel,
    double confidenceLevel,
  ) {
    // Excellent: P > 75%, R/R > 2.5, Chaos < 0.3
    if (posteriorProbability > 0.75 && 
        riskRewardRatio > 2.5 && 
        chaosRiskLevel < 0.3 &&
        confidenceLevel > 0.75) {
      return BayesianTradeQuality.excellent;
    }

    // Good: P > 65%, R/R > 2.0, Chaos < 0.5
    if (posteriorProbability > 0.65 && 
        riskRewardRatio > 2.0 && 
        chaosRiskLevel < 0.5 &&
        confidenceLevel > 0.65) {
      return BayesianTradeQuality.good;
    }

    // Acceptable: P > 55%, R/R > 1.5, Chaos < 0.7
    if (posteriorProbability > 0.55 && 
        riskRewardRatio > 1.5 && 
        chaosRiskLevel < 0.7 &&
        confidenceLevel > 0.55) {
      return BayesianTradeQuality.acceptable;
    }

    // Poor: كل ما دون ذلك
    return BayesianTradeQuality.poor;
  }

  /// تحليل سريع من بيانات Candles
  static BayesianAnalysis analyzeFromCandles({
    required List<Candle> candles,
    required double signalStrength,
    String? signalDirection,
  }) {
    if (candles.length < 50) {
      throw ArgumentError('Need at least 50 candles for Bayesian analysis');
    }

    // حساب المؤشرات من الشموع
    final trendStrength = _calculateTrendFromCandles(candles);
    final momentum = _calculateMomentumFromCandles(candles);
    final volatility = _calculateVolatilityFromCandles(candles);
    final volumeProfile = _calculateVolumeFromCandles(candles);

    // افتراضات للقيم الأخرى
    const timeframeAlignment = 0.7; // افتراضي
    const structureQuality = 0.6; // افتراضي
    final chaosRiskLevel = volatility * 0.5; // تقدير من التقلب

    return analyze(
      signalStrength: signalStrength,
      trendStrength: trendStrength,
      momentum: momentum,
      volatility: volatility,
      volumeProfile: volumeProfile,
      timeframeAlignment: timeframeAlignment,
      structureQuality: structureQuality,
      chaosRiskLevel: chaosRiskLevel,
      signalDirection: signalDirection,
    );
  }

  // Helper methods لحساب المؤشرات من Candles

  static double _calculateTrendFromCandles(List<Candle> candles) {
    final recent = candles.sublist(math.max(0, candles.length - 20));
    final closes = recent.map((c) => c.close).toList();

    final firstPrice = closes.first;
    final lastPrice = closes.last;
    final change = (lastPrice - firstPrice) / firstPrice;

    return (change * 10).clamp(-1.0, 1.0);
  }

  static double _calculateMomentumFromCandles(List<Candle> candles) {
    if (candles.length < 10) return 0.0;

    final closes = candles.map((c) => c.close).toList();
    final roc =
        (closes.last - closes[closes.length - 10]) / closes[closes.length - 10];

    return (roc * 10).clamp(-1.0, 1.0);
  }

  static double _calculateVolatilityFromCandles(List<Candle> candles) {
    final recent = candles.sublist(math.max(0, candles.length - 20));

    final ranges = recent.map((c) => c.high - c.low).toList();
    final avgRange = ranges.reduce((a, b) => a + b) / ranges.length;
    final currentPrice = candles.last.close;

    return (avgRange / currentPrice * 100).clamp(0.0, 1.0);
  }

  static double _calculateVolumeFromCandles(List<Candle> candles) {
    final recent = candles.sublist(math.max(0, candles.length - 20));
    final volumes = recent.map((c) => c.volume).toList();

    final avgVolume = volumes.reduce((a, b) => a + b) / volumes.length;
    final currentVolume = volumes.last;

    return (currentVolume / avgVolume).clamp(0.0, 1.0);
  }
}

// ══════════════════════════════════════════════════════════════════
// MODELS
// ══════════════════════════════════════════════════════════════════

/// نتيجة التحليل البايزي
class BayesianAnalysis {
  final double priorProbability; // 0-1
  final double likelihood; // 0-1
  final double evidence; // 0-1
  final double posteriorProbability; // 0-1 (احتمال النجاح)
  final double expectedReturn; // بالنقاط (pips)
  final double riskRewardRatio; // 1-5
  final double confidenceLevel; // 0-1
  final BayesianTradeQuality tradeQuality;
  final DateTime timestamp;

  const BayesianAnalysis({
    required this.priorProbability,
    required this.likelihood,
    required this.evidence,
    required this.posteriorProbability,
    required this.expectedReturn,
    required this.riskRewardRatio,
    required this.confidenceLevel,
    required this.tradeQuality,
    required this.timestamp,
  });

  /// هل الصفقة ممتازة؟
  bool get isExcellent => tradeQuality == BayesianTradeQuality.excellent;

  /// هل الصفقة جيدة؟
  bool get isGood => tradeQuality == BayesianTradeQuality.good || isExcellent;

  /// هل الصفقة مقبولة؟
  bool get isAcceptable => 
      tradeQuality == BayesianTradeQuality.acceptable || isGood;

  /// هل يجب رفض الصفقة؟
  bool get shouldReject => tradeQuality == BayesianTradeQuality.poor;

  Map<String, dynamic> toJson() {
    return {
      'prior_probability': priorProbability,
      'likelihood': likelihood,
      'evidence': evidence,
      'posterior_probability': posteriorProbability,
      'expected_return': expectedReturn,
      'risk_reward_ratio': riskRewardRatio,
      'confidence_level': confidenceLevel,
      'trade_quality': tradeQuality.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'BayesianAnalysis('
        'P(Success) = ${(posteriorProbability * 100).toStringAsFixed(1)}%, '
        'Expected Return = ${expectedReturn.toStringAsFixed(1)} pips, '
        'R/R = 1:${riskRewardRatio.toStringAsFixed(2)}, '
        'Confidence = ${(confidenceLevel * 100).toStringAsFixed(1)}%, '
        'Quality = ${tradeQuality.name}'
        ')';
  }
}

/// جودة الصفقة البايزية
enum BayesianTradeQuality {
  excellent, // ممتاز
  good, // جيد
  acceptable, // مقبول
  poor, // ضعيف
}
