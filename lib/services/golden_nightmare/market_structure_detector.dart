// 🔥 MARKET STRUCTURE DETECTOR
// Detects: BOS, CHOCH, Liquidity Sweeps, Stop Hunts, Trend Shifts

import 'dart:math';
import '../../models/candle.dart';

class MarketStructureDetector {
  /// Detect market structure from candles
  static MarketStructure analyze(List<Candle> candles) {
    if (candles.length < 50) {
      throw Exception('Need at least 50 candles for structure analysis');
    }

    // 1. Find swing highs/lows (fractal pivots)
    final pivots = _findSwingPivots(candles);

    // 2. Detect BOS (Break of Structure)
    final bos = _detectBOS(candles, pivots);

    // 3. Detect CHOCH (Change of Character)
    final choch = _detectCHOCH(candles, pivots);

    // 4. Detect liquidity sweeps
    final liquiditySweep = _detectLiquiditySweep(candles, pivots);

    // 5. Classify trend
    final trend = _classifyTrend(candles, pivots, bos, choch);

    // 6. Detect stop hunt
    final stopHunt = _detectStopHunt(candles);

    return MarketStructure(
      trend: trend,
      bos: bos,
      choch: choch,
      liquiditySweep: liquiditySweep,
      stopHunt: stopHunt,
      pivots: pivots,
      microTrend: _detectMicroTrend(candles.take(20).toList()),
    );
  }

  /// Find swing highs and lows (5-period fractals)
  static List<Pivot> _findSwingPivots(List<Candle> candles) {
    final pivots = <Pivot>[];
    final window = 5;

    for (int i = window; i < candles.length - window; i++) {
      final current = candles[i];

      // Check for swing high
      bool isHigh = true;
      for (int j = i - window; j <= i + window; j++) {
        if (j != i && candles[j].high >= current.high) {
          isHigh = false;
          break;
        }
      }

      if (isHigh) {
        pivots.add(Pivot(
          type: 'HIGH',
          price: current.high,
          index: i,
          time: current.time,
        ));
      }

      // Check for swing low
      bool isLow = true;
      for (int j = i - window; j <= i + window; j++) {
        if (j != i && candles[j].low <= current.low) {
          isLow = false;
          break;
        }
      }

      if (isLow) {
        pivots.add(Pivot(
          type: 'LOW',
          price: current.low,
          index: i,
          time: current.time,
        ));
      }
    }

    return pivots;
  }

  /// Detect Break of Structure (BOS)
  /// BOS = price breaks last swing high (uptrend) or low (downtrend)
  static BOSSignal? _detectBOS(List<Candle> candles, List<Pivot> pivots) {
    if (pivots.length < 4) return null;

    final recentPivots = pivots.reversed.take(10).toList();
    final lastCandle = candles.first;

    // Find last swing high and low
    final lastHigh = recentPivots.firstWhere(
      (p) => p.type == 'HIGH',
      orElse: () =>
          Pivot(type: 'HIGH', price: 0, index: 0, time: DateTime.now()),
    );

    final lastLow = recentPivots.firstWhere(
      (p) => p.type == 'LOW',
      orElse: () =>
          Pivot(type: 'LOW', price: 999999, index: 0, time: DateTime.now()),
    );

    // Bullish BOS: price breaks above last swing high
    if (lastCandle.close > lastHigh.price && lastHigh.price > 0) {
      return BOSSignal(
        type: 'BULLISH_BOS',
        price: lastHigh.price,
        broken: true,
        strength: _calculateBOSStrength(lastCandle.close, lastHigh.price),
      );
    }

    // Bearish BOS: price breaks below last swing low
    if (lastCandle.close < lastLow.price && lastLow.price < 999999) {
      return BOSSignal(
        type: 'BEARISH_BOS',
        price: lastLow.price,
        broken: true,
        strength: _calculateBOSStrength(lastLow.price, lastCandle.close),
      );
    }

    return null;
  }

