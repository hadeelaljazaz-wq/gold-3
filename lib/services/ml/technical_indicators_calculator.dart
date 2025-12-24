import 'dart:math';
import '../../models/candle.dart';

/// TechnicalIndicatorsCalculator - حسابات دقيقة للمؤشرات الفنية
class TechnicalIndicatorsCalculator {
  /// حساب جميع المؤشرات دفعة واحدة
  static Map<String, double> calculateAll(List<Candle> candles) {
    if (candles.isEmpty) {
      return {
        'rsi': 50.0,
        'macd': 0.0,
        'macdSignal': 0.0,
        'macdHistogram': 0.0,
        'ma20': 0.0,
        'ma50': 0.0,
        'ma100': 0.0,
        'ma200': 0.0,
        'atr': 0.0,
        'adx': 25.0,
        'stochastic': 50.0,
        'bollingerUpper': 0.0,
        'bollingerMiddle': 0.0,
        'bollingerLower': 0.0,
      };
    }

    return {
      'rsi': calculateRSI(candles, period: 14),
      'macd': calculateMACD(candles)['macd']!,
      'macdSignal': calculateMACD(candles)['signal']!,
      'macdHistogram': calculateMACD(candles)['histogram']!,
      'ma20': calculateSMA(candles, 20),
      'ma50': calculateSMA(candles, 50),
      'ma100': calculateSMA(candles, 100),
      'ma200': calculateSMA(candles, 200),
      'atr': calculateATR(candles, period: 14),
      'adx': calculateADX(candles, period: 14),
      'stochastic': calculateStochastic(candles, period: 14),
      'bollingerUpper': calculateBollingerBands(candles)['upper']!,
      'bollingerMiddle': calculateBollingerBands(candles)['middle']!,
      'bollingerLower': calculateBollingerBands(candles)['lower']!,
    };
  }

  /// حساب RSI (Relative Strength Index)
  static double calculateRSI(List<Candle> candles, {int period = 14}) {
    if (candles.length < period + 1) return 50.0;

    double gainSum = 0;
    double lossSum = 0;

    // حساب المكاسب والخسائر للفترة الأولى
    for (int i = candles.length - period; i < candles.length; i++) {
      final change = candles[i].close - candles[i - 1].close;
      if (change > 0) {
        gainSum += change;
      } else {
        lossSum += change.abs();
      }
    }

    final avgGain = gainSum / period;
    final avgLoss = lossSum / period;

    if (avgLoss == 0) return 100.0;

    final rs = avgGain / avgLoss;
    final rsi = 100 - (100 / (1 + rs));

    return rsi;
  }

  /// حساب MACD (Moving Average Convergence Divergence)
  static Map<String, double> calculateMACD(
    List<Candle> candles, {
    int fastPeriod = 12,
    int slowPeriod = 26,
    int signalPeriod = 9,
  }) {
    if (candles.length < slowPeriod + signalPeriod) {
      return {'macd': 0.0, 'signal': 0.0, 'histogram': 0.0};
    }

    final prices = candles.map((c) => c.close).toList();

    final fastEMA = calculateEMA(prices, fastPeriod);
    final slowEMA = calculateEMA(prices, slowPeriod);
    final macdLine = fastEMA - slowEMA;

    // حساب Signal line (EMA of MACD)
    final macdValues = <double>[];
    for (int i = slowPeriod; i < candles.length; i++) {
      final subPrices = prices.sublist(0, i + 1);
      final fEMA = calculateEMA(subPrices, fastPeriod);
      final sEMA = calculateEMA(subPrices, slowPeriod);
      macdValues.add(fEMA - sEMA);
    }

    final signalLine = calculateEMA(macdValues, signalPeriod);
    final histogram = macdLine - signalLine;

    return {
      'macd': macdLine,
      'signal': signalLine,
      'histogram': histogram,
    };
  }

