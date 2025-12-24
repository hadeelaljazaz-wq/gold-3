/// 👑 Gold Nightmare - Swing Trading Engine v2.0
///
/// محرك السوينج الاحترافي المستقل
///
/// **الفلسفة:**
/// - التركيز على الاتجاه العام (Macro Trend)
/// - الصبر والانتظار لنقاط الدخول المثالية
/// - إدارة مخاطر محافظة
/// - فصل كامل عن منطق السكالبينج
///
/// **محسّن للإطار الزمني: 4 ساعات (4h)**
/// - تحليل آخر 150-200 شمعة (25-33 يوم)
/// - MA طويلة: 20, 50, 100, 200
/// - RSI محافظ: 70/30 بدلاً من 60/40
/// - تركيز على الهيكل الكبير والاتجاه العام
///
/// **المكونات الأساسية:**
/// 1. Macro-Trend Analysis - تحليل الاتجاه العام
/// 2. Market Structure - هيكلة السوق (BOS, CHOCH)
/// 3. Fibonacci Retracement - مستويات فيبوناتشي
/// 4. Supply & Demand Zones - مناطق العرض والطلب
/// 5. QCF - Quantum Convergence Framework
/// 6. Reversal Detection - اكتشاف الانعكاسات
/// 7. Confluence Engine - محرك التأكيدات
///
/// **الاختلاف عن v1.0:**
/// - ✅ منطق مستقل تماماً
/// - ✅ تركيز على إطار 4h (بدلاً من H1, H4, D1)
/// - ✅ معايير دخول أكثر صرامة
/// - ✅ R:R أعلى (1:3 على الأقل)
/// - ✅ نظام تأكيدات متعدد الطبقات

import 'dart:math';
import '../../models/candle.dart';
import '../../models/swing_signal.dart';
import '../../models/trade_decision.dart';
import '../signal_validator.dart';
import '../../core/utils/logger.dart';
import '../central_bayesian_engine.dart';
import '../ml_decision_maker.dart';
import '../quantum_scalping/chaos_volatility_engine.dart';

class SwingEngineV2 {
  // ============================================================================
  // PUBLIC API
  // ============================================================================

  /// تحليل شامل وإنتاج إشارة سوينج
  ///
  /// **Parameters:**
  /// - [currentPrice]: السعر الحالي
  /// - [candles]: الشموع (H1, H4, D1)
  /// - [rsi]: RSI الحالي
  /// - [macd]: MACD الحالي
  /// - [macdSignal]: MACD Signal
  /// - [atr]: ATR
  /// - [ma20, ma50, ma100, ma200]: Moving Averages
  ///
  /// **Returns:**
  /// [SwingSignal] - إشارة سوينج كاملة أو NO_TRADE
  static Future<SwingSignal> analyze({
    required double currentPrice,
    required List<Candle> candles,
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
      AppLogger.analysis('SwingEngineV2', 'Starting analysis',
          data: 'Price: \$${currentPrice.toStringAsFixed(2)}');

      // ========================================================================
      // STEP 1: Macro-Trend Analysis (الاتجاه العام)
      // ========================================================================
      final macroTrend = _analyzeMacroTrend(
        candles: candles,
        currentPrice: currentPrice,
        ma20: ma20,
        ma50: ma50,
        ma100: ma100,
        ma200: ma200,
        rsi: rsi,
        macd: macd,
      );

      // ========================================================================
      // STEP 2: Market Structure (هيكلة السوق)
      // ========================================================================
      final marketStructure = _analyzeMarketStructure(candles, currentPrice);

      // ========================================================================
      // STEP 3: Fibonacci Retracement (مستويات فيبوناتشي)
      // ========================================================================
      final fibonacci = _calculateFibonacci(candles, macroTrend.direction);

      // ========================================================================
      // STEP 4: Supply & Demand Zones (مناطق العرض والطلب)
      // ========================================================================
      final zones = _detectSupplyDemandZones(candles, currentPrice);

      // ========================================================================
      // STEP 5: QCF - Quantum Convergence Framework
      // ========================================================================
      final qcf = _analyzeQuantumConvergence(
        macroTrend: macroTrend,
        marketStructure: marketStructure,
        fibonacci: fibonacci,
        zones: zones,
        currentPrice: currentPrice,
        rsi: rsi,
      );

      // ========================================================================
      // STEP 6: Reversal Detection (اكتشاف الانعكاسات)
      // ========================================================================
      final reversal = _detectReversal(
        candles: candles,
        currentPrice: currentPrice,
        rsi: rsi,
        macd: macd,
        zones: zones,
      );

      // ========================================================================
      // STEP 7: Confluence Check (فحص التأكيدات)
      // ========================================================================
      final confluence = _checkConfluence(
        macroTrend: macroTrend,
        marketStructure: marketStructure,
        fibonacci: fibonacci,
        zones: zones,
        qcf: qcf,
        reversal: reversal,
        currentPrice: currentPrice,
      );

      // ========================================================================
      // STEP 8: Generate Signal (توليد الإشارة)
      // ========================================================================
      if (!confluence.isValid) {
        return SwingSignal.noTrade(
            reason: confluence.reason ?? 'Invalid confluence');
      }

      return _generateSwingSignal(
        currentPrice: currentPrice,
        macroTrend: macroTrend,
        marketStructure: marketStructure,
        fibonacci: fibonacci,
        zones: zones,
        qcf: qcf,
        reversal: reversal,
        confluence: confluence,
        atr: atr,
        candles: candles,
      );
    } catch (e, stackTrace) {
      AppLogger.error('SwingEngineV2 analysis failed', e, stackTrace);
      return SwingSignal.noTrade(reason: 'System Error: $e');
    }
  }

  // ============================================================================
  // STEP 1: MACRO-TREND ANALYSIS
  // ============================================================================

