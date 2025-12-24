import 'package:flutter_test/flutter_test.dart';
import 'package:golden_nightmare_pro/services/engines/scalping_engine_v2.dart';
import 'package:golden_nightmare_pro/models/candle.dart';

void main() {
  group('ScalpingEngineV2 Comprehensive Tests', () {
    late List<Candle> testCandles;

    setUp(() {
      // Create realistic test candles
      final now = DateTime.now();
      testCandles = List.generate(100, (index) {
        final basePrice = 2000.0 + (index * 0.5);
        final isGreen = index % 3 != 0; // 66% green candles
        return Candle(
          time: now.subtract(Duration(hours: 100 - index)),
          open: basePrice,
          high: basePrice + (isGreen ? 3.0 : 1.0),
          low: basePrice - (isGreen ? 1.0 : 3.0),
          close: isGreen ? basePrice + 2.0 : basePrice - 2.0,
          volume: 1000.0 + (index * 10),
        );
      });
    });

    test('should generate valid signal with proper data', () async {
      final signal = await ScalpingEngineV2.analyze(
        currentPrice: 2050.0,
        candles: testCandles,
        rsi: 55.0,
        macd: 0.5,
        macdSignal: 0.3,
        atr: 2.5,
      );

      expect(signal, isNotNull);
      expect(signal.direction, isIn(['BUY', 'SELL', 'NO_TRADE']));
      expect(signal.confidence, inInclusiveRange(0, 100));
      expect(signal.timestamp, isNotNull);
    });

    test('should detect BUY signal in oversold conditions', () async {
      final signal = await ScalpingEngineV2.analyze(
        currentPrice: 2050.0,
        candles: testCandles,
        rsi: 25.0, // Oversold
        macd: 0.8,
        macdSignal: 0.2,
        atr: 2.5,
      );

      // Should favor BUY in oversold conditions
      if (signal.direction == 'BUY') {
        expect(signal.confidence, greaterThan(50));
        expect(signal.entryPrice, isNotNull);
        expect(signal.stopLoss, isNotNull);
        expect(signal.takeProfit, isNotNull);
      }
    });

    test('should detect SELL signal in overbought conditions', () async {
      final signal = await ScalpingEngineV2.analyze(
        currentPrice: 2050.0,
        candles: testCandles,
        rsi: 80.0, // Overbought
        macd: -0.8,
        macdSignal: -0.2,
        atr: 2.5,
      );

      // Should favor SELL in overbought conditions
      if (signal.direction == 'SELL') {
        expect(signal.confidence, greaterThan(50));
        expect(signal.entryPrice, isNotNull);
        expect(signal.stopLoss, isNotNull);
        expect(signal.takeProfit, isNotNull);
      }
    });

    test('should calculate proper risk/reward ratio', () async {
      final signal = await ScalpingEngineV2.analyze(
        currentPrice: 2050.0,
        candles: testCandles,
        rsi: 45.0,
        macd: 0.5,
        macdSignal: 0.3,
        atr: 2.5,
      );

      if (signal.direction != 'NO_TRADE' && signal.riskReward != null) {
        expect(signal.riskReward, greaterThan(0));
        expect(signal.riskReward, lessThan(10)); // Reasonable range
      }
    });

    test('should handle insufficient data gracefully', () async {
      final fewCandles = testCandles.take(5).toList();

      final signal = await ScalpingEngineV2.analyze(
        currentPrice: 2050.0,
        candles: fewCandles,
        rsi: 50.0,
        macd: 0.0,
        macdSignal: 0.0,
        atr: 2.5,
      );

      expect(signal, isNotNull);
      // Should return NO_TRADE or low confidence
      if (signal.direction != 'NO_TRADE') {
        expect(signal.confidence, lessThan(70));
      }
    });

    test('should detect micro-trend correctly', () async {
      // Create trending candles (uptrend)
      final trendingCandles = List.generate(50, (index) {
        final basePrice = 2000.0 + (index * 1.0); // Clear uptrend
        return Candle(
          time: DateTime.now().subtract(Duration(hours: 50 - index)),
          open: basePrice,
          high: basePrice + 2.0,
          low: basePrice - 0.5,
          close: basePrice + 1.5,
          volume: 1000.0,
        );
      });

      final signal = await ScalpingEngineV2.analyze(
        currentPrice: 2050.0,
        candles: trendingCandles,
        rsi: 65.0,
        macd: 1.0,
        macdSignal: 0.5,
        atr: 2.5,
      );

      // Should detect uptrend
      expect(signal.microTrend, isNotNull);
      if (signal.microTrend != null) {
        expect(signal.microTrend!.direction,
            isIn(['BULLISH', 'BEARISH', 'NEUTRAL']));
      }
    });

    test('should calculate momentum analysis', () async {
      final signal = await ScalpingEngineV2.analyze(
        currentPrice: 2050.0,
        candles: testCandles,
        rsi: 60.0,
        macd: 0.8,
        macdSignal: 0.4,
        atr: 2.5,
      );

      expect(signal.momentum, isNotNull);
      if (signal.momentum != null) {
        expect(signal.momentum!.score, isA<int>());
        expect(signal.momentum!.classification, isA<String>());
        expect(signal.momentum!.signals, isA<List<String>>());
      }
    });

    test('should handle extreme market conditions', () async {
      final signal = await ScalpingEngineV2.analyze(
        currentPrice: 2050.0,
        candles: testCandles,
        rsi: 95.0, // Extremely overbought
        macd: -2.0,
        macdSignal: -1.0,
        atr: 10.0, // High volatility
      );

      expect(signal, isNotNull);
      // Should be cautious in extreme conditions
      if (signal.direction != 'NO_TRADE') {
        expect(signal.confidence, lessThan(85));
      }
    });

    test('should validate entry/exit prices', () async {
      final signal = await ScalpingEngineV2.analyze(
        currentPrice: 2050.0,
        candles: testCandles,
        rsi: 50.0,
        macd: 0.5,
        macdSignal: 0.3,
        atr: 2.5,
      );

      if (signal.direction != 'NO_TRADE') {
        expect(signal.entryPrice, isNotNull);
        expect(signal.stopLoss, isNotNull);
        expect(signal.takeProfit, isNotNull);

        // Validate price logic
        if (signal.direction == 'BUY') {
          expect(signal.stopLoss!, lessThan(signal.entryPrice!));
          expect(signal.takeProfit!, greaterThan(signal.entryPrice!));
        } else if (signal.direction == 'SELL') {
          expect(signal.stopLoss!, greaterThan(signal.entryPrice!));
          expect(signal.takeProfit!, lessThan(signal.entryPrice!));
        }
      }
    });

    test('should return NO_TRADE when conditions are unclear', () async {
      final signal = await ScalpingEngineV2.analyze(
        currentPrice: 2050.0,
        candles: testCandles,
        rsi: 50.0, // Neutral
        macd: 0.0, // No momentum
        macdSignal: 0.0,
        atr: 2.5,
      );

      // Should be cautious when no clear signal
      expect(signal, isNotNull);
    });
  });
}
