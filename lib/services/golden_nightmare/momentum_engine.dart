// 🔥 MOMENTUM ENGINE - Layer 5
// Detects: MACD inflections, RSI divergence, Hidden divergence, Momentum exhaustion

import 'dart:math';
import '../../models/candle.dart';

class MomentumEngine {
  /// Analyze momentum state (enhanced)
  static MomentumState analyze({
    required List<Candle> candles,
    required double rsi,
    required double macd,
    required double macdSignal,
    required double currentPrice,
  }) {
    // Calculate historical RSI values for better divergence detection
    final rsiHistory = _calculateRSIHistory(candles);

    // 1. MACD inflection points
    final macdInflection = _detectMACDInflection(candles, macd, macdSignal);

    // 2. Enhanced RSI divergence (using historical RSI)
    final rsiDivergence =
        _detectEnhancedRSIDivergence(candles, rsi, rsiHistory, currentPrice);

    // 3. Enhanced hidden divergence
    final hiddenDivergence =
        _detectEnhancedHiddenDivergence(candles, rsi, rsiHistory, currentPrice);

    // 4. Enhanced momentum exhaustion (with candle patterns)
    final exhaustion = _detectEnhancedExhaustion(candles, rsi, macd);

    // 5. Candle momentum
    final candleMomentum = _analyzeCandleMomentum(candles);

    // 6. Volume divergence (NEW)
    final volumeDivergence = _detectVolumeDivergence(candles);

    // 7. Overall momentum direction
    final direction = _calculateMomentumDirection(
      macdInflection,
      rsiDivergence,
      hiddenDivergence,
      exhaustion,
      candleMomentum,
      volumeDivergence,
    );

    // 8. Agreement check
    final agreement = _checkAgreement(direction, macd, rsi);

    return MomentumState(
      direction: direction,
      macdInflection: macdInflection,
      rsiDivergence: rsiDivergence,
      hiddenDivergence: hiddenDivergence,
      exhaustion: exhaustion,
      candleMomentum: candleMomentum,
      agreement: agreement,
      strength: _calculateMomentumStrength(
        macdInflection,
        rsiDivergence,
        hiddenDivergence,
        agreement,
        volumeDivergence,
      ),
    );
  }

  /// Calculate historical RSI values
  static List<double> _calculateRSIHistory(List<Candle> candles) {
    if (candles.length < 15) return [];

    final rsiValues = <double>[];
    final closes = candles.map((c) => c.close).toList();
    final period = 14;

    // Calculate RSI for each candle
    for (int i = period; i < min(closes.length, 50); i++) {
      double avgGain = 0;
      double avgLoss = 0;

      // Calculate average gain/loss
      for (int j = 1; j <= period; j++) {
        final change = closes[i - period + j] - closes[i - period + j - 1];
        if (change > 0) {
          avgGain += change;
        } else {
          avgLoss += change.abs();
        }
      }

      avgGain /= period;
      avgLoss /= period;

      if (avgLoss == 0) {
        rsiValues.add(100);
      } else {
        final rs = avgGain / avgLoss;
        rsiValues.add(100 - (100 / (1 + rs)));
      }
    }

    return rsiValues.reversed.toList(); // Most recent first
  }

  /// Detect MACD inflection points
  static String _detectMACDInflection(
    List<Candle> candles,
    double macd,
    double macdSignal,
  ) {
    final histogram = macd - macdSignal;

    // Calculate MACD trend from recent candles
    if (candles.length < 5) return 'NEUTRAL';

    // Check if MACD crossed signal line recently
    if (macd > macdSignal && histogram > 0) {
      if (histogram.abs() < 0.5) return 'EARLY_BULLISH'; // Just crossed
      return 'BULLISH';
    }

    if (macd < macdSignal && histogram < 0) {
      if (histogram.abs() < 0.5) return 'EARLY_BEARISH'; // Just crossed
      return 'BEARISH';
    }

    return 'NEUTRAL';
  }

