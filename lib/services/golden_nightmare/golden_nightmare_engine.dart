// 🔥 GOLDEN NIGHTMARE MASTER ENGINE - THE NUCLEAR VERSION
// Deterministic, Rule-Driven, Institutional Trading Core
// 10-Layer System - Zero Randomness, Zero Mercy

import 'dart:math';
import '../../models/candle.dart';
import '../../models/trade_decision.dart';
import 'market_structure_detector.dart';
import 'zone_detector.dart';
import 'liquidity_engine.dart';
import 'momentum_engine.dart';
import '../support_resistance_service.dart';
import '../central_bayesian_engine.dart';
import '../ml_decision_maker.dart';
import '../quantum_scalping/chaos_volatility_engine.dart';

/// Golden Nightmare Master Engine
///
/// The core analysis engine implementing a 10-layer deterministic system
/// for institutional-grade trading analysis. This engine provides comprehensive
/// market analysis with zero randomness - every decision is rule-based.
///
/// **10-Layer System:**
/// 1. Market Regime Classification - Classifies market conditions
/// 2. Liquidity Mapping - Identifies liquidity zones
/// 3. Structure Engine - Analyzes market structure
/// 4. Zone Engine - Detects entry zones (scalp-critical)
/// 5. Momentum Engine - Analyzes price momentum
/// 6. Volatility Engine - Measures market volatility
/// 7. Trend Bias Enforcement - Enforces trend alignment
/// 8. Confluence Scoring - Multi-factor scoring system
/// 9. Signal Generation - Generates trading signals
/// 10. Validation & Filtering - Validates and filters signals
///
/// **Usage:**
/// ```dart
/// final result = await GoldenNightmareEngine.generate(
///   currentPrice: 2050.0,
///   candles: candles,
///   rsi: 55.0,
///   macd: 0.5,
///   macdSignal: 0.3,
///   ma20: 2230.0,
///   ma50: 2200.0,
///   ma100: 2150.0,
///   ma200: 2100.0,
///   atr: 8.0,
/// );
///
/// final scalp = result['SCALP'];
/// final swing = result['SWING'];
/// ```
///
/// **Returns:**
/// Map containing:
/// - `SCALP`: Scalping recommendation
/// - `SWING`: Swing trading recommendation
/// - Both include: direction, entry, stop loss, take profit, confidence
class GoldenNightmareEngine {
  /// Generate professional recommendations via 10-Layer System
  ///
  /// Analyzes the market using all 10 layers and generates both
  /// scalping and swing trading recommendations.
  ///
  /// **Parameters:**
  /// - [currentPrice]: Current gold price (XAU/USD)
  /// - [candles]: Historical candle data (OHLCV)
  /// - [rsi]: Current RSI value
  /// - [macd]: Current MACD value
  /// - [macdSignal]: Current MACD signal value
  /// - [ma20, ma50, ma100, ma200]: Moving averages
  /// - [atr]: Average True Range
  ///
  /// **Returns:**
  /// [Map<String, dynamic>] containing:
  /// - `SCALP`: Scalping recommendation
  /// - `SWING`: Swing trading recommendation
  ///
  /// **Example:**
  /// ```dart
  /// final result = await GoldenNightmareEngine.generate(
  ///   currentPrice: 2050.0,
  ///   candles: candles,
  ///   rsi: 55.0,
  ///   macd: 0.5,
  ///   macdSignal: 0.3,
  ///   ma20: 2230.0,
  ///   ma50: 2200.0,
  ///   ma100: 2150.0,
  ///   ma200: 2100.0,
  ///   atr: 8.0,
  /// );
  /// ```
  static Future<Map<String, dynamic>> generate({
    required double currentPrice,
    required List<Candle> candles,
    required double rsi,
    required double macd,
    required double macdSignal,
    required double ma20,
    required double ma50,
    required double ma100,
    required double ma200,
    required double atr,
  }) async {
    try {
      // ==============================================================
      // LAYER 1: MARKET REGIME CLASSIFICATION
      // ==============================================================
      final regime = _classifyMarketRegime(
        candles: candles,
        ma20: ma20,
        ma50: ma50,
        ma100: ma100,
        ma200: ma200,
        rsi: rsi,
        macd: macd,
      );

      // ==============================================================
      // LAYER 2: LIQUIDITY MAPPING
      // ==============================================================
      final liquidity = LiquidityEngine.analyze(candles, currentPrice);

      // Note: Liquidity targets are used if available, otherwise fallback to R:R

      // ==============================================================
      // LAYER 3: STRUCTURE ENGINE
      // ==============================================================
      final structure = MarketStructureDetector.analyze(candles);

      // ==============================================================
      // LAYER 4: ZONE ENGINE (SCALP-CRITICAL)
      // ==============================================================
      // Get support/resistance levels for confluence calculation
      final supportResistance =
          SupportResistanceService.calculate(candles, currentPrice);
      final supportLevels =
          supportResistance.supports.map((s) => s.price).toList();
      final resistanceLevels =
          supportResistance.resistances.map((r) => r.price).toList();

      final zones = ZoneDetector.analyze(
        candles,
        currentPrice,
        rsi,
        ma20: ma20,
        ma50: ma50,
        ma100: ma100,
        ma200: ma200,
        atr: atr,
        supportLevels: supportLevels,
        resistanceLevels: resistanceLevels,
      );

      // ==============================================================
      // LAYER 5: MOMENTUM ENGINE
      // ==============================================================
      final momentum = MomentumEngine.analyze(
        candles: candles,
        rsi: rsi,
        macd: macd,
        macdSignal: macdSignal,
        currentPrice: currentPrice,
      );

      // ==============================================================
      // LAYER 6: VOLATILITY ENGINE
      // ==============================================================
      final volatility = _analyzeVolatility(candles, atr);

      // Note: Volatility is tracked for confidence scoring only, not as a blocker

      // ==============================================================
      // LAYER 7: TREND BIAS ENFORCEMENT
      // ==============================================================
      final trendBias = _enforceTrendBias(regime, structure);

      // ==============================================================
      // LAYER 8 & 9: TARGET & STOP-LOSS ENGINE (inside trade logic)
      // ==============================================================

      // ==============================================================
      // LAYER 10: PROBABILITY SCORING (inside trade logic)
      // ==============================================================

      // Generate SCALP (zone-based, may counter-trend at extreme zones)
      final scalp = _generateScalp(
        currentPrice: currentPrice,
        regime: regime,
        structure: structure,
        zones: zones,
        liquidity: liquidity,
        momentum: momentum,
        volatility: volatility,
        trendBias: trendBias,
        rsi: rsi,
        atr: atr,
      );

      // Generate SWING (trend-based, MUST follow macro trend)
      final swing = _generateSwing(
        currentPrice: currentPrice,
        regime: regime,
        structure: structure,
        zones: zones,
        liquidity: liquidity,
        momentum: momentum,
        trendBias: trendBias,
        rsi: rsi,
        macd: macd,
        atr: atr,
      );

      return {
        'SCALP': scalp,
        'SWING': swing,
      };
    } catch (e) {
      return _noTrade('System error: $e');
    }
  }

  // ==============================================================
  // LAYER 1: MARKET REGIME CLASSIFICATION (5 levels)
  // ==============================================================
  static String _classifyMarketRegime({
    required List<Candle> candles,
    required double ma20,
    required double ma50,
    required double ma100,
    required double ma200,
    required double rsi,
    required double macd,
  }) {
    int score = 0;

    final currentPrice = candles.first.close;
    final last50 = candles.take(50).toList();

    // 1. MA Stacking (most important)
    if (ma20 > ma50 && ma50 > ma100)
      score += 3; // Strong uptrend
    else if (ma20 > ma50)
      score += 1; // Weak uptrend
    else if (ma20 < ma50 && ma50 < ma100)
      score -= 3; // Strong downtrend
    else if (ma20 < ma50) score -= 1; // Weak downtrend

    // 2. Price position
    if (currentPrice > ma20)
      score += 1;
    else if (currentPrice < ma20) score -= 1;

    // 3. RSI slope (momentum direction)
    if (rsi > 60)
      score += 1;
    else if (rsi < 40) score -= 1;

    // 4. MACD momentum
    if (macd > 0)
      score += 1;
    else if (macd < 0) score -= 1;

    // 5. Candle-body dominance (bullish vs bearish)
    int bullishCount = 0;
    int bearishCount = 0;
    for (final candle in last50.take(20)) {
      if (candle.close > candle.open)
        bullishCount++;
      else
        bearishCount++;
    }
    if (bullishCount > bearishCount + 5)
      score += 1;
    else if (bearishCount > bullishCount + 5) score -= 1;

    // 6. HH/HL or LH/LL mapping
    final highs = <double>[];
    final lows = <double>[];
    for (int i = 5; i < min(30, last50.length - 5); i++) {
      bool isHigh = true;
      bool isLow = true;
      for (int j = i - 5; j <= i + 5; j++) {
        if (j != i) {
          if (last50[j].high >= last50[i].high) isHigh = false;
          if (last50[j].low <= last50[i].low) isLow = false;
        }
      }
      if (isHigh) highs.add(last50[i].high);
      if (isLow) lows.add(last50[i].low);
    }

    // Higher highs and higher lows = uptrend
    if (highs.length >= 2 && lows.length >= 2) {
      if (highs[0] > highs[1] && lows[0] > lows[1])
        score += 2;
      else if (highs[0] < highs[1] && lows[0] < lows[1]) score -= 2;
    }

    // Classify
    if (score >= 6) return 'STRONG_TREND_UP';
    if (score >= 3) return 'WEAK_TREND_UP';
    if (score <= -6) return 'STRONG_TREND_DOWN';
    if (score <= -3) return 'WEAK_TREND_DOWN';
    return 'RANGE';
  }