  /// تحليل الاتجاه العام (محسّن للإطار الزمني 4 ساعات)
  ///
  /// **المنهجية (مخصصة لـ 4h):**
  /// - تحليل Moving Averages (20, 50, 100, 200)
  /// - اكتشاف Higher Highs/Higher Lows أو Lower Highs/Lower Lows
  /// - تحليل قوة الاتجاه
  /// - تحديد مراحل الاتجاه (Early, Mid, Late)
  /// - تحليل آخر 150 شمعة (25 يوم على 4h)
  static MacroTrend _analyzeMacroTrend({
    required List<Candle> candles,
    required double currentPrice,
    required double ma20,
    required double ma50,
    required double ma100,
    required double ma200,
    required double rsi,
    required double macd,
  }) {
    // ✅ زيادة الحد الأدنى من 100 إلى 150 للتحليل الأعمق
    if (candles.length < 150) {
      return MacroTrend.neutral('Insufficient data');
    }

    int trendScore = 0;
    final signals = <String>[];

    // 1. MA Stacking (الأهم)
    if (ma20 > ma50 && ma50 > ma100 && ma100 > ma200) {
      trendScore += 5;
      signals.add('Perfect MA Stacking (Bullish)');
    } else if (ma20 > ma50 && ma50 > ma100) {
      trendScore += 3;
      signals.add('Strong MA Stacking (Bullish)');
    } else if (ma20 > ma50) {
      trendScore += 1;
      signals.add('Weak MA Stacking (Bullish)');
    } else if (ma20 < ma50 && ma50 < ma100 && ma100 < ma200) {
      trendScore -= 5;
      signals.add('Perfect MA Stacking (Bearish)');
    } else if (ma20 < ma50 && ma50 < ma100) {
      trendScore -= 3;
      signals.add('Strong MA Stacking (Bearish)');
    } else if (ma20 < ma50) {
      trendScore -= 1;
      signals.add('Weak MA Stacking (Bearish)');
    }

    // 2. Price Position relative to MAs
    if (currentPrice > ma20 && currentPrice > ma50) {
      trendScore += 2;
      signals.add('Price above key MAs');
    } else if (currentPrice < ma20 && currentPrice < ma50) {
      trendScore -= 2;
      signals.add('Price below key MAs');
    }

    // 3. Higher Highs / Higher Lows (أو العكس) - وزن أكبر للسوينج
    final swings = _detectMajorSwings(candles);
    if (swings.isHigherHighs && swings.isHigherLows) {
      trendScore += 4; // زيادة من 3
      signals.add('Higher Highs & Higher Lows');
    } else if (swings.isLowerHighs && swings.isLowerLows) {
      trendScore -= 4; // زيادة من -3
      signals.add('Lower Highs & Lower Lows');
    }

    // 4. RSI Trend (محافظ - 70/30 بدلاً من 60/40)
    if (rsi > 70) {
      trendScore += 2; // زيادة الوزن من 1
      signals.add('RSI Strongly Bullish');
    } else if (rsi > 55) {
      trendScore += 1;
      signals.add('RSI Bullish');
    } else if (rsi < 30) {
      trendScore -= 2; // زيادة الوزن من -1
      signals.add('RSI Strongly Bearish');
    } else if (rsi < 45) {
      trendScore -= 1;
      signals.add('RSI Bearish');
    }

    // 5. MACD Trend - وزن أكبر
    if (macd > 0) {
      trendScore += 2; // زيادة من 1
      signals.add('MACD Bullish');
    } else if (macd < 0) {
      trendScore -= 2; // زيادة من -1
      signals.add('MACD Bearish');
    }

    // 6. Candle Dominance (آخر 50 شمعة)
    final last50 = candles.take(50).toList();
    int bullishCount = 0;
    int bearishCount = 0;
    for (final candle in last50) {
      if (candle.close > candle.open) {
        bullishCount++;
      } else {
        bearishCount++;
      }
    }

    if (bullishCount > bearishCount + 10) {
      trendScore += 2;
      signals.add('Strong Bullish Candle Dominance');
    } else if (bearishCount > bullishCount + 10) {
      trendScore -= 2;
      signals.add('Strong Bearish Candle Dominance');
    }

    // تحديد مرحلة الاتجاه
    String phase = 'MID';
    if (trendScore.abs() >= 10) {
      phase = 'LATE'; // اتجاه قوي جداً، قد يكون في مرحلة متأخرة
    } else if (trendScore.abs() >= 5 && trendScore.abs() < 8) {
      phase = 'MID'; // اتجاه متوسط
    } else if (trendScore.abs() > 0 && trendScore.abs() < 5) {
      phase = 'EARLY'; // اتجاه في بدايته
    }

    // تصنيف الاتجاه
    String direction;
    String strength;

    if (trendScore >= 10) {
      direction = 'BULLISH';
      strength = 'VERY_STRONG';
    } else if (trendScore >= 6) {
      direction = 'BULLISH';
      strength = 'STRONG';
    } else if (trendScore >= 3) {
      direction = 'BULLISH';
      strength = 'MODERATE';
    } else if (trendScore >= 1) {
      direction = 'BULLISH';
      strength = 'WEAK';
    } else if (trendScore <= -10) {
      direction = 'BEARISH';
      strength = 'VERY_STRONG';
    } else if (trendScore <= -6) {
      direction = 'BEARISH';
      strength = 'STRONG';
    } else if (trendScore <= -3) {
      direction = 'BEARISH';
      strength = 'MODERATE';
    } else if (trendScore <= -1) {
      direction = 'BEARISH';
      strength = 'WEAK';
    } else {
      direction = 'NEUTRAL';
      strength = 'NONE';
    }

    return MacroTrend(
      direction: direction,
      strength: strength,
      phase: phase,
      score: trendScore,
      signals: signals,
      ma20: ma20,
      ma50: ma50,
      ma100: ma100,
      ma200: ma200,
    );
  }

  // ============================================================================
  // STEP 2: MARKET STRUCTURE
  // ============================================================================

  /// تحليل هيكلة السوق
  ///
  /// **المكونات:**
  /// - Break of Structure (BOS)
  /// - Change of Character (CHOCH)
  /// - Order Blocks
  /// - Fair Value Gaps (FVG)
  static MarketStructure _analyzeMarketStructure(
      List<Candle> candles, double currentPrice) {
    final swings = _detectMajorSwings(candles);

    // اكتشاف BOS (Break of Structure)
    bool hasBOS = false;
    String bosDirection = 'NONE';

    if (swings.highs.length >= 2 && swings.lows.length >= 2) {
      // BOS Bullish: كسر آخر قمة
      if (currentPrice > swings.highs.first) {
        hasBOS = true;
        bosDirection = 'BULLISH';
      }
      // BOS Bearish: كسر آخر قاع
      else if (currentPrice < swings.lows.first) {
        hasBOS = true;
        bosDirection = 'BEARISH';
      }
    }

    // اكتشاف CHOCH (Change of Character)
    bool hasCHOCH = false;
    String chochDirection = 'NONE';

    if (swings.isHigherHighs && swings.isHigherLows) {
      // CHOCH إذا كسر آخر قاع صاعد
      if (swings.lows.length >= 2 && currentPrice < swings.lows[1]) {
        hasCHOCH = true;
        chochDirection = 'BEARISH';
      }
    } else if (swings.isLowerHighs && swings.isLowerLows) {
      // CHOCH إذا كسر آخر قمة هابطة
      if (swings.highs.length >= 2 && currentPrice > swings.highs[1]) {
        hasCHOCH = true;
        chochDirection = 'BULLISH';
      }
    }

    // Order Blocks (آخر شمعة قوية قبل حركة كبيرة)
    final orderBlocks = _detectOrderBlocks(candles);

    // Fair Value Gaps
    final fvgs = _detectFairValueGaps(candles);

    return MarketStructure(
      hasBOS: hasBOS,
      bosDirection: bosDirection,
      hasCHOCH: hasCHOCH,
      chochDirection: chochDirection,
      orderBlocks: orderBlocks,
      fairValueGaps: fvgs,
      swings: swings,
    );
  }

