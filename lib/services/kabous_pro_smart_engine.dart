// 🔥 KABOUS PRO SMART ENGINE 🔥
// محرك ذكي احترافي لتداول الذهب - نسخة محسّنة
// يحدد Entry, TP, SL ديناميكيًا بناءً على:
// - Market Structure (BOS/CHoCH)
// - Smart Money Concepts (FVG, OB, Liquidity)
// - Multi-Timeframe Confirmation
// - Dynamic Risk Management
// - Performance Caching & Optimization

import 'dart:math';
import '../models/candle.dart';

// ============================================================================
// CACHE SYSTEM - تحسين الأداء
// ============================================================================

class _CacheEntry<T> {
  final T value;
  final DateTime timestamp;
  final int candlesHash;

  _CacheEntry(this.value, this.timestamp, this.candlesHash);

  bool isValid(int currentHash, Duration maxAge) {
    return candlesHash == currentHash &&
        DateTime.now().difference(timestamp) < maxAge;
  }
}

class _AnalysisCache {
  final Map<String, _CacheEntry> _cache = {};
  static const _maxAge = Duration(seconds: 5);

  T? get<T>(String key, int candlesHash) {
    final entry = _cache[key];
    if (entry != null && entry.isValid(candlesHash, _maxAge)) {
      return entry.value as T;
    }
    return null;
  }

  void set<T>(String key, T value, int candlesHash) {
    _cache[key] = _CacheEntry<T>(value, DateTime.now(), candlesHash);
  }

  void clear() => _cache.clear();

  int computeHash(List<Candle> candles) {
    if (candles.isEmpty) return 0;
    // Hash based on last candle time and close price
    return Object.hash(
      candles.last.time.millisecondsSinceEpoch,
      candles.last.close,
      candles.length,
    );
  }
}

// ============================================================================
// MODELS
// ============================================================================

enum SignalType { BUY, SELL, NO_TRADE }

enum MarketStructure {
  STRONG_BULLISH, // Higher Highs + Higher Lows
  BULLISH, // Bullish bias
  RANGING, // Sideways
  BEARISH, // Bearish bias
  STRONG_BEARISH // Lower Highs + Lower Lows
}

class SmartSignal {
  final SignalType type;
  final double entry;
  final double stopLoss;
  final double takeProfit;
  final double confidence; // 0-100
  final double riskReward;
  final String reason;
  final Map<String, dynamic> details;

  SmartSignal({
    required this.type,
    required this.entry,
    required this.stopLoss,
    required this.takeProfit,
    required this.confidence,
    required this.riskReward,
    required this.reason,
    this.details = const {},
  });

  bool get isValid => type != SignalType.NO_TRADE && confidence >= 60.0;
}

class MarketContext {
  final MarketStructure structure;
  final double trend; // -1 to +1
  final double volatility;
  final List<double> supportLevels;
  final List<double> resistanceLevels;
  final double atr;
  final double currentPrice;

  MarketContext({
    required this.structure,
    required this.trend,
    required this.volatility,
    required this.supportLevels,
    required this.resistanceLevels,
    required this.atr,
    required this.currentPrice,
  });
}

// ============================================================================
// KABOUS PRO SMART ENGINE
// ============================================================================

class KabousProSmartEngine {
  static final _cache = _AnalysisCache();