  // ==============================================================
  // LAYER 6: VOLATILITY ENGINE
  // ==============================================================
  static VolatilityState _analyzeVolatility(List<Candle> candles, double atr) {
    final last20 = candles.take(20).toList();

    // 1. ATR expansion/compression
    final avgRange =
        last20.map((c) => c.high - c.low).reduce((a, b) => a + b) / 20;
    final atrRatio = atr / avgRange;

    bool compression = atrRatio < 0.8;
    bool expansion = atrRatio > 1.3;

    // 2. Candle body/wick ratio
    final avgBody =
        last20.map((c) => (c.close - c.open).abs()).reduce((a, b) => a + b) /
            20;
    final wickDominance = avgRange - avgBody;
    final wickRatio = wickDominance / avgBody;

    // High wick ratio = indecision = dangerous
    bool wickyMarket = wickRatio > 1.5;

    // 3. Trend exhaustion (extreme moves)
    final recent5 = last20.take(5).toList();
    final recentAvgRange =
        recent5.map((c) => c.high - c.low).reduce((a, b) => a + b) / 5;
    bool extremeMove = recentAvgRange > avgRange * 2.0;

    // 4. Probability of fakeout
    bool fakeoutRisk = wickyMarket || extremeMove;

    // Dangerous if: extreme expansion + wicky + fakeout risk
    bool dangerous = expansion && wickyMarket && fakeoutRisk;

    return VolatilityState(
      atr: atr,
      compression: compression,
      expansion: expansion,
      wickyMarket: wickyMarket,
      extremeMove: extremeMove,
      fakeoutRisk: fakeoutRisk,
      dangerous: dangerous,
      safe: !dangerous,
    );
  }

  // ==============================================================
  // LAYER 7: TREND BIAS ENFORCEMENT
  // ==============================================================
  static TrendBias _enforceTrendBias(
    String regime,
    MarketStructure structure,
  ) {
    // SWING: More flexible - allow trades in weak trends too
    String swingBias;
    if (regime == 'STRONG_TREND_UP' || regime == 'WEAK_TREND_UP') {
      swingBias = 'LONG_ONLY';
    } else if (regime == 'STRONG_TREND_DOWN' || regime == 'WEAK_TREND_DOWN') {
      swingBias = 'SHORT_ONLY';
    } else {
      // In range: follow recent momentum if available
      if (structure.bos?.type == 'BULLISH_BOS') {
        swingBias = 'LONG_ONLY';
      } else if (structure.bos?.type == 'BEARISH_BOS') {
        swingBias = 'SHORT_ONLY';
      } else {
        swingBias = 'NO_TRADE'; // True neutral range
      }
    }

    // SCALP MAY counter-trend ONLY at extreme zones
    String scalpBias;
    if (regime == 'STRONG_TREND_UP') {
      scalpBias = 'PREFER_LONG'; // Can short at extreme supply only
    } else if (regime == 'STRONG_TREND_DOWN') {
      scalpBias = 'PREFER_SHORT'; // Can long at extreme demand only
    } else if (regime == 'RANGE') {
      scalpBias = 'BOTH'; // Range = both directions allowed
    } else {
      scalpBias = 'BOTH'; // Weak trends allow both
    }

    return TrendBias(
      swingBias: swingBias,
      scalpBias: scalpBias,
    );
  }

  // ==============================================================
  // HELPER: NO-TRADE
  // ==============================================================
  static Map<String, dynamic> _noTrade(String reason) {
    return {
      'SCALP': {
        'direction': 'NO-TRADE',
        'entry_zone': 'NONE',
        'stop_loss': 'N/A',
        'take_profit': 'N/A',
        'structure_reason': reason,
        'liquidity_reason': 'N/A',
        'zone_validation': 'FAILED',
        'momentum_state': 'N/A',
        'volatility_state': 'N/A',
        'confidence': 0,
      },
      'SWING': {
        'direction': 'NO-TRADE',
        'entry': 'NONE',
        'stop_loss': 'N/A',
        'take_profit': 'N/A',
        'trend_reason': reason,
        'structure_reason': 'N/A',
        'momentum_reason': 'N/A',
        'liquidity_target': 'N/A',
        'confidence': 0,
      },
    };
  }