  /// Enhanced RSI divergence detection using historical RSI
  static String _detectEnhancedRSIDivergence(
    List<Candle> candles,
    double rsi,
    List<double> rsiHistory,
    double currentPrice,
  ) {
    if (candles.length < 20 || rsiHistory.length < 10) {
      return _detectRSIDivergence(candles, rsi, currentPrice); // Fallback
    }

    final recent = candles.take(20).toList();

    // Find price pivots and corresponding RSI values
    final priceHighs = <_PricePivot>[];
    final priceLows = <_PricePivot>[];

    for (int i = 2; i < min(recent.length - 2, rsiHistory.length - 2); i++) {
      bool isHigh = true;
      bool isLow = true;

      for (int j = i - 2; j <= i + 2; j++) {
        if (j != i && j < recent.length) {
          if (recent[j].high >= recent[i].high) isHigh = false;
          if (recent[j].low <= recent[i].low) isLow = false;
        }
      }

      if (isHigh && i < rsiHistory.length) {
        priceHighs.add(_PricePivot(
            price: recent[i].high, rsiValue: rsiHistory[i], index: i));
      }
      if (isLow && i < rsiHistory.length) {
        priceLows.add(_PricePivot(
            price: recent[i].low, rsiValue: rsiHistory[i], index: i));
      }
    }

    // Bearish divergence: price higher high + RSI lower high
    if (priceHighs.length >= 2) {
      final last = priceHighs.first;
      final prev = priceHighs[1];

      if (last.price > prev.price && last.rsiValue < prev.rsiValue) {
        return 'BEARISH_DIVERGENCE';
      }
    }

    // Bullish divergence: price lower low + RSI higher low
    if (priceLows.length >= 2) {
      final last = priceLows.first;
      final prev = priceLows[1];

      if (last.price < prev.price && last.rsiValue > prev.rsiValue) {
        return 'BULLISH_DIVERGENCE';
      }
    }

    return 'NONE';
  }

  /// Detect RSI divergence (legacy - fallback)
  static String _detectRSIDivergence(
    List<Candle> candles,
    double rsi,
    double currentPrice,
  ) {
    if (candles.length < 20) return 'NONE';

    final recent = candles.take(20).toList();

    // Find recent highs/lows
    final priceHighs = <double>[];
    final priceLows = <double>[];

    for (int i = 2; i < recent.length - 2; i++) {
      bool isHigh = true;
      bool isLow = true;

      for (int j = i - 2; j <= i + 2; j++) {
        if (j != i) {
          if (recent[j].high >= recent[i].high) isHigh = false;
          if (recent[j].low <= recent[i].low) isLow = false;
        }
      }

      if (isHigh) priceHighs.add(recent[i].high);
      if (isLow) priceLows.add(recent[i].low);
    }

    // Bearish divergence: price makes higher high, RSI makes lower high
    if (priceHighs.length >= 2) {
      final lastHigh = priceHighs.first;
      final prevHigh = priceHighs[1];

      if (lastHigh > prevHigh && rsi < 60) {
        return 'BEARISH_DIVERGENCE'; // Price up, momentum down
      }
    }

    // Bullish divergence: price makes lower low, RSI makes higher low
    if (priceLows.length >= 2) {
      final lastLow = priceLows.first;
      final prevLow = priceLows[1];

      if (lastLow < prevLow && rsi > 40) {
        return 'BULLISH_DIVERGENCE'; // Price down, momentum up
      }
    }

    return 'NONE';
  }