  /// Analyze market and generate smart signal - ENHANCED VERSION
  static SmartSignal analyze(List<Candle> candles) {
    try {
      // Validation
      if (candles.isEmpty) {
        return _noTradeSignal('No data provided');
      }
      if (candles.length < 200) {
        return _noTradeSignal(
            'Insufficient data: ${candles.length} candles (need 200+)');
      }

      final candlesHash = _cache.computeHash(candles);

      // 1. Analyze Market Context (with caching)
      final context = _analyzeMarketContext(candles, candlesHash);

      // 2. Detect Market Structure (with caching)
      final structureSignal =
          _detectMarketStructure(candles, context, candlesHash);

      // 3. Find Smart Money Zones (with caching)
      final smZones = _findSmartMoneyZones(candles, context, candlesHash);

      // 4. Multi-Timeframe Confirmation (with caching)
      final mtfScore = _calculateMTFScore(candles, candlesHash);

      // 5. Calculate Enhanced Confluence Score
      final confluence = _calculateConfluence(
        structure: structureSignal,
        smartMoney: smZones,
        mtf: mtfScore,
        context: context,
      );

      // 6. Generate Signal with improved threshold (تحسين الدقة)
      if (confluence < 58.0) {
        // تم التحسين من 55 إلى 58 لتوازن أفضل
        return _noTradeSignal(
            'Low confluence: ${confluence.toStringAsFixed(1)}% (need 58%+)');
      }

      // 7. Determine Signal Type with enhanced logic
      final signalType =
          _determineSignalType(context, structureSignal, confluence);

      if (signalType == SignalType.NO_TRADE) {
        return _noTradeSignal('Market conditions not favorable');
      }

      // 8. Calculate Smart Entry, SL, TP with enhanced risk management
      return _buildSmartSignal(
        type: signalType,
        candles: candles,
        context: context,
        smZones: smZones,
        confluence: confluence,
      );
    } catch (e) {
      return _noTradeSignal('Analysis error: ${e.toString()}');
    }
  }

  /// Clear cache - call when switching timeframes or instruments
  static void clearCache() {
    _cache.clear();
  }

  // ==========================================================================
  // MARKET CONTEXT ANALYSIS
  // ==========================================================================

  static MarketContext _analyzeMarketContext(
      List<Candle> candles, int candlesHash) {
    // Check cache first
    final cached = _cache.get<MarketContext>('market_context', candlesHash);
    if (cached != null) return cached;

    final current = candles.last.close;

    // Calculate ATR (14 periods) - with caching
    final atr = _calculateATR(candles, 14, candlesHash);

    // Calculate Trend using EMAs - with caching for better performance
    final ema20 = _calculateEMA(candles, 20, candlesHash);
    final ema50 = _calculateEMA(candles, 50, candlesHash);
    final ema100 = _calculateEMA(candles, 100, candlesHash);
    final ema200 = _calculateEMA(candles, 200, candlesHash);

    // Enhanced Trend Score: -1 (strong bear) to +1 (strong bull)
    double trend = 0.0;

    if (ema20 > ema50 && ema50 > ema100 && ema100 > ema200) {
      trend = 1.0; // Perfect bullish alignment
    } else if (ema20 < ema50 && ema50 < ema100 && ema100 < ema200) {
      trend = -1.0; // Perfect bearish alignment
    } else {
      // Partial alignment with weighted scoring
      double score = 0.0;
      if (ema20 > ema50) score += 0.4; // Most weight to recent EMAs
      if (ema50 > ema100) score += 0.35;
      if (ema100 > ema200) score += 0.25;

      trend = (score >= 0.5) ? score : -(1.0 - score);
    }

    // Detect Market Structure - with caching
    final structure = _classifyMarketStructure(candles, trend, candlesHash);

    // Calculate Volatility (ATR as % of price)
    final volatility = (atr / current) * 100;

    // Find Support/Resistance - with caching
    final levels = _findKeyLevels(candles, candlesHash);

    final context = MarketContext(
      structure: structure,
      trend: trend,
      volatility: volatility,
      supportLevels: levels['support']!,
      resistanceLevels: levels['resistance']!,
      atr: atr,
      currentPrice: current,
    );

    // Cache the result
    _cache.set('market_context', context, candlesHash);
    return context;
  }