  /// Generate SCALP recommendation (ZONE-BASED)
  /// MUST be at a valid zone OR NO TRADE
  static Map<String, dynamic> _generateScalp({
    required double currentPrice,
    required String regime,
    required MarketStructure structure,
    required ZoneAnalysis zones,
    required LiquidityMap liquidity,
    required MomentumState momentum,
    required VolatilityState volatility,
    required TrendBias trendBias,
    required double rsi,
    required double atr,
  }) {
    // ==========================================
    // CRITICAL CHECK: Must be at reaction zone OR find nearest zone
    // ==========================================
    ReactionZone? zone = zones.atReactionZone;

    // Fallback: If not at valid zone, find nearest zone within 6.0x ATR
    if (zone == null || !zone.valid) {
      final atrBasedDistance =
          atr * 6.0; // VERY flexible distance - increased from 4.0x

      // Find nearest demand zone
      DemandZone? nearestDemand;
      double minDemandDist = double.infinity;
      for (final dz in zones.demandZones) {
        final zoneMid = (dz.high + dz.low) / 2;
        final distance = (currentPrice - zoneMid).abs();
        if (distance < minDemandDist && distance <= atrBasedDistance) {
          minDemandDist = distance;
          nearestDemand = dz;
        }
      }

      // Find nearest supply zone
      SupplyZone? nearestSupply;
      double minSupplyDist = double.infinity;
      for (final sz in zones.supplyZones) {
        final zoneMid = (sz.high + sz.low) / 2;
        final distance = (currentPrice - zoneMid).abs();
        if (distance < minSupplyDist && distance <= atrBasedDistance) {
          minSupplyDist = distance;
          nearestSupply = sz;
        }
      }

      // Use nearest zone if found
      if (nearestDemand != null &&
          (nearestSupply == null || minDemandDist < minSupplyDist)) {
        zone = ReactionZone(
          type: 'DEMAND',
          zone: Zone(
            type: 'DEMAND',
            high: nearestDemand.high,
            low: nearestDemand.low,
            strength: nearestDemand.strength,
          ),
          valid: true,
          confluence: nearestDemand.strength,
        );
      } else if (nearestSupply != null) {
        zone = ReactionZone(
          type: 'SUPPLY',
          zone: Zone(
            type: 'SUPPLY',
            high: nearestSupply.high,
            low: nearestSupply.low,
            strength: nearestSupply.strength,
          ),
          valid: true,
          confluence: nearestSupply.strength,
        );
      }
    }

    // If still no zone found, return NO-TRADE
    if (zone == null || !zone.valid) {
      return {
        'direction': 'NO-TRADE',
        'entry_zone': 'NONE',
        'stop_loss': 'N/A',
        'take_profit': 'N/A',
        'structure_reason': 'Not at valid zone and no nearby zones found',
        'liquidity_reason': 'N/A',
        'zone_validation':
            'FAILED: Not at demand/supply zone (nearest zone > 6.0x ATR)',
        'momentum_state': momentum.direction,
        'volatility_state': volatility.safe ? 'SAFE' : 'RISKY',
        'confidence': 0,
        'reasoning': 'لا توجد منطقة تداول صالحة قريبة من السعر الحالي',
      };
    }

    // At this point, zone is guaranteed to be non-null and valid
    final validZone = zone;

    // ==========================================
    // STRUCTURE: Check if structure allows trade
    // ==========================================
    bool structureAllows = true;
    String structureReason = '';

    if (validZone.type == 'DEMAND') {
      // BUY setup - allow at valid zones regardless of macro structure
      structureReason = structure.trend;
      if (structure.bos?.type == 'BULLISH_BOS')
        structureReason += ' + BULLISH BOS';
      if (structure.choch?.type == 'BULLISH_CHOCH')
        structureReason += ' + BULLISH CHOCH';
    } else {
      // SELL setup - allow at valid zones regardless of macro structure
      structureReason = structure.trend;
      if (structure.bos?.type == 'BEARISH_BOS')
        structureReason += ' + BEARISH BOS';
      if (structure.choch?.type == 'BEARISH_CHOCH')
        structureReason += ' + BEARISH CHOCH';
    }

    // ==========================================
    // MOMENTUM: Must agree OR block trade
    // ==========================================
    bool momentumAgreed = true;
    String momentumState = momentum.direction;

    if (validZone.type == 'DEMAND') {
      // BUY: momentum should be bullish or neutral
      if (momentum.direction == 'BEARISH' && !momentum.agreement) {
        momentumAgreed = false;
      }
      momentumState =
          momentum.direction + (momentum.exhaustion ? ' + EXHAUSTION' : '');
    } else {
      // SELL: momentum should be bearish or neutral
      if (momentum.direction == 'BULLISH' && !momentum.agreement) {
        momentumAgreed = false;
      }
      momentumState =
          momentum.direction + (momentum.exhaustion ? ' + EXHAUSTION' : '');
    }

    // Momentum conflicts now reduce confidence instead of blocking
    // This allows more signals to be generated
    int momentumPenalty = 0;
    if (!momentumAgreed) {
      momentumPenalty = 20; // Reduce confidence by 20% instead of blocking
    }

    // ==========================================
    // RSI FORCE RULE (#2 and #3) - VERY RELAXED
    // ==========================================
    bool rsiForce = false;
    if (validZone.type == 'DEMAND' && rsi < 55)
      rsiForce = true; // Force BUY - VERY relaxed from 40
    if (validZone.type == 'SUPPLY' && rsi > 45)
      rsiForce = true; // Force SELL - VERY relaxed from 60

    // Override structure check if RSI forces
    if (rsiForce) structureAllows = true;

    // Structure is now informational only, not a blocker

    // ==========================================
    // BUILD TRADE
    // ==========================================
    String direction;
    String entryZone;
    String stopLoss;
    String takeProfit;
    String liquidityReason;
    double entryPrice = 0.0;
    double entryMin = 0.0;
    double entryMax = 0.0;

    // Ensure minimum ATR for scalp (15m timeframe)
    final scalpAtr = max(atr, 5.0); // Small ATR for scalping

    if (validZone.type == 'DEMAND') {
      direction = 'BUY';

      // Enhanced Entry Zone calculation
      // Priority: Order Block > FVG > Zone Mid > Zone Low
      double entryPrice = validZone.zone.low; // Default to zone low
      double entryMin = validZone.zone.low;
      double entryMax = validZone.zone.high;

      // Check for Order Blocks in liquidity map
      final bullishOB = liquidity.orderBlocks
          .where((ob) =>
              ob.type == 'BULLISH_OB' &&
              ob.low <= validZone.zone.high &&
              ob.high >= validZone.zone.low)
          .toList();

      if (bullishOB.isNotEmpty) {
        // Use Order Block boundaries
        final ob = bullishOB.first;
        entryPrice = (ob.low + ob.high) / 2; // Mid of Order Block
        entryMin = ob.low;
        entryMax = ob.high;
      } else if (zones.fvg != null && zones.fvg!.type == 'BULLISH_FVG') {
        // Check if FVG overlaps with zone
        if (zones.fvg!.lower <= validZone.zone.high &&
            zones.fvg!.upper >= validZone.zone.low) {
          entryPrice = (zones.fvg!.lower + zones.fvg!.upper) / 2;
          entryMin = zones.fvg!.lower;
          entryMax = zones.fvg!.upper;
        } else {
          // Use zone mid for better fill probability
          entryPrice = (validZone.zone.low + validZone.zone.high) / 2;
          entryMin = validZone.zone.low;
          entryMax = validZone.zone.high;
        }
      } else {
        // Use zone mid for better fill probability (more professional)
        entryPrice = (validZone.zone.low + validZone.zone.high) / 2;
        entryMin = validZone.zone.low;
        entryMax = validZone.zone.high;
      }

      // Format entry zone as range if there's a meaningful range
      final zoneRange = entryMax - entryMin;
      if (zoneRange > 2.0) {
        entryZone =
            '\$${entryMin.toStringAsFixed(2)}-\$${entryMax.toStringAsFixed(2)}';
      } else {
        entryZone = entryPrice.toStringAsFixed(2);
      }

      // ==========================================
      // LAYER 9: ENHANCED STOP-LOSS (Multi-method)
      // ==========================================
      // Use best of: Structure-based, Zone-based, ATR-based
      double slPrice = 0.0;

      // Method 1: Structure-based (best if available)
      final pivotsBelow = structure.pivots
          .where((p) => p.type == 'LOW' && p.price < entryMin)
          .toList();

      if (pivotsBelow.isNotEmpty) {
        pivotsBelow.sort((a, b) => b.price.compareTo(a.price)); // Nearest first
        final structureSL =
            pivotsBelow.first.price - (scalpAtr * 0.25); // Small buffer
        if (structureSL > 0 && entryPrice - structureSL >= 3.0) {
          slPrice = structureSL;
        }
      }

      // Method 2: Zone-based (below zone with ATR buffer)
      if (slPrice == 0 || slPrice > entryMin - 2.0) {
        final zoneSL = entryMin - (scalpAtr * 0.6); // 0.6x ATR below zone
        if (zoneSL > 0 && entryPrice - zoneSL >= 3.0) {
          slPrice = zoneSL;
        }
      }

      // Method 3: ATR-based (dynamic based on volatility)
      if (slPrice == 0) {
        // Dynamic ATR multiplier: higher volatility = wider SL
        final volatilityMultiplier = volatility.safe ? 0.8 : 1.2;
        final atrSL = entryPrice - (scalpAtr * volatilityMultiplier);
        if (atrSL > 0) {
          slPrice = atrSL;
        }
      }

      // Ensure minimum risk (0.3% = ~$12 for Gold at $4200) and maximum risk (0.8% of price)
      final minSLDistance = entryPrice * 0.003; // 0.3% for scalping
      final maxSLDistance = entryPrice * 0.008; // 0.8% max risk

      if (entryPrice - slPrice < minSLDistance) {
        slPrice = entryPrice - minSLDistance;
      }

      if (entryPrice - slPrice > maxSLDistance) {
        slPrice = entryPrice - maxSLDistance;
      }

      // Final validation
      if (slPrice <= 0 || slPrice >= entryPrice) {
        slPrice = entryPrice -
            max(scalpAtr * 0.8, entryPrice * 0.004); // 0.4% fallback
      }

      stopLoss = slPrice.toStringAsFixed(2);

      // ==========================================
      // LAYER 8: ENHANCED TARGET (Multi-method with Dynamic R:R)
      // ==========================================
      double tpPrice = 0.0;
      final risk = entryPrice - slPrice;
      liquidityReason = 'Calculating target...'; // Initialize

      // Calculate preliminary confidence for dynamic R:R
      final prelimConfidence = _calculatePreliminaryConfidence(
        zoneStrength: zone.zone.strength,
        zoneConfluence: zone.confluence,
        rsiForce: rsiForce,
        liquiditySweep: structure.liquiditySweep?.rejected ?? false,
      );

      // Calculate dynamic R:R based on preliminary confidence
      double targetRR = 1.5; // Base R:R
      if (prelimConfidence >= 80)
        targetRR = 2.5; // High confidence = higher target
      else if (prelimConfidence >= 70)
        targetRR = 2.0;
      else if (prelimConfidence >= 60) targetRR = 1.8;

      // Priority 1: Liquidity targets (best)
      final minLiquidityDistance =
          entryPrice * 0.006; // 0.6% minimum for liquidity target
      if (liquidity.nearestTarget?.above != null &&
          liquidity.nearestTarget!.above! > entryPrice + minLiquidityDistance) {
        final liqTarget = liquidity.nearestTarget!.above! - 1.0;
        final liqRR = (liqTarget - entryPrice) / risk;

        // Use liquidity target if R:R is acceptable (>= 1.2)
        if (liqRR >= 1.2) {
          tpPrice = liqTarget;
          liquidityReason =
              'Liquidity High \$${liquidity.nearestTarget!.above!.toStringAsFixed(2)} (R:R ${liqRR.toStringAsFixed(1)})';
        }
      }

      // Priority 2: Structure-based targets (pivots)
      if (tpPrice == 0) {
        final minPivotDistance =
            entryPrice * 0.005; // 0.5% minimum for pivot target
        final pivotsAbove = structure.pivots
            .where((p) =>
                p.type == 'HIGH' && p.price > entryPrice + minPivotDistance)
            .toList();

        if (pivotsAbove.isNotEmpty) {
          pivotsAbove
              .sort((a, b) => a.price.compareTo(b.price)); // Nearest first
          final structTarget = pivotsAbove.first.price - 2.0;
          final structRR = (structTarget - entryPrice) / risk;

          if (structRR >= 1.3) {
            tpPrice = structTarget;
            liquidityReason =
                'Structure Target (R:R ${structRR.toStringAsFixed(1)})';
          }
        }
      }

      // Priority 3: ATR-based targets
      if (tpPrice == 0) {
        final atrTarget = entryPrice + (scalpAtr * targetRR);
        tpPrice = atrTarget;
        liquidityReason =
            'ATR Target ${targetRR}x (R:R ${targetRR.toStringAsFixed(1)})';
      }

      // Priority 4: Dynamic R:R based on confidence
      if (tpPrice == 0 || (tpPrice - entryPrice) / risk < 1.2) {
        tpPrice = entryPrice + (risk * targetRR);
        liquidityReason = 'Dynamic R:R ${targetRR.toStringAsFixed(1)}:1';
      }

      // Ensure minimum profit (0.6% = ~$25 for Gold at $4200) and validate
      final minProfit = entryPrice * 0.006; // 0.6% minimum profit for scalping
      if (tpPrice - entryPrice < minProfit) {
        tpPrice = entryPrice + max(minProfit, risk * 1.5);
        liquidityReason += ' (Min Adjusted)';
      }

      if (tpPrice <= entryPrice) {
        final fallbackProfit = entryPrice * 0.008; // 0.8% fallback
        tpPrice = entryPrice + max(fallbackProfit, risk * 1.5);
        liquidityReason = 'Fallback R:R 1.5:1';
      }

      takeProfit = tpPrice.toStringAsFixed(2);
    } else {
      // SELL
      direction = 'SELL';

      // Enhanced Entry Zone calculation
      // Priority: Order Block > FVG > Zone Mid > Zone High
      double entryPrice = validZone.zone.high; // Default to zone high
      double entryMin = validZone.zone.low;
      double entryMax = validZone.zone.high;

      // Check for Order Blocks in liquidity map
      final bearishOB = liquidity.orderBlocks
          .where((ob) =>
              ob.type == 'BEARISH_OB' &&
              ob.low <= validZone.zone.high &&
              ob.high >= validZone.zone.low)
          .toList();

      if (bearishOB.isNotEmpty) {
        // Use Order Block boundaries
        final ob = bearishOB.first;
        entryPrice = (ob.low + ob.high) / 2; // Mid of Order Block
        entryMin = ob.low;
        entryMax = ob.high;
      } else if (zones.fvg != null && zones.fvg!.type == 'BEARISH_FVG') {
        // Check if FVG overlaps with zone
        if (zones.fvg!.lower <= validZone.zone.high &&
            zones.fvg!.upper >= validZone.zone.low) {
          entryPrice = (zones.fvg!.lower + zones.fvg!.upper) / 2;
          entryMin = zones.fvg!.lower;
          entryMax = zones.fvg!.upper;
        } else {
          // Use zone mid for better fill probability
          entryPrice = (validZone.zone.low + validZone.zone.high) / 2;
          entryMin = validZone.zone.low;
          entryMax = validZone.zone.high;
        }
      } else {
        // Use zone mid for better fill probability (more professional)
        entryPrice = (validZone.zone.low + validZone.zone.high) / 2;
        entryMin = validZone.zone.low;
        entryMax = validZone.zone.high;
      }

      // Format entry zone as range if there's a meaningful range
      final zoneRange = entryMax - entryMin;
      if (zoneRange > 2.0) {
        entryZone =
            '\$${entryMin.toStringAsFixed(2)}-\$${entryMax.toStringAsFixed(2)}';
      } else {
        entryZone = entryPrice.toStringAsFixed(2);
      }

      // ==========================================
      // LAYER 9: ENHANCED STOP-LOSS (Multi-method) - SELL
      // ==========================================
      double slPrice = 0.0;

      // Method 1: Structure-based (best if available)
      final pivotsAbove = structure.pivots
          .where((p) => p.type == 'HIGH' && p.price > entryMax)
          .toList();

      if (pivotsAbove.isNotEmpty) {
        pivotsAbove.sort((a, b) => a.price.compareTo(b.price)); // Nearest first
        final structureSL =
            pivotsAbove.first.price + (scalpAtr * 0.25); // Small buffer
        if (structureSL - entryPrice >= 3.0) {
          slPrice = structureSL;
        }
      }

      // Method 2: Zone-based (above zone with ATR buffer)
      if (slPrice == 0 || slPrice < entryMax + 2.0) {
        final zoneSL = entryMax + (scalpAtr * 0.6); // 0.6x ATR above zone
        if (zoneSL - entryPrice >= 3.0) {
          slPrice = zoneSL;
        }
      }

      // Method 3: ATR-based (dynamic based on volatility)
      if (slPrice == 0) {
        // Dynamic ATR multiplier
        final volatilityMultiplier = volatility.safe ? 0.8 : 1.2;
        final atrSL = entryPrice + (scalpAtr * volatilityMultiplier);
        slPrice = atrSL;
      }

      // Ensure minimum risk (0.3% = ~$12 for Gold at $4200) and maximum risk (0.8% of price)
      final minSLDistance = entryPrice * 0.003; // 0.3% for scalping
      final maxSLDistance = entryPrice * 0.008; // 0.8% max risk

      if (slPrice - entryPrice < minSLDistance) {
        slPrice = entryPrice + minSLDistance;
      }

      if (slPrice - entryPrice > maxSLDistance) {
        slPrice = entryPrice + maxSLDistance;
      }

      // Final validation
      if (slPrice <= entryPrice) {
        slPrice = entryPrice +
            max(scalpAtr * 0.8, entryPrice * 0.004); // 0.4% fallback
      }

      stopLoss = slPrice.toStringAsFixed(2);

      // ==========================================
      // LAYER 8: ENHANCED TARGET (Multi-method with Dynamic R:R) - SELL
      // ==========================================
      double tpPrice = 0.0;
      final risk = slPrice - entryPrice;
      liquidityReason = 'Calculating target...'; // Initialize

      // Calculate preliminary confidence for dynamic R:R
      final prelimConfidence = _calculatePreliminaryConfidence(
        zoneStrength: zone.zone.strength,
        zoneConfluence: zone.confluence,
        rsiForce: rsiForce,
        liquiditySweep: structure.liquiditySweep?.rejected ?? false,
      );

      // Calculate dynamic R:R
      double targetRR = 1.5;
      if (prelimConfidence >= 80)
        targetRR = 2.5;
      else if (prelimConfidence >= 70)
        targetRR = 2.0;
      else if (prelimConfidence >= 60) targetRR = 1.8;

      // Priority 1: Liquidity targets
      final minLiquidityDistance =
          entryPrice * 0.006; // 0.6% minimum for liquidity target
      if (liquidity.nearestTarget?.below != null &&
          liquidity.nearestTarget!.below! < entryPrice - minLiquidityDistance) {
        final liqTarget = liquidity.nearestTarget!.below! + 1.0;
        final liqRR = (entryPrice - liqTarget) / risk;

        if (liqRR >= 1.2 && liqTarget > 0) {
          tpPrice = liqTarget;
          liquidityReason =
              'Liquidity Low \$${liquidity.nearestTarget!.below!.toStringAsFixed(2)} (R:R ${liqRR.toStringAsFixed(1)})';
        }
      }

      // Priority 2: Structure-based targets
      if (tpPrice == 0) {
        final minPivotDistance =
            entryPrice * 0.005; // 0.5% minimum for pivot target
        final pivotsBelow = structure.pivots
            .where((p) =>
                p.type == 'LOW' && p.price < entryPrice - minPivotDistance)
            .toList();

        if (pivotsBelow.isNotEmpty) {
          pivotsBelow.sort((a, b) => b.price.compareTo(a.price));
          final structTarget = pivotsBelow.first.price + 2.0;
          final structRR = (entryPrice - structTarget) / risk;

          if (structRR >= 1.3 && structTarget > 0) {
            tpPrice = structTarget;
            liquidityReason =
                'Structure Target (R:R ${structRR.toStringAsFixed(1)})';
          }
        }
      }

      // Priority 3: ATR-based targets
      if (tpPrice == 0) {
        final atrTarget = entryPrice - (scalpAtr * targetRR);
        if (atrTarget > 0) {
          tpPrice = atrTarget;
          liquidityReason =
              'ATR Target ${targetRR}x (R:R ${targetRR.toStringAsFixed(1)})';
        }
      }

      // Priority 4: Dynamic R:R
      if (tpPrice == 0 || (entryPrice - tpPrice) / risk < 1.2) {
        tpPrice = entryPrice - (risk * targetRR);
        liquidityReason = 'Dynamic R:R ${targetRR.toStringAsFixed(1)}:1';
      }

      // Ensure minimum profit (0.6% = ~$25 for Gold at $4200) and validate
      final minProfit = entryPrice * 0.006; // 0.6% minimum profit for scalping
      if (entryPrice - tpPrice < minProfit) {
        tpPrice = entryPrice - max(minProfit, risk * 1.5);
        liquidityReason += ' (Min Adjusted)';
      }

      if (tpPrice >= entryPrice || tpPrice <= 0) {
        final fallbackProfit = entryPrice * 0.008; // 0.8% fallback
        tpPrice = entryPrice - max(fallbackProfit, risk * 1.5);
        liquidityReason = 'Fallback R:R 1.5:1';
      }

      takeProfit = tpPrice.toStringAsFixed(2);
    }

    // ==========================================
    // LAYER 10: ENHANCED PROBABILITY SCORING
    // ==========================================
    // Check liquidity strength using strictness settings
    final liquidityStrength = _calculateLiquidityStrength(liquidity);
    final hasEnoughPivots =
        structure.pivots.length >= ZoneDetector.minPivotCount;

    // Get zone test count and other zone metadata
    int zoneTestCount = 0;
    bool zoneUntested = true;
    if (validZone.type == 'DEMAND' && zones.demandZones.isNotEmpty) {
      final matchingZone = zones.demandZones.firstWhere(
        (z) =>
            (z.high - validZone.zone.high).abs() < 1.0 &&
            (z.low - validZone.zone.low).abs() < 1.0,
        orElse: () => zones.demandZones.first,
      );
      zoneTestCount = matchingZone.testCount;
      zoneUntested = matchingZone.untested;
    } else if (validZone.type == 'SUPPLY' && zones.supplyZones.isNotEmpty) {
      final matchingZone = zones.supplyZones.firstWhere(
        (z) =>
            (z.high - validZone.zone.high).abs() < 1.0 &&
            (z.low - validZone.zone.low).abs() < 1.0,
        orElse: () => zones.supplyZones.first,
      );
      zoneTestCount = matchingZone.testCount;
      zoneUntested = matchingZone.untested;
    }

    int confidence = _calculateEnhancedScalpConfidence(
      zoneStrength: validZone.zone.strength,
      zoneConfluence: validZone.confluence,
      structureAligned: structureAllows && hasEnoughPivots,
      momentumAligned: momentumAgreed,
      volatilitySafe: volatility.safe,
      liquidityTargetClear: liquidity.nearestTarget != null &&
          liquidityStrength >= ZoneDetector.minLiquidityStrength,
      rsiForce: rsiForce,
      liquiditySweep: structure.liquiditySweep?.rejected ?? false,
      zoneTestCount: zoneTestCount,
      zoneUntested: zoneUntested,
      marketRegime: regime,
      trendStrength: structure.trend,
      hasOrderBlock: liquidity.orderBlocks.any((ob) =>
          (validZone.type == 'DEMAND' && ob.type == 'BULLISH_OB') ||
          (validZone.type == 'SUPPLY' && ob.type == 'BEARISH_OB')),
    );

    // Apply momentum penalty if momentum conflicts
    confidence -= momentumPenalty;

    // Build professional reasoning with indicators
    final reasoningParts = <String>[];

    // Zone analysis
    reasoningParts.add(
        'منطقة ${zone.type == 'DEMAND' ? 'طلب' : 'عرض'} قوية (${zone.zone.strength}%)');
    reasoningParts.add('التقارب: ${zone.confluence}%');

    // RSI analysis
    if (rsiForce) {
      reasoningParts.add(
          'RSI ${zone.type == 'DEMAND' ? 'تشبع بيعي' : 'تشبع شرائي'} قوي (${rsi.toStringAsFixed(1)})');
    } else {
      reasoningParts.add(
          'RSI: ${rsi.toStringAsFixed(1)} ${rsi > 50 ? '(زخم صاعد)' : '(زخم هابط)'}');
    }

    // Structure analysis
    if (structure.bos != null) {
      reasoningParts.add(
          'كسر الهيكل: ${structure.bos!.type == 'BULLISH_BOS' ? 'صاعد' : 'هابط'}');
    }
    if (structure.choch != null) {
      reasoningParts.add(
          'تغيير الطابع: ${structure.choch!.type == 'BULLISH_CHOCH' ? 'صاعد' : 'هابط'}');
    }

    // Momentum analysis
    if (momentum.direction == 'BULLISH') {
      reasoningParts.add('الزخم: صاعد');
    } else if (momentum.direction == 'BEARISH') {
      reasoningParts.add('الزخم: هابط');
    }
    if (momentum.exhaustion) {
      reasoningParts.add('إشارة إرهاق محتمل');
    }

    // Volatility analysis
    if (volatility.safe) {
      reasoningParts.add('التقلبات: آمنة (ATR: ${atr.toStringAsFixed(2)})');
    } else {
      reasoningParts
          .add('التقلبات: مرتفعة (ATR: ${atr.toStringAsFixed(2)}) - حذر');
    }

    // Liquidity analysis
    if (liquidity.nearestTarget != null) {
      reasoningParts.add('هدف السيولة واضح');
    }

    final reasoning = reasoningParts.join(' • ');

    return {
      'direction': direction,
      'entry_zone': entryZone,
      'entry': entryPrice, // Main entry price
      'entryMin': entryMin,
      'entryMax': entryMax,
      'stop_loss': stopLoss,
      'take_profit': takeProfit,
      'structure_reason': structureReason,
      'liquidity_reason': liquidityReason,
      'zone_validation':
          'منطقة صالحة: ${validZone.confluence}% تقارب (قوة: ${validZone.zone.strength}%)',
      'momentum_state': momentumState,
      'volatility_state': volatility.safe ? 'آمن' : 'مقبول',
      'confidence': confidence,
      'reasoning': reasoning,
    };
  }

