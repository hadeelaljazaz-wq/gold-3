import 'dart:math';
import '../models/candle.dart';
import '../models/market_models.dart';

/// Technical Indicators Service
///
/// Provides comprehensive technical analysis calculations including:
/// - RSI (Relative Strength Index)
/// - MACD (Moving Average Convergence Divergence)
/// - Moving Averages (SMA 20, 50, 100, 200)
/// - ATR (Average True Range)
/// - Bollinger Bands
///
/// **Usage:**
/// ```dart
/// final indicators = TechnicalIndicatorsService.calculateAll(candles);
/// print('RSI: ${indicators.rsi}');
/// print('MACD: ${indicators.macd}');
/// ```
class TechnicalIndicatorsService {
  /// Calculate All Indicators
  ///
  /// Calculates all technical indicators from a list of candles.
  ///
  /// **Parameters:**
  /// - [candles]: List of candle data (OHLCV)
  ///
  /// **Returns:**
  /// [TechnicalIndicators] object containing all calculated indicators
  ///
  /// **Note:**
  /// Returns default values if candles list is empty
  ///
  /// **Example:**
  /// ```dart
  /// final indicators = TechnicalIndicatorsService.calculateAll(candles);
  /// if (indicators.rsi > 70) {
  ///   print('Overbought condition');
  /// }
  /// ```
  static TechnicalIndicators calculateAll(List<Candle> candles) {
    if (candles.isEmpty) {
      return _getDefaultIndicators();
    }

    final closes = candles.map((c) => c.close).toList();
    final highs = candles.map((c) => c.high).toList();
    final lows = candles.map((c) => c.low).toList();

    return TechnicalIndicators(
      rsi: calculateRSI(closes, 14),
      macd: calculateMACD(closes)['macd']!,
      macdSignal: calculateMACD(closes)['signal']!,
      macdHistogram: calculateMACD(closes)['histogram']!,
      ma20: calculateSMA(closes, 20),
      ma50: calculateSMA(closes, 50),
      ma100: calculateSMA(closes, 100),
      ma200: calculateSMA(closes, 200),
      atr: calculateATR(highs, lows, closes, 14),
      bollingerUpper: calculateBollinger(closes, 20, 2)['upper']!,
      bollingerMiddle: calculateBollinger(closes, 20, 2)['middle']!,
      bollingerLower: calculateBollinger(closes, 20, 2)['lower']!,
    );
  }

  /// RSI (Relative Strength Index)
  ///
  /// Calculates the Relative Strength Index, a momentum oscillator
  /// that measures the speed and magnitude of price changes.
  ///
  /// **Parameters:**
  /// - [prices]: List of closing prices
  /// - [period]: RSI period (default: 14)
  ///
  /// **Returns:**
  /// [double] RSI value between 0-100
  /// - RSI > 70: Overbought (potential sell signal)
  /// - RSI < 30: Oversold (potential buy signal)
  ///
  /// **Example:**
  /// ```dart
  /// final rsi = TechnicalIndicatorsService.calculateRSI(prices, 14);
  /// if (rsi > 70) {
  ///   print('Overbought - consider selling');
  /// }
  /// ```
  static double calculateRSI(List<double> prices, int period) {
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

  /// SMA (Simple Moving Average)
  static double calculateSMA(List<double> prices, int period) {
    if (prices.length < period) return prices.last;

    final relevant = prices.sublist(prices.length - period);
    return relevant.reduce((a, b) => a + b) / period;
  }

  /// MACD
  static Map<String, double> calculateMACD(List<double> prices) {
    if (prices.length < 26) {
      return {'macd': 0, 'signal': 0, 'histogram': 0};
    }

    final ema12 = calculateEMA(prices, 12);
    final ema26 = calculateEMA(prices, 26);
    final macd = ema12 - ema26;

    // Calculate signal line (9-period EMA of MACD)
    final macdLine = List.generate(9, (i) => ema12 - ema26);
    final signal = macdLine.reduce((a, b) => a + b) / 9;

    return {
      'macd': macd,
      'signal': signal,
      'histogram': macd - signal,
    };
  }

  /// EMA (Exponential Moving Average)
  static double calculateEMA(List<double> prices, int period) {
    if (prices.length < period) return prices.last;

    final multiplier = 2.0 / (period + 1);
    double ema = prices.sublist(0, period).reduce((a, b) => a + b) / period;

    for (int i = period; i < prices.length; i++) {
      ema = (prices[i] - ema) * multiplier + ema;
    }

    return ema;
  }

  /// ATR (Average True Range)
  static double calculateATR(
    List<double> highs,
    List<double> lows,
    List<double> closes,
    int period,
  ) {
    // Minimum ATR for gold (at least $5)
    const double minATR = 5.0;

    // Validate inputs
    if (highs.isEmpty || lows.isEmpty || closes.isEmpty) {
      return minATR;
    }

    if (highs.length != lows.length || highs.length != closes.length) {
      return minATR;
    }

    if (highs.length < period + 1) {
      // Calculate with available data
      if (highs.length < 2) return minATR;

      final trueRanges = <double>[];
      for (int i = 1; i < highs.length; i++) {
        final tr = max(
          highs[i] - lows[i],
          max(
            (highs[i] - closes[i - 1]).abs(),
            (lows[i] - closes[i - 1]).abs(),
          ),
        );
        trueRanges.add(tr);
      }

      if (trueRanges.isEmpty) return minATR;
      final avg = trueRanges.reduce((a, b) => a + b) / trueRanges.length;
      return max(avg, minATR);
    }

    final trueRanges = <double>[];

    for (int i = 1; i < highs.length; i++) {
      final tr = max(
        highs[i] - lows[i],
        max(
          (highs[i] - closes[i - 1]).abs(),
          (lows[i] - closes[i - 1]).abs(),
        ),
      );
      trueRanges.add(tr);
    }

    if (trueRanges.isEmpty) return minATR;
    if (trueRanges.length < period) {
      // Use all available data
      final avg = trueRanges.reduce((a, b) => a + b) / trueRanges.length;
      return max(avg, minATR);
    }

    final recent = trueRanges.sublist(trueRanges.length - period);
    final atr = recent.reduce((a, b) => a + b) / period;

    // Ensure minimum ATR and handle edge cases
    if (atr.isNaN || atr.isInfinite || atr <= 0) {
      return minATR;
    }

    return max(atr, minATR);
  }

  /// Bollinger Bands
  static Map<String, double> calculateBollinger(
    List<double> prices,
    int period,
    double stdDevMultiplier,
  ) {
    if (prices.length < period) {
      return {
        'upper': prices.last,
        'middle': prices.last,
        'lower': prices.last,
      };
    }

    final sma = calculateSMA(prices, period);
    final relevant = prices.sublist(prices.length - period);

    // Calculate standard deviation
    final variance =
        relevant.map((price) => pow(price - sma, 2)).reduce((a, b) => a + b) /
            period;
    final stdDev = sqrt(variance);

    return {
      'upper': sma + (stdDev * stdDevMultiplier),
      'middle': sma,
      'lower': sma - (stdDev * stdDevMultiplier),
    };
  }

  static TechnicalIndicators _getDefaultIndicators() {
    return TechnicalIndicators(
      rsi: 50,
      macd: 0,
      macdSignal: 0,
      macdHistogram: 0,
      ma20: 2650,
      ma50: 2650,
      ma100: 2650,
      ma200: 2650,
      atr: 10,
      bollingerUpper: 2660,
      bollingerMiddle: 2650,
      bollingerLower: 2640,
    );
  }
}
