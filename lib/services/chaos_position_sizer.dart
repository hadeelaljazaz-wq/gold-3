// 🎲 Chaos Position Sizer - Dynamic Position Sizing Based on Chaos Risk
// نظام ذكي لحساب حجم الصفقة بناءً على مستوى الفوضى والمخاطر

import 'dart:math' as math;
import '../core/utils/logger.dart';

// ══════════════════════════════════════════════════════════════════
// CHAOS POSITION SIZER
// ══════════════════════════════════════════════════════════════════

class ChaosPositionSizer {
  // إعدادات افتراضية
  static const double _minPositionSize = 0.005; // 0.5% كحد أدنى
  static const double _maxPositionSize = 0.10; // 10% كحد أقصى

  /// حساب حجم الصفقة الديناميكي
  /// 
  /// **المعادلة الأساسية:**
  /// Position Size = Base Size × (1 - Chaos Risk) × Bayesian Probability × Confidence Multiplier
  /// 
  /// **Parameters:**
  /// - [chaosRiskLevel]: مستوى المخاطرة من Chaos Analysis (0-1)
  /// - [bayesianProbability]: احتمال النجاح من Bayesian (0-1)
  /// - [confidence]: مستوى الثقة من ML (0-1)
  /// - [volatility]: التقلب الحالي (0-1)
  /// - [accountBalance]: رصيد الحساب بالدولار
  /// - [riskPercentage]: نسبة المخاطرة المسموح بها (افتراضياً 2%)
  /// 
  /// **Returns:** حجم الصفقة (0.005 - 0.10)
  static PositionSizeResult calculate({
    required double chaosRiskLevel,
    required double bayesianProbability,
    required double confidence,
    required double volatility,
    double accountBalance = 10000.0,
    double riskPercentage = 2.0,
  }) {
    AppLogger.info('🎲 Calculating Dynamic Position Size...');

    // التحقق من المدخلات
    chaosRiskLevel = chaosRiskLevel.clamp(0.0, 1.0);
    bayesianProbability = bayesianProbability.clamp(0.0, 1.0);
    confidence = confidence.clamp(0.0, 1.0);
    volatility = volatility.clamp(0.0, 1.0);

    // ══════════════════════════════════════════════════════════════════
    // STEP 1: حساب Base Position Size
    // ══════════════════════════════════════════════════════════════════
    
    double baseSize = riskPercentage / 100.0;

    // ══════════════════════════════════════════════════════════════════
    // STEP 2: تطبيق Chaos Risk Adjustment
    // ══════════════════════════════════════════════════════════════════
    
    // كلما زاد Chaos Risk، نقلل الحجم
    final chaosAdjustment = 1.0 - chaosRiskLevel;
    final chaosAdjustedSize = baseSize * chaosAdjustment;

    // ══════════════════════════════════════════════════════════════════
    // STEP 3: تطبيق Bayesian Probability Multiplier
    // ══════════════════════════════════════════════════════════════════
    
    // نستخدم دالة تربيعية لتضخيم التأثير
    final bayesianMultiplier = math.pow(bayesianProbability, 0.8).toDouble();
    final bayesianAdjustedSize = chaosAdjustedSize * bayesianMultiplier;

    // ══════════════════════════════════════════════════════════════════
    // STEP 4: تطبيق Confidence Multiplier
    // ══════════════════════════════════════════════════════════════════
    
    final confidenceMultiplier = 0.5 + (confidence * 0.5); // 0.5-1.0
    final confidenceAdjustedSize = bayesianAdjustedSize * confidenceMultiplier;

    // ══════════════════════════════════════════════════════════════════
    // STEP 5: تطبيق Volatility Adjustment
    // ══════════════════════════════════════════════════════════════════
    
    // تقليل الحجم في حالة التقلب العالي
    final volatilityAdjustment = 1.0 - (volatility * 0.3); // تقليل حتى 30%
    final volatilityAdjustedSize = confidenceAdjustedSize * volatilityAdjustment;

    // ══════════════════════════════════════════════════════════════════
    // STEP 6: التحقق من الحدود
    // ══════════════════════════════════════════════════════════════════
    
    final finalSize = volatilityAdjustedSize.clamp(_minPositionSize, _maxPositionSize);

    // ══════════════════════════════════════════════════════════════════
    // STEP 7: حساب Position Size بالدولار واللوت
    // ══════════════════════════════════════════════════════════════════
    
    final positionSizeInDollars = accountBalance * finalSize;
    
    // حساب اللوت (1 lot XAUUSD = $100 per point, 1 standard lot = 100 oz)
    // نفترض أن كل 0.01 lot = $1000
    final lotSize = positionSizeInDollars / 1000.0;

    // ══════════════════════════════════════════════════════════════════
    // STEP 8: تحديد التصنيف
    // ══════════════════════════════════════════════════════════════════
    
    final sizing = _determineSizing(finalSize, chaosRiskLevel, bayesianProbability);

    // ══════════════════════════════════════════════════════════════════
    // STEP 9: جمع الأسباب
    // ══════════════════════════════════════════════════════════════════
    
    final adjustments = <String, double>{
      'chaos_adjustment': chaosAdjustment,
      'bayesian_multiplier': bayesianMultiplier,
      'confidence_multiplier': confidenceMultiplier,
      'volatility_adjustment': volatilityAdjustment,
    };

    final reasons = _generateReasons(
      chaosRiskLevel,
      bayesianProbability,
      confidence,
      volatility,
      adjustments,
    );

    final result = PositionSizeResult(
      positionSizePercent: finalSize,
      positionSizeInDollars: positionSizeInDollars,
      lotSize: lotSize,
      sizing: sizing,
      reasons: reasons,
      adjustments: adjustments,
      metadata: {
        'base_size': baseSize,
        'chaos_risk': chaosRiskLevel,
        'bayesian_probability': bayesianProbability,
        'confidence': confidence,
        'volatility': volatility,
      },
    );

    AppLogger.success(
      '✅ Position Size: ${(finalSize * 100).toStringAsFixed(2)}% '
      '(\$${positionSizeInDollars.toStringAsFixed(2)}, '
      '${lotSize.toStringAsFixed(2)} lots) - ${sizing.name}',
    );

    return result;
  }