  /// حساب SMA (Simple Moving Average)
  static double calculateSMA(List<Candle> candles, int period) {
    if (candles.length < period) {
      return candles.isEmpty ? 0.0 : candles.last.close;
    }

    final recentCandles = candles.sublist(candles.length - period);
    final sum = recentCandles.fold<double>(0, (sum, c) => sum + c.close);

    return sum / period;
  }

  /// حساب EMA (Exponential Moving Average)
  static double calculateEMA(List<double> prices, int period) {
    if (prices.length < period) {
      return prices.isEmpty ? 0.0 : prices.last;
    }

    final multiplier = 2.0 / (period + 1);

    // ابدأ بـ SMA للفترة الأولى
    var ema = prices.sublist(0, period).reduce((a, b) => a + b) / period;

    // احسب EMA لباقي البيانات
    for (int i = period; i < prices.length; i++) {
      ema = (prices[i] * multiplier) + (ema * (1 - multiplier));
    }

    return ema;
  }

  /// حساب ATR (Average True Range)
  static double calculateATR(List<Candle> candles, {int period = 14}) {
    if (candles.length < period + 1) return 10.0;

    final trueRanges = <double>[];

    for (int i = 1; i < candles.length; i++) {
      final high = candles[i].high;
      final low = candles[i].low;
      final prevClose = candles[i - 1].close;

      final tr = max(
        high - low,
        max(
          (high - prevClose).abs(),
          (low - prevClose).abs(),
        ),
      );

      trueRanges.add(tr);
    }

    // احسب المتوسط للفترة الأخيرة
    final recentTR = trueRanges.sublist(max(0, trueRanges.length - period));
    final atr = recentTR.reduce((a, b) => a + b) / recentTR.length;

    return atr;
  }

  /// حساب Bollinger Bands
  static Map<String, double> calculateBollingerBands(
    List<Candle> candles, {
    int period = 20,
    double stdDevMultiplier = 2.0,
  }) {
    if (candles.length < period) {
      final price = candles.isEmpty ? 0.0 : candles.last.close;
      return {'upper': price, 'middle': price, 'lower': price};
    }

    final recentPrices =
        candles.sublist(candles.length - period).map((c) => c.close).toList();

    final middle = recentPrices.reduce((a, b) => a + b) / period;

    final variance = recentPrices
            .map((p) => pow(p - middle, 2))
            .reduce((a, b) => a + b) /
        period;

    final stdDev = sqrt(variance);

    return {
      'upper': middle + (stdDev * stdDevMultiplier),
      'middle': middle,
      'lower': middle - (stdDev * stdDevMultiplier),
    };
  }

  /// حساب ADX (Average Directional Index)
  static double calculateADX(List<Candle> candles, {int period = 14}) {
    if (candles.length < period * 2) return 25.0;

    final plusDMs = <double>[];
    final minusDMs = <double>[];
    final trs = <double>[];

    for (int i = 1; i < candles.length; i++) {
      final highDiff = candles[i].high - candles[i - 1].high;
      final lowDiff = candles[i - 1].low - candles[i].low;

      final plusDM = (highDiff > lowDiff && highDiff > 0) ? highDiff : 0.0;
      final minusDM = (lowDiff > highDiff && lowDiff > 0) ? lowDiff : 0.0;

      plusDMs.add(plusDM);
      minusDMs.add(minusDM);

      final highLow = candles[i].high - candles[i].low;
      final highClose = (candles[i].high - candles[i - 1].close).abs();
      final lowClose = (candles[i].low - candles[i - 1].close).abs();
      
      final tr = [highLow, highClose, lowClose].reduce(max);
      trs.add(tr);
    }

    // حساب +DI و -DI
    final recentPlusDM =
        plusDMs.sublist(max(0, plusDMs.length - period));
    final recentMinusDM =
        minusDMs.sublist(max(0, minusDMs.length - period));
    final recentTR = trs.sublist(max(0, trs.length - period));

    final sumPlusDM = recentPlusDM.reduce((a, b) => a + b);
    final sumMinusDM = recentMinusDM.reduce((a, b) => a + b);
    final sumTR = recentTR.reduce((a, b) => a + b);

    if (sumTR == 0) return 25.0;

    final plusDI = (sumPlusDM / sumTR) * 100;
    final minusDI = (sumMinusDM / sumTR) * 100;

    // حساب DX
    final diDiff = (plusDI - minusDI).abs();
    final diSum = plusDI + minusDI;

    if (diSum == 0) return 25.0;

    final dx = (diDiff / diSum) * 100;

    return dx;
  }