  // ============================================================================
  // STEP 3: FIBONACCI RETRACEMENT
  // ============================================================================

  /// حساب مستويات فيبوناتشي
  ///
  /// **المنهجية:**
  /// - رسم من أعلى قمة إلى أدنى قاع (حسب تفضيل المستخدم)
  /// - المستويات: 0.236, 0.382, 0.5, 0.618, 0.786
  static FibonacciLevels _calculateFibonacci(
      List<Candle> candles, String trendDirection) {
    if (candles.length < 50) {
      return FibonacciLevels.empty();
    }

    final last100 = candles.take(100).toList();

    // إيجاد أعلى قمة وأدنى قاع
    double highestHigh = last100.map((c) => c.high).reduce(max);
    double lowestLow = last100.map((c) => c.low).reduce(min);

    // حسب تفضيل المستخدم: من القمة إلى القاع
    final range = highestHigh - lowestLow;

    final levels = {
      '0.0': lowestLow,
      '0.236': lowestLow + (range * 0.236),
      '0.382': lowestLow + (range * 0.382),
      '0.5': lowestLow + (range * 0.5),
      '0.618': lowestLow + (range * 0.618),
      '0.786': lowestLow + (range * 0.786),
      '1.0': highestHigh,
    };

    return FibonacciLevels(
      highestHigh: highestHigh,
      lowestLow: lowestLow,
      levels: levels,
    );
  }

  // ============================================================================
  // STEP 4: SUPPLY & DEMAND ZONES
  // ============================================================================

  /// اكتشاف مناطق العرض والطلب
  ///
  /// **المنهجية:**
  /// - مناطق الطلب: مناطق انعكاس صاعد قوي
  /// - مناطق العرض: مناطق انعكاس هابط قوي
  /// - قوة المنطقة بناءً على حجم الحركة بعدها
  static SupplyDemandZones _detectSupplyDemandZones(
      List<Candle> candles, double currentPrice) {
    final demandZones = <Zone>[];
    final supplyZones = <Zone>[];

    final last100 = candles.take(100).toList();

    for (int i = 5; i < last100.length - 5; i++) {
      final candle = last100[i];
      final next5 = last100.sublist(i - 5, i);
      final prev5 = last100.sublist(i + 1, min(i + 6, last100.length));

      // Demand Zone: انعكاس صاعد قوي
      if (_isStrongBullishReversal(candle, next5, prev5)) {
        demandZones.add(Zone(
          high: candle.high,
          low: candle.low,
          strength: _calculateZoneStrength(candle, next5),
          touches: 1,
        ));
      }

      // Supply Zone: انعكاس هابط قوي
      if (_isStrongBearishReversal(candle, next5, prev5)) {
        supplyZones.add(Zone(
          high: candle.high,
          low: candle.low,
          strength: _calculateZoneStrength(candle, next5),
          touches: 1,
        ));
      }
    }

    // ترتيب المناطق حسب القوة
    demandZones.sort((a, b) => b.strength.compareTo(a.strength));
    supplyZones.sort((a, b) => b.strength.compareTo(a.strength));

    // الاحتفاظ بأقوى 5 مناطق فقط
    final topDemandZones = demandZones.take(5).toList();
    final topSupplyZones = supplyZones.take(5).toList();

    // إيجاد أقرب منطقة للسعر الحالي
    Zone? nearestDemand;
    Zone? nearestSupply;

    double minDemandDistance = double.infinity;
    double minSupplyDistance = double.infinity;

    for (final zone in topDemandZones) {
      final distance = (currentPrice - zone.high).abs();
      if (distance < minDemandDistance) {
        minDemandDistance = distance;
        nearestDemand = zone;
      }
    }

    for (final zone in topSupplyZones) {
      final distance = (currentPrice - zone.low).abs();
      if (distance < minSupplyDistance) {
        minSupplyDistance = distance;
        nearestSupply = zone;
      }
    }

    return SupplyDemandZones(
      demandZones: topDemandZones,
      supplyZones: topSupplyZones,
      nearestDemand: nearestDemand,
      nearestSupply: nearestSupply,
    );
  }

  // ============================================================================
  // STEP 5: QCF - QUANTUM CONVERGENCE FRAMEWORK
  // ============================================================================

  /// تحليل التقارب الكمي
  ///
  /// **الفلسفة:**
  /// - تقارب عدة عوامل في نقطة واحدة = فرصة قوية
  /// - كلما زاد عدد التأكيدات، زادت الثقة
  static QuantumConvergence _analyzeQuantumConvergence({
    required MacroTrend macroTrend,
    required MarketStructure marketStructure,
    required FibonacciLevels fibonacci,
    required SupplyDemandZones zones,
    required double currentPrice,
    required double rsi,
  }) {
    int convergenceScore = 0;
    final factors = <String>[];

    // 1. Trend Alignment
    if (macroTrend.strength == 'STRONG' ||
        macroTrend.strength == 'VERY_STRONG') {
      convergenceScore += 3;
      factors.add('Strong Macro Trend');
    } else if (macroTrend.strength == 'MODERATE') {
      convergenceScore += 1;
      factors.add('Moderate Macro Trend');
    }

    // 2. Structure Confirmation
    if (marketStructure.hasBOS) {
      convergenceScore += 2;
      factors.add('Break of Structure');
    }

    // 3. Fibonacci Level
    final nearestFibLevel = _findNearestFibLevel(currentPrice, fibonacci);
    if (nearestFibLevel != null && nearestFibLevel.distance < 5.0) {
      convergenceScore += 2;
      factors.add('Near Fibonacci ${nearestFibLevel.level}');
    }

    // 4. Supply/Demand Zone
    if (zones.nearestDemand != null &&
        _isPriceInZone(currentPrice, zones.nearestDemand!)) {
      convergenceScore += 3;
      factors.add('In Demand Zone');
    } else if (zones.nearestSupply != null &&
        _isPriceInZone(currentPrice, zones.nearestSupply!)) {
      convergenceScore += 3;
      factors.add('In Supply Zone');
    }

    // 5. RSI Extreme
    if (rsi < 30 || rsi > 70) {
      convergenceScore += 2;
      factors.add('RSI Extreme');
    }

    // تصنيف التقارب
    String classification;
    if (convergenceScore >= 8) {
      classification = 'VERY_HIGH';
    } else if (convergenceScore >= 5) {
      classification = 'HIGH';
    } else if (convergenceScore >= 3) {
      classification = 'MODERATE';
    } else {
      classification = 'LOW';
    }

    return QuantumConvergence(
      score: convergenceScore,
      classification: classification,
      factors: factors,
    );
  }

