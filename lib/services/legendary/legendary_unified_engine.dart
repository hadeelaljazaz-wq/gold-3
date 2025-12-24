/// 👑 Legendary Unified Engine
///
/// المحرك الموحد الذي يجمع جميع الاستراتيجيات
library;

import 'dart:async';
import '../../models/candle.dart';
import '../../models/legendary/legendary_signal.dart';
import '../engines/scalping_engine_v2.dart';
import '../engines/swing_engine_v2.dart';
import '../../core/utils/logger.dart';

class LegendaryUnifiedEngine {
  // ═══════════════════════════════════════════════════════════════
  // 🎯 WEIGHTS - أوزان الاستراتيجيات
  // ═══════════════════════════════════════════════════════════════

  static const Map<String, double> strategyWeights = {
    'scalping_v2': 0.35, // 35% - المحركات الموجودة المحسّنة
    'swing_v2': 0.35, // 35% - المحركات الموجودة المحسّنة
    'smc': 0.10, // 10% - Smart Money (سنضيفه لاحقاً)
    'ict': 0.10, // 10% - ICT (سنضيفه لاحقاً)
    'wyckoff': 0.05, // 5% - Wyckoff (سنضيفه لاحقاً)
    'elliott': 0.05, // 5% - Elliott (سنضيفه لاحقاً)
  };

  // ═══════════════════════════════════════════════════════════════
  // 🚀 MAIN ANALYSIS
  // ═══════════════════════════════════════════════════════════════