  static MarketStructure _classifyMarketStructure(
      List<Candle> candles, double trend, int candlesHash) {
    // Check cache first
    final cached = _cache.get<MarketStructure>('market_structure', candlesHash);
    if (cached != null) return cached;

    // Analyze recent swing highs and lows
    final swings =
        _findSwingPoints(candles, lookback: 50, candlesHash: candlesHash);

    if (swings.isEmpty || swings.length < 4) {
      final result = MarketStructure.RANGING;
      _cache.set('market_structure', result, candlesHash);
      return result;
    }

    // FIXED: Separate highs and lows for proper comparison
    final highs = swings.where((s) => s['type'] == 'high').toList();
    final lows = swings.where((s) => s['type'] == 'low').toList();

    int hhCount = 0; // Higher Highs
    int lhCount = 0; // Lower Highs
    int hlCount = 0; // Higher Lows
    int llCount = 0; // Lower Lows

    // Compare consecutive highs
    for (int i = 1; i < highs.length; i++) {
      if (highs[i]['price'] > highs[i - 1]['price']) {
        hhCount++;
      } else {
        lhCount++;
      }
    }

    // Compare consecutive lows
    for (int i = 1; i < lows.length; i++) {
      if (lows[i]['price'] > lows[i - 1]['price']) {
        hlCount++;
      } else {
        llCount++;
      }
    }

    // Enhanced classification with trend confirmation
    MarketStructure result;

    if (hhCount >= 2 && hlCount >= 2 && trend > 0.3) {
      result = MarketStructure.STRONG_BULLISH;
    } else if (hhCount > lhCount && hlCount >= llCount && trend > 0) {
      result = MarketStructure.BULLISH;
    } else if (lhCount >= 2 && llCount >= 2 && trend < -0.3) {
      result = MarketStructure.STRONG_BEARISH;
    } else if (lhCount > hhCount && llCount > hlCount && trend < 0) {
      result = MarketStructure.BEARISH;
    } else {
      result = MarketStructure.RANGING;
    }

    _cache.set('market_structure', result, candlesHash);
    return result;
  }

  static List<Map<String, dynamic>> _findSwingPoints(
    List<Candle> candles, {
    int lookback = 50,
    int? candlesHash,
  }) {
    // Check cache if hash provided
    if (candlesHash != null) {
      final cached = _cache.get<List<Map<String, dynamic>>>(
          'swing_points_$lookback', candlesHash);
      if (cached != null) return cached;
    }

    final swings = <Map<String, dynamic>>[];

    // Safety check
    if (candles.length < 5) return swings;

    final recent = candles.sublist(max(0, candles.length - lookback));

    // FIXED: Proper boundary checking to prevent index out of bounds
    final maxIndex = recent.length - 3; // Need at least 2 candles ahead

    if (maxIndex < 2) return swings; // Not enough data

    for (int i = 2; i <= maxIndex; i++) {
      final candle = recent[i];

      // Swing High - with safe index access
      if (i >= 2 && i < recent.length - 2) {
        if (candle.high > recent[i - 1].high &&
            candle.high > recent[i - 2].high &&
            candle.high > recent[i + 1].high &&
            candle.high > recent[i + 2].high) {
          swings.add({
            'type': 'high',
            'price': candle.high,
            'index': i,
            'time': candle.time,
          });
        }
      }

      // Swing Low - with safe index access
      if (i >= 2 && i < recent.length - 2) {
        if (candle.low < recent[i - 1].low &&
            candle.low < recent[i - 2].low &&
            candle.low < recent[i + 1].low &&
            candle.low < recent[i + 2].low) {
          swings.add({
            'type': 'low',
            'price': candle.low,
            'index': i,
            'time': candle.time,
          });
        }
      }
    }

    // Cache the result
    if (candlesHash != null) {
      _cache.set('swing_points_$lookback', swings, candlesHash);
    }

    return swings;
  }

  // ==========================================================================
  // SMART MONEY CONCEPTS
  // ==========================================================================