  /// Calculate preliminary confidence (used before full confidence calculation)
  static int _calculatePreliminaryConfidence({
    required int zoneStrength,
    required int zoneConfluence,
    required bool rsiForce,
    required bool liquiditySweep,
  }) {
    int score = 50; // Base

    // Zone quality (30 points max)
    score += (zoneConfluence * 0.15).round(); // Up to 15 pts
    score += (zoneStrength * 0.15).round(); // Up to 15 pts

    // Bonus factors
    if (rsiForce) score += 10; // RSI extreme
    if (liquiditySweep) score += 10; // Liquidity sweep

    return min(score, 100);
  }

  /// Calculate liquidity strength (0-100)
  static double _calculateLiquidityStrength(LiquidityMap liquidity) {
    double strength = 0.0;

    // Base strength from having targets
    if (liquidity.nearestTarget != null) strength += 30.0;

    // Add strength from liquidity levels
    strength += min(liquidity.liquidityHighs.length * 5.0, 20.0);
    strength += min(liquidity.liquidityLows.length * 5.0, 20.0);

    // Add strength from stop clusters
    strength += min(liquidity.stopClusters.length * 3.0, 15.0);

    // Add strength from order blocks
    strength += min(liquidity.orderBlocks.length * 2.0, 10.0);

    // Add strength from breaker blocks
    strength += min(liquidity.breakerBlocks.length * 2.0, 5.0);

    return min(strength, 100.0);
  }

