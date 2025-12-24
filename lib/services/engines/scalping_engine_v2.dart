/// 👑 Gold Nightmare - Scalping Engine v2.0
///
/// محرك السكالبينج الاحترافي الجديد
///
/// **الفلسفة:**
/// - التركيز على الحركات اللحظية (Micro-Movements)
/// - الاستجابة السريعة للتغيرات
/// - دقة عالية في نقاط الدخول والخروج
/// - فصل كامل عن منطق السوينج
///
/// **محسّن للإطار الزمني: 5 دقائق (5m)**
/// - تحليل آخر 30 شمعة (2.5 ساعة)
/// - EMA سريع: 3, 7, 15
/// - RSI عدواني: 65/35 بدلاً من 70/30
/// - حساسية عالية للتغيرات الأخيرة
///
/// **المكونات الأساسية:**
/// 1. Micro-Trend Detection - اكتشاف الاتجاه اللحظي
/// 2. Momentum Analysis - تحليل الزخم
/// 3. Micro-Volatility - الذبذبة اللحظية
/// 4. CM_Ult_MacD_MTF Integration
/// 5. RSI Signal Zones
/// 6. Entry/Exit Precision
///
/// **الاختلاف عن v1.0:**
/// - ✅ منطق مستقل تماماً
/// - ✅ تركيز على إطار 5m (بدلاً من M1, M5, M15)
/// - ✅ دقة أعلى في التوقيت
/// - ✅ معايير دخول/خروج أكثر صرامة
/// - ✅ إدارة مخاطر محسّنة

import 'dart:math';
import '../../models/candle.dart';
import '../../models/scalping_signal.dart';
import '../../models/trade_decision.dart';
import '../signal_validator.dart';
import '../../core/utils/logger.dart';
import '../central_bayesian_engine.dart';
import '../ml_decision_maker.dart';
import '../quantum_scalping/chaos_volatility_engine.dart';

class ScalpingEngineV2 {
  // ============================================================================
  // PUBLIC API
  // ============================================================================

  /// تحليل شامل وإنتاج إشارة سكالبينج
  ///
  /// **Parameters:**
  /// - [currentPrice]: السعر الحالي
  /// - [candles]: الشموع (M1, M5, M15)
  /// - [rsi]: RSI الحالي
  /// - [macd]: MACD الحالي
  /// - [macdSignal]: MACD Signal
  /// - [atr]: ATR (Average True Range)
  /// - [cmUltMacd]: CM Ultimate MACD MTF (optional)
  ///
  /// **Returns:**
  /// [ScalpingSignal] - إشارة سكالبينج كاملة أو NO_TRADE
  static Future<ScalpingSignal> analyze({
    required double currentPrice,
    required List<Candle> candles,
    required double rsi,
    required double macd,
    required double macdSignal,
    required double atr,
    Map<String, dynamic>? cmUltMacd,
  }) async {
    try {
      AppLogger.analysis('ScalpingEngineV2', 'Starting analysis',
          data: 'Price: \$${currentPrice.toStringAsFixed(2)}');

      // ========================================================================
      // STEP 1: Micro-Trend Detection (الاتجاه اللحظي)
      // ========================================================================
      final microTrend = _detectMicroTrend(candles, currentPrice);
      AppLogger.debug(
          'Micro-Trend: ${microTrend.direction} (Score: ${microTrend.score}, Reason: ${microTrend.reason ?? "N/A"})');

      // ========================================================================
      // STEP 2: Momentum Analysis (تحليل الزخم)
      // ========================================================================
      final momentum = _analyzeMomentum(
        candles: candles,
        rsi: rsi,
        macd: macd,
        macdSignal: macdSignal,
        cmUltMacd: cmUltMacd,
      );

      // ========================================================================
      // STEP 3: Micro-Volatility Analysis (الذبذبة اللحظية)
      // ========================================================================
      final volatility = _analyzeMicroVolatility(candles, atr);

      // ========================================================================
      // STEP 4: RSI Signal Zones (مناطق إشارات RSI)
      // ========================================================================
      final rsiZone = _detectRsiSignalZone(rsi, candles);

      // ========================================================================
      // STEP 5: Entry Precision Check (فحص دقة الدخول)
      // ========================================================================
      final entryPrecision = _checkEntryPrecision(
        microTrend: microTrend,
        momentum: momentum,
        volatility: volatility,
        rsiZone: rsiZone,
        currentPrice: currentPrice,
        candles: candles,
      );

      // ========================================================================
      // STEP 6: Generate Signal (توليد الإشارة)
      // ========================================================================
      if (!entryPrecision.isValid) {
        return ScalpingSignal.noTrade(
            reason: entryPrecision.reason ?? 'Invalid entry');
      }

      return _generateScalpSignal(
        currentPrice: currentPrice,
        microTrend: microTrend,
        momentum: momentum,
        volatility: volatility,
        rsiZone: rsiZone,
        entryPrecision: entryPrecision,
        atr: atr,
        candles: candles,
      );
    } catch (e, stackTrace) {
      AppLogger.error('ScalpingEngineV2 analysis failed', e, stackTrace);
      return ScalpingSignal.noTrade(reason: 'System Error: $e');
    }
  }