  static Map<String, List<double>> _findSmartMoneyZones(
      List<Candle> candles, MarketContext context, int candlesHash) {
    // Check cache first
    final cached =
        _cache.get<Map<String, List<double>>>('smart_money_zones', candlesHash);
    if (cached != null) return cached;

    final zones = <String, List<double>>{
      'demand': [],
      'supply': [],
      'fvg': [], // Fair Value Gaps
    };

    // Safety check
    if (candles.length < 10) return zones;

    // Find Order Blocks (last 100 candles)
    final recent = candles.sublist(max(0, candles.length - 100));

    // Enhanced threshold for stronger signals
    final atrThreshold = context.atr * 0.75; // Slightly more lenient

    // Optimized loop - single pass for all zones
    for (int i = 5; i < recent.length - 1; i++) {
      // Safety checks
      if (i < 4 || i >= recent.length) continue;

      final prev4 = recent[i - 4];
      final prev3 = recent[i - 3];
      final prev2 = recent[i - 2];
      final curr = recent[i];

      // Bullish Order Block: Strong bullish candle after pullback
      // Enhanced: Check for momentum reversal
      if (prev4.isBearish &&
          prev3.isBearish &&
          prev2.isBearish &&
          curr.isBullish &&
          curr.bodySize > atrThreshold) {
        zones['demand']!.add(curr.low);
      }

      // Bearish Order Block: Strong bearish candle after rally
      // Enhanced: Check for momentum reversal
      if (prev4.isBullish &&
          prev3.isBullish &&
          prev2.isBullish &&
          curr.isBearish &&
          curr.bodySize > atrThreshold) {
        zones['supply']!.add(curr.high);
      }

      // Fair Value Gap (FVG): Gap between candles
      if (i >= 2 && i < recent.length) {
        final prev = recent[i - 2];
        final next = recent[i];

        // Bullish FVG - with minimum gap size validation
        final bullishGap = next.low - prev.high;
        if (bullishGap > context.atr * 0.1) {
          zones['fvg']!.add((prev.high + next.low) / 2);
        }

        // Bearish FVG - with minimum gap size validation
        final bearishGap = prev.low - next.high;
        if (bearishGap > context.atr * 0.1) {
          zones['fvg']!.add((prev.low + next.high) / 2);
        }
      }
    }

    // Limit zones to most recent/relevant (prevent memory bloat)
    if (zones['demand']!.length > 5) {
      zones['demand'] = zones['demand']!.sublist(zones['demand']!.length - 5);
    }
    if (zones['supply']!.length > 5) {
      zones['supply'] = zones['supply']!.sublist(zones['supply']!.length - 5);
    }
    if (zones['fvg']!.length > 5) {
      zones['fvg'] = zones['fvg']!.sublist(zones['fvg']!.length - 5);
    }

    // Cache the result
    _cache.set('smart_money_zones', zones, candlesHash);
    return zones;
  }

  // ==========================================================================
  // CONFLUENCE CALCULATION
  // ==========================================================================

  static double _calculateConfluence({
    required double structure,
    required Map<String, List<double>> smartMoney,
    required double mtf,
    required MarketContext context,
  }) {
    double score = 0.0;

    // 1. Market Structure (30%) - وزن متوازن
    score += structure * 0.30;

    // 2. Smart Money Zones (35%) - أهم عامل للدخول
    final demandCount = smartMoney['demand']!.length;
    final supplyCount = smartMoney['supply']!.length;
    final fvgCount = smartMoney['fvg']!.length;

    // Enhanced scoring based on zone quality and quantity
    if (context.trend > 0.2) {
      // Bullish context
      if (demandCount > 0) {
        score += 15.0 + min(demandCount * 3.0, 10.0); // 15-25 points
      }
      if (fvgCount > 0 && context.trend > 0) {
        score += 5.0 + min(fvgCount * 2.0, 5.0); // 5-10 points
      }
    } else if (context.trend < -0.2) {
      // Bearish context
      if (supplyCount > 0) {
        score += 15.0 + min(supplyCount * 3.0, 10.0); // 15-25 points
      }
      if (fvgCount > 0 && context.trend < 0) {
        score += 5.0 + min(fvgCount * 2.0, 5.0); // 5-10 points
      }
    }

    // 3. Multi-Timeframe (20%) - تأكيد مهم
    score += mtf * 0.20;

    // 4. Trend Strength (15%) - قوة الاتجاه
    final trendScore = context.trend.abs() * 15.0;
    score += trendScore;

    // 5. Volatility Factor (bonus/penalty up to ±5%)
    // Low volatility = better for precision entries
    if (context.volatility < 0.5) {
      score += 5.0; // Bonus for stable market
    } else if (context.volatility > 2.0) {
      score -= 3.0; // Penalty for high volatility
    }

    return score.clamp(0.0, 100.0);
  }

  // ==========================================================================
  // SIGNAL GENERATION
  // ==========================================================================