  /// Calculate enhanced scalp confidence with advanced factors
  static int _calculateEnhancedScalpConfidence({
    required int zoneStrength,
    required int zoneConfluence,
    required bool structureAligned,
    required bool momentumAligned,
    required bool volatilitySafe,
    required bool liquidityTargetClear,
    required bool rsiForce,
    required bool liquiditySweep,
    required int zoneTestCount,
    required bool zoneUntested,
    required String marketRegime,
    required String trendStrength,
    required bool hasOrderBlock,
  }) {
    int score = 50; // Base

    // Zone quality (30 points max)
    score += (zoneConfluence * 0.15).round(); // Up to 15 pts
    score += (zoneStrength * 0.15).round(); // Up to 15 pts

    // Zone test count factor (NEW)
    if (zoneUntested) {
      score += 12; // Untested zone = strongest
    } else if (zoneTestCount == 1) {
      score += 8; // Tested once and held = still very strong
    } else if (zoneTestCount == 2) {
      score += 4; // Tested twice = moderate
    } else if (zoneTestCount > 3) {
      score -= 8; // Over-tested = weak
    }

    // Structure alignment (15 points)
    if (structureAligned) score += 15;

    // Momentum alignment (15 points)
    if (momentumAligned) score += 15;

    // Volatility safety (10 points)
    if (volatilitySafe) score += 10;

    // Liquidity target (10 points)
    if (liquidityTargetClear) score += 10;

    // Bonus factors
    if (rsiForce) score += 10; // RSI extreme
    if (liquiditySweep) score += 10; // Liquidity sweep
    if (hasOrderBlock) score += 8; // Order Block present

    // Market Context (NEW) - adjust based on regime
    if (marketRegime == 'TRENDING_BULLISH' ||
        marketRegime == 'TRENDING_BEARISH') {
      score += 8; // Trending market = better scalp opportunities
    } else if (marketRegime == 'VOLATILE') {
      score += 5; // Volatile = some opportunities
    } else if (marketRegime == 'RANGE') {
      score -= 5; // Range = harder to scalp
    }

    // Trend strength alignment (NEW)
    if (trendStrength == 'STRONG_UPTREND' ||
        trendStrength == 'STRONG_DOWNTREND') {
      score += 6; // Strong trend = better probability
    } else if (trendStrength == 'WEAK_UPTREND' ||
        trendStrength == 'WEAK_DOWNTREND') {
      score += 3; // Weak trend = some advantage
    }

    return min(max(score, 0), 100); // Clamp between 0-100
  }

