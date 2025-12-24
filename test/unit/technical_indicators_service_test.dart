import 'package:flutter_test/flutter_test.dart';
import 'package:golden_nightmare_pro/services/technical_indicators_service.dart';
import 'package:golden_nightmare_pro/models/candle.dart';

void main() {
  group('TechnicalIndicatorsService Tests', () {
    late List<Candle> testCandles;

    setUp(() {
      final now = DateTime.now();
      testCandles = List.generate(200, (index) {
        final basePrice = 2000.0 + (index * 0.5);
        return Candle(
          time: now.subtract(Duration(hours: 200 - index)),
          open: basePrice,
          high: basePrice + 3.0,
          low: basePrice - 3.0,
          close: basePrice + (index % 2 == 0 ? 1.5 : -1.5),
          volume: 2000.0 + (index * 20),
        );
      });
    });

    test('should calculate all indicators', () {
      final indicators = TechnicalIndicatorsService.calculateAll(testCandles);

      expect(indicators, isNotNull);
      expect(indicators.rsi, inInclusiveRange(0.0, 100.0));
      expect(indicators.macd, isNotNull);
      expect(indicators.macdSignal, isNotNull);
      expect(indicators.ma20, greaterThan(0));
      expect(indicators.ma50, greaterThan(0));
      expect(indicators.ma100, greaterThan(0));
      expect(indicators.ma200, greaterThan(0));
      expect(indicators.atr, greaterThan(0));
    });

    test('should calculate RSI correctly', () {
      final closes = testCandles.map((c) => c.close).toList();
      final rsi = TechnicalIndicatorsService.calculateRSI(closes, 14);

      expect(rsi, inInclusiveRange(0.0, 100.0));

      // RSI should be around 50 for mixed candles
      expect(rsi, greaterThan(20));
      expect(rsi, lessThan(80));
    });

    test('should detect overbought RSI', () {
      // Create overbought candles (mostly green)
      final bullishCandles = List.generate(50, (index) {
        final basePrice = 2000.0 + (index * 2.0);
        return Candle(
          time: DateTime.now().subtract(Duration(hours: 50 - index)),
          open: basePrice,
          high: basePrice + 5.0,
          low: basePrice - 1.0,
          close: basePrice + 4.0,
          volume: 2000.0,
        );
      });

      final closes = bullishCandles.map((c) => c.close).toList();
      final rsi = TechnicalIndicatorsService.calculateRSI(closes, 14);

      // RSI should be high for bullish candles
      expect(rsi, greaterThan(50));
    });

    test('should detect oversold RSI', () {
      // Create oversold candles (mostly red)
      final bearishCandles = List.generate(50, (index) {
        final basePrice = 2100.0 - (index * 2.0);
        return Candle(
          time: DateTime.now().subtract(Duration(hours: 50 - index)),
          open: basePrice,
          high: basePrice + 1.0,
          low: basePrice - 5.0,
          close: basePrice - 4.0,
          volume: 2000.0,
        );
      });

      final closes = bearishCandles.map((c) => c.close).toList();
      final rsi = TechnicalIndicatorsService.calculateRSI(closes, 14);

      // RSI should be low for bearish candles
      expect(rsi, lessThan(50));
    });

    test('should calculate MACD correctly', () {
      final closes = testCandles.map((c) => c.close).toList();
      final macd = TechnicalIndicatorsService.calculateMACD(closes);

      expect(macd, isNotNull);
      expect(macd.containsKey('macd'), isTrue);
      expect(macd.containsKey('signal'), isTrue);
      expect(macd.containsKey('histogram'), isTrue);

      expect(macd['macd'], isA<double>());
      expect(macd['signal'], isA<double>());
      expect(macd['histogram'], isA<double>());
    });

    test('should calculate SMA correctly', () {
      final closes = testCandles.map((c) => c.close).toList();

      final sma20 = TechnicalIndicatorsService.calculateSMA(closes, 20);
      final sma50 = TechnicalIndicatorsService.calculateSMA(closes, 50);

      expect(sma20, greaterThan(0));
      expect(sma50, greaterThan(0));

      // SMA should be close to average of closes
      final avgClose = closes.reduce((a, b) => a + b) / closes.length;
      expect(sma20, closeTo(avgClose, avgClose * 0.1));
    });

    test('should calculate ATR correctly', () {
      final highs = testCandles.map((c) => c.high).toList();
      final lows = testCandles.map((c) => c.low).toList();
      final closes = testCandles.map((c) => c.close).toList();

      final atr =
          TechnicalIndicatorsService.calculateATR(highs, lows, closes, 14);

      expect(atr, greaterThan(0));

      // ATR should be reasonable (not too high or too low)
      final avgPrice = closes.reduce((a, b) => a + b) / closes.length;
      final atrPercent = atr / avgPrice;
      expect(atrPercent, greaterThan(0.001));
      expect(atrPercent, lessThan(0.1));
    });

    test('should calculate Bollinger Bands correctly', () {
      final closes = testCandles.map((c) => c.close).toList();
      final bollinger =
          TechnicalIndicatorsService.calculateBollinger(closes, 20, 2);

      expect(bollinger, isNotNull);
      expect(bollinger.containsKey('upper'), isTrue);
      expect(bollinger.containsKey('middle'), isTrue);
      expect(bollinger.containsKey('lower'), isTrue);

      expect(bollinger['upper'], greaterThan(bollinger['middle']!));
      expect(bollinger['middle'], greaterThan(bollinger['lower']!));
    });

    test('should handle empty candles list', () {
      final indicators = TechnicalIndicatorsService.calculateAll([]);

      expect(indicators, isNotNull);
      expect(indicators.rsi, equals(50.0)); // Default
      expect(indicators.macd, equals(0.0));
      expect(indicators.atr, equals(0.0));
    });

    test('should handle insufficient candles for RSI', () {
      final fewCandles = testCandles.take(5).toList();
      final closes = fewCandles.map((c) => c.close).toList();
      final rsi = TechnicalIndicatorsService.calculateRSI(closes, 14);

      // Should return default value (50.0) when insufficient data
      expect(rsi, equals(50.0));
    });

    test('should calculate EMA correctly', () {
      final closes = testCandles.map((c) => c.close).toList();
      final ema20 = TechnicalIndicatorsService.calculateEMA(closes, 20);

      expect(ema20, greaterThan(0));

      // EMA should be close to SMA for trending data
      final sma20 = TechnicalIndicatorsService.calculateSMA(closes, 20);
      final diff = (ema20 - sma20).abs() / sma20;
      expect(diff, lessThan(0.2)); // Within 20%
    });

    test('should handle different period values', () {
      final closes = testCandles.map((c) => c.close).toList();

      final rsi14 = TechnicalIndicatorsService.calculateRSI(closes, 14);
      final rsi21 = TechnicalIndicatorsService.calculateRSI(closes, 21);

      expect(rsi14, inInclusiveRange(0.0, 100.0));
      expect(rsi21, inInclusiveRange(0.0, 100.0));
    });

    test('should calculate indicators consistently', () {
      final indicators1 = TechnicalIndicatorsService.calculateAll(testCandles);
      final indicators2 = TechnicalIndicatorsService.calculateAll(testCandles);

      expect(indicators1.rsi, equals(indicators2.rsi));
      expect(indicators1.macd, equals(indicators2.macd));
      expect(indicators1.ma20, equals(indicators2.ma20));
    });

    test('should handle extreme price movements', () {
      // Create candles with extreme volatility
      final volatileCandles = List.generate(100, (index) {
        const basePrice = 2000.0;
        final volatility = (index % 10) * 10.0; // High volatility
        return Candle(
          time: DateTime.now().subtract(Duration(hours: 100 - index)),
          open: basePrice,
          high: basePrice + volatility,
          low: basePrice - volatility,
          close: basePrice + (index % 2 == 0 ? volatility : -volatility),
          volume: 2000.0,
        );
      });

      final indicators =
          TechnicalIndicatorsService.calculateAll(volatileCandles);

      expect(indicators, isNotNull);
      expect(indicators.atr, greaterThan(0));
      expect(indicators.rsi, inInclusiveRange(0.0, 100.0));
    });
  });
}
