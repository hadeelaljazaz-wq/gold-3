// 🔥 KABOUS ULTRA ENGINE - Professional Grade Trading System
// lib/services/kabous_ultra_engine.dart

import 'dart:math' show max, min, pow, sqrt;
import '../models/candle.dart';
import '../models/trade_decision.dart';
import 'central_bayesian_engine.dart';
import 'ml_decision_maker.dart';
import 'quantum_scalping/chaos_volatility_engine.dart';

// ============================================================================
// DATA MODELS
// ============================================================================

enum SignalType { buy, sell, noTrade }

enum MarketPhase { accumulation, markup, distribution, markdown, ranging }

class UltraSignal {
  final SignalType type;
  final double entry;
  final double stopLoss;
  final double takeProfit;
  final double confidence;
  final String reason;
  final MarketPhase phase;
  final double atr;

  UltraSignal({
    required this.type,
    required this.entry,
    required this.stopLoss,
    required this.takeProfit,
    required this.confidence,
    required this.reason,
    required this.phase,
    required this.atr,
  });
}

// ============================================================================
// KABOUS ULTRA ENGINE - THE LEGENDARY SYSTEM
// ============================================================================

class KabousUltraEngine {
  // 🎯 Main Signal Generation - The Brain
  static UltraSignal generateSignal({
    required List<Candle> candles,
    required String timeframe,
  }) {
    if (candles.length < 300) {
      return _noTrade('Insufficient data');
    }

    // 1. Calculate all indicators
    final indicators = _calculateAllIndicators(candles);

    // 2. Detect market phase (Wyckoff)
    final phase = _detectMarketPhase(candles, indicators);

    // 3. Multi-timeframe analysis
    final mtfScore = _multiTimeframeScore(candles);

    // 4. Smart Money Concepts
    final smcScore = _smartMoneyScore(candles, indicators);

    // 5. Volume analysis
    final volumeConfirmation = _analyzeVolume(candles);

    // 6. Market structure
    final structureQuality = _analyzeStructure(candles);

    // 7. Risk environment
    final riskScore = _assessRiskEnvironment(indicators);

    // 8. Final decision matrix
    return _makeTradingDecision(
      candles: candles,
      indicators: indicators,
      phase: phase,
      mtfScore: mtfScore,
      smcScore: smcScore,
      volumeConfirmation: volumeConfirmation,
      structureQuality: structureQuality,
      riskScore: riskScore,
    );
  }

  // ============================================================================
  // INDICATORS CALCULATION
  // ============================================================================

  static Map<String, dynamic> _calculateAllIndicators(List<Candle> candles) {
    return {
      'ema20': _calculateEMA(candles, 20),
      'ema50': _calculateEMA(candles, 50),
      'ema100': _calculateEMA(candles, 100),
      'ema200': _calculateEMA(candles, 200),
      'atr': _calculateATR(candles, 14),
      'rsi': _calculateRSI(candles, 14),
      'adx': _calculateADX(candles, 14),
      'macd': _calculateMACD(candles),
      'bb': _calculateBollingerBands(candles, 20, 2.0),
      'stoch': _calculateStochastic(candles, 14, 3, 3),
      'vwap': _calculateVWAP(candles),
    };
  }

  static double _calculateEMA(List<Candle> candles, int period) {
    if (candles.length < period) return candles.last.close;

    final multiplier = 2.0 / (period + 1);
    double ema = candles[candles.length - period].close;

    for (int i = candles.length - period + 1; i < candles.length; i++) {
      ema = (candles[i].close - ema) * multiplier + ema;
    }

    return ema;
  }

  static double _calculateATR(List<Candle> candles, int period) {
    if (candles.length < period + 1) return 0.0;

    double atr = 0.0;
    for (int i = candles.length - period; i < candles.length; i++) {
      final tr = max(
        candles[i].high - candles[i].low,
        max(
          (candles[i].high - candles[i - 1].close).abs(),
          (candles[i].low - candles[i - 1].close).abs(),
        ),
      );
      atr += tr;
    }

    return atr / period;
  }

  static double _calculateRSI(List<Candle> candles, int period) {
    if (candles.length < period + 1) return 50.0;

    double gains = 0.0;
    double losses = 0.0;

    for (int i = candles.length - period; i < candles.length; i++) {
      final change = candles[i].close - candles[i - 1].close;
      if (change > 0) {
        gains += change;
      } else {
        losses += change.abs();
      }
    }

    if (losses == 0) return 100.0;

    final rs = (gains / period) / (losses / period);
    return 100 - (100 / (1 + rs));
  }