  /// Generate SWING recommendation (TREND-BASED)
  /// MUST follow macro trend OR NO TRADE
  static Map<String, dynamic> _generateSwing({
    required double currentPrice,
    required String regime,
    required MarketStructure structure,
    required ZoneAnalysis zones,
    required LiquidityMap liquidity,
    required MomentumState momentum,
    required TrendBias trendBias,
    required double rsi,
    required double macd,
    required double atr,
  }) {
    // ==========================================
    // CRITICAL: Swing must follow trend bias
    // ==========================================
    if (trendBias.swingBias == 'NO_TRADE') {
      return {
        'direction': 'NO-TRADE',
        'entry': 'NONE',
        'stop_loss': 'N/A',
        'take_profit': 'N/A',
        'trend_reason': 'RANGE market - no clear trend',
        'structure_reason': 'N/A',
        'momentum_reason': 'N/A',
        'liquidity_target': 'N/A',
        'confidence': 0,
      };
    }

    // ==========================================
    // BUILD TRADE
    // ==========================================
    String direction;
    double entry = currentPrice;
    String stopLoss;
    String takeProfit;
    String trendReason;
    String structureReason;
    String momentumReason;
    String liquidityTarget;

    // 🔥 CRITICAL FIX: Swing uses MUCH LARGER ATR (4h timeframe vs 15m)
    // Swing ATR should be 6-8x larger than Scalp ATR for realistic targets
    final swingAtr = max(atr * 6.0, 30.0); // Swing = 6x Scalp ATR (minimum 30$)
    final effectiveAtr = swingAtr; // Use swingAtr for all swing calculations

    if (trendBias.swingBias == 'LONG_ONLY') {
      direction = 'BUY';

      // ==========================================
      // TREND REASON
      // ==========================================
      trendReason = regime;
      if (structure.bos?.type == 'BULLISH_BOS') {
        trendReason += ' + BULLISH BOS (structure break)';
      }
      if (structure.choch?.type == 'BULLISH_CHOCH') {
        trendReason += ' + BULLISH CHOCH (trend reversal)';
      }

      // ==========================================
      // STRUCTURE REASON
      // ==========================================
      structureReason = 'HH/HL pattern';
      if (structure.pivots.isNotEmpty) {
        final recentHighs =
            structure.pivots.where((p) => p.type == 'HIGH').take(2).toList();
        if (recentHighs.length == 2 &&
            recentHighs[0].price > recentHighs[1].price) {
          structureReason = 'Higher Highs confirmed';
        }
      }

      // ==========================================
      // MOMENTUM REASON
      // ==========================================
      final momentumReasons = <String>[];
      if (momentum.direction == 'BULLISH')
        momentumReasons.add('Bullish momentum');
      if (momentum.macdInflection == 'BULLISH')
        momentumReasons.add('MACD bullish');
      if (momentum.rsiDivergence == 'BULLISH_DIVERGENCE') {
        momentumReasons.add('RSI bullish divergence');
      }
      if (momentum.hiddenDivergence == 'HIDDEN_BULLISH') {
        momentumReasons.add('Hidden bullish divergence (continuation)');
      }
      if (rsi > 50) momentumReasons.add('RSI>${rsi.toStringAsFixed(0)}');

      momentumReason = momentumReasons.isEmpty
          ? 'Trend-based (momentum neutral)'
          : momentumReasons.join(' + ');

      // ==========================================
      // LAYER 9: STOP-LOSS (structure-based)
      // ==========================================
      double slPrice;
      if (structure.pivots.isNotEmpty) {
        final recentLows = structure.pivots
            .where((p) => p.type == 'LOW' && p.price < currentPrice)
            .toList();
        if (recentLows.isNotEmpty) {
          recentLows.sort((a, b) => b.price.compareTo(a.price));
          slPrice = recentLows.first.price - (effectiveAtr * 0.5);
        } else {
          slPrice = currentPrice - (effectiveAtr * 1.5);
        }
      } else {
        slPrice = currentPrice - (effectiveAtr * 1.5);
      }

      // Ensure SL is at least 0.5% below entry for BUY (swing trade)
      final minSwingSL = entry * 0.005; // 0.5% for swing trades
      if (entry - slPrice < minSwingSL) {
        slPrice = entry - (entry * 0.008); // 0.8% fallback
      }

      // Ensure SL is valid
      if (slPrice <= 0 || slPrice >= entry) {
        slPrice = entry - (entry * 0.008); // 0.8% fallback
      }

      stopLoss = slPrice.toStringAsFixed(2);

      // ==========================================
      // LAYER 8: TARGET (liquidity-based with reasonable limits)
      // ==========================================
      double tpPrice;

      // Calculate maximum TP distance (3% of price or 5x ATR, whichever is smaller)
      final maxTPDistance = min(entry * 0.03, effectiveAtr * 5.0);

      final minSwingTarget = entry * 0.008; // 0.8% minimum for swing target
      if (liquidity.nearestTarget?.above != null &&
          liquidity.nearestTarget!.above! > entry + minSwingTarget) {
        final targetPrice = liquidity.nearestTarget!.above! - 1.0;
        // Apply limit: don't exceed maxTPDistance
        if (targetPrice - entry <= maxTPDistance) {
          tpPrice = targetPrice;
          liquidityTarget =
              'Liquidity high at \$${liquidity.nearestTarget!.above!.toStringAsFixed(2)}';
        } else {
          // Use R:R instead if target is too far
          final risk = entry - slPrice;
          tpPrice = entry + (risk * 2.0);
          liquidityTarget = 'R:R 1:2 target (liquidity too far)';
        }
      } else if (liquidity.liquidityHighs.isNotEmpty &&
          liquidity.liquidityHighs.first.price > entry + minSwingTarget) {
        final targetPrice = liquidity.liquidityHighs.first.price - 1.0;
        // Apply limit: don't exceed maxTPDistance
        if (targetPrice - entry <= maxTPDistance) {
          tpPrice = targetPrice;
          liquidityTarget = 'Nearest liquidity high';
        } else {
          // Use R:R instead if target is too far
          final risk = entry - slPrice;
          tpPrice = entry + (risk * 2.0);
          liquidityTarget = 'R:R 1:2 target (liquidity too far)';
        }
      } else {
        // R:R 1:2 - use calculated risk
        final risk = entry - slPrice;
        tpPrice = entry + (risk * 2.0);
        liquidityTarget = 'R:R 1:2 target';
      }

      // Apply maximum distance limit
      if (tpPrice - entry > maxTPDistance) {
        tpPrice = entry + maxTPDistance;
        liquidityTarget =
            'R:R target (limited to ${(maxTPDistance / (entry - slPrice)).toStringAsFixed(1)}x)';
      }

      // Ensure TP is at least 1.2% above entry for BUY (swing trade)
      final minSwingProfit = entry * 0.012; // 1.2% minimum profit for swing
      if (tpPrice - entry < minSwingProfit) {
        tpPrice = entry + minSwingProfit;
      }

      // Ensure TP is valid
      if (tpPrice <= entry) {
        tpPrice = entry + (entry * 0.015); // 1.5% fallback
      }

      takeProfit = tpPrice.toStringAsFixed(2);
    } else {
      // SHORT_ONLY
      direction = 'SELL';

      trendReason = regime;
      if (structure.bos?.type == 'BEARISH_BOS') {
        trendReason += ' + BEARISH BOS (structure break)';
      }
      if (structure.choch?.type == 'BEARISH_CHOCH') {
        trendReason += ' + BEARISH CHOCH (trend reversal)';
      }

      structureReason = 'LH/LL pattern';
      if (structure.pivots.isNotEmpty) {
        final recentLows =
            structure.pivots.where((p) => p.type == 'LOW').take(2).toList();
        if (recentLows.length == 2 &&
            recentLows[0].price < recentLows[1].price) {
          structureReason = 'Lower Lows confirmed';
        }
      }

      final momentumReasons = <String>[];
      if (momentum.direction == 'BEARISH')
        momentumReasons.add('Bearish momentum');
      if (momentum.macdInflection == 'BEARISH')
        momentumReasons.add('MACD bearish');
      if (momentum.rsiDivergence == 'BEARISH_DIVERGENCE') {
        momentumReasons.add('RSI bearish divergence');
      }
      if (momentum.hiddenDivergence == 'HIDDEN_BEARISH') {
        momentumReasons.add('Hidden bearish divergence (continuation)');
      }
      if (rsi < 50) momentumReasons.add('RSI<${rsi.toStringAsFixed(0)}');

      momentumReason = momentumReasons.isEmpty
          ? 'Trend-based (momentum neutral)'
          : momentumReasons.join(' + ');

      // SL above recent high
      double slPrice;
      if (structure.pivots.isNotEmpty) {
        final recentHighs = structure.pivots
            .where((p) => p.type == 'HIGH' && p.price > currentPrice)
            .toList();
        if (recentHighs.isNotEmpty) {
          recentHighs.sort((a, b) => a.price.compareTo(b.price));
          slPrice = recentHighs.first.price + (effectiveAtr * 0.5);
        } else {
          slPrice = currentPrice + (effectiveAtr * 1.5);
        }
      } else {
        slPrice = currentPrice + (effectiveAtr * 1.5);
      }

      // Ensure SL is at least 0.5% above entry for SELL (swing trade)
      final minSwingSL = entry * 0.005; // 0.5% for swing trades
      if (slPrice - entry < minSwingSL) {
        slPrice = entry + (entry * 0.008); // 0.8% fallback
      }

      // Ensure SL is valid
      if (slPrice <= entry) {
        slPrice = entry + (entry * 0.008); // 0.8% fallback
      }

      stopLoss = slPrice.toStringAsFixed(2);

      // TP: liquidity low with reasonable limits
      double tpPrice;

      // Calculate maximum TP distance (3% of price or 5x ATR, whichever is smaller)
      final maxTPDistance = min(entry * 0.03, effectiveAtr * 5.0);

      final minSwingTarget = entry * 0.008; // 0.8% minimum for swing target
      if (liquidity.nearestTarget?.below != null &&
          liquidity.nearestTarget!.below! < entry - minSwingTarget) {
        final targetPrice = liquidity.nearestTarget!.below! + 1.0;
        // Apply limit: don't exceed maxTPDistance
        if (entry - targetPrice <= maxTPDistance) {
          tpPrice = targetPrice;
          liquidityTarget =
              'Liquidity low at \$${liquidity.nearestTarget!.below!.toStringAsFixed(2)}';
        } else {
          // Use R:R instead if target is too far
          final risk = slPrice - entry;
          tpPrice = entry - (risk * 2.0);
          liquidityTarget = 'R:R 1:2 target (liquidity too far)';
        }
      } else if (liquidity.liquidityLows.isNotEmpty &&
          liquidity.liquidityLows.first.price < entry - minSwingTarget) {
        final targetPrice = liquidity.liquidityLows.first.price + 1.0;
        // Apply limit: don't exceed maxTPDistance
        if (entry - targetPrice <= maxTPDistance) {
          tpPrice = targetPrice;
          liquidityTarget = 'Nearest liquidity low';
        } else {
          // Use R:R instead if target is too far
          final risk = slPrice - entry;
          tpPrice = entry - (risk * 2.0);
          liquidityTarget = 'R:R 1:2 target (liquidity too far)';
        }
      } else {
        final risk = slPrice - entry;
        tpPrice = entry - (risk * 2.0);
        liquidityTarget = 'R:R 1:2 target';
      }

      // Apply maximum distance limit
      if (entry - tpPrice > maxTPDistance) {
        tpPrice = entry - maxTPDistance;
        liquidityTarget =
            'R:R target (limited to ${(maxTPDistance / (slPrice - entry)).toStringAsFixed(1)}x)';
      }

      // Ensure TP is at least 1.2% below entry for SELL (swing trade)
      final minSwingProfit = entry * 0.012; // 1.2% minimum profit for swing
      if (entry - tpPrice < minSwingProfit) {
        tpPrice = entry - minSwingProfit;
      }

      // Ensure TP is valid
      if (tpPrice >= entry) {
        tpPrice = entry - (entry * 0.015); // 1.5% fallback
      }

      takeProfit = tpPrice.toStringAsFixed(2);
    }

    // ==========================================
    // LAYER 10: PROBABILITY SCORING
    // ==========================================
    final liquidityStrength = _calculateLiquidityStrength(liquidity);
    final hasEnoughPivots =
        structure.pivots.length >= ZoneDetector.minPivotCount;

    final confidence = _calculateSwingConfidence(
      regimeStrength:
          regime == 'STRONG_TREND_UP' || regime == 'STRONG_TREND_DOWN'
              ? 80
              : 60,
      structureConfirmed:
          (structure.bos != null || structure.choch != null) && hasEnoughPivots,
      momentumAligned: momentum.direction != 'NEUTRAL',
      liquidityTargetClear: liquidity.nearestTarget != null &&
          liquidityStrength >= ZoneDetector.minLiquidityStrength,
    );

    // Build professional reasoning with indicators for Swing
    final swingReasoningParts = <String>[];

    // Trend analysis
    swingReasoningParts.add(
        'الاتجاه: ${regime == 'STRONG_TREND_UP' ? 'صاعد قوي' : regime == 'WEAK_TREND_UP' ? 'صاعد ضعيف' : regime == 'STRONG_TREND_DOWN' ? 'هابط قوي' : regime == 'WEAK_TREND_DOWN' ? 'هابط ضعيف' : 'تداول جانبي'}');

    // Structure analysis
    if (structure.bos != null) {
      swingReasoningParts.add(
          'كسر الهيكل ${structure.bos!.type == 'BULLISH_BOS' ? 'صاعد' : 'هابط'}');
    }
    if (structure.choch != null) {
      swingReasoningParts.add(
          'تغيير الطابع ${structure.choch!.type == 'BULLISH_CHOCH' ? 'صاعد' : 'هابط'}');
    }
    swingReasoningParts.add(structureReason);

    // Momentum analysis with MACD
    swingReasoningParts.add(momentumReason);
    if (momentum.macdInflection == 'BULLISH') {
      swingReasoningParts.add('MACD: إشارة صاعدة');
    } else if (momentum.macdInflection == 'BEARISH') {
      swingReasoningParts.add('MACD: إشارة هابطة');
    }

    // RSI analysis
    if (rsi > 70) {
      swingReasoningParts
          .add('RSI: تشبع شرائي (${rsi.toStringAsFixed(1)}) - حذر');
    } else if (rsi < 30) {
      swingReasoningParts
          .add('RSI: تشبع بيعي (${rsi.toStringAsFixed(1)}) - فرصة');
    } else {
      swingReasoningParts.add(
          'RSI: ${rsi.toStringAsFixed(1)} (${rsi > 50 ? 'زخم صاعد' : 'زخم هابط'})');
    }

    // Volatility with ATR
    swingReasoningParts.add(
        'ATR: ${atr.toStringAsFixed(2)} (${atr > 15 ? 'تقلبات عالية' : atr > 10 ? 'تقلبات متوسطة' : 'تقلبات منخفضة'})');

    // Liquidity
    if (liquidity.nearestTarget != null) {
      swingReasoningParts.add('هدف السيولة: $liquidityTarget');
    }

    // Risk/Reward
    final risk = direction == 'BUY'
        ? (entry - double.parse(stopLoss.replaceAll('\$', '')))
        : (double.parse(stopLoss.replaceAll('\$', '')) - entry);
    final reward = direction == 'BUY'
        ? (double.parse(takeProfit.replaceAll('\$', '')) - entry)
        : (entry - double.parse(takeProfit.replaceAll('\$', '')));
    final rr = risk > 0 ? (reward / risk) : 0;
    swingReasoningParts.add('نسبة المخاطرة/العائد: 1:${rr.toStringAsFixed(2)}');

    final swingReasoning = swingReasoningParts.join(' • ');

    return {
      'direction': direction,
      'entry': entry.toStringAsFixed(2),
      'stop_loss': stopLoss,
      'take_profit': takeProfit,
      'trend_reason': trendReason,
      'structure_reason': structureReason,
      'momentum_reason': momentumReason,
      'liquidity_target': liquidityTarget,
      'confidence': confidence,
      'reasoning': swingReasoning,
    };
  }