  /// Enhanced hidden divergence detection
  static String _detectEnhancedHiddenDivergence(
    List<Candle> candles,
    double rsi,
    List<double> rsiHistory,
    double currentPrice,
  ) {
    if (candles.length < 20 || rsiHistory.length < 10) {
      return _detectHiddenDivergence(candles, rsi, currentPrice); // Fallback
    }

    final recent = candles.take(20).toList();

    // Hidden bullish: price higher low + RSI lower low (continuation)
    final lows = <_PricePivot>[];
    for (int i = 2; i < min(recent.length - 2, rsiHistory.length - 2); i++) {
      bool isLow = true;
      for (int j = i - 2; j <= i + 2; j++) {
        if (j != i && j < recent.length && recent[j].low <= recent[i].low) {
          isLow = false;
          break;
        }
      }
      if (isLow && i < rsiHistory.length) {
        lows.add(_PricePivot(
            price: recent[i].low, rsiValue: rsiHistory[i], index: i));
      }
    }

    if (lows.length >= 2) {
      final last = lows.first;
      final prev = lows[1];

      if (last.price > prev.price && last.rsiValue < prev.rsiValue) {
        return 'HIDDEN_BULLISH';
      }
    }

    // Hidden bearish: price lower high + RSI higher high (continuation)
    final highs = <_PricePivot>[];
    for (int i = 2; i < min(recent.length - 2, rsiHistory.length - 2); i++) {
      bool isHigh = true;
      for (int j = i - 2; j <= i + 2; j++) {
        if (j != i && j < recent.length && recent[j].high >= recent[i].high) {
          isHigh = false;
          break;
        }
      }
      if (isHigh && i < rsiHistory.length) {
        highs.add(_PricePivot(
            price: recent[i].high, rsiValue: rsiHistory[i], index: i));
      }
    }

    if (highs.length >= 2) {
      final last = highs.first;
      final prev = highs[1];

      if (last.price < prev.price && last.rsiValue > prev.rsiValue) {
        return 'HIDDEN_BEARISH';
      }
    }

    return 'NONE';
  }

  /// Detect hidden divergence (legacy - fallback)
  static String _detectHiddenDivergence(
    List<Candle> candles,
    double rsi,
    double currentPrice,
  ) {
    if (candles.length < 20) return 'NONE';

    final recent = candles.take(20).toList();

    // Hidden bullish divergence: price makes higher low, RSI makes lower low
    // (bullish trend continuation)
    final lows = <double>[];
    for (int i = 2; i < recent.length - 2; i++) {
      bool isLow = true;
      for (int j = i - 2; j <= i + 2; j++) {
        if (j != i && recent[j].low <= recent[i].low) {
          isLow = false;
          break;
        }
      }
      if (isLow) lows.add(recent[i].low);
    }

    if (lows.length >= 2) {
      final lastLow = lows.first;
      final prevLow = lows[1];

      if (lastLow > prevLow && rsi < 50) {
        return 'HIDDEN_BULLISH';
      }
    }

    // Hidden bearish divergence: price makes lower high, RSI makes higher high
    // (bearish trend continuation)
    final highs = <double>[];
    for (int i = 2; i < recent.length - 2; i++) {
      bool isHigh = true;
      for (int j = i - 2; j <= i + 2; j++) {
        if (j != i && recent[j].high >= recent[i].high) {
          isHigh = false;
          break;
        }
      }
      if (isHigh) highs.add(recent[i].high);
    }

    if (highs.length >= 2) {
      final lastHigh = highs.first;
      final prevHigh = highs[1];

      if (lastHigh < prevHigh && rsi > 50) {
        return 'HIDDEN_BEARISH';
      }
    }

    return 'NONE';
  }