  // ============================================================================
  // STEP 1: MICRO-TREND DETECTION
  // ============================================================================

  /// اكتشاف الاتجاه اللحظي (محسّن لإطار 5 دقائق)
  ///
  /// **المنهجية:**
  /// - تحليل آخر 30 شمعة (150 دقيقة = 2.5 ساعة على 5m)
  /// - حساب EMA سريع جداً (3, 7, 15) - مخصص للسكالب
  /// - اكتشاف HH/HL أو LH/LL
  /// - تحديد قوة الاتجاه مع حساسية عالية
  static MicroTrend _detectMicroTrend(
      List<Candle> candles, double currentPrice) {
    if (candles.length < 30) {
      return MicroTrend.neutral('Insufficient data');
    }

    // ✅ زيادة عدد الشموع المحللة من 20 إلى 30 للحساسية الأعلى
    final last30 = candles.take(30).toList();

    // ✅ حساب EMA سريع جداً (3, 7, 15 بدلاً من 5, 10, 20) - مخصص للسكالب 5m
    final ema3 = _calculateEMA(last30, 3);
    final ema7 = _calculateEMA(last30, 7);
    final ema15 = _calculateEMA(last30, 15);

    // تحليل ترتيب EMA (مع حساسية أعلى للسكالب)
    int trendScore = 0;

    // EMA Stacking - وزن أكبر للسكالب
    if (ema3 > ema7 && ema7 > ema15) {
      trendScore += 4; // اتجاه صاعد قوي (زيادة من 3)
    } else if (ema3 > ema7) {
      trendScore += 2; // اتجاه صاعد ضعيف (زيادة من 1)
    } else if (ema3 < ema7 && ema7 < ema15) {
      trendScore -= 4; // اتجاه هابط قوي (زيادة من -3)
    } else if (ema3 < ema7) {
      trendScore -= 2; // اتجاه هابط ضعيف (زيادة من -1)
    }

    // موقع السعر بالنسبة لـ EMA (وزن أكبر)
    if (currentPrice > ema3) {
      trendScore += 2; // زيادة من 1
    } else if (currentPrice < ema3) {
      trendScore -= 2; // زيادة من -1
    }

    // تحليل HH/HL أو LH/LL على آخر 30 شمعة
    final swings = _detectSwingPoints(last30);
    if (swings.isHigherHighs && swings.isHigherLows) {
      trendScore += 3; // زيادة من 2
    } else if (swings.isLowerHighs && swings.isLowerLows) {
      trendScore -= 3; // زيادة من -2
    }

    // ✅ تحليل قوة الشموع الأخيرة (آخر 7 شموع بدلاً من 5)
    final last7 = last30.take(7).toList();
    int bullishCount = 0;
    int bearishCount = 0;
    for (final candle in last7) {
      if (candle.close > candle.open) {
        bullishCount++;
      } else {
        bearishCount++;
      }
    }

    // حساسية أعلى للاتجاه الأخير
    if (bullishCount >= 5) {
      trendScore += 2; // زيادة من 1
    } else if (bearishCount >= 5) {
      trendScore -= 2; // زيادة من -1
    }

    // ✅ تصنيف الاتجاه (عتبات أعلى بسبب زيادة الحساسية)
    if (trendScore >= 7) {
      return MicroTrend.strongBullish(trendScore, ema3, ema7, ema15);
    } else if (trendScore >= 3) {
      return MicroTrend.bullish(trendScore, ema3, ema7, ema15);
    } else if (trendScore <= -7) {
      return MicroTrend.strongBearish(trendScore, ema3, ema7, ema15);
    } else if (trendScore <= -3) {
      return MicroTrend.bearish(trendScore, ema3, ema7, ema15);
    } else {
      return MicroTrend.neutral('Range-bound market', ema3, ema7, ema15);
    }
  }

  // ============================================================================
  // STEP 2: MOMENTUM ANALYSIS
  // ============================================================================

