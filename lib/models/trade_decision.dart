// 🎯 Trade Decision Models - Unified Decision System
// نظام موحد لاتخاذ قرارات التداول عبر جميع المحركات

import 'package:flutter/foundation.dart';

// ══════════════════════════════════════════════════════════════════
// TRADE ACTION ENUM
// ══════════════════════════════════════════════════════════════════

/// قرار التداول النهائي
enum TradeAction {
  /// تنفيذ الصفقة فوراً - ثقة عالية (75%+)
  execute,

  /// الانتظار والمراقبة - ثقة متوسطة (55-75%)
  wait,

  /// إلغاء الصفقة - ثقة منخفضة أو خطر عالي (<55%)
  abort;

  /// الحصول على اللون المناسب
  int get color {
    switch (this) {
      case TradeAction.execute:
        return 0xFF00FF88; // أخضر
      case TradeAction.wait:
        return 0xFFFFAA00; // برتقالي
      case TradeAction.abort:
        return 0xFFFF3366; // أحمر
    }
  }

  /// الحصول على الأيقونة المناسبة
  String get icon {
    switch (this) {
      case TradeAction.execute:
        return '✅';
      case TradeAction.wait:
        return '⏳';
      case TradeAction.abort:
        return '❌';
    }
  }

  /// الحصول على النص العربي
  String get nameAr {
    switch (this) {
      case TradeAction.execute:
        return 'تنفيذ';
      case TradeAction.wait:
        return 'انتظار';
      case TradeAction.abort:
        return 'إلغاء';
    }
  }

  /// الحصول على الوصف
  String get description {
    switch (this) {
      case TradeAction.execute:
        return 'الصفقة قوية - يُنصح بالتنفيذ الفوري';
      case TradeAction.wait:
        return 'الصفقة متوسطة - راقب التطورات';
      case TradeAction.abort:
        return 'الصفقة ضعيفة أو خطرة - تجنب الدخول';
    }
  }
}

// ══════════════════════════════════════════════════════════════════
// TRADE DECISION MODEL
// ══════════════════════════════════════════════════════════════════

/// قرار التداول المتكامل
@immutable
class TradeDecision {
  /// القرار النهائي
  final TradeAction action;

  /// مستوى الثقة (0.0 - 1.0)
  final double confidence;

  /// حجم الصفقة الموصى به (0.0 - 1.0 من رأس المال)
  final double positionSize;

  /// نسبة المخاطرة (0.0 - 1.0)
  final double riskLevel;

  /// احتمال النجاح من Bayesian (0.0 - 1.0)
  final double bayesianProbability;

  /// نسبة الربح/الخسارة
  final double riskRewardRatio;

  /// الأسباب وراء القرار
  final List<String> reasons;

  /// التحذيرات (إن وجدت)
  final List<String> warnings;

  /// البيانات الإضافية
  final Map<String, dynamic>? metadata;

  const TradeDecision({
    required this.action,
    required this.confidence,
    required this.positionSize,
    required this.riskLevel,
    required this.bayesianProbability,
    required this.riskRewardRatio,
    required this.reasons,
    this.warnings = const [],
    this.metadata,
  });

  /// هل يجب التنفيذ؟
  bool get shouldExecute => action == TradeAction.execute;

  /// هل يجب الانتظار؟
  bool get shouldWait => action == TradeAction.wait;

  /// هل يجب الإلغاء؟
  bool get shouldAbort => action == TradeAction.abort;

  /// درجة الجودة الإجمالية (0-10)
  double get qualityScore {
    double score = 0.0;
    score += confidence * 3.0; // 0-3
    score += bayesianProbability * 2.5; // 0-2.5
    score += (1 - riskLevel) * 2.0; // 0-2
    score += (riskRewardRatio / 5) * 2.5; // 0-2.5
    return score.clamp(0.0, 10.0);
  }

  /// نسخ مع تعديلات
  TradeDecision copyWith({
    TradeAction? action,
    double? confidence,
    double? positionSize,
    double? riskLevel,
    double? bayesianProbability,
    double? riskRewardRatio,
    List<String>? reasons,
    List<String>? warnings,
    Map<String, dynamic>? metadata,
  }) {
    return TradeDecision(
      action: action ?? this.action,
      confidence: confidence ?? this.confidence,
      positionSize: positionSize ?? this.positionSize,
      riskLevel: riskLevel ?? this.riskLevel,
      bayesianProbability: bayesianProbability ?? this.bayesianProbability,
      riskRewardRatio: riskRewardRatio ?? this.riskRewardRatio,
      reasons: reasons ?? this.reasons,
      warnings: warnings ?? this.warnings,
      metadata: metadata ?? this.metadata,
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'action': action.name,
      'confidence': confidence,
      'position_size': positionSize,
      'risk_level': riskLevel,
      'bayesian_probability': bayesianProbability,
      'risk_reward_ratio': riskRewardRatio,
      'reasons': reasons,
      'warnings': warnings,
      'quality_score': qualityScore,
      'metadata': metadata,
    };
  }