  /// Enhanced exhaustion detection with candle patterns
  static bool _detectEnhancedExhaustion(
    List<Candle> candles,
    double rsi,
    double macd,
  ) {
    if (candles.length < 10) return false;

    final recent = candles.take(10).toList();

    // 1. Extreme RSI
    bool extremeRSI = rsi > 80 || rsi < 20;

    // 2. Slowing candle size
    final avgSize1 =
        recent.take(3).map((c) => c.high - c.low).reduce((a, b) => a + b) / 3;
    final avgSize2 = recent
            .skip(3)
            .take(3)
            .map((c) => c.high - c.low)
            .reduce((a, b) => a + b) /
        3;
    bool slowingSize = avgSize1 < avgSize2 * 0.7;

    // 3. Decreasing volume
    final avgVol1 =
        recent.take(3).map((c) => c.volume).reduce((a, b) => a + b) / 3;
    final avgVol2 =
        recent.skip(3).take(3).map((c) => c.volume).reduce((a, b) => a + b) / 3;
    bool decreasingVol = avgVol1 < avgVol2 * 0.8;

    // 4. Exhaustion candle patterns (NEW)
    final lastCandle = recent.first;
    final prevCandle = recent.length > 1 ? recent[1] : lastCandle;

    bool hasExhaustionPattern = false;

    // Doji: very small body (< 10% of range)
    final body = (lastCandle.close - lastCandle.open).abs();
    final range = lastCandle.high - lastCandle.low;
    if (range > 0 && body < range * 0.1) {
      hasExhaustionPattern = true;
    }

    // Hammer/Shooting star with large wick
    final upperWick = lastCandle.high - max(lastCandle.open, lastCandle.close);
    final lowerWick = min(lastCandle.open, lastCandle.close) - lastCandle.low;
    if (upperWick > body * 2.5 || lowerWick > body * 2.5) {
      hasExhaustionPattern = true;
    }

    // Engulfing reversal pattern
    if (recent.length > 1) {
      final prevBody = (prevCandle.close - prevCandle.open).abs();
      if (body > prevBody * 1.5 &&
          ((lastCandle.close > lastCandle.open &&
                  prevCandle.close < prevCandle.open) ||
              (lastCandle.close < lastCandle.open &&
                  prevCandle.close > prevCandle.open))) {
        hasExhaustionPattern = true;
      }
    }

    // Count signals
    int signals = 0;
    if (extremeRSI) signals++;
    if (slowingSize) signals++;
    if (decreasingVol) signals++;
    if (hasExhaustionPattern) signals++;

    // Exhaustion if 2+ signals present
    return signals >= 2;
  }

  /// Analyze candle momentum (compression/expansion)
  static String _analyzeCandleMomentum(List<Candle> candles) {
    if (candles.length < 20) return 'NEUTRAL';

    final recent10 = candles.take(10).toList();
    final prev10 = candles.skip(10).take(10).toList();

    final avgRange1 =
        recent10.map((c) => c.high - c.low).reduce((a, b) => a + b) / 10;
    final avgRange2 =
        prev10.map((c) => c.high - c.low).reduce((a, b) => a + b) / 10;

    // Compression: recent ranges < previous ranges
    if (avgRange1 < avgRange2 * 0.7) return 'COMPRESSION';

    // Expansion: recent ranges > previous ranges
    if (avgRange1 > avgRange2 * 1.3) return 'EXPANSION';

    return 'NORMAL';
  }

  /// Detect volume divergence (NEW)
  static String _detectVolumeDivergence(List<Candle> candles) {
    if (candles.length < 20) return 'NONE';

    final recent = candles.take(20).toList();

    // Find price and volume pivots
    final priceHighs = <double>[];
    final volHighs = <double>[];

    for (int i = 2; i < recent.length - 2; i++) {
      bool isHigh = true;
      for (int j = i - 2; j <= i + 2; j++) {
        if (j != i && recent[j].high >= recent[i].high) {
          isHigh = false;
          break;
        }
      }
      if (isHigh) {
        priceHighs.add(recent[i].high);
        volHighs.add(recent[i].volume);
      }
    }

    // Bearish volume divergence: higher price, lower volume
    if (priceHighs.length >= 2 && volHighs.length >= 2) {
      if (priceHighs.first > priceHighs[1] &&
          volHighs.first < volHighs[1] * 0.7) {
        return 'BEARISH_VOLUME_DIV';
      }
    }

    return 'NONE';
  }

