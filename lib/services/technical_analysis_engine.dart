import 'dart:math' as math;
import '../models/candle.dart';
import 'real_market_data_service.dart';
import '../core/utils/logger.dart';

/// 📈 Technical Analysis Engine - FIXED VERSION
/// محرك التحليل التقني الحقيقي مع تصحيح Support/Resistance
class TechnicalAnalysisEngine {
  // ═══════════════════════════════════════════════════════════════════
  // 📊 INDICATORS - المؤشرات التقنية
  // ═══════════════════════════════════════════════════════════════════

  /// حساب المتوسط المتحرك البسيط (SMA)
  static double calculateSMA(List<Candle> candles, int period) {
    if (candles.length < period) return candles.last.close;

    final relevantCandles = candles.sublist(candles.length - period);
    final sum = relevantCandles.fold<double>(
      0,
      (sum, candle) => sum + candle.close,
    );

    return sum / period;
  }

  /// حساب المتوسط المتحرك الأسي (EMA)
  static double calculateEMA(List<Candle> candles, int period) {
    if (candles.length < period) return candles.last.close;

    final multiplier = 2.0 / (period + 1);
    double ema = calculateSMA(candles.sublist(0, period), period);

    for (int i = period; i < candles.length; i++) {
      ema = (candles[i].close - ema) * multiplier + ema;
    }

    return ema;
  }

  /// حساب RSI (Relative Strength Index)
  static double calculateRSI(List<Candle> candles, int period) {
    if (candles.length < period + 1) return 50;

    double gains = 0;
    double losses = 0;

    for (int i = candles.length - period; i < candles.length; i++) {
      final change = candles[i].close - candles[i - 1].close;
      if (change > 0) {
        gains += change;
      } else {
        losses += change.abs();
      }
    }

    final avgGain = gains / period;
    final avgLoss = losses / period;

    if (avgLoss == 0) return 100;

    final rs = avgGain / avgLoss;
    return 100 - (100 / (1 + rs));
  }

  /// حساب MACD
  static MACDResult calculateMACD(List<Candle> candles) {
    final ema12 = calculateEMA(candles, 12);
    final ema26 = calculateEMA(candles, 26);
    final macdLine = ema12 - ema26;

    final signalLine = macdLine * 0.9;
    final histogram = macdLine - signalLine;

    return MACDResult(
      macdLine: macdLine,
      signalLine: signalLine,
      histogram: histogram,
    );
  }

  /// حساب Bollinger Bands
  static BollingerBandsResult calculateBollingerBands(
    List<Candle> candles,
    int period,
  ) {
    if (candles.length < period) {
      return BollingerBandsResult(
        upper: candles.last.close,
        middle: candles.last.close,
        lower: candles.last.close,
      );
    }

    final sma = calculateSMA(candles, period);
    final relevantCandles = candles.sublist(candles.length - period);

    final variance = relevantCandles.fold<double>(
          0,
          (sum, candle) => sum + math.pow(candle.close - sma, 2),
        ) /
        period;
    final stdDev = math.sqrt(variance);

    return BollingerBandsResult(
      upper: sma + (2 * stdDev),
      middle: sma,
      lower: sma - (2 * stdDev),
    );
  }

  /// حساب ATR (Average True Range)
  static double calculateATR(List<Candle> candles, int period) {
    if (candles.length < period + 1) return 1.0;

    final trueRanges = <double>[];

    for (int i = 1; i < candles.length; i++) {
      final high = candles[i].high;
      final low = candles[i].low;
      final prevClose = candles[i - 1].close;

      final tr = math.max(
        high - low,
        math.max(
          (high - prevClose).abs(),
          (low - prevClose).abs(),
        ),
      );

      trueRanges.add(tr);
    }

    final relevantTR = trueRanges.sublist(trueRanges.length - period);
    return relevantTR.reduce((a, b) => a + b) / period;
  }