  /// Calculate BOS strength (0-100)
  static int _calculateBOSStrength(double price1, double price2) {
    final diff = (price1 - price2).abs();
    final strength = min((diff / price1 * 1000).round(), 100);
    return max(strength, 50); // minimum 50
  }

  /// Detect Change of Character (CHOCH)
  /// CHOCH = trend reversal signal
  static CHOCHSignal? _detectCHOCH(List<Candle> candles, List<Pivot> pivots) {
    if (pivots.length < 6) return null;

    final recentPivots = pivots.reversed.take(6).toList();

    // Look for pattern: HH-HL-LL (uptrend to downtrend)
    // or LL-LH-HH (downtrend to uptrend)

    int higherHighs = 0;
    int lowerLows = 0;

    for (int i = 0; i < recentPivots.length - 1; i++) {
      if (recentPivots[i].type == 'HIGH') {
        if (i + 1 < recentPivots.length) {
          final nextHigh = recentPivots.skip(i + 1).firstWhere(
                (p) => p.type == 'HIGH',
                orElse: () => recentPivots[i],
              );
          if (recentPivots[i].price > nextHigh.price) higherHighs++;
        }
      }

      if (recentPivots[i].type == 'LOW') {
        if (i + 1 < recentPivots.length) {
          final nextLow = recentPivots.skip(i + 1).firstWhere(
                (p) => p.type == 'LOW',
                orElse: () => recentPivots[i],
              );
          if (recentPivots[i].price < nextLow.price) lowerLows++;
        }
      }
    }

    // CHOCH to bullish: was making LLs, now making HH
    if (lowerLows >= 2 && higherHighs >= 1) {
      return CHOCHSignal(
        type: 'BULLISH_CHOCH',
        confidence: 75,
      );
    }

    // CHOCH to bearish: was making HHs, now making LL
    if (higherHighs >= 2 && lowerLows >= 1) {
      return CHOCHSignal(
        type: 'BEARISH_CHOCH',
        confidence: 75,
      );
    }

    return null;
  }

  /// Detect liquidity sweep
  /// Liquidity sweep = wick beyond key level then rejection
  static LiquiditySweep? _detectLiquiditySweep(
    List<Candle> candles,
    List<Pivot> pivots,
  ) {
    if (candles.length < 10 || pivots.isEmpty) return null;

    final last5 = candles.take(5).toList();
    final lastCandle = last5.first;

    // Find nearest pivot
    final nearestHigh =
        pivots.where((p) => p.type == 'HIGH').fold<Pivot?>(null, (closest, p) {
      if (closest == null) return p;
      return (p.price - lastCandle.close).abs() <
              (closest.price - lastCandle.close).abs()
          ? p
          : closest;
    });

    final nearestLow =
        pivots.where((p) => p.type == 'LOW').fold<Pivot?>(null, (closest, p) {
      if (closest == null) return p;
      return (p.price - lastCandle.close).abs() <
              (closest.price - lastCandle.close).abs()
          ? p
          : closest;
    });

    // Check for sweep above high
    if (nearestHigh != null) {
      for (final candle in last5) {
        // Wick above key high + close below = sweep
        if (candle.high > nearestHigh.price &&
            candle.close < nearestHigh.price) {
          return LiquiditySweep(
            type: 'SWEEP_HIGH',
            level: nearestHigh.price,
            rejected: true,
          );
        }
      }
    }

    // Check for sweep below low
    if (nearestLow != null) {
      for (final candle in last5) {
        // Wick below key low + close above = sweep
        if (candle.low < nearestLow.price && candle.close > nearestLow.price) {
          return LiquiditySweep(
            type: 'SWEEP_LOW',
            level: nearestLow.price,
            rejected: true,
          );
        }
      }
    }

    return null;
  }

