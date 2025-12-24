// 🔥 KABOUS MASTER SIGNAL ENGINE 🔥
// المحرك المركزي الموحد لاستخراج توصية نهائية واحدة
// يدمج 4 أنظمة: Quantum + NEXUS + Royal + Golden Nightmare
// Zero Noise | One Decision | Maximum Clarity
// 🤖 Enhanced with ML Confidence Predictor

import '../models/candle.dart';
import '../models/market_models.dart';
import '../core/utils/logger.dart';
import 'golden_nightmare/golden_nightmare_engine.dart';
import 'quantum_scalping/quantum_scalping_engine.dart';
import 'engines/scalping_engine_v2.dart';
import 'engines/swing_engine_v2.dart';
import 'ml_confidence_predictor.dart';

/// نموذج التوصية النهائية للسكالب
class KabousMasterScalpSignal {
  final String direction; // BUY or SELL
  final double entry;
  final double target;
  final double stopLoss;
  final double confidence; // 0-100
  final String reason;
  final double riskRewardRatio;
  final String? stopActivation;

  KabousMasterScalpSignal({
    required this.direction,
    required this.entry,
    required this.target,
    required this.stopLoss,
    required this.confidence,
    required this.reason,
    required this.riskRewardRatio,
    this.stopActivation,
  });

  Map<String, dynamic> toJson() => {
        'direction': direction,
        'entry': entry,
        'target': target,
        'stopLoss': stopLoss,
        'confidence': confidence,
        'reason': reason,
        'riskRewardRatio': riskRewardRatio,
        'stopActivation': stopActivation,
      };
}

/// نموذج التوصية النهائية للسوينغ
class KabousMasterSwingSignal {
  final String direction; // BUY or SELL
  final double entry;
  final double target1;
  final double target2;
  final double stopLoss;
  final double confidence; // 0-100
  final String reason;
  final double riskRewardRatio;

  KabousMasterSwingSignal({
    required this.direction,
    required this.entry,
    required this.target1,
    required this.target2,
    required this.stopLoss,
    required this.confidence,
    required this.reason,
    required this.riskRewardRatio,
  });

  Map<String, dynamic> toJson() => {
        'direction': direction,
        'entry': entry,
        'target1': target1,
        'target2': target2,
        'stopLoss': stopLoss,
        'confidence': confidence,
        'reason': reason,
        'riskRewardRatio': riskRewardRatio,
      };
}

/// مستويات الدعم والمقاومة
class SupportResistanceLevels {
  final List<double> supports; // أقرب 3 دعوم
  final List<double> resistances; // أقرب 3 مقاومات
  final double currentPrice;

  SupportResistanceLevels({
    required this.supports,
    required this.resistances,
    required this.currentPrice,
  });

  Map<String, dynamic> toJson() => {
        'supports': supports,
        'resistances': resistances,
        'currentPrice': currentPrice,
      };
}

/// نتيجة التحليل الشاملة
class KabousMasterAnalysis {
  final KabousMasterScalpSignal scalping;
  final KabousMasterSwingSignal swing;
  final SupportResistanceLevels levels;
  final DateTime timestamp;
  final int analysisTimeMs;

  KabousMasterAnalysis({
    required this.scalping,
    required this.swing,
    required this.levels,
    required this.timestamp,
    required this.analysisTimeMs,
  });

  Map<String, dynamic> toJson() => {
        'scalping': scalping.toJson(),
        'swing': swing.toJson(),
        'levels': levels.toJson(),
        'timestamp': timestamp.toIso8601String(),
        'analysisTimeMs': analysisTimeMs,
      };
}

/// 🔥 KABOUS MASTER SIGNAL ENGINE
///
/// المحرك المركزي الموحد المسؤول عن:
/// 1. جمع إشارات الأنظمة الأربعة
/// 2. تطبيع البيانات
/// 3. الترجيح والدمج
/// 4. حل التعارضات
/// 5. محرك التقاء الإشارات
/// 6. فلتر المخاطرة
/// 7. إصدار توصية نهائية واحدة
class KabousMasterEngine {
  // أوزان الأنظمة (المجموع = 100%)
  static const double _goldenNightmareWeight = 0.47; // 47%
  static const double _quantumWeight = 0.29; // 29%
  static const double _royalWeight = 0.24; // 24%
  // static const double _nexusWeight = 0.00; // 0% (غير مستخدم حالياً) - Reserved for future use

  // حدود القرار
  static const double _buyThreshold = 60.0;
  static const double _sellThreshold = 40.0;

  /// تحليل شامل وإصدار توصية نهائية واحدة
  ///
  /// Parameters:
  /// - [currentPrice]: السعر الحالي للذهب
  /// - [candles]: بيانات الشموع التاريخية
  /// - [indicators]: المؤشرات الفنية
  ///
  /// Returns: [KabousMasterAnalysis] يحتوي على توصية سكالب وسوينغ
  static Future<KabousMasterAnalysis> analyze({
    required double currentPrice,
    required List<Candle> candles,
    required TechnicalIndicators indicators,
  }) async {
    final startTime = DateTime.now();
    AppLogger.info('🔥 KABOUS MASTER ENGINE - بدء التحليل الشامل');

    try {
      // ==========================================
      // PHASE 0: 🤖 ML Feature Extraction
      // ==========================================
      final mlFeatures = MLConfidencePredictor.extractFeatures(
        currentPrice: currentPrice,
        indicators: indicators,
        currentTime: DateTime.now(),
      );

      // ==========================================
      // PHASE 1: جمع الإشارات من الأنظمة الأربعة
      // ==========================================
      final systemSignals = await _collectSystemSignals(
        currentPrice: currentPrice,
        candles: candles,
        indicators: indicators,
      );

      // ==========================================
      // PHASE 2: تطبيع وترجيح الإشارات
      // ==========================================
      final normalizedSignals = _normalizeSignals(systemSignals);

      // ==========================================
      // PHASE 3: حل التعارضات والدمج
      // ==========================================
      final resolvedSignals = _resolveConflicts(normalizedSignals);

      // ==========================================
      // PHASE 4: محرك التقاء الإشارات (Confluence)
      // ==========================================
      final confluenceData = _calculateConfluence(
        currentPrice: currentPrice,
        candles: candles,
        indicators: indicators,
        resolvedSignals: resolvedSignals,
      );

      // ==========================================
      // PHASE 5: 🤖 ML-Enhanced Signal Generation
      // ==========================================
      final mlWeights = MLConfidencePredictor.predictWeights(mlFeatures);

      final scalpSignal = _generateScalpSignalML(
        currentPrice: currentPrice,
        confluenceData: confluenceData,
        resolvedSignals: resolvedSignals,
        indicators: indicators,
        mlFeatures: mlFeatures,
        mlWeights: mlWeights,
      );

      final swingSignal = _generateSwingSignalML(
        currentPrice: currentPrice,
        confluenceData: confluenceData,
        resolvedSignals: resolvedSignals,
        indicators: indicators,
        mlFeatures: mlFeatures,
        mlWeights: mlWeights,
      );

      // ==========================================
      // PHASE 6: حساب الدعوم والمقاومات القريبة
      // ==========================================
      final levels = _calculateSupportResistance(
        currentPrice: currentPrice,
        candles: candles,
        indicators: indicators,
      );

      final endTime = DateTime.now();
      final analysisTime = endTime.difference(startTime).inMilliseconds;

      AppLogger.success(
        '✅ KABOUS MASTER - اكتمل التحليل في ${analysisTime}ms',
      );

      return KabousMasterAnalysis(
        scalping: scalpSignal,
        swing: swingSignal,
        levels: levels,
        timestamp: DateTime.now(),
        analysisTimeMs: analysisTime,
      );
    } catch (e, stackTrace) {
      AppLogger.error('❌ KABOUS MASTER - فشل التحليل', e, stackTrace);
      rethrow;
    }
  }