  /// تحليل الزخم الشامل
  ///
  /// **المكونات:**
  /// - RSI Momentum
  /// - MACD Momentum
  /// - CM Ultimate MACD (if available)
  /// - Price Action Momentum
  static MomentumAnalysis _analyzeMomentum({
    required List<Candle> candles,
    required double rsi,
    required double macd,
    required double macdSignal,
    Map<String, dynamic>? cmUltMacd,
  }) {
    int momentumScore = 0;
    final signals = <String>[];

    // 1. RSI Momentum
    if (rsi > 70) {
      momentumScore += 2;
      signals.add('RSI Overbought (Strong Bullish)');
    } else if (rsi > 60) {
      momentumScore += 1;
      signals.add('RSI Bullish');
    } else if (rsi < 30) {
      momentumScore -= 2;
      signals.add('RSI Oversold (Strong Bearish)');
    } else if (rsi < 40) {
      momentumScore -= 1;
      signals.add('RSI Bearish');
    }

    // 2. MACD Momentum
    final macdHistogram = macd - macdSignal;
    if (macdHistogram > 0 && macd > 0) {
      momentumScore += 2;
      signals.add('MACD Strong Bullish');
    } else if (macdHistogram > 0) {
      momentumScore += 1;
      signals.add('MACD Bullish');
    } else if (macdHistogram < 0 && macd < 0) {
      momentumScore -= 2;
      signals.add('MACD Strong Bearish');
    } else if (macdHistogram < 0) {
      momentumScore -= 1;
      signals.add('MACD Bearish');
    }

    // 3. MACD Crossover Detection
    if (candles.length >= 2) {
      // تحليل الكروس أوفر
      // Bullish Crossover: MACD crosses above Signal
      if (macd > macdSignal && candles.length >= 2) {
        final previousMacd = macd - (macd - macdSignal) * 0.5; // تقدير تقريبي
        final previousSignal = macdSignal;

        if (previousMacd <= previousSignal && macd > macdSignal) {
          signals.add('MACD Bullish Crossover');
          momentumScore += 3;
        }
      }

      // Bearish Crossover: MACD crosses below Signal
      if (macd < macdSignal && candles.length >= 2) {
        final previousMacd = macd - (macd - macdSignal) * 0.5; // تقدير تقريبي
        final previousSignal = macdSignal;

        if (previousMacd >= previousSignal && macd < macdSignal) {
          signals.add('MACD Bearish Crossover');
          momentumScore -= 3;
        }
      }
    }

    // 4. CM Ultimate MACD (if available)
    if (cmUltMacd != null) {
      // دمج CM Ultimate MACD
      try {
        final cmMacd = cmUltMacd['macd'] as double?;
        final cmSignal = cmUltMacd['signal'] as double?;
        final cmHistogram = cmUltMacd['histogram'] as double?;

        if (cmMacd != null && cmSignal != null) {
          // Bullish signal from CM MACD
          if (cmMacd > cmSignal) {
            momentumScore += 2;
            signals.add('CM MACD Bullish');
          }

          // Bearish signal from CM MACD
          if (cmMacd < cmSignal) {
            momentumScore -= 2;
            signals.add('CM MACD Bearish');
          }

          // Histogram confirmation
          if (cmHistogram != null) {
            if (cmHistogram > 0) {
              momentumScore += 1;
            } else {
              momentumScore -= 1;
            }
          }
        }
      } catch (e) {
        AppLogger.warn('Failed to parse CM Ultimate MACD data: $e');
      }
    }

    // 5. Price Action Momentum (حركة السعر)
    final last10 = candles.take(10).toList();
    final priceChange =
        (last10.first.close - last10.last.close) / last10.last.close * 100;

    if (priceChange > 0.5) {
      momentumScore += 1;
      signals.add('Strong Price Momentum Up');
    } else if (priceChange < -0.5) {
      momentumScore -= 1;
      signals.add('Strong Price Momentum Down');
    }

    // تصنيف الزخم
    String classification;
    if (momentumScore >= 5) {
      classification = 'VERY_STRONG_BULLISH';
    } else if (momentumScore >= 3) {
      classification = 'STRONG_BULLISH';
    } else if (momentumScore >= 1) {
      classification = 'BULLISH';
    } else if (momentumScore <= -5) {
      classification = 'VERY_STRONG_BEARISH';
    } else if (momentumScore <= -3) {
      classification = 'STRONG_BEARISH';
    } else if (momentumScore <= -1) {
      classification = 'BEARISH';
    } else {
      classification = 'NEUTRAL';
    }

    return MomentumAnalysis(
      score: momentumScore,
      classification: classification,
      rsi: rsi,
      macd: macd,
      macdSignal: macdSignal,
      macdHistogram: macdHistogram,
      signals: signals,
    );
  }

  // ============================================================================
  // STEP 3: MICRO-VOLATILITY ANALYSIS
  // ============================================================================