  /// Classify trend (5 levels)
  static String _classifyTrend(
    List<Candle> candles,
    List<Pivot> pivots,
    BOSSignal? bos,
    CHOCHSignal? choch,
  ) {
    final last50 = candles.take(50).toList();
    final firstPrice = last50.last.close;
    final lastPrice = last50.first.close;
    final change = ((lastPrice - firstPrice) / firstPrice * 100);

    // Factor in BOS and CHOCH
    int trendScore = 0;

    if (change > 0)
      trendScore += (change * 10).round();
    else
      trendScore -= (change.abs() * 10).round();

    if (bos?.type == 'BULLISH_BOS') trendScore += 30;
    if (bos?.type == 'BEARISH_BOS') trendScore -= 30;

    if (choch?.type == 'BULLISH_CHOCH') trendScore += 20;
    if (choch?.type == 'BEARISH_CHOCH') trendScore -= 20;

    // Classify
    if (trendScore > 50) return 'STRONG_UPTREND';
    if (trendScore > 20) return 'WEAK_UPTREND';
    if (trendScore < -50) return 'STRONG_DOWNTREND';
    if (trendScore < -20) return 'WEAK_DOWNTREND';
    return 'RANGE';
  }

  /// Detect stop hunt
  static bool _detectStopHunt(List<Candle> candles) {
    if (candles.length < 3) return false;

    final last3 = candles.take(3).toList();

    // Stop hunt = large wick + immediate reversal
    for (final candle in last3) {
      final body = (candle.close - candle.open).abs();
      final upperWick = candle.high - max(candle.open, candle.close);
      final lowerWick = min(candle.open, candle.close) - candle.low;

      // Upper wick > 3x body = possible stop hunt
      if (upperWick > body * 3 && candle.close < candle.open) return true;

      // Lower wick > 3x body = possible stop hunt
      if (lowerWick > body * 3 && candle.close > candle.open) return true;
    }

    return false;
  }

  /// Detect micro trend (last 20 candles)
  static String _detectMicroTrend(List<Candle> candles) {
    if (candles.length < 20) return 'NEUTRAL';

    final first = candles.last.close;
    final last = candles.first.close;
    final change = ((last - first) / first * 100);

    if (change > 0.3) return 'MICRO_BULLISH';
    if (change < -0.3) return 'MICRO_BEARISH';
    return 'NEUTRAL';
  }
}

// ============================================
// DATA MODELS
// ============================================

class Pivot {
  final String type; // 'HIGH' or 'LOW'
  final double price;
  final int index;
  final DateTime time;

  Pivot({
    required this.type,
    required this.price,
    required this.index,
    required this.time,
  });
}

class BOSSignal {
  final String type; // 'BULLISH_BOS' or 'BEARISH_BOS'
  final double price;
  final bool broken;
  final int strength; // 0-100

  BOSSignal({
    required this.type,
    required this.price,
    required this.broken,
    required this.strength,
  });
}

class CHOCHSignal {
  final String type; // 'BULLISH_CHOCH' or 'BEARISH_CHOCH'
  final int confidence; // 0-100

  CHOCHSignal({
    required this.type,
    required this.confidence,
  });
}

class LiquiditySweep {
  final String type; // 'SWEEP_HIGH' or 'SWEEP_LOW'
  final double level;
  final bool rejected;

  LiquiditySweep({
    required this.type,
    required this.level,
    required this.rejected,
  });
}

class MarketStructure {
  final String trend; // STRONG_UPTREND, WEAK_UPTREND, RANGE, etc.
  final BOSSignal? bos;
  final CHOCHSignal? choch;
  final LiquiditySweep? liquiditySweep;
  final bool stopHunt;
  final List<Pivot> pivots;
  final String microTrend;

  MarketStructure({
    required this.trend,
    this.bos,
    this.choch,
    this.liquiditySweep,
    required this.stopHunt,
    required this.pivots,
    required this.microTrend,
  });
}