  // ============================================================================
  // STEP 6: REVERSAL DETECTION
  // ============================================================================

  /// اكتشاف الانعكاسات
  ///
  /// **الأنماط:**
  /// - Double Top/Bottom
  /// - Head & Shoulders
  /// - RSI Divergence
  /// - Candlestick Patterns
  static ReversalDetection _detectReversal({
    required List<Candle> candles,
    required double currentPrice,
    required double rsi,
    required double macd,
    required SupplyDemandZones zones,
  }) {
    final patterns = <String>[];
    int reversalScore = 0;

    // 1. Double Top/Bottom
    final doublePattern = _detectDoublePattern(candles);
    if (doublePattern != null) {
      reversalScore += 3;
      patterns.add(doublePattern);
    }

    // 2. RSI Divergence
    if (candles.length >= 14) {
      // حساب RSI للشموع السابقة
      final closes = candles.map((c) => c.close).toList();
      final rsiValues = <double>[];

      // حساب RSI لكل شمعة (نحتاج على الأقل 14 شمعة)
      for (int i = 14; i < closes.length; i++) {
        final periodCloses = closes.sublist(i - 14, i + 1);
        final rsi = _calculateRSI(periodCloses);
        rsiValues.add(rsi);
      }

      // البحث عن Divergence
      if (rsiValues.length >= 5 && candles.length >= 19) {
        final recentCandles =
            candles.sublist(candles.length - rsiValues.length);
        final recentRsi = rsiValues.sublist(rsiValues.length - 5);

        // Bullish Divergence: السعر يصنع قيعان أقل لكن RSI يصنع قيعان أعلى
        final priceLows = recentCandles.map((c) => c.low).toList();
        final rsiLows = recentRsi;

        if (priceLows.length >= 2 && rsiLows.length >= 2) {
          final lastPriceLow = priceLows.last;
          final prevPriceLow = priceLows[priceLows.length - 2];
          final lastRsiLow = rsiLows.last;
          final prevRsiLow = rsiLows[rsiLows.length - 2];

          if (lastPriceLow < prevPriceLow && lastRsiLow > prevRsiLow) {
            reversalScore += 4;
            patterns.add('RSI Bullish Divergence');
          }
        }

        // Bearish Divergence: السعر يصنع قمم أعلى لكن RSI يصنع قمم أقل
        final priceHighs = recentCandles.map((c) => c.high).toList();

        if (priceHighs.length >= 2 && rsiLows.length >= 2) {
          final lastPriceHigh = priceHighs.last;
          final prevPriceHigh = priceHighs[priceHighs.length - 2];
          final lastRsiHigh = rsiLows.last;
          final prevRsiHigh = rsiLows[rsiLows.length - 2];

          if (lastPriceHigh > prevPriceHigh && lastRsiHigh < prevRsiHigh) {
            reversalScore += 4;
            patterns.add('RSI Bearish Divergence');
          }
        }
      }
    }

    // 3. Candlestick Patterns
    if (candles.length >= 3) {
      final last3 = candles.take(3).toList();

      // Hammer / Shooting Star
      if (_isHammer(last3.first)) {
        reversalScore += 2;
        patterns.add('Hammer (Bullish Reversal)');
      } else if (_isShootingStar(last3.first)) {
        reversalScore += 2;
        patterns.add('Shooting Star (Bearish Reversal)');
      }

      // Engulfing
      if (_isBullishEngulfing(last3[1], last3[0])) {
        reversalScore += 2;
        patterns.add('Bullish Engulfing');
      } else if (_isBearishEngulfing(last3[1], last3[0])) {
        reversalScore += 2;
        patterns.add('Bearish Engulfing');
      }
    }

    // 4. Price at Zone
    bool atDemandZone = zones.nearestDemand != null &&
        _isPriceInZone(currentPrice, zones.nearestDemand!);
    bool atSupplyZone = zones.nearestSupply != null &&
        _isPriceInZone(currentPrice, zones.nearestSupply!);

    if (atDemandZone || atSupplyZone) {
      reversalScore += 2;
      patterns.add(atDemandZone ? 'At Demand Zone' : 'At Supply Zone');
    }

    bool hasReversal = reversalScore >= 4;
    String? direction;

    if (hasReversal) {
      // تحديد اتجاه الانعكاس
      if (atDemandZone || patterns.any((p) => p.contains('Bullish'))) {
        direction = 'BULLISH';
      } else if (atSupplyZone || patterns.any((p) => p.contains('Bearish'))) {
        direction = 'BEARISH';
      }
    }

    return ReversalDetection(
      hasReversal: hasReversal,
      direction: direction,
      patterns: patterns,
      score: reversalScore,
    );
  }

  // ============================================================================
  // STEP 7: CONFLUENCE CHECK
  // ============================================================================