  /// إنشاء من JSON
  factory TradeDecision.fromJson(Map<String, dynamic> json) {
    return TradeDecision(
      action: TradeAction.values.firstWhere(
        (e) => e.name == json['action'],
        orElse: () => TradeAction.abort,
      ),
      confidence: (json['confidence'] as num).toDouble(),
      positionSize: (json['position_size'] as num).toDouble(),
      riskLevel: (json['risk_level'] as num).toDouble(),
      bayesianProbability: (json['bayesian_probability'] as num).toDouble(),
      riskRewardRatio: (json['risk_reward_ratio'] as num).toDouble(),
      reasons: List<String>.from(json['reasons'] ?? []),
      warnings: List<String>.from(json['warnings'] ?? []),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'TradeDecision('
        'action: ${action.name}, '
        'confidence: ${(confidence * 100).toStringAsFixed(1)}%, '
        'positionSize: ${(positionSize * 100).toStringAsFixed(1)}%, '
        'riskLevel: ${(riskLevel * 100).toStringAsFixed(1)}%, '
        'probability: ${(bayesianProbability * 100).toStringAsFixed(1)}%, '
        'R/R: 1:${riskRewardRatio.toStringAsFixed(2)}, '
        'quality: ${qualityScore.toStringAsFixed(1)}/10'
        ')';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TradeDecision &&
          runtimeType == other.runtimeType &&
          action == other.action &&
          confidence == other.confidence &&
          positionSize == other.positionSize;

  @override
  int get hashCode => action.hashCode ^ confidence.hashCode ^ positionSize.hashCode;
}

// ══════════════════════════════════════════════════════════════════
// DECISION FACTORS
// ══════════════════════════════════════════════════════════════════

/// العوامل المؤثرة في القرار
@immutable
class DecisionFactors {
  /// قوة الاتجاه (-1 إلى 1)
  final double trendStrength;

  /// التقلب (0 إلى 1)
  final double volatility;

  /// الزخم (-1 إلى 1)
  final double momentum;

  /// مستوى الفوضى (0 إلى 1)
  final double chaosLevel;

  /// قوة الإشارة (0 إلى 1)
  final double signalStrength;

  /// توافق الأطر الزمنية (0 إلى 1)
  final double timeframeAlignment;

  /// حجم التداول (0 إلى 1)
  final double volumeProfile;

  /// موقع السعر من الدعم/المقاومة (0 إلى 1)
  final double structureQuality;

  const DecisionFactors({
    required this.trendStrength,
    required this.volatility,
    required this.momentum,
    required this.chaosLevel,
    required this.signalStrength,
    required this.timeframeAlignment,
    required this.volumeProfile,
    required this.structureQuality,
  });

  /// الدرجة الإجمالية (0-1)
  double get overallScore {
    return (
      trendStrength.abs() * 0.15 +
      (1 - volatility) * 0.10 +
      momentum.abs() * 0.15 +
      (1 - chaosLevel) * 0.15 +
      signalStrength * 0.20 +
      timeframeAlignment * 0.15 +
      volumeProfile * 0.05 +
      structureQuality * 0.05
    ).clamp(0.0, 1.0);
  }

  /// هل البيئة مواتية؟
  bool get isFavorable => overallScore > 0.65;

  /// هل البيئة محايدة؟
  bool get isNeutral => overallScore >= 0.45 && overallScore <= 0.65;

  /// هل البيئة غير مواتية؟
  bool get isUnfavorable => overallScore < 0.45;

  Map<String, dynamic> toJson() {
    return {
      'trend_strength': trendStrength,
      'volatility': volatility,
      'momentum': momentum,
      'chaos_level': chaosLevel,
      'signal_strength': signalStrength,
      'timeframe_alignment': timeframeAlignment,
      'volume_profile': volumeProfile,
      'structure_quality': structureQuality,
      'overall_score': overallScore,
    };
  }
}