  static Map<String, double> _calculateADX(List<Candle> candles, int period) {
    if (candles.length < period + 1) {
      return {'adx': 20.0, 'plusDI': 0.0, 'minusDI': 0.0};
    }

    double plusDM = 0.0, minusDM = 0.0, tr = 0.0;

    for (int i = candles.length - period; i < candles.length; i++) {
      final highDiff = candles[i].high - candles[i - 1].high;
      final lowDiff = candles[i - 1].low - candles[i].low;

      plusDM += (highDiff > lowDiff && highDiff > 0) ? highDiff : 0;
      minusDM += (lowDiff > highDiff && lowDiff > 0) ? lowDiff : 0;

      tr += max(
        candles[i].high - candles[i].low,
        max(
          (candles[i].high - candles[i - 1].close).abs(),
          (candles[i].low - candles[i - 1].close).abs(),
        ),
      );
    }

    final plusDI = (plusDM / tr) * 100;
    final minusDI = (minusDM / tr) * 100;
    final dx = (plusDI - minusDI).abs() / (plusDI + minusDI) * 100;

    return {'adx': dx, 'plusDI': plusDI, 'minusDI': minusDI};
  }

  static Map<String, double> _calculateMACD(List<Candle> candles) {
    final ema12 = _calculateEMA(candles, 12);
    final ema26 = _calculateEMA(candles, 26);
    final macdLine = ema12 - ema26;

    // Simple signal line (would need proper EMA of MACD)
    final signal = macdLine * 0.9;
    final histogram = macdLine - signal;

    return {
      'macd': macdLine,
      'signal': signal,
      'histogram': histogram,
    };
  }

  static Map<String, double> _calculateBollingerBands(
    List<Candle> candles,
    int period,
    double stdDev,
  ) {
    if (candles.length < period) {
      final close = candles.last.close;
      return {'upper': close, 'middle': close, 'lower': close};
    }

    double sum = 0.0;
    for (int i = candles.length - period; i < candles.length; i++) {
      sum += candles[i].close;
    }
    final sma = sum / period;

    double variance = 0.0;
    for (int i = candles.length - period; i < candles.length; i++) {
      variance += pow(candles[i].close - sma, 2);
    }
    final std = sqrt(variance / period);

    return {
      'upper': sma + (stdDev * std),
      'middle': sma,
      'lower': sma - (stdDev * std),
    };
  }

  static Map<String, double> _calculateStochastic(
    List<Candle> candles,
    int kPeriod,
    int kSmooth,
    int dPeriod,
  ) {
    if (candles.length < kPeriod) return {'k': 50.0, 'd': 50.0};

    final recent = candles.sublist(candles.length - kPeriod);
    final highs = recent.map((c) => c.high).toList();
    final lows = recent.map((c) => c.low).toList();

    if (highs.isEmpty || lows.isEmpty) return {'k': 50.0, 'd': 50.0};

    final high = highs.reduce(max);
    final low = lows.reduce(min);
    final close = candles.last.close;

    if (high == low) return {'k': 50.0, 'd': 50.0};

    final k = ((close - low) / (high - low)) * 100;
    final d = k; // Simplified

    return {'k': k, 'd': d};
  }

  static double _calculateVWAP(List<Candle> candles) {
    if (candles.isEmpty) return 0.0;

    double cumVolPrice = 0.0;
    double cumVol = 0.0;

    final recent =
        candles.length > 96 ? candles.sublist(candles.length - 96) : candles;

    for (final candle in recent) {
      final typical = (candle.high + candle.low + candle.close) / 3;
      cumVolPrice += typical * candle.volume;
      cumVol += candle.volume;
    }

    return cumVol > 0 ? cumVolPrice / cumVol : candles.last.close;
  }

  // ============================================================================
  // MARKET PHASE DETECTION (Wyckoff)
  // ============================================================================