  /// جمع الإشارات من جميع الأنظمة
  static Future<Map<String, dynamic>> _collectSystemSignals({
    required double currentPrice,
    required List<Candle> candles,
    required TechnicalIndicators indicators,
  }) async {
    AppLogger.info('📊 جمع الإشارات من الأنظمة الأربعة...');

    // 1. Golden Nightmare Engine
    final goldenNightmareResult = await GoldenNightmareEngine.generate(
      currentPrice: currentPrice,
      candles: candles,
      rsi: indicators.rsi,
      macd: indicators.macd,
      macdSignal: indicators.macdSignal,
      ma20: indicators.ma20,
      ma50: indicators.ma50,
      ma100: indicators.ma100,
      ma200: indicators.ma200,
      atr: indicators.atr,
    );

    // 2. Quantum Scalping Engine
    final quantumResult = await QuantumScalpingEngine.analyze(
      goldCandles: candles,
    );

    // 3. Royal Engine (ScalpingV2 + SwingV2)
    final scalpingV2 = await ScalpingEngineV2.analyze(
      currentPrice: currentPrice,
      candles: candles,
      rsi: indicators.rsi,
      macd: indicators.macd,
      macdSignal: indicators.macdSignal,
      atr: indicators.atr,
    );

    final swingV2 = await SwingEngineV2.analyze(
      currentPrice: currentPrice,
      candles: candles,
      rsi: indicators.rsi,
      macd: indicators.macd,
      macdSignal: indicators.macdSignal,
      ma20: indicators.ma20,
      ma50: indicators.ma50,
      ma100: indicators.ma100,
      ma200: indicators.ma200,
      atr: indicators.atr,
    );

    return {
      'goldenNightmare': goldenNightmareResult,
      'quantum': quantumResult,
      'scalpingV2': scalpingV2,
      'swingV2': swingV2,
      'currentPrice': currentPrice,
    };
  }