  /// تحليل الذبذبة اللحظية
  ///
  /// **الهدف:**
  /// - تحديد إذا كان السوق مناسب للسكالبينج
  /// - اكتشاف الحركات الكاذبة (Fakeouts)
  /// - تحديد حجم الستوب لوس المناسب
  static MicroVolatility _analyzeMicroVolatility(
      List<Candle> candles, double atr) {
    final last20 = candles.take(20).toList();

    // 1. حساب متوسط المدى
    final avgRange =
        last20.map((c) => c.high - c.low).reduce((a, b) => a + b) / 20;

    // 2. نسبة ATR
    final atrRatio = atr / avgRange;

    // 3. تحليل الأجسام vs الظلال
    double totalBody = 0;
    double totalWick = 0;
    for (final candle in last20) {
      final body = (candle.close - candle.open).abs();
      final range = candle.high - candle.low;
      final wick = range - body;
      totalBody += body;
      totalWick += wick;
    }
    final wickRatio = totalWick / totalBody;

    // 4. تحليل الحركات المفاجئة
    final last5 = last20.take(5).toList();
    final recentAvgRange =
        last5.map((c) => c.high - c.low).reduce((a, b) => a + b) / 5;
    final suddenMove = recentAvgRange > (avgRange * 1.5);

    // تصنيف الذبذبة
    bool isLowVolatility = atrRatio < 0.8;
    bool isHighVolatility = atrRatio > 1.3;
    bool isWickyMarket = wickRatio > 1.5;
    bool isSuddenMove = suddenMove;

    // تحديد مدى ملاءمة السوق للسكالبينج
    bool isSuitableForScalping = !isWickyMarket && !isSuddenMove;

    // السوق المثالي للسكالبينج: ذبذبة متوسطة، أجسام واضحة، حركة مستقرة
    bool isIdeal = !isLowVolatility &&
        !isHighVolatility &&
        !isWickyMarket &&
        !isSuddenMove;

    return MicroVolatility(
      atr: atr,
      avgRange: avgRange,
      atrRatio: atrRatio,
      wickRatio: wickRatio,
      isLowVolatility: isLowVolatility,
      isHighVolatility: isHighVolatility,
      isWickyMarket: isWickyMarket,
      isSuddenMove: isSuddenMove,
      isSuitableForScalping: isSuitableForScalping,
      isIdeal: isIdeal,
    );
  }

  // ============================================================================
  // STEP 4: RSI SIGNAL ZONES
  // ============================================================================

  /// اكتشاف مناطق إشارات RSI (محسّن للسكالب - أكثر عدوانية)
  ///
  /// **المناطق (مخصصة للسكالب 5m):**
  /// - Extreme Overbought (>75): احتمال انعكاس عالي (كان 80)
  /// - Overbought (65-75): قوة صاعدة (كان 70-80)
  /// - Bullish (55-65): زخم صاعد (كان 60-70)
  /// - Neutral (45-55): محايد (كان 40-60)
  /// - Bearish (35-45): زخم هابط (كان 30-40)
  /// - Oversold (25-35): قوة هابطة (كان 20-30)
  /// - Extreme Oversold (<25): احتمال انعكاس عالي (كان 20)
  static RsiSignalZone _detectRsiSignalZone(double rsi, List<Candle> candles) {
    String zone;
    String signal;
    double reversalProbability = 0.0;

    // ✅ مستويات أكثر عدوانية للسكالب (65/35 بدلاً من 70/30)
    if (rsi > 75) {
      zone = 'EXTREME_OVERBOUGHT';
      signal = 'SELL_REVERSAL';
      reversalProbability = 0.80; // زيادة من 0.75
    } else if (rsi > 65) {
      zone = 'OVERBOUGHT';
      signal = 'SELL_CAUTION';
      reversalProbability = 0.60; // زيادة من 0.50
    } else if (rsi > 55) {
      zone = 'BULLISH';
      signal = 'BUY_CONTINUATION';
      reversalProbability = 0.25; // زيادة من 0.20
    } else if (rsi >= 45) {
      zone = 'NEUTRAL';
      signal = 'WAIT';
      reversalProbability = 0.50;
    } else if (rsi >= 35) {
      zone = 'BEARISH';
      signal = 'SELL_CONTINUATION';
      reversalProbability = 0.25; // زيادة من 0.20
    } else if (rsi >= 25) {
      zone = 'OVERSOLD';
      signal = 'BUY_CAUTION';
      reversalProbability = 0.60; // زيادة من 0.50
    } else {
      zone = 'EXTREME_OVERSOLD';
      signal = 'BUY_REVERSAL';
      reversalProbability = 0.80; // زيادة من 0.75
    }

    // تحليل RSI Divergence
    bool hasDivergence = false;
    if (candles.length >= 10) {
      // Bullish Divergence: السعر يصنع قيعان أقل لكن RSI يصنع قيعان أعلى
      final recentCandles = candles.take(10).toList();

      // البحث عن قيعان في السعر
      final priceLows = <double>[];
      for (int i = 1; i < recentCandles.length - 1; i++) {
        if (recentCandles[i].low < recentCandles[i - 1].low &&
            recentCandles[i].low < recentCandles[i + 1].low) {
          priceLows.add(recentCandles[i].low);
        }
      }

      if (priceLows.length >= 2) {
        // إذا كان السعر يصنع قيعان أقل لكن RSI لا يتبع (Bullish Divergence)
        if (priceLows.last < priceLows.first && rsi > 30) {
          hasDivergence = true;
          signal = 'BUY_REVERSAL';
          reversalProbability = 0.8;
        }
      }

      // Bearish Divergence: السعر يصنع قمم أعلى لكن RSI يصنع قمم أقل
      final priceHighs = <double>[];
      for (int i = 1; i < recentCandles.length - 1; i++) {
        if (recentCandles[i].high > recentCandles[i - 1].high &&
            recentCandles[i].high > recentCandles[i + 1].high) {
          priceHighs.add(recentCandles[i].high);
        }
      }

      if (priceHighs.length >= 2) {
        // إذا كان السعر يصنع قمم أعلى لكن RSI لا يتبع (Bearish Divergence)
        if (priceHighs.last > priceHighs.first && rsi < 70) {
          hasDivergence = true;
          signal = 'SELL_REVERSAL';
          reversalProbability = 0.8;
        }
      }
    }

    return RsiSignalZone(
      rsi: rsi,
      zone: zone,
      signal: signal,
      reversalProbability: reversalProbability,
      hasDivergence: hasDivergence,
    );
  }