  /// Calculate momentum direction (enhanced)
  static String _calculateMomentumDirection(
    String macdInflection,
    String rsiDivergence,
    String hiddenDivergence,
    bool exhaustion,
    String candleMomentum,
    String volumeDivergence,
  ) {
    int bullishScore = 0;
    int bearishScore = 0;

    // MACD
    if (macdInflection == 'BULLISH' || macdInflection == 'EARLY_BULLISH') {
      bullishScore += 3;
    } else if (macdInflection == 'BEARISH' ||
        macdInflection == 'EARLY_BEARISH') {
      bearishScore += 3;
    }

    // RSI Divergence
    if (rsiDivergence == 'BULLISH_DIVERGENCE') bullishScore += 2;
    if (rsiDivergence == 'BEARISH_DIVERGENCE') bearishScore += 2;

    // Hidden Divergence (trend continuation)
    if (hiddenDivergence == 'HIDDEN_BULLISH') bullishScore += 2;
    if (hiddenDivergence == 'HIDDEN_BEARISH') bearishScore += 2;

    // Exhaustion (reversal signal)
    if (exhaustion) {
      // If already bullish momentum, exhaustion = bearish reversal
      if (bullishScore > bearishScore)
        bearishScore += 2;
      else if (bearishScore > bullishScore) bullishScore += 2;
    }

    // Candle momentum
    if (candleMomentum == 'EXPANSION') {
      if (bullishScore > bearishScore) {
        bullishScore += 1;
      } else {
        bearishScore += 1;
      }
    }

    // Volume divergence (NEW)
    if (volumeDivergence == 'BEARISH_VOLUME_DIV') {
      bearishScore += 2;
    }

    // Decide
    if (bullishScore > bearishScore + 2) return 'BULLISH';
    if (bearishScore > bullishScore + 2) return 'BEARISH';
    return 'NEUTRAL';
  }

  /// Check if momentum agrees with indicators
  static bool _checkAgreement(String direction, double macd, double rsi) {
    if (direction == 'NEUTRAL') return true; // Neutral always agrees

    if (direction == 'BULLISH') {
      // Bullish momentum should have: MACD > 0 or RSI > 50
      return macd > 0 || rsi > 50;
    }

    if (direction == 'BEARISH') {
      // Bearish momentum should have: MACD < 0 or RSI < 50
      return macd < 0 || rsi < 50;
    }

    return false;
  }

  /// Calculate momentum strength (0-100) - enhanced
  static int _calculateMomentumStrength(
    String macdInflection,
    String rsiDivergence,
    String hiddenDivergence,
    bool agreement,
    String volumeDivergence,
  ) {
    int strength = 50; // Base

    if (macdInflection == 'BULLISH' || macdInflection == 'BEARISH') {
      strength += 15;
    } else if (macdInflection == 'EARLY_BULLISH' ||
        macdInflection == 'EARLY_BEARISH') {
      strength += 10;
    }

    if (rsiDivergence != 'NONE') strength += 15;
    if (hiddenDivergence != 'NONE') strength += 10;
    if (agreement) strength += 10;
    if (volumeDivergence != 'NONE') strength += 5; // NEW

    return min(strength, 100);
  }
}

// Helper class for pivot tracking
class _PricePivot {
  final double price;
  final double rsiValue;
  final int index;

  _PricePivot({
    required this.price,
    required this.rsiValue,
    required this.index,
  });
}

// ============================================
// DATA MODELS
// ============================================

class MomentumState {
  final String direction; // BULLISH, BEARISH, NEUTRAL
  final String macdInflection;
  final String rsiDivergence;
  final String hiddenDivergence;
  final bool exhaustion;
  final String candleMomentum;
  final bool agreement; // Does momentum agree with direction?
  final int strength; // 0-100

  MomentumState({
    required this.direction,
    required this.macdInflection,
    required this.rsiDivergence,
    required this.hiddenDivergence,
    required this.exhaustion,
    required this.candleMomentum,
    required this.agreement,
    required this.strength,
  });
}