  /// Calculate swing confidence (Layer 10)
  static int _calculateSwingConfidence({
    required int regimeStrength,
    required bool structureConfirmed,
    required bool momentumAligned,
    required bool liquidityTargetClear,
  }) {
    int score = regimeStrength; // 60-80 base

    if (structureConfirmed) score += 10; // BOS or CHOCH
    if (momentumAligned) score += 5;
    if (liquidityTargetClear) score += 5;

    return min(score, 100);
  }

  // ══════════════════════════════════════════════════════════════════
  // 🆕 ENHANCED ANALYSIS WITH INTEGRATED SYSTEMS
  // ══════════════════════════════════════════════════════════════════

  /// تحليل محسّن مع Bayesian + Chaos + ML Decision
  ///
  /// **يضيف:**
  /// - Bayesian Probability Analysis
  /// - Chaos Risk Assessment
  /// - Dynamic Position Sizing
  /// - ML-Based EXECUTE/WAIT/ABORT Decision
  ///
  /// **Returns:** Map مع النتائج الأصلية + التحليلات المتقدمة
  static Future<Map<String, dynamic>> generateEnhanced({
    required double currentPrice,
    required List<Candle> candles,
    required double rsi,
    required double macd,
    required double macdSignal,
    required double ma20,
    required double ma50,
    required double ma100,
    required double ma200,
    required double atr,
    double accountBalance = 10000.0,
  }) async {
    // الحصول على التحليل الأصلي
    final originalResult = await generate(
      currentPrice: currentPrice,
      candles: candles,
      rsi: rsi,
      macd: macd,
      macdSignal: macdSignal,
      ma20: ma20,
      ma50: ma50,
      ma100: ma100,
      ma200: ma200,
      atr: atr,
    );

    // ══════════════════════════════════════════════════════════════════
    // SCALP ANALYSIS
    // ══════════════════════════════════════════════════════════════════

    final scalpSignal = originalResult['SCALP'] as Map<String, dynamic>;
    final scalpDirection = scalpSignal['direction'] as String;
    final scalpConfidence = (scalpSignal['confidence'] as int) / 100.0;

    // Chaos Analysis
    ChaosAnalysis? chaosAnalysis;
    try {
      if (candles.length >= 100) {
        chaosAnalysis = ChaosVolatilityEngine.analyze(candles);
      }
    } catch (e) {
      // Use fallback values
    }

    final chaosRiskLevel =
        chaosAnalysis?.riskLevel ?? (atr / currentPrice * 10).clamp(0.0, 1.0);

    // حساب العوامل للتحليل البايزي
    final trendStrength =
        _calculateTrendStrength(ma20, ma50, ma100, ma200, currentPrice);
    final momentum = (macd - macdSignal) / currentPrice * 100;
    final volatility = (atr / currentPrice * 100).clamp(0.0, 1.0);
    final volumeProfile = candles.length >= 20
        ? _calculateVolumeProfile(candles.sublist(candles.length - 20))
        : 0.5;

    // Bayesian Analysis للـ Scalp
    final scalpBayesian = CentralBayesianEngine.analyze(
      signalStrength: scalpConfidence,
      trendStrength: trendStrength,
      momentum: momentum,
      volatility: volatility,
      volumeProfile: volumeProfile,
      timeframeAlignment: 0.7, // افتراضي
      structureQuality: 0.65, // من market structure
      chaosRiskLevel: chaosRiskLevel,
      signalDirection: scalpDirection == 'NO TRADE' ? null : scalpDirection,
    );

    // Decision Factors
    final scalpFactors = DecisionFactors(
      trendStrength: trendStrength,
      volatility: volatility,
      momentum: momentum,
      chaosLevel: chaosRiskLevel,
      signalStrength: scalpConfidence,
      timeframeAlignment: 0.7,
      volumeProfile: volumeProfile,
      structureQuality: 0.65,
    );

    // ML Decision
    final scalpDecision = MLDecisionMaker.makeDecision(
      bayesianAnalysis: scalpBayesian,
      chaosRiskLevel: chaosRiskLevel,
      signalStrength: scalpConfidence,
      signalConfidence: scalpConfidence,
      volatility: volatility,
      factors: scalpFactors,
      accountBalance: accountBalance,
      signalDirection: scalpDirection,
    );

    // ══════════════════════════════════════════════════════════════════
    // SWING ANALYSIS
    // ══════════════════════════════════════════════════════════════════

    final swingSignal = originalResult['SWING'] as Map<String, dynamic>;
    final swingDirection = swingSignal['direction'] as String;
    final swingConfidence = (swingSignal['confidence'] as int) / 100.0;

    // Bayesian Analysis للـ Swing
    final swingBayesian = CentralBayesianEngine.analyze(
      signalStrength: swingConfidence,
      trendStrength: trendStrength,
      momentum: momentum,
      volatility: volatility,
      volumeProfile: volumeProfile,
      timeframeAlignment: 0.8, // Swing يحتاج توافق أعلى
      structureQuality: 0.70,
      chaosRiskLevel: chaosRiskLevel,
      signalDirection: swingDirection == 'NO TRADE' ? null : swingDirection,
    );

    // Decision Factors للـ Swing
    final swingFactors = DecisionFactors(
      trendStrength: trendStrength,
      volatility: volatility,
      momentum: momentum,
      chaosLevel: chaosRiskLevel,
      signalStrength: swingConfidence,
      timeframeAlignment: 0.8,
      volumeProfile: volumeProfile,
      structureQuality: 0.70,
    );

    // ML Decision للـ Swing
    final swingDecision = MLDecisionMaker.makeDecision(
      bayesianAnalysis: swingBayesian,
      chaosRiskLevel: chaosRiskLevel,
      signalStrength: swingConfidence,
      signalConfidence: swingConfidence,
      volatility: volatility,
      factors: swingFactors,
      accountBalance: accountBalance,
      signalDirection: swingDirection,
    );

    // ══════════════════════════════════════════════════════════════════
    // BUILD ENHANCED RESULT
    // ══════════════════════════════════════════════════════════════════

    return {
      // النتائج الأصلية
      'SCALP': scalpSignal,
      'SWING': swingSignal,

      // التحليلات المتقدمة - SCALP
      'SCALP_ENHANCED': {
        'bayesian': scalpBayesian.toJson(),
        'decision': scalpDecision.toJson(),
        'action': scalpDecision.action.name,
        'action_icon': scalpDecision.action.icon,
        'action_description': scalpDecision.action.description,
        'position_size_percent': scalpDecision.positionSize,
        'position_size_dollars': scalpDecision.positionSize * accountBalance,
        'chaos_risk_level': chaosRiskLevel,
        'quality_score': scalpDecision.qualityScore,
      },

      // التحليلات المتقدمة - SWING
      'SWING_ENHANCED': {
        'bayesian': swingBayesian.toJson(),
        'decision': swingDecision.toJson(),
        'action': swingDecision.action.name,
        'action_icon': swingDecision.action.icon,
        'action_description': swingDecision.action.description,
        'position_size_percent': swingDecision.positionSize,
        'position_size_dollars': swingDecision.positionSize * accountBalance,
        'chaos_risk_level': chaosRiskLevel,
        'quality_score': swingDecision.qualityScore,
      },

      // معلومات إضافية
      'CHAOS_ANALYSIS': chaosAnalysis?.toJson(),
      'MARKET_FACTORS': {
        'trend_strength': trendStrength,
        'momentum': momentum,
        'volatility': volatility,
        'volume_profile': volumeProfile,
      },
    };
  }