  static SignalType _determineSignalType(
      MarketContext context, double structureScore, double confluence) {
    // Enhanced signal type determination with confluence weighting

    // Strong bullish conditions
    if (context.trend > 0.35 &&
        context.structure == MarketStructure.STRONG_BULLISH &&
        structureScore > 65.0 &&
        confluence >= 65.0) {
      return SignalType.BUY;
    }

    // Moderate bullish - requires higher confluence
    if (context.trend > 0.2 &&
        (context.structure == MarketStructure.BULLISH ||
            context.structure == MarketStructure.STRONG_BULLISH) &&
        structureScore > 60.0 &&
        confluence >= 60.0) {
      return SignalType.BUY;
    }

    // Strong bearish conditions
    if (context.trend < -0.35 &&
        context.structure == MarketStructure.STRONG_BEARISH &&
        structureScore > 65.0 &&
        confluence >= 65.0) {
      return SignalType.SELL;
    }

    // Moderate bearish - requires higher confluence
    if (context.trend < -0.2 &&
        (context.structure == MarketStructure.BEARISH ||
            context.structure == MarketStructure.STRONG_BEARISH) &&
        structureScore > 60.0 &&
        confluence >= 60.0) {
      return SignalType.SELL;
    }

    // Ranging market filter - avoid false signals
    if (context.structure == MarketStructure.RANGING &&
        context.trend.abs() < 0.3) {
      return SignalType.NO_TRADE;
    }

    return SignalType.NO_TRADE;
  }

  static SmartSignal _buildSmartSignal({
    required SignalType type,
    required List<Candle> candles,
    required MarketContext context,
    required Map<String, List<double>> smZones,
    required double confluence,
  }) {
    final current = context.currentPrice;
    final atr = context.atr;

    double entry, sl, tp;
    String reason;
    Map<String, dynamic> details = {};

    if (type == SignalType.BUY) {
      // Entry: Use demand zone if close, otherwise current price
      entry = current;
      if (smZones['demand']!.isNotEmpty) {
        final nearestDemand = smZones['demand']!
            .where((d) => d < current && (current - d) < atr * 1.5)
            .toList();
        if (nearestDemand.isNotEmpty) {
          nearestDemand.sort((a, b) => b.compareTo(a)); // Closest first
          entry = (current + nearestDemand.first) / 2; // Average for safety
        }
      }

      // Stop Loss: Below nearest demand zone or structure low
      final nearestSupport =
          _findNearestLevel(entry, context.supportLevels, direction: 'below');

      if (nearestSupport != null && (entry - nearestSupport) < atr * 3) {
        sl = nearestSupport - (atr * 0.4);
      } else if (smZones['demand']!.isNotEmpty) {
        // Use demand zone
        final demandZone = smZones['demand']!.last;
        sl = demandZone - (atr * 0.5);
      } else {
        sl = entry - (atr * 1.8);
      }

      // Validate SL is not too tight or too wide
      final slDistance = entry - sl;
      if (slDistance < atr * 0.8) {
        sl = entry - (atr * 0.8); // Minimum distance
      } else if (slDistance > atr * 3.5) {
        sl = entry - (atr * 3.5); // Maximum distance
      }

      // Take Profit: Nearest resistance with dynamic RR
      final nearestResistance = _findNearestLevel(
          entry, context.resistanceLevels,
          direction: 'above');

      // Dynamic RR based on confluence (higher confluence = higher TP)
      final targetRR = confluence >= 70 ? 3.0 : (confluence >= 65 ? 2.5 : 2.0);
      final minTP = entry + ((entry - sl) * targetRR);

      if (nearestResistance != null && nearestResistance > minTP) {
        tp = nearestResistance - (atr * 0.25);
      } else {
        tp = minTP;
      }

      reason =
          'Bullish: ${context.structure.toString().split('.').last} + ${smZones['demand']!.length} demand zones';
      details = {
        'demandZones': smZones['demand']!.length,
        'supplyZones': smZones['supply']!.length,
        'fvgZones': smZones['fvg']!.length,
      };
    } else {
      // SELL
      entry = current;
      if (smZones['supply']!.isNotEmpty) {
        final nearestSupply = smZones['supply']!
            .where((s) => s > current && (s - current) < atr * 1.5)
            .toList();
        if (nearestSupply.isNotEmpty) {
          nearestSupply.sort(); // Closest first
          entry = (current + nearestSupply.first) / 2;
        }
      }

      // Stop Loss: Above nearest supply zone or structure high
      final nearestResistance = _findNearestLevel(
          entry, context.resistanceLevels,
          direction: 'above');

      if (nearestResistance != null && (nearestResistance - entry) < atr * 3) {
        sl = nearestResistance + (atr * 0.4);
      } else if (smZones['supply']!.isNotEmpty) {
        final supplyZone = smZones['supply']!.last;
        sl = supplyZone + (atr * 0.5);
      } else {
        sl = entry + (atr * 1.8);
      }

      // Validate SL
      final slDistance = sl - entry;
      if (slDistance < atr * 0.8) {
        sl = entry + (atr * 0.8);
      } else if (slDistance > atr * 3.5) {
        sl = entry + (atr * 3.5);
      }

      // Take Profit
      final nearestSupport =
          _findNearestLevel(entry, context.supportLevels, direction: 'below');

      final targetRR = confluence >= 70 ? 3.0 : (confluence >= 65 ? 2.5 : 2.0);
      final minTP = entry - ((sl - entry) * targetRR);

      if (nearestSupport != null && nearestSupport < minTP) {
        tp = nearestSupport + (atr * 0.25);
      } else {
        tp = minTP;
      }

      reason =
          'Bearish: ${context.structure.toString().split('.').last} + ${smZones['supply']!.length} supply zones';
      details = {
        'demandZones': smZones['demand']!.length,
        'supplyZones': smZones['supply']!.length,
        'fvgZones': smZones['fvg']!.length,
      };
    }

    // Calculate Risk:Reward
    final risk = (entry - sl).abs();
    final reward = (tp - entry).abs();
    final rr = reward / risk;

    // Validation: Ensure minimum RR of 1.5:1
    if (rr < 1.5) {
      return _noTradeSignal('Risk:Reward too low: ${rr.toStringAsFixed(2)}:1');
    }

    return SmartSignal(
      type: type,
      entry: entry,
      stopLoss: sl,
      takeProfit: tp,
      confidence: confluence,
      riskReward: rr,
      reason: reason,
      details: {
        'atr': atr,
        'structure': context.structure.toString(),
        'trend': context.trend,
        'volatility': context.volatility,
        ...details,
      },
    );
  }

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  static double _detectMarketStructure(
      List<Candle> candles, MarketContext context, int candlesHash) {
    // Check cache
    final cached = _cache.get<double>('structure_score', candlesHash);
    if (cached != null) return cached;

    // Return a score based on market structure quality
    double score;
    switch (context.structure) {
      case MarketStructure.STRONG_BULLISH:
        score = 90.0;
        break;
      case MarketStructure.BULLISH:
        score = 75.0;
        break;
      case MarketStructure.RANGING:
        score = 50.0;
        break;
      case MarketStructure.BEARISH:
        score = 75.0;
        break;
      case MarketStructure.STRONG_BEARISH:
        score = 90.0;
        break;
    }

    // Cache the result
    _cache.set('structure_score', score, candlesHash);
    return score;
  }