  /// حساب Position Size باستخدام Kelly Criterion المعدل
  /// 
  /// **Kelly Criterion:**
  /// Kelly% = (p × b - q) / b
  /// - p = احتمال الربح
  /// - q = احتمال الخسارة (1 - p)
  /// - b = نسبة الربح/الخسارة (R/R ratio)
  /// 
  /// **التعديل:**
  /// نضرب في (1 - Chaos Risk) للأمان
  static PositionSizeResult calculateKellyBased({
    required double bayesianProbability,
    required double riskRewardRatio,
    required double chaosRiskLevel,
    required double confidence,
    double accountBalance = 10000.0,
    bool useHalfKelly = true,
  }) {
    AppLogger.info('🎲 Calculating Kelly-Based Position Size...');

    // Kelly Criterion
    final p = bayesianProbability;
    final q = 1 - p;
    final b = riskRewardRatio;

    double kelly = 0.0;
    if (b > 0) {
      kelly = (p * b - q) / b;
    }

    // استخدام Half Kelly للأمان
    if (useHalfKelly) {
      kelly = kelly / 2;
    }

    // تطبيق Chaos Risk Adjustment
    final chaosAdjustment = 1.0 - chaosRiskLevel;
    kelly = kelly * chaosAdjustment;

    // تطبيق Confidence Adjustment
    final confidenceMultiplier = 0.5 + (confidence * 0.5);
    kelly = kelly * confidenceMultiplier;

    // Clamp
    final finalSize = kelly.clamp(_minPositionSize, _maxPositionSize);

    final positionSizeInDollars = accountBalance * finalSize;
    final lotSize = positionSizeInDollars / 1000.0;

    final sizing = _determineSizing(finalSize, chaosRiskLevel, bayesianProbability);

    return PositionSizeResult(
      positionSizePercent: finalSize,
      positionSizeInDollars: positionSizeInDollars,
      lotSize: lotSize,
      sizing: sizing,
      reasons: [
        'Kelly Criterion: ${(kelly * 100).toStringAsFixed(1)}%',
        'Chaos Adjustment: ${(chaosAdjustment * 100).toStringAsFixed(0)}%',
        'R/R Ratio: 1:${riskRewardRatio.toStringAsFixed(2)}',
      ],
      adjustments: {
        'kelly': kelly,
        'chaos_adjustment': chaosAdjustment,
        'confidence_multiplier': confidenceMultiplier,
      },
      metadata: {
        'method': 'kelly_criterion',
        'half_kelly': useHalfKelly,
      },
    );
  }

  /// تحديد تصنيف الحجم
  static PositionSizing _determineSizing(
    double positionSize,
    double chaosRisk,
    double bayesianProbability,
  ) {
    if (chaosRisk > 0.7) {
      return PositionSizing.micro; // خطر عالي = حجم صغير جداً
    } else if (chaosRisk > 0.5 || bayesianProbability < 0.6) {
      return PositionSizing.conservative; // خطر متوسط
    } else if (positionSize >= 0.04 && bayesianProbability > 0.75) {
      return PositionSizing.aggressive; // فرصة قوية
    } else if (positionSize >= 0.025) {
      return PositionSizing.moderate;
    } else {
      return PositionSizing.conservative;
    }
  }