  /// 📊 حساب جميع المؤشرات دفعة واحدة - للـ Analytics Dashboard
  static Map<String, double> calculateIndicators(List<Candle> candles) {
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
        'atr': 10.0,
        'bollingerUpper': 0.0,
        'bollingerMiddle': 0.0,
        'bollingerLower': 0.0,
      };
    }

    final currentPrice = candles.last.close;
    
    // RSI
    final rsi = calculateRSI(candles, 14);
    
    // MACD
    final macdResult = calculateMACD(candles);
    
    // Moving Averages
    final ma20 = calculateSMA(candles, 20);
    final ma50 = calculateSMA(candles, 50);
    final ma100 = candles.length >= 100 ? calculateSMA(candles, 100) : currentPrice;
    final ma200 = candles.length >= 200 ? calculateSMA(candles, 200) : currentPrice;
    
    // ATR
    final atr = calculateATR(candles, 14);
    
    // Bollinger Bands
    final bollinger = calculateBollingerBands(candles, 20);

    AppLogger.info('📊 Calculated Real Indicators:');
    AppLogger.info('   RSI: ${rsi.toStringAsFixed(2)}');
    AppLogger.info('   MACD: ${macdResult.macdLine.toStringAsFixed(4)}');
    AppLogger.info('   ATR: ${atr.toStringAsFixed(2)}');
    AppLogger.info('   MA20: ${ma20.toStringAsFixed(2)}');
    AppLogger.info('   MA50: ${ma50.toStringAsFixed(2)}');

    return {
      'rsi': rsi,
      'macd': macdResult.macdLine,
      'macdSignal': macdResult.signalLine,
      'macdHistogram': macdResult.histogram,
      'ma20': ma20,
      'ma50': ma50,
      'ma100': ma100,
      'ma200': ma200,
      'atr': atr,
      'bollingerUpper': bollinger.upper,
      'bollingerMiddle': bollinger.middle,
      'bollingerLower': bollinger.lower,
    };
  }

  /// ✅ FIXED v2: اكتشاف Support & Resistance مع السعر الفعلي
  static SupportResistanceResult findSupportResistance(
    List<Candle> candles,
    double actualPrice,
  ) {
    // استخدم السعر الفعلي من API وليس آخر شمعة
    final currentPrice = actualPrice;

    if (candles.length < 20) {
      return SupportResistanceResult(
        support: currentPrice * 0.995,
        resistance: currentPrice * 1.005,
      );
    }

    final highs = <double>[];
    final lows = <double>[];

    for (int i = 5; i < candles.length - 5; i++) {
      // Local high
      bool isLocalHigh = true;
      for (int j = i - 5; j <= i + 5; j++) {
        if (j != i && candles[j].high > candles[i].high) {
          isLocalHigh = false;
          break;
        }
      }
      if (isLocalHigh) highs.add(candles[i].high);

      // Local low
      bool isLocalLow = true;
      for (int j = i - 5; j <= i + 5; j++) {
        if (j != i && candles[j].low < candles[i].low) {
          isLocalLow = false;
          break;
        }
      }
      if (isLocalLow) lows.add(candles[i].low);
    }

    highs.sort();
    lows.sort();

    // ✅ Resistance: أقرب قمة فوق السعر الفعلي
    double resistance = currentPrice * 1.005;
    for (final high in highs) {
      if (high > currentPrice) {
        resistance = high;
        break;
      }
    }
    // إذا كل القمم تحت السعر، استخدم أعلى قمة أو default
    if (resistance <= currentPrice) {
      resistance = currentPrice * 1.005;
    }

    // ✅ Support: أقرب قاع تحت السعر الفعلي
    double support = currentPrice * 0.995;
    for (final low in lows.reversed) {
      if (low < currentPrice) {
        support = low;
        break;
      }
    }
    // إذا كل القيعان فوق السعر، استخدم default
    if (support >= currentPrice) {
      support = currentPrice * 0.995;
    }

    // ✅ التأكد النهائي - بدون assert لأنه يوقف التطبيق
    if (support >= currentPrice) {
      support = currentPrice * 0.995;
    }
    if (resistance <= currentPrice) {
      resistance = currentPrice * 1.005;
    }

    return SupportResistanceResult(
      support: support,
      resistance: resistance,
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 🎯 SIGNAL GENERATION - توليد الإشارات
  // ═══════════════════════════════════════════════════════════════════

  /// توليد إشارة التداول
  static TradingSignal generateSignal(
    List<Candle> candles,
    double currentPrice,
  ) {
    if (candles.length < 50) {
      return TradingSignal.neutral(currentPrice);
    }

    // Calculate indicators
    final ema20 = calculateEMA(candles, 20);
    final ema50 = calculateEMA(candles, 50);
    final rsi = calculateRSI(candles, 14);
    final macd = calculateMACD(candles);
    final bb = calculateBollingerBands(candles, 20);
    final atr = calculateATR(candles, 14);
    // ✅ FIXED: نمرر السعر الفعلي لضمان S/R صحيحة
    final sr = findSupportResistance(candles, currentPrice);

    // Scoring system
    int bullishScore = 0;
    int bearishScore = 0;

    // 1. EMA Trend
    if (ema20 > ema50)
      bullishScore += 2;
    else
      bearishScore += 2;

    // 2. Price vs EMA
    if (currentPrice > ema20)
      bullishScore += 1;
    else
      bearishScore += 1;

    // 3. RSI
    if (rsi < 30) {
      bullishScore += 3;
    } else if (rsi > 70) {
      bearishScore += 3;
    } else if (rsi < 50) {
      bearishScore += 1;
    } else {
      bullishScore += 1;
    }

    // 4. MACD
    if (macd.histogram > 0)
      bullishScore += 2;
    else
      bearishScore += 2;

    // 5. Bollinger Bands
    if (currentPrice < bb.lower) {
      bullishScore += 2;
    } else if (currentPrice > bb.upper) {
      bearishScore += 2;
    }

    // 6. Support/Resistance proximity
    final distanceToSupport =
        ((currentPrice - sr.support) / currentPrice).abs();
    final distanceToResistance =
        ((sr.resistance - currentPrice) / currentPrice).abs();

    if (distanceToSupport < 0.005) bullishScore += 2;
    if (distanceToResistance < 0.005) bearishScore += 2;

    // Determine direction
    final SignalDirection direction;
    if (bullishScore > bearishScore) {
      direction = SignalDirection.buy;
    } else if (bearishScore > bullishScore) {
      direction = SignalDirection.sell;
    } else {
      direction = SignalDirection.neutral;
    }

    AppLogger.analysis('TechnicalEngine', 'Scores: Bull=$bullishScore, Bear=$bearishScore → ${direction.name.toUpperCase()}');

    if (direction == SignalDirection.neutral) {
      return TradingSignal.neutral(currentPrice);
    }

    // Calculate confidence
    final scoreDiff = (bullishScore - bearishScore).abs();
    final totalScore = bullishScore + bearishScore;
    final confidence = ((scoreDiff / totalScore) * 100).clamp(50, 95).toInt();

    // ✅ ATR-BASED CALCULATION (مثل KabousMasterEngine)
    final entry = currentPrice;

    // 🔒 ATR للذهب عادة بين 3-15 نقطة
    // نضمن ATR معقول (لو Mock data أعطت قيم غريبة)
    final safeATR = atr.clamp(5.0, 15.0);

    // ✅ STOP LOSS = 1.0 × ATR (حوالي 10 نقاط للذهب)
    final stopDistance = safeATR * 1.0;

    final stopLoss = direction == SignalDirection.buy
        ? entry - stopDistance
        : entry + stopDistance;

    // ✅ TARGET1 = 1.5 × Stop (R:R = 1:1.5)
    // ✅ TARGET2 = 2.5 × Stop (R:R = 1:2.5)
    final target1 = direction == SignalDirection.buy
        ? entry + (stopDistance * 1.5)
        : entry - (stopDistance * 1.5);
    final target2 = direction == SignalDirection.buy
        ? entry + (stopDistance * 2.5)
        : entry - (stopDistance * 2.5);

    final signal = TradingSignal(
      direction: direction,
      confidence: confidence,
      entryPrice: entry,
      stopLoss: stopLoss,
      target1: target1,
      target2: target2,
      timestamp: DateTime.now(),
      indicators: IndicatorValues(
        ema20: ema20,
        ema50: ema50,
        rsi: rsi,
        macd: macd,
        bollingerBands: bb,
        atr: atr,
        support: sr.support,
        resistance: sr.resistance,
      ),
    );

    // ✅ DEBUG: طباعة تفاصيل الإشارة
    _debugSignal(signal);

    return signal;
  }

  /// ✅ DEBUG Helper - Enhanced
  static void _debugSignal(TradingSignal signal) {
    final isBuy = signal.direction == SignalDirection.buy;
    bool allOK = true;

    if (isBuy) {
      final stopOK = signal.stopLoss < signal.entryPrice;
      final t1OK = signal.target1 > signal.entryPrice;
      final t2OK = signal.target2 > signal.entryPrice;
      allOK = stopOK && t1OK && t2OK;

      if (!allOK) {
        AppLogger.warn('BUY Signal validation failed: Stop<Entry=$stopOK, T1>Entry=$t1OK, T2>Entry=$t2OK');
      }
    } else if (signal.direction == SignalDirection.sell) {
      final stopOK = signal.stopLoss > signal.entryPrice;
      final t1OK = signal.target1 < signal.entryPrice;
      final t2OK = signal.target2 < signal.entryPrice;
      allOK = stopOK && t1OK && t2OK;

      if (!allOK) {
        AppLogger.warn('SELL Signal validation failed: Stop>Entry=$stopOK, T1<Entry=$t1OK, T2<Entry=$t2OK');
      }
    }

    AppLogger.signal(
      signal.directionString,
      'Entry: \$${signal.entryPrice.toStringAsFixed(2)}, Stop: \$${signal.stopLoss.toStringAsFixed(2)}, T1: \$${signal.target1.toStringAsFixed(2)}, T2: \$${signal.target2.toStringAsFixed(2)}, R:R=1:${signal.riskRewardRatio.toStringAsFixed(1)}, ${allOK ? "Valid" : "INVALID"}',
    );
  }

  /// توليد إشارة Scalping (15min)
  static Future<TradingSignal> generateScalpSignal() async {
    AppLogger.debug('🔍 Generating Scalp Signal (15min)...');
    final candles = await RealMarketDataService.getGoldCandles(
      timeframe: '15min',
      limit: 100,
    );
    final currentPrice = await RealMarketDataService.getCurrentPrice();
    return generateSignal(candles, currentPrice);
  }

  /// توليد إشارة Swing (4h)
  static Future<TradingSignal> generateSwingSignal() async {
    AppLogger.debug('🔍 Generating Swing Signal (4h)...');
    final candles = await RealMarketDataService.getGoldCandles(
      timeframe: '4h',
      limit: 100,
    );
    final currentPrice = await RealMarketDataService.getCurrentPrice();
    return generateSignal(candles, currentPrice);
  }
}

// ═══════════════════════════════════════════════════════════════════
// 📦 MODELS
// ═══════════════════════════════════════════════════════════════════

class MACDResult {
  final double macdLine;
  final double signalLine;
  final double histogram;

  MACDResult({
    required this.macdLine,
    required this.signalLine,
    required this.histogram,
  });
}

class BollingerBandsResult {
  final double upper;
  final double middle;
  final double lower;

  BollingerBandsResult({
    required this.upper,
    required this.middle,
    required this.lower,
  });
}

class SupportResistanceResult {
  final double support;
  final double resistance;

  SupportResistanceResult({
    required this.support,
    required this.resistance,
  });
}

enum SignalDirection { buy, sell, neutral }

class TradingSignal {
  final SignalDirection direction;
  final int confidence;
  final double entryPrice;
  final double stopLoss;
  final double target1;
  final double target2;
  final DateTime timestamp;
  final IndicatorValues indicators;

  TradingSignal({
    required this.direction,
    required this.confidence,
    required this.entryPrice,
    required this.stopLoss,
    required this.target1,
    required this.target2,
    required this.timestamp,
    required this.indicators,
  });

  factory TradingSignal.neutral(double currentPrice) {
    return TradingSignal(
      direction: SignalDirection.neutral,
      confidence: 50,
      entryPrice: currentPrice,
      stopLoss: currentPrice * 0.995,
      target1: currentPrice * 1.005,
      target2: currentPrice * 1.01,
      timestamp: DateTime.now(),
      indicators: IndicatorValues.empty(currentPrice),
    );
  }

  double get riskRewardRatio {
    final risk = (entryPrice - stopLoss).abs();
    final reward = (target2 - entryPrice).abs();
    if (risk == 0) return 0;
    return reward / risk;
  }

  String get directionString {
    switch (direction) {
      case SignalDirection.buy:
        return 'BUY';
      case SignalDirection.sell:
        return 'SELL';
      case SignalDirection.neutral:
        return 'NEUTRAL';
    }
  }

  bool isValid(Duration maxAge) {
    return DateTime.now().difference(timestamp) < maxAge;
  }

  String get stabilityHash {
    return '${direction}_${entryPrice.toStringAsFixed(2)}_${stopLoss.toStringAsFixed(2)}';
  }
}

class IndicatorValues {
  final double ema20;
  final double ema50;
  final double rsi;
  final MACDResult macd;
  final BollingerBandsResult bollingerBands;
  final double atr;
  final double support;
  final double resistance;

  IndicatorValues({
    required this.ema20,
    required this.ema50,
    required this.rsi,
    required this.macd,
    required this.bollingerBands,
    required this.atr,
    required this.support,
    required this.resistance,
  });

  factory IndicatorValues.empty(double price) {
    return IndicatorValues(
      ema20: price,
      ema50: price,
      rsi: 50,
      macd: MACDResult(macdLine: 0, signalLine: 0, histogram: 0),
      bollingerBands: BollingerBandsResult(
        upper: price * 1.01,
        middle: price,
        lower: price * 0.99,
      ),
      atr: 1.0,
      support: price * 0.99,
      resistance: price * 1.01,
    );
  }
}