  static MarketPhase _detectMarketPhase(
    List<Candle> candles,
    Map<String, dynamic> indicators,
  ) {
    final ema20 = indicators['ema20'] as double;
    final ema50 = indicators['ema50'] as double;
    final ema200 = indicators['ema200'] as double;
    final adx = indicators['adx']['adx'] as double;
    final price = candles.last.close;

    // Volume trend
    final recentVolumes =
        candles.sublist(candles.length - 20).map((c) => c.volume).toList();
    final olderVolumes = candles
        .sublist(candles.length - 40, candles.length - 20)
        .map((c) => c.volume)
        .toList();

    if (recentVolumes.isEmpty || olderVolumes.isEmpty) {
      return MarketPhase.ranging;
    }

    final recentVol = recentVolumes.reduce((a, b) => a + b) / 20;
    final olderVol = olderVolumes.reduce((a, b) => a + b) / 20;
    final volumeIncreasing = recentVol > olderVol * 1.2;

    // Price position relative to EMAs
    final aboveAll = price > ema20 && price > ema50 && price > ema200;
    final belowAll = price < ema20 && price < ema50 && price < ema200;

    // Trend strength
    final strongTrend = adx > 25;
    final weakTrend = adx < 20;

    // Decision matrix
    if (weakTrend && !volumeIncreasing) {
      return MarketPhase.ranging;
    }

    if (aboveAll && strongTrend && volumeIncreasing) {
      return MarketPhase.markup; // Bullish trending
    }

    if (belowAll && strongTrend && volumeIncreasing) {
      return MarketPhase.markdown; // Bearish trending
    }

    if (aboveAll && !strongTrend) {
      return MarketPhase.distribution; // Potential top
    }

    if (belowAll && !strongTrend) {
      return MarketPhase.accumulation; // Potential bottom
    }

    return MarketPhase.ranging;
  }

  // ============================================================================
  // MULTI-TIMEFRAME ANALYSIS
  // ============================================================================

  static double _multiTimeframeScore(List<Candle> candles) {
    double score = 0.0;

    // M15 trend (last 96 candles = 24 hours)
    if (candles.length >= 96) {
      final m15Trend = _calculateTrendScore(
        candles.sublist(candles.length - 96),
      );
      score += m15Trend * 0.2;
    }

    // H1 trend (last 24 candles)
    if (candles.length >= 24) {
      final h1Trend = _calculateTrendScore(
        candles.sublist(candles.length - 24),
      );
      score += h1Trend * 0.3;
    }

    // H4 trend (last 6 candles)
    if (candles.length >= 6) {
      final h4Trend = _calculateTrendScore(
        candles.sublist(candles.length - 6),
      );
      score += h4Trend * 0.5;
    }

    return score; // -1 to +1
  }

  static double _calculateTrendScore(List<Candle> candles) {
    if (candles.length < 2) return 0.0;

    final start = candles.first.close;
    final end = candles.last.close;
    final change = (end - start) / start;

    return change.clamp(-1.0, 1.0) * 10; // Scale up
  }

  // ============================================================================
  // SMART MONEY CONCEPTS
  // ============================================================================

  static double _smartMoneyScore(
    List<Candle> candles,
    Map<String, dynamic> indicators,
  ) {
    double score = 0.0;

    // 1. Order Blocks
    final orderBlocks = _detectOrderBlocks(candles);
    score += orderBlocks * 25;

    // 2. Fair Value Gaps
    final fvgScore = _detectFairValueGaps(candles);
    score += fvgScore * 25;

    // 3. Liquidity Sweeps
    final liquidityScore = _detectLiquiditySweeps(candles);
    score += liquidityScore * 25;

    // 4. Market Structure Breaks
    final msbScore = _detectMarketStructureBreak(candles);
    score += msbScore * 25;

    return score; // 0 to 100
  }

  static double _detectOrderBlocks(List<Candle> candles) {
    if (candles.length < 10) return 0.0;

    final recent = candles.sublist(candles.length - 10);
    final currentPrice = candles.last.close;

    // Look for strong moves from a consolidation
    for (int i = 3; i < recent.length - 1; i++) {
      final prevRange = recent[i - 1].high - recent[i - 1].low;
      final currentRange = recent[i].high - recent[i].low;

      // Bullish Order Block
      if (currentRange > prevRange * 2 && recent[i].close > recent[i].open) {
        if (currentPrice > recent[i].low && currentPrice < recent[i].high) {
          return 1.0; // Near bullish OB
        }
      }

      // Bearish Order Block
      if (currentRange > prevRange * 2 && recent[i].close < recent[i].open) {
        if (currentPrice < recent[i].high && currentPrice > recent[i].low) {
          return -1.0; // Near bearish OB
        }
      }
    }

    return 0.0;
  }