  static double _calculateMTFScore(List<Candle> candles, int candlesHash) {
    // Check cache
    final cached = _cache.get<double>('mtf_score', candlesHash);
    if (cached != null) return cached;

    // Enhanced MTF score with momentum confirmation
    final ema20 = _calculateEMA(candles, 20, candlesHash);
    final ema50 = _calculateEMA(candles, 50, candlesHash);
    final ema100 = _calculateEMA(candles, 100, candlesHash);
    final current = candles.last.close;

    double score = 50.0;

    // Strong bullish alignment with momentum
    if (current > ema20 && ema20 > ema50 && ema50 > ema100) {
      final momentum = (current - ema50) / ema50 * 100;
      score = momentum > 0.5 ? 90.0 : 80.0;
    }
    // Moderate bullish
    else if (current > ema20 && ema20 > ema50) {
      score = 75.0;
    }
    // Strong bearish alignment with momentum
    else if (current < ema20 && ema20 < ema50 && ema50 < ema100) {
      final momentum = (ema50 - current) / ema50 * 100;
      score = momentum > 0.5 ? 90.0 : 80.0;
    }
    // Moderate bearish
    else if (current < ema20 && ema20 < ema50) {
      score = 75.0;
    }
    // Mixed signals
    else {
      score = 55.0;
    }

    // Cache the result
    _cache.set('mtf_score', score, candlesHash);
    return score;
  }

