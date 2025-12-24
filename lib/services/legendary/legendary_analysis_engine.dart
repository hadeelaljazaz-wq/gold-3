/// 👑 LEGENDARY ANALYSIS ENGINE 👑
///
/// **محرك التحليل الأسطوري - Gold Nightmare Pro**
///
/// ═══════════════════════════════════════════════════════════════
/// 🎯 الفلسفة: دمج أقوى استراتيجيات التداول الاحترافية
/// ═══════════════════════════════════════════════════════════════
///
/// **المدارس والاستراتيجيات المدمجة:**
/// 1. 📊 **Smart Money Concepts (SMC)**
///    - Order Blocks (كتل الأوامر المؤسسية)
///    - Fair Value Gaps (FVG)
///    - Liquidity Pools
///    - Break of Structure (BOS)
///    - Change of Character (CHoCH)
///
/// 2. 🎓 **ICT Methodology (Inner Circle Trader)**
///    - Optimal Trade Entry (OTE)
///    - Breaker Blocks
///    - Mitigation Blocks
///    - Kill Zones (London/NY)
///    - Market Maker Models
///
/// 3. 📈 **Wyckoff Method**
///    - Accumulation/Distribution Phases
///    - Springs & Upthrusts
///    - Composite Operator Analysis
///    - Volume Spread Analysis (VSA)
///
/// 4. 🌊 **Elliott Wave Theory**
///    - Impulse & Corrective Waves
///    - Fibonacci Extensions
///    - Wave Counting & Validation
///
/// 5. 🎯 **Price Action Master**
///    - Pin Bars, Engulfing, Inside Bars
///    - Support/Resistance Dynamics
///    - Trend Structure Analysis
///
/// 6. 📊 **Volume Profile Analysis**
///    - Point of Control (POC)
///    - Value Area High/Low (VAH/VAL)
///    - Volume Nodes
///
/// **الأهداف:**
/// ✅ دقة 85%+ في التوصيات
/// ✅ مستويات دخول/خروج/وقف حقيقية ومحسوبة
/// ✅ تحليل شامل متعدد الإطارات الزمنية
/// ✅ إدارة مخاطر احترافية
/// ✅ توصيات واضحة وقابلة للتنفيذ
///
library;

import 'dart:math';
import '../../models/candle.dart';
import '../../core/utils/logger.dart';

class LegendaryAnalysisEngine {
  // ═══════════════════════════════════════════════════════════════
  // 🎯 CORE ANALYSIS - التحليل الأساسي
  // ═══════════════════════════════════════════════════════════════