  static double _detectFairValueGaps(List<Candle> candles) {
    if (candles.length < 5) return 0.0;

    final recent = candles.sublist(candles.length - 5);
    final currentPrice = candles.last.close;

    // Bullish FVG: Gap up
    if (recent[1].low > recent[0].high) {
      final gapBottom = recent[0].high;
      final gapTop = recent[1].low;

      if (currentPrice >= gapBottom && currentPrice <= gapTop) {
        return 1.0; // In bullish FVG
      }
    }

    // Bearish FVG: Gap down
    if (recent[1].high < recent[0].low) {
      final gapTop = recent[0].low;
      final gapBottom = recent[1].high;

      if (currentPrice <= gapTop && currentPrice >= gapBottom) {
        return -1.0; // In bearish FVG
      }
    }

    return 0.0;
  }

  static double _detectLiquiditySweeps(List<Candle> candles) {
    if (candles.length < 20) return 0.0;

    final recent = candles.sublist(candles.length - 20);
    final recentHighs = recent.map((c) => c.high).toList()..sort();
    final recentLows = recent.map((c) => c.low).toList()..sort();

    final currentHigh = candles.last.high;
    final currentLow = candles.last.low;

    // Swept highs (bearish)
    if (currentHigh > recentHighs[recentHighs.length - 2]) {
      return -0.5;
    }

    // Swept lows (bullish)
    if (currentLow < recentLows[1]) {
      return 0.5;
    }

    return 0.0;
  }

  static double _detectMarketStructureBreak(List<Candle> candles) {
    if (candles.length < 30) return 0.0;

    final swings = _findSwingPoints(candles.sublist(candles.length - 30));
    if (swings.length < 4) return 0.0;

    final highs = swings
        .where((s) => s['type'] == 'high')
        .map((s) => s['price'] as double)
        .toList();

    final lows = swings
        .where((s) => s['type'] == 'low')
        .map((s) => s['price'] as double)
        .toList();

    if (highs.isEmpty || lows.isEmpty) return 0.0;

    final lastHigh = highs.reduce(max);
    final lastLow = lows.reduce(min);

    final currentPrice = candles.last.close;

    // Bullish BOS
    if (currentPrice > lastHigh) return 1.0;

    // Bearish BOS
    if (currentPrice < lastLow) return -1.0;

    return 0.0;
  }

  static List<Map<String, dynamic>> _findSwingPoints(List<Candle> candles) {
    final swings = <Map<String, dynamic>>[];

    for (int i = 2; i < candles.length - 2; i++) {
      // Swing High
      if (candles[i].high > candles[i - 1].high &&
          candles[i].high > candles[i - 2].high &&
          candles[i].high > candles[i + 1].high &&
          candles[i].high > candles[i + 2].high) {
        swings.add({'type': 'high', 'price': candles[i].high, 'index': i});
      }

      // Swing Low
      if (candles[i].low < candles[i - 1].low &&
          candles[i].low < candles[i - 2].low &&
          candles[i].low < candles[i + 1].low &&
          candles[i].low < candles[i + 2].low) {
        swings.add({'type': 'low', 'price': candles[i].low, 'index': i});
      }
    }

    return swings;
  }

  // ============================================================================
  // VOLUME ANALYSIS
  // ============================================================================

  static double _analyzeVolume(List<Candle> candles) {
    if (candles.length < 50) return 0.5;

    final recent20 = candles.sublist(candles.length - 20);
    final older30 = candles.sublist(candles.length - 50, candles.length - 20);

    final recentVols = recent20.map((c) => c.volume).toList();
    final olderVols = older30.map((c) => c.volume).toList();

    if (recentVols.isEmpty || olderVols.isEmpty) return 0.5;

    final avgRecent = recentVols.reduce((a, b) => a + b) / 20;
    final avgOlder = olderVols.reduce((a, b) => a + b) / 30;

    final currentVolume = candles.last.volume;

    double score = 0.5;

    // High volume confirmation
    if (currentVolume > avgRecent * 1.5) score += 0.3;

    // Increasing volume trend
    if (avgRecent > avgOlder * 1.2) score += 0.2;

    return score.clamp(0.0, 1.0);
  }