  /// فحص التأكيدات
  ///
  /// **المعايير:**
  /// - يجب وجود اتجاه واضح
  /// - يجب وجود تقارب عالي
  /// - يجب وجود تأكيد من الهيكلة
  /// - يجب وجود منطقة دعم/مقاومة
  static ConfluenceCheck _checkConfluence({
    required MacroTrend macroTrend,
    required MarketStructure marketStructure,
    required FibonacciLevels fibonacci,
    required SupplyDemandZones zones,
    required QuantumConvergence qcf,
    required ReversalDetection reversal,
    required double currentPrice,
  }) {
    final issues = <String>[];
    int confidenceScore = 0;

    // 1. Trend Check
    if (macroTrend.direction == 'NEUTRAL') {
      issues.add('No clear macro trend');
      return ConfluenceCheck.invalid('No clear macro trend', 0);
    } else {
      confidenceScore += 20;
    }

    // 2. Trend Strength
    if (macroTrend.strength == 'VERY_STRONG' ||
        macroTrend.strength == 'STRONG') {
      confidenceScore += 20;
    } else if (macroTrend.strength == 'MODERATE') {
      confidenceScore += 10;
    } else {
      issues.add('Weak trend');
      confidenceScore += 5;
    }

    // 3. Convergence
    if (qcf.classification == 'VERY_HIGH') {
      confidenceScore += 30;
    } else if (qcf.classification == 'HIGH') {
      confidenceScore += 20;
    } else if (qcf.classification == 'MODERATE') {
      confidenceScore += 10;
    } else {
      issues.add('Low convergence');
      confidenceScore += 5;
    }

    // 4. Structure Confirmation
    if (marketStructure.hasBOS || marketStructure.hasCHOCH) {
      confidenceScore += 15;
    } else {
      issues.add('No structure confirmation');
    }

    // 5. Zone Proximity
    bool nearZone = (zones.nearestDemand != null &&
            _isPriceNearZone(currentPrice, zones.nearestDemand!, 10.0)) ||
        (zones.nearestSupply != null &&
            _isPriceNearZone(currentPrice, zones.nearestSupply!, 10.0));

    if (nearZone) {
      confidenceScore += 15;
    } else {
      issues.add('Not near supply/demand zone');
    }

    // 6. Minimum Confidence
    if (confidenceScore < 60) {
      return ConfluenceCheck.invalid(
        'Confidence too low (${confidenceScore}%)',
        confidenceScore,
      );
    }

    // تحديد الاتجاه النهائي
    String direction = macroTrend.direction;

    // إذا كان هناك انعكاس قوي، قد نأخذه في الاعتبار
    if (reversal.hasReversal && reversal.score >= 6) {
      direction = reversal.direction ?? direction;
    }

    return ConfluenceCheck.valid(
      direction: direction,
      confidenceScore: confidenceScore,
      issues: issues,
    );
  }

  // ============================================================================
  // STEP 8: GENERATE SWING SIGNAL
  // ============================================================================