  // ============================================================================
  // STEP 5: ENTRY PRECISION CHECK
  // ============================================================================

  /// فحص دقة الدخول
  ///
  /// **المعايير:**
  /// - توافق الاتجاه والزخم
  /// - ملاءمة الذبذبة
  /// - إشارة RSI واضحة
  /// - عدم وجود تضارب
  static EntryPrecision _checkEntryPrecision({
    required MicroTrend microTrend,
    required MomentumAnalysis momentum,
    required MicroVolatility volatility,
    required RsiSignalZone rsiZone,
    required double currentPrice,
    required List<Candle> candles,
  }) {
    final issues = <String>[];
    int confidenceScore = 100;

    // 1. فحص ملاءمة الذبذبة
    if (!volatility.isSuitableForScalping) {
      issues.add('Market not suitable for scalping (wicky or sudden moves)');
      confidenceScore -= 30;
    }

    // 2. فحص توافق الاتجاه والزخم
    final trendDirection = microTrend.direction;
    final momentumDirection = momentum.classification.contains('BULLISH')
        ? 'BULLISH'
        : momentum.classification.contains('BEARISH')
            ? 'BEARISH'
            : 'NEUTRAL';

    if (trendDirection == 'NEUTRAL' && momentumDirection == 'NEUTRAL') {
      issues.add('No clear trend or momentum');
      return EntryPrecision.invalid(
          'No clear trend or momentum', confidenceScore);
    }

    if (trendDirection != 'NEUTRAL' &&
        momentumDirection != 'NEUTRAL' &&
        trendDirection != momentumDirection) {
      issues.add('Trend and momentum conflict');
      confidenceScore -= 20;
    }

    // 3. فحص إشارة RSI
    if (rsiZone.signal == 'WAIT') {
      issues.add('RSI in neutral zone');
      confidenceScore -= 15;
    }

    // 4. فحص الحد الأدنى للثقة
    if (confidenceScore < 50) {
      return EntryPrecision.invalid(
        'Confidence too low (${confidenceScore}%)',
        confidenceScore,
      );
    }

    // تحديد الاتجاه النهائي
    String finalDirection;
    if (trendDirection != 'NEUTRAL') {
      finalDirection = trendDirection;
    } else {
      finalDirection = momentumDirection;
    }

    return EntryPrecision.valid(
      direction: finalDirection,
      confidenceScore: confidenceScore,
      issues: issues,
    );
  }

  // ============================================================================
  // STEP 6: GENERATE SCALP SIGNAL
  // ============================================================================