  // ============================================================================
  // STRUCTURE ANALYSIS
  // ============================================================================

  static double _analyzeStructure(List<Candle> candles) {
    if (candles.length < 50) return 0.5;

    final swings = _findSwingPoints(candles.sublist(candles.length - 50));

    if (swings.length < 4) return 0.3; // Poor structure

    final highs = swings.where((s) => s['type'] == 'high').toList();
    final lows = swings.where((s) => s['type'] == 'low').toList();

    if (highs.length < 2 || lows.length < 2) return 0.4;

    // Check for HH/HL (bullish) or LH/LL (bearish)
    final lastTwoHighs = highs.sublist(highs.length - 2);
    final lastTwoLows = lows.sublist(lows.length - 2);

    final hh = lastTwoHighs[1]['price'] > lastTwoHighs[0]['price'];
    final hl = lastTwoLows[1]['price'] > lastTwoLows[0]['price'];

    final lh = lastTwoHighs[1]['price'] < lastTwoHighs[0]['price'];
    final ll = lastTwoLows[1]['price'] < lastTwoLows[0]['price'];

    if (hh && hl) return 0.9; // Strong bullish structure
    if (lh && ll) return 0.9; // Strong bearish structure

    return 0.6; // Mixed structure
  }

  // ============================================================================
  // RISK ENVIRONMENT ASSESSMENT
  // ============================================================================

  static double _assessRiskEnvironment(Map<String, dynamic> indicators) {
    double riskScore = 100.0;

    final adx = indicators['adx']['adx'] as double;
    final rsi = indicators['rsi'] as double;
    final bb = indicators['bb'] as Map<String, double>;

    // Extreme volatility = higher risk
    final bbWidth = bb['upper']! - bb['lower']!;
    final bbMid = bb['middle']!;
    final volatilityRatio = bbWidth / bbMid;

    if (volatilityRatio > 0.05) riskScore -= 20; // Very wide BB

    // Weak trend = higher risk
    if (adx < 20) riskScore -= 15;

    // Overbought/Oversold extremes
    if (rsi > 75 || rsi < 25) riskScore -= 15;

    // Choppy market
    if (adx < 15) riskScore -= 20;

    return riskScore.clamp(0.0, 100.0);
  }

  // ============================================================================
  // FINAL DECISION MATRIX
  // ============================================================================

  static UltraSignal _makeTradingDecision({
    required List<Candle> candles,
    required Map<String, dynamic> indicators,
    required MarketPhase phase,
    required double mtfScore,
    required double smcScore,
    required double volumeConfirmation,
    required double structureQuality,
    required double riskScore,
  }) {
    final price = candles.last.close;
    final ema20 = indicators['ema20'] as double;
    final ema50 = indicators['ema50'] as double;
    final rsi = indicators['rsi'] as double;
    final adx = indicators['adx']['adx'] as double;
    final macd = indicators['macd'] as Map<String, double>;

    // ✅ MASTER FILTERS - Must pass ALL

    // Filter 1: Risk Environment
    if (riskScore < 60) {
      return _noTrade(
          'High risk environment: ${riskScore.toStringAsFixed(0)}/100');
    }

    // Filter 2: Minimum Trend Strength
    if (adx < 18) {
      return _noTrade('Weak trend (ADX: ${adx.toStringAsFixed(1)})');
    }

    // Filter 3: Extreme RSI
    if (rsi > 80 || rsi < 20) {
      return _noTrade('Extreme RSI: ${rsi.toStringAsFixed(1)}');
    }

    // Filter 4: Market Phase
    if (phase == MarketPhase.ranging) {
      return _noTrade('Market ranging - no clear direction');
    }

    // Filter 5: Structure Quality
    if (structureQuality < 0.6) {
      return _noTrade('Poor market structure');
    }

    // ✅ SCORING SYSTEM
    double bullishScore = 0.0;
    double bearishScore = 0.0;

    // Multi-Timeframe (30 points)
    if (mtfScore > 0.5) bullishScore += mtfScore * 30;
    if (mtfScore < -0.5) bearishScore += mtfScore.abs() * 30;

    // Smart Money (30 points)
    if (smcScore > 60) bullishScore += (smcScore / 100) * 30;
    if (smcScore < 40) bearishScore += ((100 - smcScore) / 100) * 30;

    // EMA Alignment (20 points)
    if (price > ema20 && ema20 > ema50) bullishScore += 20;
    if (price < ema20 && ema20 < ema50) bearishScore += 20;

    // MACD (10 points)
    if (macd['histogram']! > 0) bullishScore += 10;
    if (macd['histogram']! < 0) bearishScore += 10;

    // Volume (10 points)
    if (volumeConfirmation > 0.7) {
      if (bullishScore > bearishScore) {
        bullishScore += 10;
      } else {
        bearishScore += 10;
      }
    }

    // ✅ DECISION
    const minScore = 65.0;
    final confidence = max(bullishScore, bearishScore);

    if (bullishScore >= minScore && bullishScore > bearishScore) {
      return _createBuySignal(
        candles: candles,
        indicators: indicators,
        confidence: confidence,
        phase: phase,
      );
    }

    if (bearishScore >= minScore && bearishScore > bullishScore) {
      return _createSellSignal(
        candles: candles,
        indicators: indicators,
        confidence: confidence,
        phase: phase,
      );
    }

    return _noTrade(
      'Insufficient score - Bull: ${bullishScore.toStringAsFixed(0)}, '
      'Bear: ${bearishScore.toStringAsFixed(0)} (need ${minScore.toStringAsFixed(0)}+)',
    );
  }