  /// توليد إشارة السوينج النهائية
  static SwingSignal _generateSwingSignal({
    required double currentPrice,
    required MacroTrend macroTrend,
    required MarketStructure marketStructure,
    required FibonacciLevels fibonacci,
    required SupplyDemandZones zones,
    required QuantumConvergence qcf,
    required ReversalDetection reversal,
    required ConfluenceCheck confluence,
    required double atr,
    required List<Candle> candles,
  }) {
    final direction = confluence.direction;
    final isBuy = direction == 'BULLISH';
    final signalDirection = isBuy ? 'BUY' : 'SELL';

    final entryPrice = currentPrice;

    // SWING: حساب ديناميكي باستخدام ATR - أهداف أكبر من السكالب
    // الفرق الرئيسي: السوينج يستخدم ATR مضاعف أكبر بكثير
    final atrMultiplierStop = 3.5; // 3.5x ATR للستوب (أوسع من السكالب)
    final stopLossDistance = atr * atrMultiplierStop;
    
    // هدف السوينج = 3x إلى 5x الريسك (R:R = 1:3 إلى 1:5)
    final riskRewardRatio = 4.0; // R:R = 1:4 (احترافي للسوينج)
    final takeProfitDistance = stopLossDistance * riskRewardRatio;
    
    double stopLoss;
    if (isBuy) {
      stopLoss = entryPrice - stopLossDistance;
    } else {
      stopLoss = entryPrice + stopLossDistance;
    }
    final takeProfit = isBuy
        ? entryPrice + takeProfitDistance
        : entryPrice - takeProfitDistance;

    final riskReward = takeProfitDistance / stopLossDistance;
    
    // ═══════════════════════════════════════════════════════════════════════════
    // DETAILED LOGGING
    // ═══════════════════════════════════════════════════════════════════════════
    AppLogger.info('═══════════════════════════════════════');
    AppLogger.info('🎯 SWING ENGINE CALCULATION (ATR-BASED WIDE):');
    AppLogger.info('  Entry: \$${entryPrice.toStringAsFixed(2)}');
    AppLogger.info('  Direction: $signalDirection');
    AppLogger.info('  ATR: ${atr.toStringAsFixed(3)}');
    AppLogger.info('  Zones - Demand: ${zones.nearestDemand?.low.toStringAsFixed(2) ?? "N/A"}, Supply: ${zones.nearestSupply?.high.toStringAsFixed(2) ?? "N/A"}');
    AppLogger.info('  Stop: ${atrMultiplierStop}x ATR = \$${stopLossDistance.toStringAsFixed(3)} (${((stopLossDistance/entryPrice)*100).toStringAsFixed(2)}%)');
    AppLogger.info('  Target: ${riskRewardRatio}x Risk = \$${takeProfitDistance.toStringAsFixed(3)} (${((takeProfitDistance/entryPrice)*100).toStringAsFixed(2)}%)');
    AppLogger.info('  Stop Loss: \$${stopLoss.toStringAsFixed(2)}');
    AppLogger.info('  Take Profit: \$${takeProfit.toStringAsFixed(2)}');
    AppLogger.info('  R:R: ${riskReward.toStringAsFixed(2)}');
    AppLogger.info('  🔥 SWING targets are 3-4x LARGER than SCALP');
    AppLogger.info('═══════════════════════════════════════');

    // ========================================================================
    // CRITICAL: VALIDATE SIGNAL BEFORE RETURNING
    // ========================================================================
    final validation = SignalValidator.validateSwingSignal(
      direction: signalDirection,
      entry: entryPrice,
      stop: stopLoss,
      target: takeProfit,
    );

    // If validation fails, return NO_TRADE signal
    if (!validation.isValid) {
      return SwingSignal.noTrade(
        reason: 'Validation failed: ${validation.errorMessage}',
      );
    }

    // Log warnings if any
    if (validation.warnings.isNotEmpty) {
      AppLogger.warn(
          '⚠️ SwingEngine Warnings: ${validation.warnings.join(", ")}');
    }

    // 🔍 DEBUG: Log signal for validation
    AppLogger.info('🎯 SwingEngineV2 Generated Signal:');
    AppLogger.info('   Direction: $signalDirection');
    AppLogger.info('   Entry: \$$entryPrice');
    AppLogger.info('   Stop Loss: \$$stopLoss');
    AppLogger.info('   Take Profit: \$$takeProfit');
    AppLogger.info('   Confidence: ${confluence.confidenceScore}%');
    
    return SwingSignal(
      direction: signalDirection,
      entryPrice: entryPrice,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
      confidence: confluence.confidenceScore,
      riskReward: validation.calculatedRR ?? riskReward,
      macroTrend: macroTrend,
      marketStructure: marketStructure,
      fibonacci: fibonacci,
      zones: zones,
      qcf: qcf,
      reversal: reversal,
      timestamp: DateTime.now(),
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// اكتشاف نقاط التأرجح الرئيسية
  static MajorSwings _detectMajorSwings(List<Candle> candles) {
    final highs = <double>[];
    final lows = <double>[];

    for (int i = 10; i < candles.length - 10; i++) {
      bool isHigh = true;
      bool isLow = true;

      for (int j = i - 10; j <= i + 10; j++) {
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

    return MajorSwings(
      highs: highs,
      lows: lows,
      isHigherHighs: isHigherHighs,
      isHigherLows: isHigherLows,
      isLowerHighs: isLowerHighs,
      isLowerLows: isLowerLows,
    );
  }

  /// اكتشاف Order Blocks
  /// Order Blocks هي مناطق حيث المؤسسات الكبيرة وضعت أوامر كبيرة
  /// تتميز بشموع قوية مع wicks صغيرة
  static List<OrderBlock> _detectOrderBlocks(List<Candle> candles) {
    if (candles.length < 3) return [];

    final orderBlocks = <OrderBlock>[];

    for (int i = 2; i < candles.length; i++) {
      final current = candles[i];
      final previous = candles[i - 1];
      final beforePrevious = candles[i - 2];

      // Order Block Bullish: شمعة صاعدة قوية بعد شموع هابطة
      if (current.close > current.open &&
          previous.close < previous.open &&
          beforePrevious.close < beforePrevious.open) {
        final bodySize = current.close - current.open;
        final totalRange = current.high - current.low;

        // يجب أن تكون الشمعة قوية (body > 70% من النطاق)
        if (bodySize / totalRange > 0.7) {
          final upperBound = current.high;
          final lowerBound = min(current.open, current.close);

          orderBlocks.add(OrderBlock(
            high: upperBound,
            low: lowerBound,
            type: 'BULLISH',
          ));
        }
      }

      // Order Block Bearish: شمعة هابطة قوية بعد شموع صاعدة
      if (current.close < current.open &&
          previous.close > previous.open &&
          beforePrevious.close > beforePrevious.open) {
        final bodySize = current.open - current.close;
        final totalRange = current.high - current.low;

        // يجب أن تكون الشمعة قوية (body > 70% من النطاق)
        if (bodySize / totalRange > 0.7) {
          final upperBound = max(current.open, current.close);
          final lowerBound = current.low;

          orderBlocks.add(OrderBlock(
            high: upperBound,
            low: lowerBound,
            type: 'BEARISH',
          ));
        }
      }
    }

    return orderBlocks;
  }

  /// اكتشاف Fair Value Gaps (FVG)
  /// FVG هي فجوات في السعر حيث لا يوجد تداول
  /// تحدث عندما تترك الشمعة السابقة wick غير مغطاة
  static List<FairValueGap> _detectFairValueGaps(List<Candle> candles) {
    if (candles.length < 3) return [];

    final fvgs = <FairValueGap>[];

    for (int i = 1; i < candles.length - 1; i++) {
      final previous = candles[i - 1];
      final current = candles[i];
      final next = candles[i + 1];

      // Bullish FVG: الشمعة السابقة لها upper wick غير مغطاة
      // والشمعة الحالية لا تغطيها
      if (previous.high > current.low && current.low > previous.close) {
        final gapHigh = min(previous.high, current.low);
        final gapLow = max(previous.close, current.open);

        if (gapHigh > gapLow) {
          // التحقق من أن الشمعة التالية لم تغطي الفجوة
          if (next.low > gapLow) {
            fvgs.add(FairValueGap(
              high: gapHigh,
              low: gapLow,
              type: 'BULLISH',
            ));
          }
        }
      }

      // Bearish FVG: الشمعة السابقة لها lower wick غير مغطاة
      // والشمعة الحالية لا تغطيها
      if (previous.low < current.high && current.high < previous.close) {
        final gapHigh = min(previous.close, current.open);
        final gapLow = max(previous.low, current.high);

        if (gapHigh > gapLow) {
          // التحقق من أن الشمعة التالية لم تغطي الفجوة
          if (next.high < gapHigh) {
            fvgs.add(FairValueGap(
              high: gapHigh,
              low: gapLow,
              type: 'BEARISH',
            ));
          }
        }
      }
    }

    return fvgs;
  }

  /// التحقق من انعكاس صاعد قوي
  static bool _isStrongBullishReversal(
      Candle candle, List<Candle> before, List<Candle> after) {
    // شمعة صاعدة كبيرة بعد حركة هابطة
    final isBullish = candle.close > candle.open;
    final bodySize = (candle.close - candle.open).abs();
    final avgBefore =
        before.map((c) => (c.close - c.open).abs()).reduce((a, b) => a + b) /
            before.length;

    return isBullish && bodySize > avgBefore * 2.0;
  }

  /// التحقق من انعكاس هابط قوي
  static bool _isStrongBearishReversal(
      Candle candle, List<Candle> before, List<Candle> after) {
    final isBearish = candle.close < candle.open;
    final bodySize = (candle.close - candle.open).abs();
    final avgBefore =
        before.map((c) => (c.close - c.open).abs()).reduce((a, b) => a + b) /
            before.length;

    return isBearish && bodySize > avgBefore * 2.0;
  }

  /// حساب قوة المنطقة
  static double _calculateZoneStrength(Candle candle, List<Candle> next) {
    final bodySize = (candle.close - candle.open).abs();
    final avgNext =
        next.map((c) => (c.close - c.open).abs()).reduce((a, b) => a + b) /
            next.length;
    return bodySize / avgNext;
  }

  /// إيجاد أقرب مستوى فيبوناتشي
  static FibLevel? _findNearestFibLevel(double price, FibonacciLevels fib) {
    if (fib.levels.isEmpty) return null;

    double minDistance = double.infinity;
    String? nearestLevel;

    for (final entry in fib.levels.entries) {
      final distance = (price - entry.value).abs();
      if (distance < minDistance) {
        minDistance = distance;
        nearestLevel = entry.key;
      }
    }

    return nearestLevel != null
        ? FibLevel(
            level: nearestLevel,
            price: fib.levels[nearestLevel]!,
            distance: minDistance)
        : null;
  }

  /// التحقق من وجود السعر داخل منطقة
  static bool _isPriceInZone(double price, Zone zone) {
    return price >= zone.low && price <= zone.high;
  }

  /// التحقق من قرب السعر من منطقة
  static bool _isPriceNearZone(double price, Zone zone, double threshold) {
    final distanceToLow = (price - zone.low).abs();
    final distanceToHigh = (price - zone.high).abs();
    return distanceToLow <= threshold || distanceToHigh <= threshold;
  }

  /// اكتشاف Double Top/Bottom
  /// نمط انعكاسي قوي يشير إلى تغيير محتمل في الاتجاه
  static String? _detectDoublePattern(List<Candle> candles) {
    if (candles.length < 20) return null;

    // البحث عن Double Top
    // يحتاج إلى قمتين متقاربتين في السعر مع قاع بينهما
    final highs = <double>[];
    final lows = <double>[];

    for (int i = 1; i < candles.length - 1; i++) {
      final current = candles[i];
      final previous = candles[i - 1];
      final next = candles[i + 1];

      // Peak detection
      if (current.high > previous.high && current.high > next.high) {
        highs.add(current.high);
      }

      // Trough detection
      if (current.low < previous.low && current.low < next.low) {
        lows.add(current.low);
      }
    }

    if (highs.length < 2 || lows.length < 1) return null;

    // البحث عن Double Top
    for (int i = 0; i < highs.length - 1; i++) {
      final firstHigh = highs[i];
      final secondHigh = highs[i + 1];

      // يجب أن تكون القمتان متقاربتين (فارق أقل من 0.5%)
      final priceDiff = ((firstHigh - secondHigh).abs() / firstHigh * 100);
      if (priceDiff < 0.5) {
        // يجب أن يكون هناك قاع بين القمتين
        final middleLow = lows.firstWhere(
          (low) => low < firstHigh && low < secondHigh,
          orElse: () => double.infinity,
        );

        if (middleLow != double.infinity) {
          // يجب أن يكون القاع أقل من القمتين بنسبة معقولة
          final lowDiff1 = ((firstHigh - middleLow) / firstHigh * 100);
          final lowDiff2 = ((secondHigh - middleLow) / secondHigh * 100);

          if (lowDiff1 > 1.0 && lowDiff2 > 1.0) {
            return 'Double Top (Bearish Reversal)';
          }
        }
      }
    }

    // البحث عن Double Bottom
    for (int i = 0; i < lows.length - 1; i++) {
      final firstLow = lows[i];
      final secondLow = lows[i + 1];

      // يجب أن تكون القيعان متقاربتين (فارق أقل من 0.5%)
      final priceDiff = ((firstLow - secondLow).abs() / firstLow * 100);
      if (priceDiff < 0.5) {
        // يجب أن يكون هناك قمة بين القيعان
        final middleHigh = highs.firstWhere(
          (high) => high > firstLow && high > secondLow,
          orElse: () => 0.0,
        );

        if (middleHigh > 0) {
          // يجب أن تكون القمة أعلى من القيعان بنسبة معقولة
          final highDiff1 = ((middleHigh - firstLow) / firstLow * 100);
          final highDiff2 = ((middleHigh - secondLow) / secondLow * 100);

          if (highDiff1 > 1.0 && highDiff2 > 1.0) {
            return 'Double Bottom (Bullish Reversal)';
          }
        }
      }
    }

    return null;
  }

  /// التحقق من Hammer
  static bool _isHammer(Candle candle) {
    final body = (candle.close - candle.open).abs();
    final lowerWick = min(candle.open, candle.close) - candle.low;
    final upperWick = candle.high - max(candle.open, candle.close);
    return lowerWick > body * 2 && upperWick < body * 0.5;
  }

  /// التحقق من Shooting Star
  static bool _isShootingStar(Candle candle) {
    final body = (candle.close - candle.open).abs();
    final upperWick = candle.high - max(candle.open, candle.close);
    final lowerWick = min(candle.open, candle.close) - candle.low;
    return upperWick > body * 2 && lowerWick < body * 0.5;
  }

  /// التحقق من Bullish Engulfing
  static bool _isBullishEngulfing(Candle prev, Candle current) {
    return prev.close < prev.open && // شمعة سابقة هابطة
        current.close > current.open && // شمعة حالية صاعدة
        current.open < prev.close && // فتح أقل من إغلاق السابقة
        current.close > prev.open; // إغلاق أعلى من فتح السابقة
  }

  /// التحقق من Bearish Engulfing
  static bool _isBearishEngulfing(Candle prev, Candle current) {
    return prev.close > prev.open && // شمعة سابقة صاعدة
        current.close < current.open && // شمعة حالية هابطة
        current.open > prev.close && // فتح أعلى من إغلاق السابقة
        current.close < prev.open; // إغلاق أقل من فتح السابقة
  }

  /// حساب RSI (Relative Strength Index)
  static double _calculateRSI(List<double> prices, {int period = 14}) {
    if (prices.length < period + 1) return 50.0;

    double avgGain = 0;
    double avgLoss = 0;

    // Calculate initial average gain/loss
    for (int i = 1; i <= period; i++) {
      final change = prices[i] - prices[i - 1];
      if (change > 0) {
        avgGain += change;
      } else {
        avgLoss += change.abs();
      }
    }

    avgGain /= period;
    avgLoss /= period;

    // Calculate subsequent values
    for (int i = period + 1; i < prices.length; i++) {
      final change = prices[i] - prices[i - 1];
      if (change > 0) {
        avgGain = (avgGain * (period - 1) + change) / period;
        avgLoss = (avgLoss * (period - 1)) / period;
      } else {
        avgGain = (avgGain * (period - 1)) / period;
        avgLoss = (avgLoss * (period - 1) + change.abs()) / period;
      }
    }

    if (avgLoss == 0) return 100;

    final rs = avgGain / avgLoss;
    return 100 - (100 / (1 + rs));
  }
}

// ==============================================================================
// DATA CLASSES
// ==============================================================================

/// Macro Trend
class MacroTrend {
  final String direction; // BULLISH, BEARISH, NEUTRAL
  final String strength; // VERY_STRONG, STRONG, MODERATE, WEAK, NONE
  final String phase; // EARLY, MID, LATE
  final int score;
  final List<String> signals;
  final double ma20;
  final double ma50;
  final double ma100;
  final double ma200;

  MacroTrend({
    required this.direction,
    required this.strength,
    required this.phase,
    required this.score,
    required this.signals,
    required this.ma20,
    required this.ma50,
    required this.ma100,
    required this.ma200,
  });

  factory MacroTrend.neutral(String reason) {
    return MacroTrend(
      direction: 'NEUTRAL',
      strength: 'NONE',
      phase: 'MID',
      score: 0,
      signals: [reason],
      ma20: 0,
      ma50: 0,
      ma100: 0,
      ma200: 0,
    );
  }
}

/// Market Structure
class MarketStructure {
  final bool hasBOS;
  final String bosDirection;
  final bool hasCHOCH;
  final String chochDirection;
  final List<OrderBlock> orderBlocks;
  final List<FairValueGap> fairValueGaps;
  final MajorSwings swings;

  MarketStructure({
    required this.hasBOS,
    required this.bosDirection,
    required this.hasCHOCH,
    required this.chochDirection,
    required this.orderBlocks,
    required this.fairValueGaps,
    required this.swings,
  });
}

/// Major Swings
class MajorSwings {
  final List<double> highs;
  final List<double> lows;
  final bool isHigherHighs;
  final bool isHigherLows;
  final bool isLowerHighs;
  final bool isLowerLows;

  MajorSwings({
    required this.highs,
    required this.lows,
    required this.isHigherHighs,
    required this.isHigherLows,
    required this.isLowerHighs,
    required this.isLowerLows,
  });
}

/// Order Block
class OrderBlock {
  final double high;
  final double low;
  final String type; // BULLISH, BEARISH

  OrderBlock({
    required this.high,
    required this.low,
    required this.type,
  });
}

/// Fair Value Gap
class FairValueGap {
  final double high;
  final double low;
  final String type; // BULLISH, BEARISH

  FairValueGap({
    required this.high,
    required this.low,
    required this.type,
  });
}

/// Fibonacci Levels
class FibonacciLevels {
  final double highestHigh;
  final double lowestLow;
  final Map<String, double> levels;

  FibonacciLevels({
    required this.highestHigh,
    required this.lowestLow,
    required this.levels,
  });

  factory FibonacciLevels.empty() {
    return FibonacciLevels(
      highestHigh: 0,
      lowestLow: 0,
      levels: {},
    );
  }
}

/// Fib Level
class FibLevel {
  final String level;
  final double price;
  final double distance;

  FibLevel({
    required this.level,
    required this.price,
    required this.distance,
  });
}

/// Supply & Demand Zones
class SupplyDemandZones {
  final List<Zone> demandZones;
  final List<Zone> supplyZones;
  final Zone? nearestDemand;
  final Zone? nearestSupply;

  SupplyDemandZones({
    required this.demandZones,
    required this.supplyZones,
    this.nearestDemand,
    this.nearestSupply,
  });
}

/// Zone
class Zone {
  final double high;
  final double low;
  final double strength;
  final int touches;

  Zone({
    required this.high,
    required this.low,
    required this.strength,
    required this.touches,
  });
}

/// Quantum Convergence
class QuantumConvergence {
  final int score;
  final String classification; // VERY_HIGH, HIGH, MODERATE, LOW
  final List<String> factors;

  QuantumConvergence({
    required this.score,
    required this.classification,
    required this.factors,
  });
}

/// Reversal Detection
class ReversalDetection {
  final bool hasReversal;
  final String? direction;
  final List<String> patterns;
  final int score;

  ReversalDetection({
    required this.hasReversal,
    this.direction,
    required this.patterns,
    required this.score,
  });
}

/// Confluence Check
class ConfluenceCheck {
  final bool isValid;
  final String direction;
  final int confidenceScore;
  final List<String> issues;
  final String? reason;

  ConfluenceCheck({
    required this.isValid,
    required this.direction,
    required this.confidenceScore,
    required this.issues,
    this.reason,
  });

  factory ConfluenceCheck.valid({
    required String direction,
    required int confidenceScore,
    List<String>? issues,
  }) {
    return ConfluenceCheck(
      isValid: true,
      direction: direction,
      confidenceScore: confidenceScore,
      issues: issues ?? [],
    );
  }

  factory ConfluenceCheck.invalid(String reason, int confidenceScore) {
    return ConfluenceCheck(
      isValid: false,
      direction: 'NONE',
      confidenceScore: confidenceScore,
      issues: [reason],
      reason: reason,
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 🆕 SWING ENGINE V2 - ENHANCED EXTENSIONS
// ══════════════════════════════════════════════════════════════════

class SwingEngineV2Enhanced {
  /// تحليل محسّن للسوينج مع Bayesian + Chaos + ML
  static Future<Map<String, dynamic>> analyzeEnhanced({
    required double currentPrice,
    required List<Candle> candles,
    required double rsi,
    required double macd,
    required double macdSignal,
    required double atr,
    required double ma20,
    required double ma50,
    required double ma100,
    required double ma200,
    double accountBalance = 10000.0,
  }) async {
    // الحصول على الإشارة الأصلية
    final originalSignal = await SwingEngineV2.analyze(
      currentPrice: currentPrice,
      candles: candles,
      rsi: rsi,
      macd: macd,
      macdSignal: macdSignal,
      atr: atr,
      ma20: ma20,
      ma50: ma50,
      ma100: ma100,
      ma200: ma200,
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
    
    // Trend from MAs
    final trendStrength = _calculateTrendStrengthFromMAs(ma20, ma50, ma100, ma200, currentPrice);
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
      timeframeAlignment: 0.85, // Swing = higher timeframe alignment
      structureQuality: 0.75,
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
      timeframeAlignment: 0.85,
      volumeProfile: volumeProfile,
      structureQuality: 0.75,
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

  static double _calculateTrendStrengthFromMAs(
    double ma20,
    double ma50,
    double ma100,
    double ma200,
    double currentPrice,
  ) {
    int bullish = 0;
    int bearish = 0;

    if (ma20 > ma50) {
      bullish++;
    } else {
      bearish++;
    }
    if (ma50 > ma100) {
      bullish++;
    } else {
      bearish++;
    }
    if (ma100 > ma200) {
      bullish++;
    } else {
      bearish++;
    }
    if (currentPrice > ma20) {
      bullish++;
    } else {
      bearish++;
    }
    if (currentPrice > ma50) {
      bullish++;
    } else {
      bearish++;
    }

    final strength = (bullish - bearish) / 5.0;
    return strength.clamp(-1.0, 1.0);
  }

  static double _calculateVolumeProfileQuick(List<Candle> recentCandles) {
    if (recentCandles.isEmpty) {
      return 0.5;
    }

    final volumes = recentCandles.map((c) => c.volume).toList();
    final avgVolume = volumes.reduce((a, b) => a + b) / volumes.length;
    final currentVolume = volumes.last;

    return (currentVolume / avgVolume).clamp(0.0, 1.0);
  }
}
