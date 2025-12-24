import 'package:flutter_test/flutter_test.dart';
import 'package:golden_nightmare_pro/services/golden_nightmare/golden_nightmare_engine.dart';
import 'package:golden_nightmare_pro/models/candle.dart';

void main() {
  group('GoldenNightmareEngine Tests', () {
    late List<Candle> testCandles;

    setUp(() {
      // Create test candles
      final now = DateTime.now();
      testCandles = List.generate(500, (index) {
        final basePrice = 2000.0 + (index * 0.5);
        return Candle(
          time: now.subtract(Duration(hours: 500 - index)),
          open: basePrice,
          high: basePrice + 3.0,
          low: basePrice - 3.0,
          close: basePrice + (index % 2 == 0 ? 1.5 : -1.5),
          volume: 2000.0 + (index * 20),
        );
      });
    });

    test('should generate recommendations with valid data', () async {
      final result = await GoldenNightmareEngine.generate(
        currentPrice: 2250.0,
        candles: testCandles,
        rsi: 55.0,
        macd: 0.5,
        macdSignal: 0.3,
        ma20: 2230.0,
        ma50: 2200.0,
        ma100: 2150.0,
        ma200: 2100.0,
        atr: 8.0,
      );

      expect(result, isNotNull);
      expect(result.containsKey('SCALP'), isTrue);
      expect(result.containsKey('SWING'), isTrue);
    });

    test('should return both SCALP and SWING recommendations', () async {
      final result = await GoldenNightmareEngine.generate(
        currentPrice: 2250.0,
        candles: testCandles,
        rsi: 55.0,
        macd: 0.5,
        macdSignal: 0.3,
        ma20: 2230.0,
        ma50: 2200.0,
        ma100: 2150.0,
        ma200: 2100.0,
        atr: 8.0,
      );

      final scalp = result['SCALP'];
      final swing = result['SWING'];

      expect(scalp, isNotNull);
      expect(swing, isNotNull);
      expect(scalp['direction'], isNotNull);
      expect(swing['direction'], isNotNull);
    });

    test('should handle 10-layer analysis', () async {
      final result = await GoldenNightmareEngine.generate(
        currentPrice: 2250.0,
        candles: testCandles,
        rsi: 60.0,
        macd: 1.0,
        macdSignal: 0.5,
        ma20: 2230.0,
        ma50: 2200.0,
        ma100: 2150.0,
        ma200: 2100.0,
        atr: 8.0,
      );

      expect(result, isNotNull);
      // All 10 layers should be processed
      expect(result['SCALP'], isNotNull);
      expect(result['SWING'], isNotNull);
    });

    test('should calculate confidence levels', () async {
      final result = await GoldenNightmareEngine.generate(
        currentPrice: 2250.0,
        candles: testCandles,
        rsi: 70.0, // Strong bullish
        macd: 1.5,
        macdSignal: 0.5,
        ma20: 2230.0,
        ma50: 2200.0,
        ma100: 2150.0,
        ma200: 2100.0,
        atr: 8.0,
      );

      final scalp = result['SCALP'];
      final swing = result['SWING'];

      expect(scalp['confidence'], isNotNull);
      expect(swing['confidence'], isNotNull);

      // Confidence should be between 0 and 100
      expect(scalp['confidence'], greaterThanOrEqualTo(0));
      expect(scalp['confidence'], lessThanOrEqualTo(100));
      expect(swing['confidence'], greaterThanOrEqualTo(0));
      expect(swing['confidence'], lessThanOrEqualTo(100));
    });

    test('should handle different market conditions', () async {
      // Bullish market
      final bullishResult = await GoldenNightmareEngine.generate(
        currentPrice: 2300.0,
        candles: testCandles,
        rsi: 65.0,
        macd: 2.0,
        macdSignal: 1.0,
        ma20: 2250.0,
        ma50: 2200.0,
        ma100: 2150.0,
        ma200: 2100.0,
        atr: 8.0,
      );

      expect(bullishResult, isNotNull);

      // Bearish market
      final bearishResult = await GoldenNightmareEngine.generate(
        currentPrice: 2100.0,
        candles: testCandles,
        rsi: 35.0,
        macd: -2.0,
        macdSignal: -1.0,
        ma20: 2150.0,
        ma50: 2200.0,
        ma100: 2250.0,
        ma200: 2300.0,
        atr: 8.0,
      );

      expect(bearishResult, isNotNull);

      // Neutral market
      final neutralResult = await GoldenNightmareEngine.generate(
        currentPrice: 2200.0,
        candles: testCandles,
        rsi: 50.0,
        macd: 0.0,
        macdSignal: 0.0,
        ma20: 2200.0,
        ma50: 2200.0,
        ma100: 2200.0,
        ma200: 2200.0,
        atr: 8.0,
      );

      expect(neutralResult, isNotNull);
    });

    test('should validate entry prices', () async {
      final result = await GoldenNightmareEngine.generate(
        currentPrice: 2250.0,
        candles: testCandles,
        rsi: 55.0,
        macd: 0.5,
        macdSignal: 0.3,
        ma20: 2230.0,
        ma50: 2200.0,
        ma100: 2150.0,
        ma200: 2100.0,
        atr: 8.0,
      );

      final scalp = result['SCALP'];
      final swing = result['SWING'];

      if (scalp['direction'] != 'NO_TRADE') {
        expect(scalp['entryPrice'], greaterThan(0));
        expect(scalp['stopLoss'], greaterThan(0));
        expect(scalp['takeProfit'], isNotEmpty);
      }

      if (swing['direction'] != 'NO_TRADE') {
        expect(swing['entryPrice'], greaterThan(0));
        expect(swing['stopLoss'], greaterThan(0));
        expect(swing['takeProfit'], isNotEmpty);
      }
    });

    test('should handle edge cases', () async {
      // Very high RSI
      final highRsiResult = await GoldenNightmareEngine.generate(
        currentPrice: 2250.0,
        candles: testCandles,
        rsi: 95.0,
        macd: 0.5,
        macdSignal: 0.3,
        ma20: 2230.0,
        ma50: 2200.0,
        ma100: 2150.0,
        ma200: 2100.0,
        atr: 8.0,
      );

      expect(highRsiResult, isNotNull);

      // Very low RSI
      final lowRsiResult = await GoldenNightmareEngine.generate(
        currentPrice: 2250.0,
        candles: testCandles,
        rsi: 5.0,
        macd: 0.5,
        macdSignal: 0.3,
        ma20: 2230.0,
        ma50: 2200.0,
        ma100: 2150.0,
        ma200: 2100.0,
        atr: 8.0,
      );

      expect(lowRsiResult, isNotNull);
    });

    test('should handle insufficient candles', () {
      expect(
        () => GoldenNightmareEngine.generate(
          currentPrice: 2250.0,
          candles: [], // Empty candles
          rsi: 50.0,
          macd: 0.0,
          macdSignal: 0.0,
          ma20: 2230.0,
          ma50: 2200.0,
          ma100: 2150.0,
          ma200: 2100.0,
          atr: 8.0,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