  // ============================================================================
  // SIGNAL CREATION
  // ============================================================================

  static UltraSignal _createBuySignal({
    required List<Candle> candles,
    required Map<String, dynamic> indicators,
    required double confidence,
    required MarketPhase phase,
  }) {
    final price = candles.last.close;
    final atr = indicators['atr'] as double;

    // Find recent support
    final swings = _findSwingPoints(candles.sublist(candles.length - 50));
    final lows = swings
        .where((s) => s['type'] == 'low')
        .map((s) => s['price'] as double)
        .toList();

    lows.sort();
    final nearestSupport = lows.lastWhere(
      (low) => low < price,
      orElse: () => price - (atr * 2.5),
    );

    // Stop Loss: Below support or structure
    final stopLoss = max(
      nearestSupport - (atr * 0.5),
      price - (atr * 2.5),
    );

    // Dynamic R:R based on phase
    double rrRatio;
    if (phase == MarketPhase.markup) {
      rrRatio = 3.5;
    } else if (phase == MarketPhase.accumulation) {
      rrRatio = 3.0;
    } else {
      rrRatio = 2.5;
    }

    final takeProfit = price + ((price - stopLoss) * rrRatio);

    return UltraSignal(
      type: SignalType.buy,
      entry: price,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
      confidence: confidence,
      reason:
          'BUY: Phase=${phase.name}, Confidence=${confidence.toStringAsFixed(0)}/100',
      phase: phase,
      atr: atr,
    );
  }

  static UltraSignal _createSellSignal({
    required List<Candle> candles,
    required Map<String, dynamic> indicators,
    required double confidence,
    required MarketPhase phase,
  }) {
    final price = candles.last.close;
    final atr = indicators['atr'] as double;

    // Find recent resistance
    final swings = _findSwingPoints(candles.sublist(candles.length - 50));
    final highs = swings
        .where((s) => s['type'] == 'high')
        .map((s) => s['price'] as double)
        .toList();

    highs.sort();
    final nearestResistance = highs.firstWhere(
      (high) => high > price,
      orElse: () => price + (atr * 2.5),
    );

    // Stop Loss: Above resistance
    final stopLoss = min(
      nearestResistance + (atr * 0.5),
      price + (atr * 2.5),
    );

    // Dynamic R:R
    double rrRatio;
    if (phase == MarketPhase.markdown) {
      rrRatio = 3.5;
    } else if (phase == MarketPhase.distribution) {
      rrRatio = 3.0;
    } else {
      rrRatio = 2.5;
    }

    final takeProfit = price - ((stopLoss - price) * rrRatio);

    return UltraSignal(
      type: SignalType.sell,
      entry: price,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
      confidence: confidence,
      reason:
          'SELL: Phase=${phase.name}, Confidence=${confidence.toStringAsFixed(0)}/100',
      phase: phase,
      atr: atr,
    );
  }