  /// التحليل الشامل الأسطوري
  static Future<LegendaryAnalysisResult> analyzeLegendary({
    required double currentPrice,
    required List<Candle> candles15m, // 100+ candles
    required List<Candle> candles1h, // 100+ candles
    required List<Candle> candles4h, // 100+ candles
    required List<Candle> candlesDaily, // 50+ candles
    required double rsi,
    required double macd,
    required double macdSignal,
    required double atr,
  }) async {
    try {
      AppLogger.analysis('LegendaryEngine', 'Starting LEGENDARY Analysis...');

      // ═══════════════════════════════════════════════════════════
      // 1️⃣ SMART MONEY CONCEPTS - تحليل الأموال الذكية
      // ═══════════════════════════════════════════════════════════
      final smcAnalysis = await _analyzeSmartMoneyConcepts(
        candles15m: candles15m,
        candles1h: candles1h,
        candles4h: candles4h,
        currentPrice: currentPrice,
      );

      // ═══════════════════════════════════════════════════════════
      // 2️⃣ ICT METHODOLOGY - منهجية ICT
      // ═══════════════════════════════════════════════════════════
      final ictAnalysis = await _analyzeICTMethodology(
        candles15m: candles15m,
        candles1h: candles1h,
        candles4h: candles4h,
        currentPrice: currentPrice,
        atr: atr,
      );

      // ═══════════════════════════════════════════════════════════
      // 3️⃣ WYCKOFF ANALYSIS - تحليل وايكوف
      // ═══════════════════════════════════════════════════════════
      final wyckoffAnalysis = await _analyzeWyckoff(
        candles4h: candles4h,
        candlesDaily: candlesDaily,
        currentPrice: currentPrice,
      );

      // ═══════════════════════════════════════════════════════════
      // 4️⃣ ELLIOTT WAVE - موجات إليوت
      // ═══════════════════════════════════════════════════════════
      final elliottAnalysis = await _analyzeElliottWave(
        candles4h: candles4h,
        candlesDaily: candlesDaily,
        currentPrice: currentPrice,
      );

      // ═══════════════════════════════════════════════════════════
      // 5️⃣ VOLUME PROFILE - تحليل الحجم
      // ═══════════════════════════════════════════════════════════
      final volumeAnalysis = await _analyzeVolumeProfile(
        candles15m: candles15m,
        candles1h: candles1h,
        candles4h: candles4h,
        currentPrice: currentPrice,
      );

      // ═══════════════════════════════════════════════════════════
      // 6️⃣ PRICE ACTION MASTER - حركة السعر الاحترافية
      // ═══════════════════════════════════════════════════════════
      final priceActionAnalysis = await _analyzePriceAction(
        candles15m: candles15m,
        candles1h: candles1h,
        currentPrice: currentPrice,
        rsi: rsi,
        macd: macd,
      );

      // ═══════════════════════════════════════════════════════════
      // 7️⃣ CONFLUENCE ANALYSIS - تحليل التقاء العوامل
      // ═══════════════════════════════════════════════════════════
      final confluence = _calculateConfluence(
        smcAnalysis: smcAnalysis,
        ictAnalysis: ictAnalysis,
        wyckoffAnalysis: wyckoffAnalysis,
        elliottAnalysis: elliottAnalysis,
        volumeAnalysis: volumeAnalysis,
        priceActionAnalysis: priceActionAnalysis,
      );

      // ═══════════════════════════════════════════════════════════
      // 8️⃣ GENERATE LEGENDARY SIGNALS - توليد الإشارات الأسطورية
      // ═══════════════════════════════════════════════════════════
      final scalpSignal = _generateScalpingSignal(
        currentPrice: currentPrice,
        confluence: confluence,
        candles15m: candles15m,
        atr: atr,
        smcAnalysis: smcAnalysis,
        ictAnalysis: ictAnalysis,
      );

      final swingSignal = _generateSwingSignal(
        currentPrice: currentPrice,
        confluence: confluence,
        candles4h: candles4h,
        atr: atr,
        wyckoffAnalysis: wyckoffAnalysis,
        elliottAnalysis: elliottAnalysis,
      );

      // ═══════════════════════════════════════════════════════════
      // 9️⃣ SUPPORT & RESISTANCE LEVELS - مستويات الدعم والمقاومة
      // ═══════════════════════════════════════════════════════════
      final supportResistance = _calculateSupportResistance(
        candles4h: candles4h,
        candlesDaily: candlesDaily,
        currentPrice: currentPrice,
        smcAnalysis: smcAnalysis,
        volumeAnalysis: volumeAnalysis,
      );

      // Split support/resistance from the list
      final allLevels = supportResistance;
      final midPoint = currentPrice;
      final supports = allLevels.where((l) => l < midPoint).toList();
      final resistances = allLevels.where((l) => l >= midPoint).toList();

      return LegendaryAnalysisResult(
        scalpSignal: scalpSignal,
        swingSignal: swingSignal,
        supportLevels: supports.isEmpty ? [currentPrice - 10] : supports,
        resistanceLevels:
            resistances.isEmpty ? [currentPrice + 10] : resistances,
        confluence: confluence,
        smcAnalysis: smcAnalysis,
        ictAnalysis: ictAnalysis,
        wyckoffAnalysis: wyckoffAnalysis,
        elliottAnalysis: elliottAnalysis,
        timestamp: DateTime.now(),
      );
    } catch (e, stack) {
      AppLogger.error('LegendaryEngine', 'Analysis failed: $e', stack);
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔥 SMART MONEY CONCEPTS ANALYSIS
  // ═══════════════════════════════════════════════════════════════

  static Future<SMCAnalysis> _analyzeSmartMoneyConcepts({
    required List<Candle> candles15m,
    required List<Candle> candles1h,
    required List<Candle> candles4h,
    required double currentPrice,
  }) async {
    // 1️⃣ Detect Order Blocks (كتل الأوامر)
    final orderBlocks = _detectOrderBlocks(candles4h);

    // 2️⃣ Detect Fair Value Gaps (FVG)
    final fvgs = _detectFairValueGaps(candles15m);

    // 3️⃣ Detect Break of Structure (BOS)
    final bos = _detectBreakOfStructure(candles1h);

    // 4️⃣ Detect Change of Character (CHoCH)
    final choch = _detectChangeOfCharacter(candles1h);

    // 5️⃣ Identify Liquidity Pools
    final liquidityPools = _identifyLiquidityPools(candles4h);

    // 6️⃣ Market Structure (Higher Highs, Lower Lows)
    final marketStructure = _analyzeMarketStructure(candles4h);

    return SMCAnalysis(
      orderBlocks: orderBlocks,
      fairValueGaps: fvgs,
      breakOfStructure: bos,
      changeOfCharacter: choch,
      liquidityPools: liquidityPools,
      marketStructure: marketStructure,
      bias: _determineSMCBias(orderBlocks, fvgs, bos, choch, marketStructure),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🎯 ORDER BLOCKS DETECTION - كشف كتل الأوامر
  // ═══════════════════════════════════════════════════════════════

  static List<OrderBlock> _detectOrderBlocks(List<Candle> candles) {
    List<OrderBlock> blocks = [];

    for (int i = 10; i < candles.length - 10; i++) {
      final candle = candles[i];
      final nextCandles = candles.sublist(i + 1, min(i + 11, candles.length));

      // Bullish Order Block: شمعة هابطة كبيرة تليها حركة صعودية قوية
      if (_isBigBearishCandle(candle)) {
        final hasStrongBullishMove =
            nextCandles.where((c) => c.close > candle.high).length >= 3;
        if (hasStrongBullishMove) {
          blocks.add(OrderBlock(
            type: OrderBlockType.bullish,
            high: candle.high,
            low: candle.low,
            timestamp: candle.time,
            strength: _calculateOrderBlockStrength(candle, nextCandles),
          ));
        }
      }

      // Bearish Order Block: شمعة صعودية كبيرة تليها حركة هبوطية قوية
      if (_isBigBullishCandle(candle)) {
        final hasStrongBearishMove =
            nextCandles.where((c) => c.close < candle.low).length >= 3;
        if (hasStrongBearishMove) {
          blocks.add(OrderBlock(
            type: OrderBlockType.bearish,
            high: candle.high,
            low: candle.low,
            timestamp: candle.time,
            strength: _calculateOrderBlockStrength(candle, nextCandles),
          ));
        }
      }
    }

    // Return the 3 strongest recent blocks
    blocks.sort((a, b) => b.strength.compareTo(a.strength));
    return blocks.take(3).toList();
  }

  static bool _isBigBearishCandle(Candle candle) {
    final body = (candle.open - candle.close).abs();
    final range = candle.high - candle.low;
    return candle.close < candle.open && body / range > 0.6 && range > 2.0;
  }

  static bool _isBigBullishCandle(Candle candle) {
    final body = (candle.close - candle.open).abs();
    final range = candle.high - candle.low;
    return candle.close > candle.open && body / range > 0.6 && range > 2.0;
  }

  static double _calculateOrderBlockStrength(
      Candle orderCandle, List<Candle> followingCandles) {
    // حساب قوة كتلة الأمر بناءً على حجم الشمعة والحركة التالية
    final bodySize = (orderCandle.close - orderCandle.open).abs();
    final avgMove = followingCandles
            .map((c) => (c.close - c.open).abs())
            .reduce((a, b) => a + b) /
        followingCandles.length;

    return min(100.0, (bodySize / avgMove) * 50);
  }

  // ═══════════════════════════════════════════════════════════════
  // 💎 FAIR VALUE GAPS (FVG) DETECTION
  // ═══════════════════════════════════════════════════════════════

  static List<FairValueGap> _detectFairValueGaps(List<Candle> candles) {
    List<FairValueGap> fvgs = [];

    for (int i = 1; i < candles.length - 1; i++) {
      final prev = candles[i - 1];
      final current = candles[i];
      final next = candles[i + 1];

      // Bullish FVG: gap بين أدنى سعر الشمعة القادمة وأعلى سعر الشمعة السابقة
      if (next.low > prev.high) {
        final gap = next.low - prev.high;
        if (gap > 0.5) {
          // فجوة معتبرة
          fvgs.add(FairValueGap(
            type: FVGType.bullish,
            high: next.low,
            low: prev.high,
            timestamp: current.time,
            size: gap,
          ));
        }
      }

      // Bearish FVG: gap بين أعلى سعر الشمعة القادمة وأدنى سعر الشمعة السابقة
      if (next.high < prev.low) {
        final gap = prev.low - next.high;
        if (gap > 0.5) {
          fvgs.add(FairValueGap(
            type: FVGType.bearish,
            high: prev.low,
            low: next.high,
            timestamp: current.time,
            size: gap,
          ));
        }
      }
    }

    // Return the 5 most recent significant FVGs
    return fvgs.reversed.take(5).toList();
  }

  // ═══════════════════════════════════════════════════════════════
  // 📊 BREAK OF STRUCTURE (BOS) DETECTION
  // ═══════════════════════════════════════════════════════════════

  static BreakOfStructure _detectBreakOfStructure(List<Candle> candles) {
    // البحث عن آخر swing high و swing low
    final swingHighs = _findSwingHighs(candles);
    final swingLows = _findSwingLows(candles);

    if (swingHighs.isEmpty || swingLows.isEmpty) {
      return BreakOfStructure(detected: false);
    }

    final lastSwingHigh = swingHighs.last;
    final lastSwingLow = swingLows.last;
    final currentPrice = candles.last.close;

    // Bullish BOS: كسر آخر swing high
    if (currentPrice > lastSwingHigh) {
      return BreakOfStructure(
        detected: true,
        type: BOSType.bullish,
        level: lastSwingHigh,
        timestamp: candles.last.time,
      );
    }

    // Bearish BOS: كسر آخر swing low
    if (currentPrice < lastSwingLow) {
      return BreakOfStructure(
        detected: true,
        type: BOSType.bearish,
        level: lastSwingLow,
        timestamp: candles.last.time,
      );
    }

    return BreakOfStructure(detected: false);
  }

  static List<double> _findSwingHighs(List<Candle> candles,
      {int lookback = 5}) {
    List<double> swingHighs = [];
    for (int i = lookback; i < candles.length - lookback; i++) {
      final current = candles[i].high;
      bool isSwingHigh = true;

      for (int j = i - lookback; j < i + lookback; j++) {
        if (j != i && candles[j].high > current) {
          isSwingHigh = false;
          break;
        }
      }

      if (isSwingHigh) swingHighs.add(current);
    }
    return swingHighs;
  }

  static List<double> _findSwingLows(List<Candle> candles, {int lookback = 5}) {
    List<double> swingLows = [];
    for (int i = lookback; i < candles.length - lookback; i++) {
      final current = candles[i].low;
      bool isSwingLow = true;

      for (int j = i - lookback; j < i + lookback; j++) {
        if (j != i && candles[j].low < current) {
          isSwingLow = false;
          break;
        }
      }

      if (isSwingLow) swingLows.add(current);
    }
    return swingLows;
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔄 CHANGE OF CHARACTER (CHoCH) DETECTION
  // ═══════════════════════════════════════════════════════════════

  static ChangeOfCharacter _detectChangeOfCharacter(List<Candle> candles) {
    // تحليل آخر 20 شمعة
    final recentCandles =
        candles.length > 20 ? candles.sublist(candles.length - 20) : candles;

    // حساب عدد الشموع الصعودية والهبوطية
    int bullishCount = 0;
    int bearishCount = 0;

    for (final candle in recentCandles) {
      if (candle.close > candle.open) {
        bullishCount++;
      } else {
        bearishCount++;
      }
    }

    // CHoCH from Bearish to Bullish
    if (bullishCount >= 12 && bearishCount <= 8) {
      return ChangeOfCharacter(
        detected: true,
        from: TrendDirection.bearish,
        to: TrendDirection.bullish,
        strength: (bullishCount / recentCandles.length * 100),
      );
    }

    // CHoCH from Bullish to Bearish
    if (bearishCount >= 12 && bullishCount <= 8) {
      return ChangeOfCharacter(
        detected: true,
        from: TrendDirection.bullish,
        to: TrendDirection.bearish,
        strength: (bearishCount / recentCandles.length * 100),
      );
    }

    return ChangeOfCharacter(detected: false);
  }

  // ═══════════════════════════════════════════════════════════════
  // 💧 LIQUIDITY POOLS IDENTIFICATION
  // ═══════════════════════════════════════════════════════════════

  static List<LiquidityPool> _identifyLiquidityPools(List<Candle> candles) {
    List<LiquidityPool> pools = [];

    // البحث عن equal highs/lows (مناطق تجمع الأوامر)
    final swingHighs = _findSwingHighs(candles);
    final swingLows = _findSwingLows(candles);

    // Equal Highs - مقاومة قوية
    for (int i = 0; i < swingHighs.length - 1; i++) {
      if ((swingHighs[i] - swingHighs[i + 1]).abs() < 1.0) {
        pools.add(LiquidityPool(
          type: LiquidityType.sellSide,
          level: (swingHighs[i] + swingHighs[i + 1]) / 2,
          strength: 80.0,
        ));
      }
    }

    // Equal Lows - دعم قوي
    for (int i = 0; i < swingLows.length - 1; i++) {
      if ((swingLows[i] - swingLows[i + 1]).abs() < 1.0) {
        pools.add(LiquidityPool(
          type: LiquidityType.buySide,
          level: (swingLows[i] + swingLows[i + 1]) / 2,
          strength: 80.0,
        ));
      }
    }

    return pools.take(4).toList();
  }

  // ═══════════════════════════════════════════════════════════════
  // 📈 MARKET STRUCTURE ANALYSIS
  // ═══════════════════════════════════════════════════════════════

  static MarketStructure _analyzeMarketStructure(List<Candle> candles) {
    final swingHighs = _findSwingHighs(candles);
    final swingLows = _findSwingLows(candles);

    if (swingHighs.length < 2 || swingLows.length < 2) {
      return MarketStructure(trend: TrendDirection.ranging);
    }

    // Uptrend: Higher Highs & Higher Lows
    final hasHigherHighs = swingHighs.last > swingHighs[swingHighs.length - 2];
    final hasHigherLows = swingLows.last > swingLows[swingLows.length - 2];

    if (hasHigherHighs && hasHigherLows) {
      return MarketStructure(
        trend: TrendDirection.bullish,
        strength: 85.0,
        lastSwingHigh: swingHighs.last,
        lastSwingLow: swingLows.last,
      );
    }

    // Downtrend: Lower Highs & Lower Lows
    final hasLowerHighs = swingHighs.last < swingHighs[swingHighs.length - 2];
    final hasLowerLows = swingLows.last < swingLows[swingLows.length - 2];

    if (hasLowerHighs && hasLowerLows) {
      return MarketStructure(
        trend: TrendDirection.bearish,
        strength: 85.0,
        lastSwingHigh: swingHighs.last,
        lastSwingLow: swingLows.last,
      );
    }

    return MarketStructure(trend: TrendDirection.ranging);
  }

  // ═══════════════════════════════════════════════════════════════
  // 🎯 SMC BIAS DETERMINATION
  // ═══════════════════════════════════════════════════════════════

  static TrendDirection _determineSMCBias(
    List<OrderBlock> orderBlocks,
    List<FairValueGap> fvgs,
    BreakOfStructure bos,
    ChangeOfCharacter choch,
    MarketStructure structure,
  ) {
    int bullishScore = 0;
    int bearishScore = 0;

    // Market Structure (40%)
    if (structure.trend == TrendDirection.bullish) bullishScore += 40;
    if (structure.trend == TrendDirection.bearish) bearishScore += 40;

    // BOS (25%)
    if (bos.detected && bos.type == BOSType.bullish) bullishScore += 25;
    if (bos.detected && bos.type == BOSType.bearish) bearishScore += 25;

    // CHoCH (20%)
    if (choch.detected && choch.to == TrendDirection.bullish)
      bullishScore += 20;
    if (choch.detected && choch.to == TrendDirection.bearish)
      bearishScore += 20;

    // Order Blocks (15%)
    final bullishOB =
        orderBlocks.where((ob) => ob.type == OrderBlockType.bullish).length;
    final bearishOB =
        orderBlocks.where((ob) => ob.type == OrderBlockType.bearish).length;
    if (bullishOB > bearishOB) bullishScore += 15;
    if (bearishOB > bullishOB) bearishScore += 15;

    if (bullishScore > bearishScore) return TrendDirection.bullish;
    if (bearishScore > bullishScore) return TrendDirection.bearish;
    return TrendDirection.ranging;
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔧 HELPER METHODS - الدوال المساعدة
  // ═══════════════════════════════════════════════════════════════

  static dynamic _analyzeICTMethodology({
    required List<Candle> candles15m,
    required List<Candle> candles1h,
    required List<Candle> candles4h,
    required double currentPrice,
    required double atr,
  }) {
    // TODO: Implement full ICT analysis from part2
    return null;
  }

  static dynamic _analyzeWyckoff({
    required List<Candle> candles4h,
    required List<Candle> candlesDaily,
    required double currentPrice,
  }) {
    // TODO: Implement full Wyckoff analysis from part2
    return null;
  }

  static dynamic _analyzeElliottWave({
    required List<Candle> candles4h,
    required List<Candle> candlesDaily,
    required double currentPrice,
  }) {
    // TODO: Implement full Elliott Wave analysis from part2
    return null;
  }

  static dynamic _analyzeVolumeProfile({
    required List<Candle> candles15m,
    required List<Candle> candles1h,
    required List<Candle> candles4h,
    required double currentPrice,
  }) {
    // TODO: Implement full Volume Profile analysis from part2
    return null;
  }

  static dynamic _analyzePriceAction({
    required List<Candle> candles15m,
    required List<Candle> candles1h,
    required double currentPrice,
    required double rsi,
    required double macd,
  }) {
    // TODO: Implement Price Action analysis
    return null;
  }

  static double _calculateConfluence({
    required SMCAnalysis smcAnalysis,
    required dynamic ictAnalysis,
    required dynamic wyckoffAnalysis,
    required dynamic elliottAnalysis,
    required dynamic volumeAnalysis,
    required dynamic priceActionAnalysis,
  }) {
    // Simple confluence based on SMC bias
    return smcAnalysis.bias == TrendDirection.bullish
        ? 75.0
        : smcAnalysis.bias == TrendDirection.bearish
            ? 70.0
            : 50.0;
  }

  static dynamic _generateScalpingSignal({
    required double currentPrice,
    required double confluence,
    required List<Candle> candles15m,
    required double atr,
    required SMCAnalysis smcAnalysis,
    required dynamic ictAnalysis,
  }) {
    // TODO: Generate proper scalping signal
    return null;
  }

  static dynamic _generateSwingSignal({
    required double currentPrice,
    required double confluence,
    required List<Candle> candles4h,
    required double atr,
    required dynamic wyckoffAnalysis,
    required dynamic elliottAnalysis,
  }) {
    // TODO: Generate proper swing signal
    return null;
  }

  static List<double> _calculateSupportResistance({
    required List<Candle> candles4h,
    required List<Candle> candlesDaily,
    required double currentPrice,
    required SMCAnalysis smcAnalysis,
    required dynamic volumeAnalysis,
  }) {
    // Use order blocks as support/resistance
    List<double> levels = [];
    for (var ob in smcAnalysis.orderBlocks) {
      levels.add(ob.high);
      levels.add(ob.low);
    }
    return levels.take(6).toList();
  }

  // [باقي الوظائف في الملف التالي...]
}

// ═══════════════════════════════════════════════════════════════
// 📦 DATA MODELS
// ═══════════════════════════════════════════════════════════════

enum OrderBlockType { bullish, bearish }

enum FVGType { bullish, bearish }

enum BOSType { bullish, bearish }

enum LiquidityType { buySide, sellSide }

enum TrendDirection { bullish, bearish, ranging }

class OrderBlock {
  final OrderBlockType type;
  final double high;
  final double low;
  final DateTime timestamp;
  final double strength;

  OrderBlock({
    required this.type,
    required this.high,
    required this.low,
    required this.timestamp,
    required this.strength,
  });
}

class FairValueGap {
  final FVGType type;
  final double high;
  final double low;
  final DateTime timestamp;
  final double size;

  FairValueGap({
    required this.type,
    required this.high,
    required this.low,
    required this.timestamp,
    required this.size,
  });
}

class BreakOfStructure {
  final bool detected;
  final BOSType? type;
  final double? level;
  final DateTime? timestamp;

  BreakOfStructure({
    required this.detected,
    this.type,
    this.level,
    this.timestamp,
  });
}

class ChangeOfCharacter {
  final bool detected;
  final TrendDirection? from;
  final TrendDirection? to;
  final double? strength;

  ChangeOfCharacter({
    required this.detected,
    this.from,
    this.to,
    this.strength,
  });
}

class LiquidityPool {
  final LiquidityType type;
  final double level;
  final double strength;

  LiquidityPool({
    required this.type,
    required this.level,
    required this.strength,
  });
}

class MarketStructure {
  final TrendDirection trend;
  final double? strength;
  final double? lastSwingHigh;
  final double? lastSwingLow;

  MarketStructure({
    required this.trend,
    this.strength,
    this.lastSwingHigh,
    this.lastSwingLow,
  });
}

class SMCAnalysis {
  final List<OrderBlock> orderBlocks;
  final List<FairValueGap> fairValueGaps;
  final BreakOfStructure breakOfStructure;
  final ChangeOfCharacter changeOfCharacter;
  final List<LiquidityPool> liquidityPools;
  final MarketStructure marketStructure;
  final TrendDirection bias;

  SMCAnalysis({
    required this.orderBlocks,
    required this.fairValueGaps,
    required this.breakOfStructure,
    required this.changeOfCharacter,
    required this.liquidityPools,
    required this.marketStructure,
    required this.bias,
  });
}

// [Placeholder for remaining analyses...]
class LegendaryAnalysisResult {
  final dynamic scalpSignal;
  final dynamic swingSignal;
  final List<double> supportLevels;
  final List<double> resistanceLevels;
  final dynamic confluence;
  final SMCAnalysis smcAnalysis;
  final dynamic ictAnalysis;
  final dynamic wyckoffAnalysis;
  final dynamic elliottAnalysis;
  final DateTime timestamp;

  LegendaryAnalysisResult({
    required this.scalpSignal,
    required this.swingSignal,
    required this.supportLevels,
    required this.resistanceLevels,
    required this.confluence,
    required this.smcAnalysis,
    required this.ictAnalysis,
    required this.wyckoffAnalysis,
    required this.elliottAnalysis,
    required this.timestamp,
  });
}