  static double? _findNearestLevel(double price, List<double> levels,
      {required String direction}) {
    if (levels.isEmpty || price <= 0) return null;

    try {
      final filtered = direction == 'above'
          ? levels.where((l) => l > price && l.isFinite).toList()
          : levels.where((l) => l < price && l.isFinite).toList();

      if (filtered.isEmpty) return null;

      filtered.sort(
          (a, b) => direction == 'above' ? a.compareTo(b) : b.compareTo(a));

      // Ensure the level is within reasonable range (not too far)
      final nearest = filtered.first;
      final distance = (nearest - price).abs() / price;

      // Reject levels more than 5% away
      if (distance > 0.05) return null;

      return nearest;
    } catch (e) {
      return null;
    }
  }

  static Map<String, List<double>> _findKeyLevels(
      List<Candle> candles, int candlesHash) {
    // Check cache
    final cached =
        _cache.get<Map<String, List<double>>>('key_levels', candlesHash);
    if (cached != null) return cached;

    final support = <double>[];
    final resistance = <double>[];

    // Use last 200 candles
    final recent = candles.sublist(max(0, candles.length - 200));
    final swings =
        _findSwingPoints(recent, lookback: 100, candlesHash: candlesHash);

    for (final swing in swings) {
      if (swing['type'] == 'high') {
        resistance.add(swing['price']);
      } else {
        support.add(swing['price']);
      }
    }

    // Remove duplicates within 0.2% range
    final cleanSupport = _cleanLevels(support);
    final cleanResistance = _cleanLevels(resistance);

    final result = {
      'support': cleanSupport,
      'resistance': cleanResistance,
    };

    // Cache the result
    _cache.set('key_levels', result, candlesHash);
    return result;
  }

  static List<double> _cleanLevels(List<double> levels) {
    if (levels.isEmpty) return [];

    try {
      // Remove invalid values
      final validLevels = levels.where((l) => l > 0 && l.isFinite).toList();
      if (validLevels.isEmpty) return [];

      validLevels.sort();
      final cleaned = <double>[validLevels.first];

      for (int i = 1; i < validLevels.length; i++) {
        final last = cleaned.last;
        final diff = (validLevels[i] - last).abs() / last;

        // More than 0.2% difference
        if (diff > 0.002) {
          cleaned.add(validLevels[i]);
        }
      }

      // Limit to most relevant levels (top 10)
      if (cleaned.length > 10) {
        return cleaned.sublist(0, 10);
      }

      return cleaned;
    } catch (e) {
      return [];
    }
  }

  static SmartSignal _noTradeSignal(String reason) {
    return SmartSignal(
      type: SignalType.NO_TRADE,
      entry: 0,
      stopLoss: 0,
      takeProfit: 0,
      confidence: 0,
      riskReward: 0,
      reason: reason,
    );
  }

  // ==========================================================================
  // TECHNICAL INDICATORS
  // ==========================================================================

  static double _calculateATR(
      List<Candle> candles, int period, int candlesHash) {
    // Check cache
    final cacheKey = 'atr_$period';
    final cached = _cache.get<double>(cacheKey, candlesHash);
    if (cached != null) return cached;

    if (candles.length < period + 1) return 0.0;

    final trList = <double>[];

    // Optimized loop - only calculate for needed range
    final startIdx = max(1, candles.length - period - 50);
    for (int i = startIdx; i < candles.length; i++) {
      final curr = candles[i];
      final prev = candles[i - 1];

      final tr = max(
        curr.high - curr.low,
        max(
          (curr.high - prev.close).abs(),
          (curr.low - prev.close).abs(),
        ),
      );

      trList.add(tr);
    }

    // Simple moving average of TR
    final recent = trList.sublist(max(0, trList.length - period));
    if (recent.isEmpty) return 0.0;

    final atr = recent.reduce((a, b) => a + b) / recent.length;

    // Cache the result
    _cache.set(cacheKey, atr, candlesHash);
    return atr;
  }

  static double _calculateEMA(
      List<Candle> candles, int period, int candlesHash) {
    // Check cache
    final cacheKey = 'ema_$period';
    final cached = _cache.get<double>(cacheKey, candlesHash);
    if (cached != null) return cached;

    if (candles.length < period) {
      return candles.isNotEmpty ? candles.last.close : 0.0;
    }

    final multiplier = 2.0 / (period + 1);
    double ema = candles[candles.length - period].close;

    for (int i = candles.length - period + 1; i < candles.length; i++) {
      ema = (candles[i].close - ema) * multiplier + ema;
    }

    // Cache the result
    _cache.set(cacheKey, ema, candlesHash);
    return ema;
  }
}