  // Helper methods

  static double _calculateTrendStrength(
    double ma20,
    double ma50,
    double ma100,
    double ma200,
    double currentPrice,
  ) {
    int bullish = 0;
    int bearish = 0;

    // MA alignment
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

    final strength = (bullish - bearish) / 4.0;
    return strength.clamp(-1.0, 1.0);
  }

  static double _calculateVolumeProfile(List<Candle> recentCandles) {
    if (recentCandles.isEmpty) {
      return 0.5;
    }

    final volumes = recentCandles.map((c) => c.volume).toList();
    final avgVolume = volumes.reduce((a, b) => a + b) / volumes.length;
    final currentVolume = volumes.last;

    return (currentVolume / avgVolume).clamp(0.0, 1.0);
  }
}

// ============================================
// DATA MODELS
// ============================================

class VolatilityState {
  final double atr;
  final bool compression;
  final bool expansion;
  final bool wickyMarket;
  final bool extremeMove;
  final bool fakeoutRisk;
  final bool dangerous;
  final bool safe;

  VolatilityState({
    required this.atr,
    required this.compression,
    required this.expansion,
    required this.wickyMarket,
    required this.extremeMove,
    required this.fakeoutRisk,
    required this.dangerous,
    required this.safe,
  });
}

class TrendBias {
  final String swingBias; // LONG_ONLY, SHORT_ONLY, NO_TRADE
  final String scalpBias; // PREFER_LONG, PREFER_SHORT, BOTH

  TrendBias({
    required this.swingBias,
    required this.scalpBias,
  });
}