  static UltraSignal _noTrade(String reason) {
    return UltraSignal(
      type: SignalType.noTrade,
      entry: 0,
      stopLoss: 0,
      takeProfit: 0,
      confidence: 0,
      reason: reason,
      phase: MarketPhase.ranging,
      atr: 0,
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 🆕 ENHANCED ANALYSIS WITH INTEGRATED SYSTEMS
  // ══════════════════════════════════════════════════════════════════

  /// تحليل محسّن لـ KABOUS Ultra مع Bayesian + Chaos + ML
  static Map<String, dynamic> generateSignalEnhanced({
    required List<Candle> candles,
    required String timeframe,
    double accountBalance = 10000.0,
  }) {
    // الحصول على الإشارة الأصلية
    final originalSignal = generateSignal(
      candles: candles,
      timeframe: timeframe,
    );

    // إذا كانت NO_TRADE، نرجع النتيجة مباشرة
    if (originalSignal.type == SignalType.noTrade) {
      return {
        'original_signal': {
          'type': originalSignal.type.name,
          'reason': originalSignal.reason,
          'confidence': 0,
        },
        'action': TradeAction.abort.name,
        'action_icon': TradeAction.abort.icon,
        'action_description': TradeAction.abort.description,
        'position_size_percent': 0.0,
        'quality_score': 0.0,
      };
    }

    // Chaos Analysis
    ChaosAnalysis? chaosAnalysis;
    try {
      if (candles.length >= 100) {
        chaosAnalysis = ChaosVolatilityEngine.analyze(candles);
      }
    } catch (e) {
      // Use fallback
    }

    final chaosRiskLevel = chaosAnalysis?.riskLevel ?? 
        (originalSignal.atr / originalSignal.entry * 10).clamp(0.0, 1.0);

    // حساب العوامل
    const signalConfidence = 0.7; // Default confidence
    final volatility = (originalSignal.atr / originalSignal.entry * 100).clamp(0.0, 1.0);
    
    // Trend & Momentum من الشموع
    final trendStrength = _calculateTrendStrengthQuick(candles);
    final momentum = _calculateMomentumQuick(candles);
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
      timeframeAlignment: 0.75,
      structureQuality: 0.70,
      chaosRiskLevel: chaosRiskLevel,
      signalDirection: originalSignal.type == SignalType.buy ? 'BUY' : 'SELL',
    );

    // Decision Factors
    final factors = DecisionFactors(
      trendStrength: trendStrength,
      volatility: volatility,
      momentum: momentum,
      chaosLevel: chaosRiskLevel,
      signalStrength: signalConfidence,
      timeframeAlignment: 0.75,
      volumeProfile: volumeProfile,
      structureQuality: 0.70,
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
      signalDirection: originalSignal.type == SignalType.buy ? 'BUY' : 'SELL',
    );

    // Build enhanced result
    return {
      'original_signal': {
        'type': originalSignal.type.name,
        'entry': originalSignal.entry,
        'stop_loss': originalSignal.stopLoss,
        'take_profit': originalSignal.takeProfit,
        'confidence': originalSignal.confidence,
        'reason': originalSignal.reason,
        'phase': originalSignal.phase.name,
        'atr': originalSignal.atr,
      },
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

  // Helper methods
  static double _calculateTrendStrengthQuick(List<Candle> candles) {
    if (candles.length < 20) return 0.0;
    
    final recent = candles.sublist(candles.length - 20);
    final closes = recent.map((c) => c.close).toList();
    
    final firstPrice = closes.first;
    final lastPrice = closes.last;
    final change = (lastPrice - firstPrice) / firstPrice;
    
    return (change * 10).clamp(-1.0, 1.0);
  }

  static double _calculateMomentumQuick(List<Candle> candles) {
    if (candles.length < 10) return 0.0;
    
    final closes = candles.map((c) => c.close).toList();
    final roc = (closes.last - closes[closes.length - 10]) / closes[closes.length - 10];
    
    return (roc * 10).clamp(-1.0, 1.0);
  }

  static double _calculateVolumeProfileQuick(List<Candle> recentCandles) {
    if (recentCandles.isEmpty) return 0.5;

    final volumes = recentCandles.map((c) => c.volume).toList();
    final avgVolume = volumes.reduce((a, b) => a + b) / volumes.length;
    final currentVolume = volumes.last;

    return (currentVolume / avgVolume).clamp(0.0, 1.0);
  }
}