  /// توليد إشارة السكالبينج النهائية
  static ScalpingSignal _generateScalpSignal({
    required double currentPrice,
    required MicroTrend microTrend,
    required MomentumAnalysis momentum,
    required MicroVolatility volatility,
    required RsiSignalZone rsiZone,
    required EntryPrecision entryPrecision,
    required double atr,
    required List<Candle> candles,
  }) {
    final direction = entryPrecision.direction;
    final isBuy = direction == 'BULLISH';
    final signalDirection = isBuy ? 'BUY' : 'SELL';

    // حساب نقاط الدخول والخروج
    final entryPrice = currentPrice;

    // SCALP: نسب ثابتة من السعر (صغيرة جداً - دقائق)
    final stopLossDistance = entryPrice * 0.0012; // 0.12% stop
    final takeProfitDistance = entryPrice * 0.003; // 0.3% target (R:R = 1:2.5)
    
    final stopLoss =
        isBuy ? entryPrice - stopLossDistance : entryPrice + stopLossDistance;
    final takeProfit = isBuy
        ? entryPrice + takeProfitDistance
        : entryPrice - takeProfitDistance;

    // Risk/Reward
    final riskReward = takeProfitDistance / stopLossDistance;
    
    // ═══════════════════════════════════════════════════════════════════════════
    // DETAILED LOGGING
    // ═══════════════════════════════════════════════════════════════════════════
    AppLogger.info('═══════════════════════════════════════');
    AppLogger.info('🎯 SCALPING ENGINE CALCULATION:');
    AppLogger.info('  Entry: \$${entryPrice.toStringAsFixed(2)}');
    AppLogger.info('  Direction: $signalDirection');
    AppLogger.info('  ATR: ${atr.toStringAsFixed(3)}');
    AppLogger.info('  Fixed Stop %: 0.12% = \$${stopLossDistance.toStringAsFixed(3)}');
    AppLogger.info('  Fixed Target %: 0.3% = \$${takeProfitDistance.toStringAsFixed(3)}');
    AppLogger.info('  Stop Loss: \$${stopLoss.toStringAsFixed(2)}');
    AppLogger.info('  Take Profit: \$${takeProfit.toStringAsFixed(2)}');
    AppLogger.info('  R:R: ${riskReward.toStringAsFixed(2)}');
    AppLogger.info('═══════════════════════════════════════');

    // ========================================================================
    // CRITICAL: VALIDATE SIGNAL BEFORE RETURNING
    // ========================================================================
    final validation = SignalValidator.validateScalpSignal(
      direction: signalDirection,
      entry: entryPrice,
      stop: stopLoss,
      target: takeProfit,
    );

    // If validation fails, return NO_TRADE signal
    if (!validation.isValid) {
      return ScalpingSignal.noTrade(
        reason: 'Validation failed: ${validation.errorMessage}',
      );
    }

    // Log warnings if any
    if (validation.warnings.isNotEmpty) {
      AppLogger.warn(
          '⚠️ ScalpingEngine Warnings: ${validation.warnings.join(", ")}');
    }

    // 🔍 DEBUG: Log signal for validation
    AppLogger.info('🎯 ScalpingEngineV2 Generated Signal:');
    AppLogger.info('   Direction: $signalDirection');
    AppLogger.info('   Entry: \$$entryPrice');
    AppLogger.info('   Stop Loss: \$$stopLoss');
    AppLogger.info('   Take Profit: \$$takeProfit');
    AppLogger.info('   Confidence: ${entryPrecision.confidenceScore}%');
    
    return ScalpingSignal(
      direction: signalDirection,
      entryPrice: entryPrice,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
      confidence: entryPrecision.confidenceScore,
      riskReward: validation.calculatedRR ?? riskReward,
      microTrend: microTrend,
      momentum: momentum,
      volatility: volatility,
      rsiZone: rsiZone,
      timestamp: DateTime.now(),
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// حساب EMA
  static double _calculateEMA(List<Candle> candles, int period) {
    if (candles.length < period) return candles.first.close;

    final multiplier = 2.0 / (period + 1);
    double ema =
        candles.take(period).map((c) => c.close).reduce((a, b) => a + b) /
            period;

    for (int i = period; i < min(candles.length, period * 2); i++) {
      ema = (candles[i].close - ema) * multiplier + ema;
    }

    return ema;
  }

  /// اكتشاف نقاط التأرجح (Swing Points)
  static SwingPoints _detectSwingPoints(List<Candle> candles) {
    final highs = <double>[];
    final lows = <double>[];

    for (int i = 5; i < candles.length - 5; i++) {
      bool isHigh = true;
      bool isLow = true;

      for (int j = i - 5; j <= i + 5; j++) {
        if (j != i) {
          if (candles[j].high >= candles[i].high) isHigh = false;
          if (candles[j].low <= candles[i].low) isLow = false;
        }
      }

      if (isHigh) highs.add(candles[i].high);
      if (isLow) lows.add(candles[i].low);
    }

    bool isHigherHighs = false;
    bool isHigherLows = false;
    bool isLowerHighs = false;
    bool isLowerLows = false;

    if (highs.length >= 2) {
      isHigherHighs = highs[0] > highs[1];
      isLowerHighs = highs[0] < highs[1];
    }

    if (lows.length >= 2) {
      isHigherLows = lows[0] > lows[1];
      isLowerLows = lows[0] < lows[1];
    }

    return SwingPoints(
      highs: highs,
      lows: lows,
      isHigherHighs: isHigherHighs,
      isHigherLows: isHigherLows,
      isLowerHighs: isLowerHighs,
      isLowerLows: isLowerLows,
    );
  }
}

// ==============================================================================
// DATA CLASSES
// ==============================================================================

/// Micro Trend
class MicroTrend {
  final String direction; // BULLISH, BEARISH, NEUTRAL
  final int score;
  final double ema5;
  final double ema10;
  final double ema20;
  final String? reason;

  MicroTrend({
    required this.direction,
    required this.score,
    required this.ema5,
    required this.ema10,
    required this.ema20,
    this.reason,
  });

  factory MicroTrend.strongBullish(
      int score, double ema5, double ema10, double ema20) {
    return MicroTrend(
      direction: 'BULLISH',
      score: score,
      ema5: ema5,
      ema10: ema10,
      ema20: ema20,
      reason: 'Strong bullish micro-trend',
    );
  }

  factory MicroTrend.bullish(
      int score, double ema5, double ema10, double ema20) {
    return MicroTrend(
      direction: 'BULLISH',
      score: score,
      ema5: ema5,
      ema10: ema10,
      ema20: ema20,
      reason: 'Bullish micro-trend',
    );
  }

  factory MicroTrend.strongBearish(
      int score, double ema5, double ema10, double ema20) {
    return MicroTrend(
      direction: 'BEARISH',
      score: score,
      ema5: ema5,
      ema10: ema10,
      ema20: ema20,
      reason: 'Strong bearish micro-trend',
    );
  }

  factory MicroTrend.bearish(
      int score, double ema5, double ema10, double ema20) {
    return MicroTrend(
      direction: 'BEARISH',
      score: score,
      ema5: ema5,
      ema10: ema10,
      ema20: ema20,
      reason: 'Bearish micro-trend',
    );
  }

  factory MicroTrend.neutral(String reason,
      [double? ema5, double? ema10, double? ema20]) {
    return MicroTrend(
      direction: 'NEUTRAL',
      score: 0,
      ema5: ema5 ?? 0,
      ema10: ema10 ?? 0,
      ema20: ema20 ?? 0,
      reason: reason,
    );
  }
}

/// Momentum Analysis
class MomentumAnalysis {
  final int score;
  final String classification;
  final double rsi;
  final double macd;
  final double macdSignal;
  final double macdHistogram;
  final List<String> signals;

  MomentumAnalysis({
    required this.score,
    required this.classification,
    required this.rsi,
    required this.macd,
    required this.macdSignal,
    required this.macdHistogram,
    required this.signals,
  });
}

/// Micro Volatility
class MicroVolatility {
  final double atr;
  final double avgRange;
  final double atrRatio;
  final double wickRatio;
  final bool isLowVolatility;
  final bool isHighVolatility;
  final bool isWickyMarket;
  final bool isSuddenMove;
  final bool isSuitableForScalping;
  final bool isIdeal;

  MicroVolatility({
    required this.atr,
    required this.avgRange,
    required this.atrRatio,
    required this.wickRatio,
    required this.isLowVolatility,
    required this.isHighVolatility,
    required this.isWickyMarket,
    required this.isSuddenMove,
    required this.isSuitableForScalping,
    required this.isIdeal,
  });
}

/// RSI Signal Zone
class RsiSignalZone {
  final double rsi;
  final String zone;
  final String signal;
  final double reversalProbability;
  final bool hasDivergence;

  RsiSignalZone({
    required this.rsi,
    required this.zone,
    required this.signal,
    required this.reversalProbability,
    required this.hasDivergence,
  });
}

// ══════════════════════════════════════════════════════════════════
// 🆕 SCALPING ENGINE V2 - ENHANCED EXTENSIONS
// ══════════════════════════════════════════════════════════════════

class ScalpingEngineV2Enhanced {
  /// تحليل محسّن للسكالبينج مع Bayesian + Chaos + ML
  static Future<Map<String, dynamic>> analyzeEnhanced({
    required double currentPrice,
    required List<Candle> candles,
    required double rsi,
    required double macd,
    required double macdSignal,
    required double atr,
    Map<String, dynamic>? cmUltMacd,
    double accountBalance = 10000.0,
  }) async {
    // الحصول على الإشارة الأصلية
    final originalSignal = await ScalpingEngineV2.analyze(
      currentPrice: currentPrice,
      candles: candles,
      rsi: rsi,
      macd: macd,
      macdSignal: macdSignal,
      atr: atr,
      cmUltMacd: cmUltMacd,
    );

    // Chaos Analysis
    ChaosAnalysis? chaosAnalysis;
    try {
      if (candles.length >= 100) {
        chaosAnalysis = ChaosVolatilityEngine.analyze(candles);
      }
    } catch (e) {
      AppLogger.warn('Chaos analysis failed: $e');
    }

    final chaosRiskLevel = chaosAnalysis?.riskLevel ?? (atr / currentPrice * 10).clamp(0.0, 1.0);

    // حساب العوامل
    final signalConfidence = (originalSignal.confidence) / 100.0;
    final volatility = (atr / currentPrice * 100).clamp(0.0, 1.0);
    final momentum = (macd - macdSignal) / currentPrice * 100;
    
    // Trend from candles
    final trendStrength = _quickTrendFromCandles(candles);
    final volumeProfile = candles.length >= 20 
        ? _calculateVolumeProfileQuick(candles.sublist(candles.length - 20))
        : 0.5;

    // Bayesian Analysis
    final bayesianAnalysis = CentralBayesianEngine.analyze(
      signalStrength: signalConfidence,
      trendStrength: trendStrength,
      momentum: momentum,
      volatility: volatility,
      volumeProfile: volumeProfile,
      timeframeAlignment: 0.65, // Scalping = lower timeframe alignment
      structureQuality: 0.60,
      chaosRiskLevel: chaosRiskLevel,
      signalDirection: originalSignal.direction == 'NO_TRADE' ? null : originalSignal.direction,
    );

    // Decision Factors
    final factors = DecisionFactors(
      trendStrength: trendStrength,
      volatility: volatility,
      momentum: momentum,
      chaosLevel: chaosRiskLevel,
      signalStrength: signalConfidence,
      timeframeAlignment: 0.65,
      volumeProfile: volumeProfile,
      structureQuality: 0.60,
    );

    // ML Decision
    final mlDecision = MLDecisionMaker.makeDecision(
      bayesianAnalysis: bayesianAnalysis,
      chaosRiskLevel: chaosRiskLevel,
      signalStrength: signalConfidence,
      signalConfidence: signalConfidence,
      volatility: volatility,
      factors: factors,
      accountBalance: accountBalance,
      signalDirection: originalSignal.direction,
    );

    // Build enhanced result
    return {
      'original_signal': originalSignal.toJson(),
      'bayesian': bayesianAnalysis.toJson(),
      'decision': mlDecision.toJson(),
      'action': mlDecision.action.name,
      'action_icon': mlDecision.action.icon,
      'action_description': mlDecision.action.description,
      'position_size_percent': mlDecision.positionSize,
      'position_size_dollars': mlDecision.positionSize * accountBalance,
      'chaos_risk_level': chaosRiskLevel,
      'quality_score': mlDecision.qualityScore,
      'chaos_analysis': chaosAnalysis?.toJson(),
    };
  }

  static double _quickTrendFromCandles(List<Candle> candles) {
    if (candles.length < 20) return 0.0;
    
    final recent = candles.sublist(candles.length - 20);
    final closes = recent.map((c) => c.close).toList();
    
    final firstPrice = closes.first;
    final lastPrice = closes.last;
    final change = (lastPrice - firstPrice) / firstPrice;
    
    return (change * 10).clamp(-1.0, 1.0);
  }

  static double _calculateVolumeProfileQuick(List<Candle> recentCandles) {
    if (recentCandles.isEmpty) return 0.5;

    final volumes = recentCandles.map((c) => c.volume).toList();
    final avgVolume = volumes.reduce((a, b) => a + b) / volumes.length;
    final currentVolume = volumes.last;

    return (currentVolume / avgVolume).clamp(0.0, 1.0);
  }
}

/// Entry Precision
class EntryPrecision {
  final bool isValid;
  final String direction;
  final int confidenceScore;
  final List<String> issues;
  final String? reason;

  EntryPrecision({
    required this.isValid,
    required this.direction,
    required this.confidenceScore,
    required this.issues,
    this.reason,
  });

  factory EntryPrecision.valid({
    required String direction,
    required int confidenceScore,
    List<String>? issues,
  }) {
    return EntryPrecision(
      isValid: true,
      direction: direction,
      confidenceScore: confidenceScore,
      issues: issues ?? [],
    );
  }

  factory EntryPrecision.invalid(String reason, int confidenceScore) {
    return EntryPrecision(
      isValid: false,
      direction: 'NONE',
      confidenceScore: confidenceScore,
      issues: [reason],
      reason: reason,
    );
  }
}

/// Swing Points
class SwingPoints {
  final List<double> highs;
  final List<double> lows;
  final bool isHigherHighs;
  final bool isHigherLows;
  final bool isLowerHighs;
  final bool isLowerLows;

  SwingPoints({
    required this.highs,
    required this.lows,
    required this.isHigherHighs,
    required this.isHigherLows,
    required this.isLowerHighs,
    required this.isLowerLows,
  });
}