  /// التحليل الأسطوري الموحد
  static Future<LegendaryAnalysisResult> analyze({
    required double currentPrice,
    required List<Candle> candles15m,
    required List<Candle> candles1h,
    required List<Candle> candles4h,
    required double rsi,
    required double macd,
    required double macdSignal,
    required double atr,
    required double ma20,
    required double ma50,
    required double ma100,
    required double ma200,
  }) async {
    try {
      AppLogger.info('🏆 Starting Legendary Unified Analysis...');

      // ═══════════════════════════════════════════════════════════
      // 1️⃣ تحليل السكالبينج (المحرك الموجود)
      // ═══════════════════════════════════════════════════════════
      final scalpingResult = await ScalpingEngineV2.analyze(
        currentPrice: currentPrice,
        candles: candles15m,
        rsi: rsi,
        macd: macd,
        macdSignal: macdSignal,
        atr: atr,
      );

      // ═══════════════════════════════════════════════════════════
      // 2️⃣ تحليل السوينج (المحرك الموجود)
      // ═══════════════════════════════════════════════════════════
      final swingResult = await SwingEngineV2.analyze(
        currentPrice: currentPrice,
        candles: candles4h,
        rsi: rsi,
        macd: macd,
        macdSignal: macdSignal,
        atr: atr,
        ma20: ma20,
        ma50: ma50,
        ma100: ma100,
        ma200: ma200,
      );

      // ═══════════════════════════════════════════════════════════
      // 3️⃣ حساب Confluence Score
      // ═══════════════════════════════════════════════════════════
      final confluenceScore = _calculateConfluence(
        scalpSignal: scalpingResult,
        swingSignal: swingResult,
      );

      // ═══════════════════════════════════════════════════════════
      // 4️⃣ حساب الدعوم والمقاومات
      // ═══════════════════════════════════════════════════════════
      final supportResistance = _calculateSupportResistance(
        candles4h: candles4h,
        currentPrice: currentPrice,
      );

      // ═══════════════════════════════════════════════════════════
      // 5️⃣ تحويل إلى LegendarySignal
      // ═══════════════════════════════════════════════════════════
      final legendaryScalp = _convertToLegendarySignal(
        signal: scalpingResult,
        type: 'scalp',
        confluenceScore: confluenceScore,
      );

      final legendarySwing = _convertToLegendarySignal(
        signal: swingResult,
        type: 'swing',
        confluenceScore: confluenceScore,
      );

      // ═══════════════════════════════════════════════════════════
      // 6️⃣ بناء النتيجة النهائية
      // ═══════════════════════════════════════════════════════════
      final result = LegendaryAnalysisResult(
        scalpSignal: legendaryScalp,
        swingSignal: legendarySwing,
        supportLevels: supportResistance['support']!,
        resistanceLevels: supportResistance['resistance']!,
        confluenceScore: confluenceScore,
        marketStructure: _determineMarketStructure(swingResult),
        strategies: {
          'scalping': scalpingResult.toJson(),
          'swing': swingResult.toJson(),
          'confluence': confluenceScore,
        },
        timestamp: DateTime.now(),
      );

      AppLogger.success(
        '✅ Legendary Analysis Complete! Confluence: ${confluenceScore.toStringAsFixed(1)}%',
      );

      return result;
    } catch (e, stack) {
      AppLogger.error('LegendaryUnifiedEngine', 'Analysis failed: $e', stack);
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🧮 CONFLUENCE CALCULATION
  // ═══════════════════════════════════════════════════════════════

  static double _calculateConfluence({
    required dynamic scalpSignal,
    required dynamic swingSignal,
  }) {
    double totalScore = 0;
    int agreementCount = 0;

    // فحص اتفاق الاتجاه
    if (scalpSignal.direction == swingSignal.direction &&
        scalpSignal.direction != 'NO_TRADE') {
      agreementCount++;
      totalScore += 40; // وزن عالي للاتفاق
    }

    // فحص قوة الإشارات
    final scalpConfidence = scalpSignal.confidence ?? 0;
    final swingConfidence = swingSignal.confidence ?? 0;
    final avgConfidence = (scalpConfidence + swingConfidence) / 2;

    totalScore += (avgConfidence / 100) * 30; // 30% من المجموع

    // إضافة نقاط للثقة العالية
    if (scalpConfidence >= 70 && swingConfidence >= 70) {
      totalScore += 20;
      agreementCount++;
    }

    // تطبيع النتيجة
    final finalScore = totalScore.clamp(0.0, 100.0);

    AppLogger.debug('Confluence: $finalScore% (Agreements: $agreementCount)');

    return finalScore;
  }

  // ═══════════════════════════════════════════════════════════════
  // 🎯 SUPPORT & RESISTANCE
  // ═══════════════════════════════════════════════════════════════

  static Map<String, List<double>> _calculateSupportResistance({
    required List<Candle> candles4h,
    required double currentPrice,
  }) {
    final supports = <double>[];
    final resistances = <double>[];

    if (candles4h.length < 50) {
      return {
        'support': [currentPrice - 10, currentPrice - 20, currentPrice - 30],
        'resistance': [currentPrice + 10, currentPrice + 20, currentPrice + 30],
      };
    }

    // حساب Swing Points
    final swingHighs = _findSwingHighs(candles4h);
    final swingLows = _findSwingLows(candles4h);

    // الدعوم = Swing Lows أسفل السعر
    for (final low in swingLows) {
      if (low < currentPrice) {
        supports.add(low);
      }
    }

    // المقاومات = Swing Highs أعلى السعر
    for (final high in swingHighs) {
      if (high > currentPrice) {
        resistances.add(high);
      }
    }

    // ترتيب وأخذ أقرب 3
    supports.sort(
      (a, b) => (b - currentPrice).abs().compareTo((a - currentPrice).abs()),
    );
    resistances.sort(
      (a, b) => (a - currentPrice).abs().compareTo((b - currentPrice).abs()),
    );

    return {
      'support': supports.take(3).toList(),
      'resistance': resistances.take(3).toList(),
    };
  }

  static List<double> _findSwingHighs(List<Candle> candles) {
    final List<double> swingHighs = [];
    const lookback = 10;

    for (int i = lookback; i < candles.length - lookback; i++) {
      bool isSwingHigh = true;
      final currentHigh = candles[i].high;

      for (int j = i - lookback; j <= i + lookback; j++) {
        if (j != i && candles[j].high >= currentHigh) {
          isSwingHigh = false;
          break;
        }
      }

      if (isSwingHigh) {
        swingHighs.add(currentHigh);
      }
    }

    return swingHighs;
  }

  static List<double> _findSwingLows(List<Candle> candles) {
    final List<double> swingLows = [];
    const lookback = 10;

    for (int i = lookback; i < candles.length - lookback; i++) {
      bool isSwingLow = true;
      final currentLow = candles[i].low;

      for (int j = i - lookback; j <= i + lookback; j++) {
        if (j != i && candles[j].low <= currentLow) {
          isSwingLow = false;
          break;
        }
      }

      if (isSwingLow) {
        swingLows.add(currentLow);
      }
    }

    return swingLows;
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔄 CONVERSION HELPERS
  // ═══════════════════════════════════════════════════════════════

  static LegendarySignal _convertToLegendarySignal({
    required dynamic signal,
    required String type,
    required double confluenceScore,
  }) {
    // تحديد الاتجاه
    SignalDirection direction;
    if (signal.direction == 'BUY') {
      direction = SignalDirection.buy;
    } else if (signal.direction == 'SELL') {
      direction = SignalDirection.sell;
    } else {
      direction = SignalDirection.wait;
    }

    // استخراج البيانات
    final entryPrice = signal.entryPrice ?? 0.0;
    final stopLoss = signal.stopLoss ?? 0.0;
    final takeProfit1 = signal.takeProfit ?? entryPrice + 5;
    final takeProfit2 = takeProfit1 + 5;
    final confidence = signal.confidence ?? 50.0;
    final reasoning = signal.reasoning ?? 'تحليل من المحرك الموجود';

    // بناء التأكيدات
    final confirmations = <String>[];
    if (signal.microTrend?.direction != null) {
      confirmations.add('Micro Trend: ${signal.microTrend.direction}');
    }
    if (signal.momentum?.classification != null) {
      confirmations.add('Momentum: ${signal.momentum.classification}');
    }
    if (signal.rsiZone?.zone != null) {
      confirmations.add('RSI Zone: ${signal.rsiZone.zone}');
    }

    return LegendarySignal(
      direction: direction,
      entryPrice: entryPrice,
      stopLoss: stopLoss,
      takeProfit1: takeProfit1,
      takeProfit2: takeProfit2,
      confidence: confidence,
      reasoning: reasoning,
      confirmations: confirmations,
      confluenceScore: confluenceScore,
      timestamp: DateTime.now(),
    );
  }

  static String _determineMarketStructure(dynamic swingSignal) {
    if (swingSignal.macroTrend?.direction == 'BULLISH') {
      return 'صعودي قوي (Strong Uptrend)';
    } else if (swingSignal.macroTrend?.direction == 'BEARISH') {
      return 'هبوطي قوي (Strong Downtrend)';
    } else {
      return 'جانبي (Ranging)';
    }
  }
}
