// 🤖 ML Decision Maker - Intelligent Trade Decision System
// نظام ذكي لاتخاذ قرارات التداول بناءً على ML و Bayesian و Chaos

import 'dart:math' as math;
import '../core/utils/logger.dart';
import '../models/trade_decision.dart';
import 'central_bayesian_engine.dart';
import 'chaos_position_sizer.dart';

// ══════════════════════════════════════════════════════════════════
// ML DECISION MAKER
// ══════════════════════════════════════════════════════════════════

class MLDecisionMaker {
  /// اتخاذ قرار تداول متكامل
  /// 
  /// **يدمج:**
  /// - Bayesian Probability
  /// - Chaos Risk Level
  /// - ML Confidence
  /// - Signal Strength
  /// - Market Conditions
  /// 
  /// **Returns:** TradeDecision مع EXECUTE / WAIT / ABORT
  static TradeDecision makeDecision({
    required BayesianAnalysis bayesianAnalysis,
    required double chaosRiskLevel,
    required double signalStrength,
    required double signalConfidence,
    required double volatility,
    required DecisionFactors factors,
    double accountBalance = 10000.0,
    String? signalDirection,
  }) {
    AppLogger.info('🤖 ML Decision Maker - Analyzing...');

    // ══════════════════════════════════════════════════════════════════
    // STEP 1: جمع المدخلات
    // ══════════════════════════════════════════════════════════════════
    
    final bayesianProb = bayesianAnalysis.posteriorProbability;
    final bayesianConfidence = bayesianAnalysis.confidenceLevel;
    final riskRewardRatio = bayesianAnalysis.riskRewardRatio;

    // ══════════════════════════════════════════════════════════════════
    // STEP 2: حساب الثقة الإجمالية
    // ══════════════════════════════════════════════════════════════════
    
    final overallConfidence = _calculateOverallConfidence(
      bayesianProb: bayesianProb,
      bayesianConfidence: bayesianConfidence,
      signalConfidence: signalConfidence,
      signalStrength: signalStrength,
      chaosRiskLevel: chaosRiskLevel,
      factorsScore: factors.overallScore,
    );

    // ══════════════════════════════════════════════════════════════════
    // STEP 3: حساب Position Size
    // ══════════════════════════════════════════════════════════════════
    
    final positionSizeResult = ChaosPositionSizer.calculate(
      chaosRiskLevel: chaosRiskLevel,
      bayesianProbability: bayesianProb,
      confidence: overallConfidence,
      volatility: volatility,
      accountBalance: accountBalance,
    );

    // ══════════════════════════════════════════════════════════════════
    // STEP 4: تطبيق القواعد الذكية لاتخاذ القرار
    // ══════════════════════════════════════════════════════════════════
    
    final actionDecision = _determineAction(
      bayesianProb: bayesianProb,
      overallConfidence: overallConfidence,
      chaosRiskLevel: chaosRiskLevel,
      riskRewardRatio: riskRewardRatio,
      bayesianQuality: bayesianAnalysis.tradeQuality,
      signalStrength: signalStrength,
      factorsScore: factors.overallScore,
    );

    // ══════════════════════════════════════════════════════════════════
    // STEP 5: جمع الأسباب والتحذيرات
    // ══════════════════════════════════════════════════════════════════
    
    final reasons = _generateReasons(
      action: actionDecision,
      bayesianProb: bayesianProb,
      overallConfidence: overallConfidence,
      chaosRiskLevel: chaosRiskLevel,
      riskRewardRatio: riskRewardRatio,
      signalStrength: signalStrength,
      factors: factors,
    );

    final warnings = _generateWarnings(
      chaosRiskLevel: chaosRiskLevel,
      volatility: volatility,
      bayesianProb: bayesianProb,
      factors: factors,
    );

    // ══════════════════════════════════════════════════════════════════
    // STEP 6: بناء القرار النهائي
    // ══════════════════════════════════════════════════════════════════
    
    final decision = TradeDecision(
      action: actionDecision,
      confidence: overallConfidence,
      positionSize: positionSizeResult.positionSizePercent,
      riskLevel: chaosRiskLevel,
      bayesianProbability: bayesianProb,
      riskRewardRatio: riskRewardRatio,
      reasons: reasons,
      warnings: warnings,
      metadata: {
        'bayesian_analysis': bayesianAnalysis.toJson(),
        'position_sizing': positionSizeResult.toJson(),
        'signal_direction': signalDirection,
        'decision_factors': factors.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    AppLogger.success(
      '✅ Decision: ${actionDecision.name} | '
      'Confidence: ${(overallConfidence * 100).toStringAsFixed(1)}% | '
      'Position: ${(positionSizeResult.positionSizePercent * 100).toStringAsFixed(2)}% | '
      'Quality: ${decision.qualityScore.toStringAsFixed(1)}/10',
    );

    return decision;
  }

  /// حساب الثقة الإجمالية (Ensemble Confidence)
  static double _calculateOverallConfidence({
    required double bayesianProb,
    required double bayesianConfidence,
    required double signalConfidence,
    required double signalStrength,
    required double chaosRiskLevel,
    required double factorsScore,
  }) {
    // Weighted ensemble من مصادر متعددة
    double confidence = 0.0;

    // 1. Bayesian Probability (30%)
    confidence += bayesianProb * 0.30;

    // 2. Bayesian Confidence (20%)
    confidence += bayesianConfidence * 0.20;

    // 3. Signal Confidence (20%)
    confidence += signalConfidence * 0.20;

    // 4. Signal Strength (15%)
    confidence += signalStrength * 0.15;

    // 5. Low Chaos Risk (10%)
    confidence += (1 - chaosRiskLevel) * 0.10;

    // 6. Market Factors Score (5%)
    confidence += factorsScore * 0.05;

    return confidence.clamp(0.0, 1.0);
  }

  /// تحديد القرار النهائي: EXECUTE / WAIT / ABORT
  static TradeAction _determineAction({
    required double bayesianProb,
    required double overallConfidence,
    required double chaosRiskLevel,
    required double riskRewardRatio,
    required BayesianTradeQuality bayesianQuality,
    required double signalStrength,
    required double factorsScore,
  }) {
    // ══════════════════════════════════════════════════════════════════
    // ABORT CONDITIONS - تحقق أولاً من شروط الإلغاء
    // ══════════════════════════════════════════════════════════════════
    
    // Rule 1: Chaos Risk عالي جداً
    if (chaosRiskLevel > 0.80) {
      AppLogger.warn('ABORT: Extreme chaos risk (${(chaosRiskLevel * 100).toStringAsFixed(0)}%)');
      return TradeAction.abort;
    }

    // Rule 2: Bayesian Probability منخفض جداً
    if (bayesianProb < 0.50) {
      AppLogger.warn('ABORT: Low Bayesian probability (${(bayesianProb * 100).toStringAsFixed(0)}%)');
      return TradeAction.abort;
    }

    // Rule 3: Overall Confidence منخفض جداً
    if (overallConfidence < 0.50) {
      AppLogger.warn('ABORT: Low overall confidence (${(overallConfidence * 100).toStringAsFixed(0)}%)');
      return TradeAction.abort;
    }

    // Rule 4: R/R Ratio سيء
    if (riskRewardRatio < 1.2) {
      AppLogger.warn('ABORT: Poor risk/reward ratio (1:${riskRewardRatio.toStringAsFixed(2)})');
      return TradeAction.abort;
    }

    // Rule 5: Bayesian Quality ضعيف
    if (bayesianQuality == BayesianTradeQuality.poor) {
      AppLogger.warn('ABORT: Poor Bayesian quality');
      return TradeAction.abort;
    }

    // Rule 6: Signal Strength ضعيف جداً
    if (signalStrength < 0.40) {
      AppLogger.warn('ABORT: Weak signal strength (${(signalStrength * 100).toStringAsFixed(0)}%)');
      return TradeAction.abort;
    }

    // Rule 7: Market Factors غير مواتية
    if (factorsScore < 0.35) {
      AppLogger.warn('ABORT: Unfavorable market conditions');
      return TradeAction.abort;
    }

    // ══════════════════════════════════════════════════════════════════
    // EXECUTE CONDITIONS - شروط التنفيذ الفوري
    // ══════════════════════════════════════════════════════════════════
    
    // Rule 1: Perfect Storm (كل العوامل قوية)
    if (bayesianProb >= 0.75 && 
        overallConfidence >= 0.75 && 
        chaosRiskLevel < 0.30 &&
        riskRewardRatio >= 2.5 &&
        signalStrength >= 0.75 &&
        factorsScore >= 0.70) {
      AppLogger.info('EXECUTE: Perfect conditions detected!');
      return TradeAction.execute;
    }

    // Rule 2: Strong Bayesian + Low Risk
    if (bayesianProb >= 0.75 && 
        chaosRiskLevel < 0.40 &&
        riskRewardRatio >= 2.0) {
      AppLogger.info('EXECUTE: Strong Bayesian probability with low risk');
      return TradeAction.execute;
    }

    // Rule 3: High Confidence + Good R/R
    if (overallConfidence >= 0.75 && 
        riskRewardRatio >= 2.5 &&
        chaosRiskLevel < 0.50) {
      AppLogger.info('EXECUTE: High confidence with excellent R/R');
      return TradeAction.execute;
    }

    // Rule 4: Excellent Bayesian Quality
    if (bayesianQuality == BayesianTradeQuality.excellent) {
      AppLogger.info('EXECUTE: Excellent Bayesian quality');
      return TradeAction.execute;
    }

    // ══════════════════════════════════════════════════════════════════
    // WAIT CONDITIONS - الباقي = انتظار ومراقبة
    // ══════════════════════════════════════════════════════════════════
    
    AppLogger.info('WAIT: Moderate conditions - monitoring required');
    return TradeAction.wait;
  }

  /// توليد الأسباب
  static List<String> _generateReasons({
    required TradeAction action,
    required double bayesianProb,
    required double overallConfidence,
    required double chaosRiskLevel,
    required double riskRewardRatio,
    required double signalStrength,
    required DecisionFactors factors,
  }) {
    final reasons = <String>[];

    // حسب القرار
    switch (action) {
      case TradeAction.execute:
        reasons.add('✅ High success probability: ${(bayesianProb * 100).toStringAsFixed(0)}%');
        reasons.add('💪 Strong confidence: ${(overallConfidence * 100).toStringAsFixed(0)}%');
        reasons.add('📊 Good R/R ratio: 1:${riskRewardRatio.toStringAsFixed(2)}');
        if (chaosRiskLevel < 0.3) {
          reasons.add('🛡️ Low chaos risk: ${(chaosRiskLevel * 100).toStringAsFixed(0)}%');
        }
        break;

      case TradeAction.wait:
        reasons.add('⏳ Moderate probability: ${(bayesianProb * 100).toStringAsFixed(0)}%');
        reasons.add('⚖️ Medium confidence: ${(overallConfidence * 100).toStringAsFixed(0)}%');
        if (chaosRiskLevel > 0.5) {
          reasons.add('⚠️ Elevated chaos risk: ${(chaosRiskLevel * 100).toStringAsFixed(0)}%');
        }
        reasons.add('👁️ Monitor for better entry');
        break;

      case TradeAction.abort:
        if (bayesianProb < 0.50) {
          reasons.add('❌ Low success probability: ${(bayesianProb * 100).toStringAsFixed(0)}%');
        }
        if (chaosRiskLevel > 0.70) {
          reasons.add('🌪️ High chaos risk: ${(chaosRiskLevel * 100).toStringAsFixed(0)}%');
        }
        if (riskRewardRatio < 1.5) {
          reasons.add('📉 Poor R/R ratio: 1:${riskRewardRatio.toStringAsFixed(2)}');
        }
        if (signalStrength < 0.5) {
          reasons.add('📊 Weak signal: ${(signalStrength * 100).toStringAsFixed(0)}%');
        }
        break;
    }

    // إضافة معلومات عن العوامل
    if (factors.isFavorable) {
      reasons.add('🌟 Favorable market conditions');
    } else if (factors.isUnfavorable) {
      reasons.add('⚠️ Unfavorable market conditions');
    }

    return reasons;
  }

  /// توليد التحذيرات
  static List<String> _generateWarnings({
    required double chaosRiskLevel,
    required double volatility,
    required double bayesianProb,
    required DecisionFactors factors,
  }) {
    final warnings = <String>[];

    // Chaos Risk
    if (chaosRiskLevel > 0.70) {
      warnings.add('⚠️ EXTREME CHAOS RISK - Market highly unpredictable');
    } else if (chaosRiskLevel > 0.50) {
      warnings.add('⚡ Elevated chaos risk - Use tight stop loss');
    }

    // Volatility
    if (volatility > 0.75) {
      warnings.add('📊 Very high volatility - Wide price swings expected');
    }

    // Bayesian vs Chaos mismatch
    if (bayesianProb > 0.70 && chaosRiskLevel > 0.60) {
      warnings.add('⚖️ Conflicting signals: High probability but risky environment');
    }

    // Trend vs Momentum mismatch
    if ((factors.trendStrength > 0.5 && factors.momentum < -0.3) ||
        (factors.trendStrength < -0.5 && factors.momentum > 0.3)) {
      warnings.add('🔄 Trend-Momentum divergence detected');
    }

    // Weak structure
    if (factors.structureQuality < 0.40) {
      warnings.add('🏗️ Weak market structure - Higher failure risk');
    }

    // Low volume
    if (factors.volumeProfile < 0.40) {
      warnings.add('📉 Low volume - Reduced liquidity');
    }

    return warnings;
  }

  /// اتخاذ قرار سريع (مبسط)
  static TradeAction quickDecision({
    required double bayesianProbability,
    required double chaosRiskLevel,
    required double confidence,
  }) {
    // ABORT
    if (chaosRiskLevel > 0.75 || 
        bayesianProbability < 0.50 || 
        confidence < 0.50) {
      return TradeAction.abort;
    }

    // EXECUTE
    if (bayesianProbability >= 0.75 && 
        chaosRiskLevel < 0.35 && 
        confidence >= 0.75) {
      return TradeAction.execute;
    }

    // WAIT
    return TradeAction.wait;
  }

  /// تقييم جودة القرار بعد اتخاذه
  static double evaluateDecisionQuality(TradeDecision decision) {
    double quality = 0.0;

    // 1. Confidence (30%)
    quality += decision.confidence * 0.30;

    // 2. Bayesian Probability (25%)
    quality += decision.bayesianProbability * 0.25;

    // 3. R/R Ratio (20%)
    quality += math.min(decision.riskRewardRatio / 5.0, 1.0) * 0.20;

    // 4. Low Risk (15%)
    quality += (1 - decision.riskLevel) * 0.15;

    // 5. Action Appropriateness (10%)
    final actionScore = decision.shouldExecute ? 1.0 : (decision.shouldWait ? 0.5 : 0.0);
    quality += actionScore * 0.10;

    return quality;
  }

  /// اقتراح تحسينات على القرار
  static List<String> suggestImprovements(TradeDecision decision) {
    final suggestions = <String>[];

    if (decision.shouldAbort) {
      suggestions.add('Wait for better market conditions');
      suggestions.add('Look for clearer signals');
      if (decision.riskLevel > 0.7) {
        suggestions.add('Chaos risk too high - avoid trading until market stabilizes');
      }
    } else if (decision.shouldWait) {
      suggestions.add('Monitor price action near key levels');
      suggestions.add('Wait for confirmation from multiple timeframes');
      if (decision.confidence < 0.65) {
        suggestions.add('Confidence below optimal - wait for stronger signal');
      }
    } else if (decision.shouldExecute) {
      if (decision.positionSize < 0.015) {
        suggestions.add('Consider increasing position size if risk allows');
      }
      suggestions.add('Set alerts at key levels');
      suggestions.add('Plan partial profit-taking strategy');
    }

    return suggestions;
  }
}