  /// تحويل آمن لأي قيمة إلى double
  static double _safeToDouble(dynamic value, double fallback) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? fallback;
    }
    return fallback;
  }

  /// تطبيع الإشارات إلى مقياس موحد (0-100)
  static Map<String, dynamic> _normalizeSignals(
    Map<String, dynamic> systemSignals,
  ) {
    AppLogger.info('⚖️ تطبيع الإشارات...');

    // استخراج الاتجاهات والثقة من كل نظام
    final goldenNightmare = systemSignals['goldenNightmare'];
    final quantum = systemSignals['quantum'] as QuantumSignal;
    final scalpingV2 = systemSignals['scalpingV2'];
    final swingV2 = systemSignals['swingV2'];
    final currentPrice = systemSignals['currentPrice'] as double;

    // Golden Nightmare
    final gnScalpDirection =
        goldenNightmare['SCALP']['direction'] == 'BUY' ? 1.0 : -1.0;
    final gnScalpConfidence =
        (goldenNightmare['SCALP']['confidence'] as num).toDouble();
    final gnSwingDirection =
        goldenNightmare['SWING']['direction'] == 'BUY' ? 1.0 : -1.0;
    final gnSwingConfidence =
        (goldenNightmare['SWING']['confidence'] as num).toDouble();

    // Quantum
    final quantumDirection = quantum.direction.name == 'buy' ? 1.0 : -1.0;
    final quantumConfidence = quantum.quantumScore * 10.0; // 0-10 -> 0-100

    // Royal Scalping V2
    final scalpV2Direction = scalpingV2.direction == 'BUY' ? 1.0 : -1.0;
    final scalpV2Confidence = scalpingV2.confidence.toDouble();

    // Royal Swing V2
    final swingV2Direction = swingV2.direction == 'BUY' ? 1.0 : -1.0;
    final swingV2Confidence = swingV2.confidence.toDouble();

    return {
      'scalp': {
        'goldenNightmare': {
          'direction': gnScalpDirection,
          'confidence': gnScalpConfidence,
          'entry':
              _safeToDouble(goldenNightmare['SCALP']['entry'], currentPrice),
          'target': _safeToDouble(
              goldenNightmare['SCALP']['takeProfit'] ??
                  goldenNightmare['SCALP']['entry'],
              currentPrice),
          'stopLoss':
              _safeToDouble(goldenNightmare['SCALP']['stopLoss'], currentPrice),
        },
        'quantum': {
          'direction': quantumDirection,
          'confidence': quantumConfidence,
          'entry': _safeToDouble(quantum.entry, currentPrice),
          'target': _safeToDouble(quantum.takeProfit, currentPrice),
          'stopLoss': _safeToDouble(quantum.stopLoss, currentPrice),
        },
        'scalpingV2': {
          'direction': scalpV2Direction,
          'confidence': scalpV2Confidence,
          'entry': _safeToDouble(
              scalpingV2.entryPrice ?? currentPrice, currentPrice),
          'target': _safeToDouble(
              scalpingV2.takeProfit ?? currentPrice, currentPrice),
          'stopLoss':
              _safeToDouble(scalpingV2.stopLoss ?? currentPrice, currentPrice),
        },
      },
      'swing': {
        'goldenNightmare': {
          'direction': gnSwingDirection,
          'confidence': gnSwingConfidence,
          'entry':
              _safeToDouble(goldenNightmare['SWING']['entry'], currentPrice),
          'target': _safeToDouble(
              goldenNightmare['SWING']['takeProfit'] ??
                  goldenNightmare['SWING']['entry'],
              currentPrice),
          'stopLoss':
              _safeToDouble(goldenNightmare['SWING']['stopLoss'], currentPrice),
        },
        'swingV2': {
          'direction': swingV2Direction,
          'confidence': swingV2Confidence,
          'entry':
              _safeToDouble(swingV2.entryPrice ?? currentPrice, currentPrice),
          'targets': swingV2.takeProfit != null
              ? [_safeToDouble(swingV2.takeProfit, currentPrice)]
              : [currentPrice],
          'stopLoss':
              _safeToDouble(swingV2.stopLoss ?? currentPrice, currentPrice),
        },
      },
    };
  }

  /// حل التعارضات بين الأنظمة
  static Map<String, dynamic> _resolveConflicts(
    Map<String, dynamic> normalizedSignals,
  ) {
    AppLogger.info('🔧 حل التعارضات...');

    // ===== SCALP =====
    final scalpSignals = normalizedSignals['scalp'];

    // حساب الاتجاه الموزون للسكالب
    final scalpWeightedDirection = (scalpSignals['goldenNightmare']
                ['direction'] *
            _goldenNightmareWeight) +
        (scalpSignals['quantum']['direction'] * _quantumWeight) +
        (scalpSignals['scalpingV2']['direction'] * _royalWeight);

    // حساب الثقة الموزونة للسكالب
    final scalpWeightedConfidence = (scalpSignals['goldenNightmare']
                ['confidence'] *
            _goldenNightmareWeight) +
        (scalpSignals['quantum']['confidence'] * _quantumWeight) +
        (scalpSignals['scalpingV2']['confidence'] * _royalWeight);

    // تحويل الاتجاه الموزون إلى نسبة مئوية (0-100)
    final scalpDirectionScore = ((scalpWeightedDirection + 1.0) / 2.0) * 100.0;

    // تحديد الاتجاه النهائي للسكالب
    String scalpFinalDirection;
    if (scalpDirectionScore >= _buyThreshold) {
      scalpFinalDirection = 'BUY';
    } else if (scalpDirectionScore <= _sellThreshold) {
      scalpFinalDirection = 'SELL';
    } else {
      // منطقة محايدة - استخدام أعلى ثقة
      final maxConfidenceSystem = [
        {
          'name': 'goldenNightmare',
          'confidence': scalpSignals['goldenNightmare']['confidence']
        },
        {
          'name': 'quantum',
          'confidence': scalpSignals['quantum']['confidence']
        },
        {
          'name': 'scalpingV2',
          'confidence': scalpSignals['scalpingV2']['confidence']
        },
      ].reduce((a, b) =>
          (a['confidence'] as double) > (b['confidence'] as double) ? a : b);

      final selectedDirection =
          scalpSignals[maxConfidenceSystem['name']]['direction'];
      scalpFinalDirection = (selectedDirection is String)
          ? selectedDirection
          : ((selectedDirection as double) > 0 ? 'BUY' : 'SELL');
    }

    // ===== SWING =====
    final swingSignals = normalizedSignals['swing'];

    // حساب الاتجاه الموزون للسوينغ
    final swingWeightedDirection = (swingSignals['goldenNightmare']
                ['direction'] *
            _goldenNightmareWeight) +
        (swingSignals['swingV2']['direction'] * _royalWeight);

    // حساب الثقة الموزونة للسوينغ
    final swingWeightedConfidence = (swingSignals['goldenNightmare']
                ['confidence'] *
            _goldenNightmareWeight) +
        (swingSignals['swingV2']['confidence'] * _royalWeight);

    // تحويل الاتجاه الموزون إلى نسبة مئوية
    final swingDirectionScore = ((swingWeightedDirection + 1.0) / 2.0) * 100.0;

    // تحديد الاتجاه النهائي للسوينغ
    String swingFinalDirection;
    if (swingDirectionScore >= _buyThreshold) {
      swingFinalDirection = 'BUY';
    } else if (swingDirectionScore <= _sellThreshold) {
      swingFinalDirection = 'SELL';
    } else {
      // منطقة محايدة - استخدام أعلى ثقة
      final maxConfidenceSystem = [
        {
          'name': 'goldenNightmare',
          'confidence': swingSignals['goldenNightmare']['confidence']
        },
        {
          'name': 'swingV2',
          'confidence': swingSignals['swingV2']['confidence']
        },
      ].reduce((a, b) =>
          (a['confidence'] as double) > (b['confidence'] as double) ? a : b);

      final selectedDirection =
          swingSignals[maxConfidenceSystem['name']]['direction'];
      swingFinalDirection = (selectedDirection is String)
          ? selectedDirection
          : ((selectedDirection as double) > 0 ? 'BUY' : 'SELL');
    }

    return {
      'scalp': {
        'direction': scalpFinalDirection,
        'confidence': scalpWeightedConfidence.clamp(0.0, 100.0),
        'directionScore': scalpDirectionScore,
        'systems': scalpSignals,
      },
      'swing': {
        'direction': swingFinalDirection,
        'confidence': swingWeightedConfidence.clamp(0.0, 100.0),
        'directionScore': swingDirectionScore,
        'systems': swingSignals,
      },
    };
  }

  /// حساب التقاء الإشارات (Confluence)
  static Map<String, dynamic> _calculateConfluence({
    required double currentPrice,
    required List<Candle> candles,
    required TechnicalIndicators indicators,
    required Map<String, dynamic> resolvedSignals,
  }) {
    AppLogger.info('🎯 حساب التقاء الإشارات...');

    // تحليل RSI
    final rsiOverbought = indicators.rsi > 70;
    final rsiOversold = indicators.rsi < 30;
    final rsiNeutral = !rsiOverbought && !rsiOversold;

    // تحليل MACD
    final macdBullish = indicators.macd > indicators.macdSignal;
    final macdBearish = indicators.macd < indicators.macdSignal;

    // تحليل الترند (MA Alignment)
    final bullishTrend = indicators.ma20 > indicators.ma50 &&
        indicators.ma50 > indicators.ma100 &&
        indicators.ma100 > indicators.ma200;
    final bearishTrend = indicators.ma20 < indicators.ma50 &&
        indicators.ma50 < indicators.ma100 &&
        indicators.ma100 < indicators.ma200;

    // تحليل الزخم
    final momentum = _calculateMomentum(candles);
    final strongBullishMomentum = momentum > 0.6;
    final strongBearishMomentum = momentum < -0.6;

    // تحليل التقلب
    final volatility = indicators.atr / currentPrice * 100.0;

    // حساب نقاط التقاء للسكالب
    final scalpDirection = resolvedSignals['scalp']['direction'];
    int scalpConfluenceScore = 0;

    if (scalpDirection == 'BUY') {
      if (rsiOversold || rsiNeutral) scalpConfluenceScore++;
      if (macdBullish) scalpConfluenceScore++;
      if (bullishTrend) scalpConfluenceScore++;
      if (strongBullishMomentum) scalpConfluenceScore++;
      if (currentPrice < indicators.ma20) scalpConfluenceScore++; // دعم
    } else {
      if (rsiOverbought || rsiNeutral) scalpConfluenceScore++;
      if (macdBearish) scalpConfluenceScore++;
      if (bearishTrend) scalpConfluenceScore++;
      if (strongBearishMomentum) scalpConfluenceScore++;
      if (currentPrice > indicators.ma20) scalpConfluenceScore++; // مقاومة
    }

    // حساب نقاط التقاء للسوينغ
    final swingDirection = resolvedSignals['swing']['direction'];
    int swingConfluenceScore = 0;

    if (swingDirection == 'BUY') {
      if (rsiOversold || rsiNeutral) swingConfluenceScore++;
      if (macdBullish) swingConfluenceScore++;
      if (bullishTrend) swingConfluenceScore += 2; // وزن أعلى للترند
      if (strongBullishMomentum) swingConfluenceScore++;
      if (currentPrice < indicators.ma50) swingConfluenceScore++; // دعم قوي
    } else {
      if (rsiOverbought || rsiNeutral) swingConfluenceScore++;
      if (macdBearish) swingConfluenceScore++;
      if (bearishTrend) swingConfluenceScore += 2;
      if (strongBearishMomentum) swingConfluenceScore++;
      if (currentPrice > indicators.ma50) swingConfluenceScore++; // مقاومة قوية
    }

    return {
      'scalp': {
        'confluenceScore': scalpConfluenceScore,
        'maxScore': 5,
        'rsi': indicators.rsi,
        'macdBullish': macdBullish,
        'trend': bullishTrend
            ? 'BULLISH'
            : bearishTrend
                ? 'BEARISH'
                : 'NEUTRAL',
        'momentum': momentum,
        'volatility': volatility,
      },
      'swing': {
        'confluenceScore': swingConfluenceScore,
        'maxScore': 6,
        'rsi': indicators.rsi,
        'macdBullish': macdBullish,
        'trend': bullishTrend
            ? 'BULLISH'
            : bearishTrend
                ? 'BEARISH'
                : 'NEUTRAL',
        'momentum': momentum,
        'volatility': volatility,
      },
    };
  }

  /// حساب Stop Loss ديناميكي بناءً على التقلب والترند
  static double _calculateDynamicStopLoss({
    required double entry,
    required String direction,
    required double atr,
    required double currentPrice,
    required double volatility,
    required String trendStrength,
    required bool isScalp, // ✅ NEW: تحديد نوع التداول
  }) {
    // 🎯 SCALP: ستوب ضيق جداً (15-35 نقطة للذهب)
    // 🎯 SWING: ستوب أوسع (50-150 نقطة)

    double baseMultiplier;
    if (isScalp) {
      // Scalp: 0.6 - 1.0 × ATR (حد أقصى 35 نقطة للذهب)
      baseMultiplier = 0.7; // بدل 1.5
    } else {
      // Swing: 1.5 - 2.5 × ATR
      baseMultiplier = 2.0;
    }

    // معامل التقلب (للسكالب: نقلل التأثير)
    double volatilityMultiplier = 1.0;
    if (isScalp) {
      // Scalp: تقليل التأثير لمنع ستوب واسع
      if (volatility > 2.0) {
        volatilityMultiplier = 1.1; // بدل 1.5
      } else if (volatility > 1.5) {
        volatilityMultiplier = 1.05; // بدل 1.3
      } else if (volatility < 0.5) {
        volatilityMultiplier = 0.8;
      }
    } else {
      // Swing: نفس القديم
      if (volatility > 2.0) {
        volatilityMultiplier = 1.5;
      } else if (volatility > 1.5) {
        volatilityMultiplier = 1.3;
      } else if (volatility < 0.5) {
        volatilityMultiplier = 0.7;
      }
    }

    // معامل قوة الترند (للسكالب: نلغيه!)
    double trendMultiplier = 1.0;
    if (!isScalp) {
      // فقط للـ Swing
      if (trendStrength == 'BULLISH' || trendStrength == 'BEARISH') {
        trendMultiplier = 1.2;
      }
    }

    // حساب الستوب الديناميكي
    final stopDistance =
        atr * baseMultiplier * volatilityMultiplier * trendMultiplier;

    // 🔒 SAFETY: حد أقصى للستوب
    final maxStopForScalp = isScalp ? (atr * 1.2) : double.infinity;
    final minStopForScalp = isScalp ? (atr * 0.5) : 0.0;

    final safeStopDistance =
        stopDistance.clamp(minStopForScalp, maxStopForScalp);

    if (direction == 'BUY') {
      return entry - safeStopDistance;
    } else {
      return entry + safeStopDistance;
    }
  }

  /// حساب Target ديناميكي بناءً على الزخم والتقلب
  static double _calculateDynamicTarget({
    required double entry,
    required String direction,
    required double atr,
    required double momentum,
    required double volatility,
    required int confluenceScore,
    required int maxConfluenceScore,
    required bool isScalp, // ✅ NEW
  }) {
    // 🎯 SCALP: هدف واقعي (20-60 نقطة للذهب)
    // 🎯 SWING: هدف أبعد (80-200 نقطة)

    double baseMultiplier;
    if (isScalp) {
      // Scalp: 1.2 - 2.0 × ATR (R:R = 1.5:1 to 2:1)
      baseMultiplier = 1.5; // بدل 2.0
    } else {
      // Swing: 3.0 - 5.0 × ATR
      baseMultiplier = 3.5;
    }

    // زيادة الهدف بناءً على الزخم (للسكالب: حذر!)
    if (isScalp) {
      // Scalp: زيادات صغيرة
      if (momentum > 0.7) {
        baseMultiplier += 0.3; // بدل 0.5
      } else if (momentum > 0.5) {
        baseMultiplier += 0.2; // بدل 0.3
      }
    } else {
      // Swing: نفس القديم
      if (momentum > 0.7) {
        baseMultiplier += 0.5;
      } else if (momentum > 0.5) {
        baseMultiplier += 0.3;
      }
    }

    // زيادة الهدف بناءً على التقاء الإشارات
    final confluenceRatio = confluenceScore / maxConfluenceScore;
    if (isScalp) {
      // Scalp: زيادات محدودة
      if (confluenceRatio > 0.8) {
        baseMultiplier += 0.25; // بدل 0.4
      } else if (confluenceRatio > 0.6) {
        baseMultiplier += 0.15; // بدل 0.2
      }
    } else {
      // Swing: نفس القديم
      if (confluenceRatio > 0.8) {
        baseMultiplier += 0.4;
      } else if (confluenceRatio > 0.6) {
        baseMultiplier += 0.2;
      }
    }

    // تقليل الهدف في التقلب العالي
    if (volatility > 2.5) {
      baseMultiplier *= 0.85;
    }

    final targetDistance = atr * baseMultiplier;

    // 🔒 SAFETY: حد أقصى/أدنى للهدف
    final maxTargetForScalp = isScalp ? (atr * 2.5) : double.infinity;
    final minTargetForScalp = isScalp ? (atr * 1.0) : 0.0;

    final safeTargetDistance =
        targetDistance.clamp(minTargetForScalp, maxTargetForScalp);

    if (direction == 'BUY') {
      return entry + safeTargetDistance;
    } else {
      return entry - safeTargetDistance;
    }
  }

  /// تحسين الثقة بناءً على عوامل السوق الحقيقية + فحص اتجاه السعر الفعلي
  static double _calculateRealisticConfidence({
    required double baseConfidence,
    required int confluenceScore,
    required int maxConfluenceScore,
    required double volatility,
    required double momentum,
    required double rsi,
    required String trendStrength,
    required double rrRatio,
    required String direction, // ✅ NEW: اتجاه الإشارة
    required double currentPrice, // ✅ NEW
    required TechnicalIndicators indicators, // ✅ NEW
  }) {
    double finalConfidence = baseConfidence;

    // 🔥 CRITICAL: فحص توافق الإشارة مع حركة السعر الفعلية
    // إذا الإشارة BUY لكن السعر نازل → عقوبة شديدة!
    // إذا الإشارة SELL لكن السعر طالع → عقوبة شديدة!
    final priceVsMA20 =
        ((currentPrice - indicators.ma20) / indicators.ma20) * 100;
    final priceVsMA50 =
        ((currentPrice - indicators.ma50) / indicators.ma50) * 100;

    if (direction == 'BUY') {
      // إشارة شراء
      if (priceVsMA20 < -0.5 && priceVsMA50 < -1.0) {
        // السعر أقل بكثير من المتوسطات (جيد للشراء)
        finalConfidence += 10.0;
      } else if (priceVsMA20 > 0.5 && priceVsMA50 > 1.0) {
        // السعر أعلى بكثير من المتوسطات (سيء للشراء - متأخر!)
        finalConfidence -= 20.0; // عقوبة شديدة
      }

      // فحص الزخم السلبي مع إشارة شراء
      if (momentum < -0.3) {
        finalConfidence -= 15.0; // الزخم عكس الإشارة!
      }
    } else if (direction == 'SELL') {
      // إشارة بيع
      if (priceVsMA20 > 0.5 && priceVsMA50 > 1.0) {
        // السعر أعلى بكثير من المتوسطات (جيد للبيع)
        finalConfidence += 10.0;
      } else if (priceVsMA20 < -0.5 && priceVsMA50 < -1.0) {
        // السعر أقل بكثير من المتوسطات (سيء للبيع - متأخر!)
        finalConfidence -= 20.0; // عقوبة شديدة
      }

      // فحص الزخم الإيجابي مع إشارة بيع
      if (momentum > 0.3) {
        finalConfidence -= 15.0; // الزخم عكس الإشارة!
      }
    }

    // 1. مكافأة التقاء الإشارات (أقصى +15%)
    final confluenceBonus = (confluenceScore / maxConfluenceScore) * 15.0;
    finalConfidence += confluenceBonus;

    // 2. عقوبة التقلب العالي (-10% للتقلب الشديد)
    if (volatility > 2.5) {
      finalConfidence -= 10.0;
    } else if (volatility > 2.0) {
      finalConfidence -= 5.0;
    }

    // 3. مكافأة الزخم القوي (+8% للزخم الممتاز)
    if (momentum.abs() > 0.7) {
      finalConfidence += 8.0;
    } else if (momentum.abs() > 0.5) {
      finalConfidence += 4.0;
    } else if (momentum.abs() < 0.2) {
      finalConfidence -= 5.0; // عقوبة للزخم الضعيف
    }

    // 4. تقييم RSI (عقوبة لـ Overbought/Oversold الشديد)
    if (rsi > 80 || rsi < 20) {
      finalConfidence -= 8.0; // منطقة خطرة جداً
    } else if (rsi > 70 || rsi < 30) {
      finalConfidence -= 3.0; // منطقة خطرة
    }

    // 5. مكافأة الترند القوي (+6%)
    if (trendStrength == 'BULLISH' || trendStrength == 'BEARISH') {
      finalConfidence += 6.0;
    } else if (trendStrength == 'NEUTRAL') {
      finalConfidence -= 4.0; // عقوبة للسوق الجانبي
    }

    // 6. مكافأة/عقوبة Risk/Reward
    if (rrRatio >= 2.0) {
      finalConfidence += 5.0; // R:R ممتاز
    } else if (rrRatio < 1.0) {
      finalConfidence -= 10.0; // R:R سيء
    }

    // 🔒 SAFETY: إذا الثقة نزلت تحت 40% → إلغاء الإشارة تماماً!
    if (finalConfidence < 40.0) {
      return 15.0; // إشارة ضعيفة جداً
    }

    // تطبيع النتيجة النهائية
    return finalConfidence.clamp(15.0, 95.0); // لا توجد ثقة 100% في الأسواق!
  }

  /// توليد إشارة السكالب النهائية
  static KabousMasterScalpSignal _generateScalpSignal({
    required double currentPrice,
    required Map<String, dynamic> confluenceData,
    required Map<String, dynamic> resolvedSignals,
    required TechnicalIndicators indicators,
  }) {
    AppLogger.info('⚡ توليد إشارة السكالب النهائية...');

    final scalpData = resolvedSignals['scalp'];
    final direction = scalpData['direction'] as String;
    final baseConfidence = scalpData['confidence'] as double;
    final confluenceScore = confluenceData['scalp']['confluenceScore'] as int;
    final maxConfluenceScore = confluenceData['scalp']['maxScore'] as int;
    final momentum = confluenceData['scalp']['momentum'] as double;
    final volatility = confluenceData['scalp']['volatility'] as double;
    final rsi = confluenceData['scalp']['rsi'] as double;
    final trendStrength = confluenceData['scalp']['trend'] as String;

    // حساب نقاط الدخول من الأنظمة (reserved for future multi-system analysis)
    // final systems = scalpData['systems'] as Map<String, dynamic>;
    // final gnSystem = systems['goldenNightmare'] as Map<String, dynamic>?;
    // final quantumSystem = systems['quantum'] as Map<String, dynamic>?;
    // final scalpV2System = systems['scalpingV2'] as Map<String, dynamic>?;

    // 🆕 استخدام السعر الحقيقي الحالي مباشرة (توصيات حية)
    final entry = currentPrice;

    // 🚀 حساب Stop Loss ديناميكي (بناءً على التقلب والترند)
    final dynamicStopLoss = _calculateDynamicStopLoss(
      entry: entry,
      direction: direction,
      atr: indicators.atr,
      currentPrice: currentPrice,
      volatility: volatility,
      trendStrength: trendStrength,
      isScalp: true, // ✅ SCALP mode
    );

    // 🎯 حساب Target ديناميكي (بناءً على الزخم والتقلب)
    final dynamicTarget = _calculateDynamicTarget(
      entry: entry,
      direction: direction,
      atr: indicators.atr,
      momentum: momentum.abs(),
      volatility: volatility,
      confluenceScore: confluenceScore,
      maxConfluenceScore: maxConfluenceScore,
      isScalp: true, // ✅ SCALP mode
    );

    // حساب Risk/Reward الحقيقي
    final risk = (entry - dynamicStopLoss).abs();
    final reward = (dynamicTarget - entry).abs();
    final rrRatio = risk > 0 ? reward / risk : 1.0;

    // 📊 LOG: عرض المسافات الفعلية
    AppLogger.info('🎯 SCALP $direction | '
        'Stop=${risk.toStringAsFixed(1)} pts | '
        'Target=${reward.toStringAsFixed(1)} pts | '
        'R:R=${rrRatio.toStringAsFixed(2)} | '
        'ATR=${indicators.atr.toStringAsFixed(2)}');

    // 📊 حساب الثقة الواقعية (بناءً على كل عوامل السوق)
    final realisticConfidence = _calculateRealisticConfidence(
      baseConfidence: baseConfidence,
      confluenceScore: confluenceScore,
      maxConfluenceScore: maxConfluenceScore,
      volatility: volatility,
      momentum: momentum,
      rsi: rsi,
      trendStrength: trendStrength,
      rrRatio: rrRatio,
      direction: direction, // ✅ فحص الاتجاه
      currentPrice: currentPrice, // ✅ السعر الحالي
      indicators: indicators, // ✅ المؤشرات
    );

    // بناء السبب المحسّن
    final reason = _buildScalpReason(
      direction: direction,
      confluenceScore: confluenceScore,
      trend: trendStrength,
      rsi: rsi,
      momentum: momentum,
    );

    return KabousMasterScalpSignal(
      direction: direction,
      entry: _roundPrice(entry),
      target: _roundPrice(dynamicTarget),
      stopLoss: _roundPrice(dynamicStopLoss),
      confidence: _roundConfidence(realisticConfidence),
      reason: reason,
      riskRewardRatio: _roundRatio(rrRatio),
      stopActivation:
          direction == 'BUY' ? 'فوق الستوب → بيع' : 'تحت الستوب → شراء',
    );
  }

  /// 🤖 ML-Enhanced Scalp Signal Generation
  static KabousMasterScalpSignal _generateScalpSignalML({
    required double currentPrice,
    required Map<String, dynamic> confluenceData,
    required Map<String, dynamic> resolvedSignals,
    required TechnicalIndicators indicators,
    required MarketFeatures mlFeatures,
    required MLEngineWeights mlWeights,
  }) {
    // Generate base signal
    final baseSignal = _generateScalpSignal(
      currentPrice: currentPrice,
      confluenceData: confluenceData,
      resolvedSignals: resolvedSignals,
      indicators: indicators,
    );

    // 🤖 ML Enhancement: Evaluate signal quality
    final mlAdjustedConfidence = MLConfidencePredictor.evaluateSignalQuality(
      features: mlFeatures,
      direction: baseSignal.direction,
      baseConfidence: baseSignal.confidence,
    );

    // Get ML recommendation
    final mlAction = MLConfidencePredictor.getRecommendedAction(
      mlAdjustedConfidence,
    );

    final signalQuality = mlAdjustedConfidence / baseSignal.confidence;

    // Enhanced reason with ML insight
    final mlReason =
        '${baseSignal.reason}\n🤖 ML: $mlAction (Quality: ${(signalQuality * 100).toStringAsFixed(0)}%)';

    AppLogger.success(
      '🤖 ML Scalp: ${baseSignal.direction} @ ${baseSignal.entry} '
      '| Confidence: ${baseSignal.confidence.toStringAsFixed(1)}% → '
      '${mlAdjustedConfidence.toStringAsFixed(1)}% | Action: $mlAction',
    );

    return KabousMasterScalpSignal(
      direction: baseSignal.direction,
      entry: baseSignal.entry,
      target: baseSignal.target,
      stopLoss: baseSignal.stopLoss,
      confidence: _roundConfidence(mlAdjustedConfidence),
      reason: mlReason,
      riskRewardRatio: baseSignal.riskRewardRatio,
      stopActivation: baseSignal.stopActivation,
    );
  }

  /// توليد إشارة السوينغ النهائية
  static KabousMasterSwingSignal _generateSwingSignal({
    required double currentPrice,
    required Map<String, dynamic> confluenceData,
    required Map<String, dynamic> resolvedSignals,
    required TechnicalIndicators indicators,
  }) {
    AppLogger.info('📊 توليد إشارة السوينغ النهائية...');

    final swingData = resolvedSignals['swing'];
    final direction = swingData['direction'] as String;
    final baseConfidence = swingData['confidence'] as double;
    final confluenceScore = confluenceData['swing']['confluenceScore'] as int;
    final maxConfluenceScore = confluenceData['swing']['maxScore'] as int;
    final momentum = confluenceData['swing']['momentum'] as double;
    final volatility = confluenceData['swing']['volatility'] as double;
    final rsi = confluenceData['swing']['rsi'] as double;
    final trendStrength = confluenceData['swing']['trend'] as String;

    // حساب نقاط الدخول من الأنظمة (reserved for future multi-system analysis)
    // final systems = swingData['systems'] as Map<String, dynamic>;
    // final gnSystem = systems['goldenNightmare'] as Map<String, dynamic>?;
    // final swingV2System = systems['swingV2'] as Map<String, dynamic>?;

    // 🆕 استخدام السعر الحقيقي الحالي مباشرة (توصيات حية)
    final entry = currentPrice;

    // 🚀 Stop Loss ديناميكي للسوينغ (استخدام الدالة الجديدة)
    final dynamicStopLoss = _calculateDynamicStopLoss(
      entry: entry,
      direction: direction,
      atr: indicators.atr,
      currentPrice: currentPrice,
      volatility: volatility,
      trendStrength: trendStrength,
      isScalp: false, // ✅ SWING mode
    );

    // 🎯 Targets ديناميكية للسوينغ (استخدام الدالة الجديدة)
    final dynamicTarget1 = _calculateDynamicTarget(
      entry: entry,
      direction: direction,
      atr: indicators.atr,
      momentum: momentum.abs(),
      volatility: volatility,
      confluenceScore: confluenceScore,
      maxConfluenceScore: maxConfluenceScore,
      isScalp: false, // ✅ SWING mode
    );

    // Target 2: ضعف Target 1
    final target1Distance = (dynamicTarget1 - entry).abs();
    final target2Distance = target1Distance * 2.0;
    final dynamicTarget2 =
        direction == 'BUY' ? entry + target2Distance : entry - target2Distance;

    // حساب Risk/Reward الحقيقي
    final risk = (entry - dynamicStopLoss).abs();
    final reward = (dynamicTarget2 - entry).abs();
    final rrRatio = risk > 0 ? reward / risk : 1.0;

    // 📊 الثقة الواقعية للسوينغ
    final realisticConfidence = _calculateRealisticConfidence(
      baseConfidence: baseConfidence,
      confluenceScore: confluenceScore,
      maxConfluenceScore: maxConfluenceScore,
      volatility: volatility,
      momentum: momentum,
      rsi: rsi,
      trendStrength: trendStrength,
      rrRatio: rrRatio,
      direction: direction, // ✅ فحص الاتجاه
      currentPrice: currentPrice, // ✅ السعر الحالي
      indicators: indicators, // ✅ المؤشرات
    );

    // بناء السبب المحسّن
    final reason = _buildSwingReason(
      direction: direction,
      confluenceScore: confluenceScore,
      trend: trendStrength,
      rsi: rsi,
      momentum: momentum,
    );

    return KabousMasterSwingSignal(
      direction: direction,
      entry: _roundPrice(entry),
      target1: _roundPrice(dynamicTarget1),
      target2: _roundPrice(dynamicTarget2),
      stopLoss: _roundPrice(dynamicStopLoss),
      confidence: _roundConfidence(realisticConfidence),
      reason: reason,
      riskRewardRatio: _roundRatio(rrRatio),
    );
  }

  /// 🤖 ML-Enhanced Swing Signal Generation
  static KabousMasterSwingSignal _generateSwingSignalML({
    required double currentPrice,
    required Map<String, dynamic> confluenceData,
    required Map<String, dynamic> resolvedSignals,
    required TechnicalIndicators indicators,
    required MarketFeatures mlFeatures,
    required MLEngineWeights mlWeights,
  }) {
    // Generate base signal
    final baseSignal = _generateSwingSignal(
      currentPrice: currentPrice,
      confluenceData: confluenceData,
      resolvedSignals: resolvedSignals,
      indicators: indicators,
    );

    // 🤖 ML Enhancement: Evaluate signal quality (for swing)
    final mlAdjustedConfidence = MLConfidencePredictor.evaluateSignalQuality(
      features: mlFeatures,
      direction: baseSignal.direction,
      baseConfidence: baseSignal.confidence,
    );

    // Get ML recommendation
    final mlAction = MLConfidencePredictor.getRecommendedAction(
      mlAdjustedConfidence,
    );

    final signalQuality = mlAdjustedConfidence / baseSignal.confidence;

    // Enhanced reason with ML insight
    final mlReason =
        '${baseSignal.reason}\n🤖 ML: $mlAction (Quality: ${(signalQuality * 100).toStringAsFixed(0)}%)';

    AppLogger.success(
      '🤖 ML Swing: ${baseSignal.direction} @ ${baseSignal.entry} '
      '| Confidence: ${baseSignal.confidence.toStringAsFixed(1)}% → '
      '${mlAdjustedConfidence.toStringAsFixed(1)}% | Action: $mlAction',
    );

    return KabousMasterSwingSignal(
      direction: baseSignal.direction,
      entry: baseSignal.entry,
      target1: baseSignal.target1,
      target2: baseSignal.target2,
      stopLoss: baseSignal.stopLoss,
      confidence: _roundConfidence(mlAdjustedConfidence),
      reason: mlReason,
      riskRewardRatio: baseSignal.riskRewardRatio,
    );
  }

  // ==========================================
  // HELPER FUNCTIONS
  // ==========================================

  /// حساب الزخم من الشموع
  static double _calculateMomentum(List<Candle> candles) {
    if (candles.length < 10) return 0.0;

    final recent = candles.sublist(candles.length - 10);
    int bullish = 0;
    int bearish = 0;

    for (var candle in recent) {
      if (candle.close > candle.open) {
        bullish++;
      } else {
        bearish++;
      }
    }

    return (bullish - bearish) / 10.0;
  }

  /// متوسط موزون - Reserved for future multi-system analysis
  // static double _weightedAverage(List<double> values, List<double> weights) {
  //   double sum = 0.0;
  //   double weightSum = 0.0;

  //   for (int i = 0; i < values.length; i++) {
  //     sum += values[i] * weights[i];
  //     weightSum += weights[i];
  //   }

  //   return weightSum > 0 ? sum / weightSum : 0.0;
  // }

  /// بناء السبب للسكالب
  static String _buildScalpReason({
    required String direction,
    required int confluenceScore,
    required String trend,
    required double rsi,
    required double momentum,
  }) {
    final directionAr = direction == 'BUY' ? 'صاعد' : 'هابط';
    final trendAr = trend == 'BULLISH'
        ? 'صاعد'
        : trend == 'BEARISH'
            ? 'هابط'
            : 'محايد';

    return 'اتجاه $directionAr | التقاء: $confluenceScore/5 | ترند $trendAr | RSI: ${rsi.toStringAsFixed(1)}';
  }

  /// بناء السبب للسوينغ
  static String _buildSwingReason({
    required String direction,
    required int confluenceScore,
    required String trend,
    required double rsi,
    required double momentum,
  }) {
    final trendAr = trend == 'BULLISH'
        ? 'صاعد'
        : trend == 'BEARISH'
            ? 'هابط'
            : 'محايد';

    return 'توافق الاتجاه العام $trendAr | التقاء: $confluenceScore/6 | RSI: ${rsi.toStringAsFixed(1)}';
  }

  /// تقريب السعر
  static double _roundPrice(double price) {
    return (price * 100).round() / 100;
  }

  /// تقريب الثقة
  static double _roundConfidence(double confidence) {
    return confidence.roundToDouble();
  }

  /// تقريب النسبة
  static double _roundRatio(double ratio) {
    return (ratio * 10).round() / 10;
  }

  /// حساب الدعوم والمقاومات القريبة
  ///
  /// يستخدم:
  /// - Pivot Points (Traditional)
  /// - Fibonacci Levels
  /// - Moving Averages (20, 50, 100, 200)
  /// - Recent Highs/Lows
  static SupportResistanceLevels _calculateSupportResistance({
    required double currentPrice,
    required List<Candle> candles,
    required TechnicalIndicators indicators,
  }) {
    AppLogger.info('🎯 حساب الدعوم والمقاومات القريبة...');

    final List<double> allLevels = [];

    // 1. Pivot Points (من آخر شمعة يومية)
    if (candles.isNotEmpty) {
      final lastCandle = candles.last;
      final high = lastCandle.high;
      final low = lastCandle.low;
      final close = lastCandle.close;

      final pivot = (high + low + close) / 3;
      final r1 = 2 * pivot - low;
      final r2 = pivot + (high - low);
      final s1 = 2 * pivot - high;
      final s2 = pivot - (high - low);

      allLevels.addAll([pivot, r1, r2, s1, s2]);
    }

    // 2. Fibonacci Levels (من آخر 50 شمعة)
    if (candles.length >= 50) {
      final recent = candles.sublist(candles.length - 50);
      final high = recent.map((c) => c.high).reduce((a, b) => a > b ? a : b);
      final low = recent.map((c) => c.low).reduce((a, b) => a < b ? a : b);
      final diff = high - low;

      // Fibonacci Retracement levels
      final fib236 = high - (diff * 0.236);
      final fib382 = high - (diff * 0.382);
      final fib500 = high - (diff * 0.500);
      final fib618 = high - (diff * 0.618);
      final fib786 = high - (diff * 0.786);

      allLevels.addAll([fib236, fib382, fib500, fib618, fib786]);
    }

    // 3. Moving Averages كدعوم/مقاومات
    allLevels.addAll([
      indicators.ma20,
      indicators.ma50,
      indicators.ma100,
      indicators.ma200,
    ]);

    // 4. Swing Highs/Lows (من آخر 20 شمعة)
    if (candles.length >= 20) {
      final recent = candles.sublist(candles.length - 20);

      for (int i = 2; i < recent.length - 2; i++) {
        final candle = recent[i];

        // Swing High
        if (candle.high > recent[i - 1].high &&
            candle.high > recent[i - 2].high &&
            candle.high > recent[i + 1].high &&
            candle.high > recent[i + 2].high) {
          allLevels.add(candle.high);
        }

        // Swing Low
        if (candle.low < recent[i - 1].low &&
            candle.low < recent[i - 2].low &&
            candle.low < recent[i + 1].low &&
            candle.low < recent[i + 2].low) {
          allLevels.add(candle.low);
        }
      }
    }

    // 5. Round Numbers (أرقام صحيحة قريبة)
    final roundBase = (currentPrice / 10).floor() * 10;
    for (int i = -3; i <= 3; i++) {
      allLevels.add(roundBase + (i * 10));
      allLevels.add(roundBase + (i * 10) + 5); // نصف أرقام
    }

    // فلترة المستويات
    allLevels.removeWhere((level) => level <= 0);

    // فصل الدعوم والمقاومات
    final supports = allLevels.where((level) => level < currentPrice).toList()
      ..sort((a, b) => b.compareTo(a)); // ترتيب تنازلي (الأقرب أولاً)

    final resistances = allLevels
        .where((level) => level > currentPrice)
        .toList()
      ..sort((a, b) => a.compareTo(b)); // ترتيب تصاعدي (الأقرب أولاً)

    // اختيار أقرب 3 مستويات من كل نوع
    final nearestSupports = _getTopUniqueLevels(supports, 3, currentPrice);
    final nearestResistances =
        _getTopUniqueLevels(resistances, 3, currentPrice);

    AppLogger.success(
      '✅ تم حساب ${nearestSupports.length} دعوم و ${nearestResistances.length} مقاومات',
    );

    return SupportResistanceLevels(
      supports: nearestSupports,
      resistances: nearestResistances,
      currentPrice: currentPrice,
    );
  }

  /// اختيار أفضل المستويات الفريدة (بدون تكرار قريب)
  static List<double> _getTopUniqueLevels(
    List<double> levels,
    int count,
    double currentPrice,
  ) {
    if (levels.isEmpty) return [];

    final uniqueLevels = <double>[];
    final minDistance = currentPrice * 0.001; // 0.1% كحد أدنى للمسافة

    for (final level in levels) {
      bool isTooClose = false;

      for (final existing in uniqueLevels) {
        if ((level - existing).abs() < minDistance) {
          isTooClose = true;
          break;
        }
      }

      if (!isTooClose) {
        uniqueLevels.add(_roundPrice(level));
        if (uniqueLevels.length >= count) break;
      }
    }

    return uniqueLevels;
  }
}