  /// حساب Stochastic Oscillator
  static double calculateStochastic(
    List<Candle> candles, {
    int period = 14,
  }) {
    if (candles.length < period) return 50.0;

    final recentCandles = candles.sublist(candles.length - period);

    final highest = recentCandles.map((c) => c.high).reduce(max);
    final lowest = recentCandles.map((c) => c.low).reduce(min);
    final currentClose = candles.last.close;

    if (highest == lowest) return 50.0;

    final k = ((currentClose - lowest) / (highest - lowest)) * 100;

    return k;
  }

  /// حساب موقع السعر في Bollinger Bands (0-1)
  static double calculateBollingerPosition(List<Candle> candles) {
    if (candles.length < 20) return 0.5;

    final bands = calculateBollingerBands(candles);
    final currentPrice = candles.last.close;

    final upper = bands['upper']!;
    final lower = bands['lower']!;

    if (upper == lower) return 0.5;

    return (currentPrice - lower) / (upper - lower);
  }

  /// حساب التقلب (Volatility)
  static double calculateVolatility(List<Candle> candles, {int period = 20}) {
    if (candles.length < period) return 0.0;

    final returns = <double>[];
    for (int i = candles.length - period; i < candles.length; i++) {
      if (i > 0) {
        final ret = (candles[i].close - candles[i - 1].close) / candles[i - 1].close;
        returns.add(ret);
      }
    }

    if (returns.isEmpty) return 0.0;

    final mean = returns.reduce((a, b) => a + b) / returns.length;
    final variance =
        returns.map((r) => pow(r - mean, 2)).reduce((a, b) => a + b) / returns.length;

    return sqrt(variance) * sqrt(252) * 100; // Annualized volatility
  }

  /// تحديد الاتجاه من Moving Averages
  static String determineTrend(Map<String, double> indicators) {
    final ma20 = indicators['ma20'] ?? 0;
    final ma50 = indicators['ma50'] ?? 0;
    final ma100 = indicators['ma100'] ?? 0;
    final ma200 = indicators['ma200'] ?? 0;

    if (ma20 > ma50 && ma50 > ma100 && ma100 > ma200) {
      return 'STRONG_UPTREND';
    } else if (ma20 > ma50 && ma50 > ma100) {
      return 'UPTREND';
    } else if (ma20 < ma50 && ma50 < ma100 && ma100 < ma200) {
      return 'STRONG_DOWNTREND';
    } else if (ma20 < ma50 && ma50 < ma100) {
      return 'DOWNTREND';
    } else {
      return 'SIDEWAYS';
    }
  }

  /// حساب Momentum
  static double calculateMomentum(List<Candle> candles, {int period = 10}) {
    if (candles.length < period) return 0.0;

    final current = candles.last.close;
    final past = candles[candles.length - period].close;

    return ((current - past) / past) * 100;
  }

  /// حساب قوة الاتجاه (0-100)
  static double calculateTrendStrength(List<Candle> candles) {
    if (candles.length < 50) return 50.0;

    final adx = calculateADX(candles);
    final rsi = calculateRSI(candles);

    // ADX > 25 = اتجاه قوي
    // RSI بعيد عن 50 = اتجاه واضح
    final adxScore = (adx / 50) * 100;
    final rsiScore = ((rsi - 50).abs() / 50) * 100;
    
    final result = min(100.0, (adxScore * 0.6 + rsiScore * 0.4));
    return result;
  }
}