  /// توليد الأسباب
  static List<String> _generateReasons(
    double chaosRisk,
    double bayesianProbability,
    double confidence,
    double volatility,
    Map<String, double> adjustments,
  ) {
    final reasons = <String>[];

    // Chaos Risk
    if (chaosRisk > 0.7) {
      reasons.add('⚠️ Chaos risk very high: ${(chaosRisk * 100).toStringAsFixed(0)}% - Reduced size significantly');
    } else if (chaosRisk > 0.5) {
      reasons.add('⚡ Chaos risk elevated: ${(chaosRisk * 100).toStringAsFixed(0)}% - Reduced size moderately');
    } else if (chaosRisk < 0.3) {
      reasons.add('✅ Low chaos risk: ${(chaosRisk * 100).toStringAsFixed(0)}% - Size maintained');
    }

    // Bayesian Probability
    if (bayesianProbability > 0.75) {
      reasons.add('🎯 High success probability: ${(bayesianProbability * 100).toStringAsFixed(0)}% - Increased size');
    } else if (bayesianProbability < 0.55) {
      reasons.add('⚠️ Low success probability: ${(bayesianProbability * 100).toStringAsFixed(0)}% - Reduced size');
    }

    // Confidence
    if (confidence > 0.8) {
      reasons.add('💪 High confidence: ${(confidence * 100).toStringAsFixed(0)}%');
    } else if (confidence < 0.6) {
      reasons.add('⚡ Moderate confidence: ${(confidence * 100).toStringAsFixed(0)}% - Size reduced');
    }

    // Volatility
    if (volatility > 0.7) {
      reasons.add('📊 High volatility: ${(volatility * 100).toStringAsFixed(0)}% - Size reduced');
    }

    // Adjustments summary
    final totalAdjustment = adjustments.values.reduce((a, b) => a * b);
    if (totalAdjustment < 0.5) {
      reasons.add('📉 Multiple risk factors detected - Conservative sizing applied');
    } else if (totalAdjustment > 1.2) {
      reasons.add('📈 Favorable conditions - Increased sizing applied');
    }

    return reasons;
  }

  /// حساب Stop Loss بناءً على Position Size والمخاطر
  static double calculateStopLoss({
    required double accountBalance,
    required double positionSizePercent,
    required double entryPrice,
    required bool isBuy,
    required double atr,
  }) {
    // حساب المسافة بالنقاط بناءً على ATR
    final slDistance = atr * 2.0; // 2× ATR

    // حساب Stop Loss
    if (isBuy) {
      return entryPrice - slDistance;
    } else {
      return entryPrice + slDistance;
    }
  }

  /// حساب Take Profit بناءً على R/R Ratio
  static double calculateTakeProfit({
    required double entryPrice,
    required double stopLoss,
    required double riskRewardRatio,
    required bool isBuy,
  }) {
    final slDistance = (entryPrice - stopLoss).abs();
    final tpDistance = slDistance * riskRewardRatio;

    if (isBuy) {
      return entryPrice + tpDistance;
    } else {
      return entryPrice - tpDistance;
    }
  }
}

// ══════════════════════════════════════════════════════════════════
// MODELS
// ══════════════════════════════════════════════════════════════════

/// تصنيف حجم الصفقة
enum PositionSizing {
  micro, // 0.5-1% - خطر عالي جداً
  conservative, // 1-2% - خطر متوسط
  moderate, // 2-4% - طبيعي
  aggressive, // 4-10% - فرصة قوية
}

/// نتيجة حساب Position Size
class PositionSizeResult {
  /// نسبة من رأس المال (0.005 - 0.10)
  final double positionSizePercent;

  /// حجم الصفقة بالدولار
  final double positionSizeInDollars;

  /// حجم اللوت
  final double lotSize;

  /// تصنيف الحجم
  final PositionSizing sizing;

  /// الأسباب
  final List<String> reasons;

  /// التعديلات المطبقة
  final Map<String, double> adjustments;

  /// بيانات إضافية
  final Map<String, dynamic>? metadata;

  const PositionSizeResult({
    required this.positionSizePercent,
    required this.positionSizeInDollars,
    required this.lotSize,
    required this.sizing,
    required this.reasons,
    required this.adjustments,
    this.metadata,
  });

  /// هل الحجم آمن؟
  bool get isSafe => positionSizePercent <= 0.03;

  /// هل الحجم محافظ؟
  bool get isConservative => sizing == PositionSizing.conservative || sizing == PositionSizing.micro;

  /// هل الحجم هجومي؟
  bool get isAggressive => sizing == PositionSizing.aggressive;

  Map<String, dynamic> toJson() {
    return {
      'position_size_percent': positionSizePercent,
      'position_size_dollars': positionSizeInDollars,
      'lot_size': lotSize,
      'sizing': sizing.name,
      'reasons': reasons,
      'adjustments': adjustments,
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'PositionSize('
        '${(positionSizePercent * 100).toStringAsFixed(2)}%, '
        '\$${positionSizeInDollars.toStringAsFixed(2)}, '
        '${lotSize.toStringAsFixed(2)} lots, '
        '${sizing.name}'
        ')';
  }
}
