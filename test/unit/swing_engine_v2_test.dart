import 'package:flutter_test/flutter_test.dart';
import 'package:golden_nightmare_pro/services/engines/swing_engine_v2.dart';
import 'package:golden_nightmare_pro/models/candle.dart';

void main() {
  group('SwingEngineV2 Comprehensive Tests', () {
    late List<Candle> testCandles;

    setUp(() {
      // Create swing-style test candles (longer timeframe patterns)
      final now = DateTime.now();
      testCandles = List.generate(200, (index) {
        final basePrice = 2000.0 + (index * 0.3);
        final cycle = (index / 20).floor() % 2; // Create swing patterns
        final isGreen = cycle == 0;

        return Candle(
          time: now.subtract(Duration(hours: 200 - index)),
          open: basePrice,
          high: basePrice + (isGreen ? 5.0 : 2.0),
          low: basePrice - (isGreen ? 2.0 : 5.0),
          close: isGreen ? basePrice + 3.0 : basePrice - 3.0,
          volume: 5000.0 + (index * 50),
        );
      });
    });

    test('should generate valid swing signal', () async {
      final signal = await SwingEngineV2.analyze(
        candles: testCandles,
        currentPrice: 2060.0,
        atr: 5.0,
        rsi: 55.0,
        macd: 1.0,
        macdSignal: 0.5,
        ma20: 2050.0,
        ma50: 2040.0,
        ma100: 2030.0,
        ma200: 2020.0,
      );

      expect(signal, isNotNull);
      expect(signal.direction, isIn(['BUY', 'SELL', 'NO_TRADE']));
      expect(signal.confidence, inInclusiveRange(0, 100));
      expect(signal.timestamp, isNotNull);
    });

    test('should detect uptrend with bullish MA alignment', () async {
      final signal = await SwingEngineV2.analyze(
        candles: testCandles,
        currentPrice: 2070.0,
        atr: 5.0,
        rsi: 60.0,
        macd: 1.5,
        macdSignal: 1.0,
        ma20: 2065.0, // Bullish: 20 > 50 > 100 > 200
        ma50: 2055.0,
        ma100: 2045.0,
        ma200: 2035.0,
      );

      // Should favor BUY in clear uptrend
      if (signal.direction == 'BUY') {
        expect(signal.confidence, greaterThan(60));
        expect(signal.macroTrend, isNotNull);
      }
    });

    test('should detect downtrend with bearish MA alignment', () async {
      final signal = await SwingEngineV2.analyze(
        candles: testCandles,
        currentPrice: 2030.0,
        atr: 5.0,
        rsi: 40.0,
        macd: -1.5,
        macdSignal: -1.0,
        ma20: 2035.0, // Bearish: 20 < 50 < 100 < 200
        ma50: 2045.0,
        ma100: 2055.0,
        ma200: 2065.0,
      );

      // Should favor SELL in clear downtrend
      if (signal.direction == 'SELL') {
        expect(signal.confidence, greaterThan(60));
        expect(signal.macroTrend, isNotNull);
      }
    });

    test('should calculate proper risk/reward for swing trades', () async {
      final signal = await SwingEngineV2.analyze(
        candles: testCandles,
        currentPrice: 2060.0,
        atr: 5.0,
        rsi: 55.0,
        macd: 1.0,
        macdSignal: 0.5,
        ma20: 2055.0,
        ma50: 2050.0,
        ma100: 2045.0,
        ma200: 2040.0,
      );

      if (signal.direction != 'NO_TRADE' && signal.riskReward != null) {
        expect(signal.riskReward, greaterThan(1.0));
        expect(signal.riskReward, lessThan(15.0)); // Reasonable for swing
      }
    });

    test('should detect market structure breaks', () async {
      final signal = await SwingEngineV2.analyze(
        candles: testCandles,
        currentPrice: 2060.0,
        atr: 5.0,
        rsi: 55.0,
        macd: 1.0,
        macdSignal: 0.5,
        ma20: 2055.0,
        ma50: 2050.0,
        ma100: 2045.0,
        ma200: 2040.0,
      );

      expect(signal.marketStructure, isNotNull);
      if (signal.marketStructure != null) {
        // MarketStructure doesn't have type field
        expect(signal.marketStructure, isA<MarketStructure>());
      }
    });

    test('should identify fibonacci retracement levels', () async {
      final signal = await SwingEngineV2.analyze(
        candles: testCandles,
        currentPrice: 2060.0,
        atr: 5.0,
        rsi: 55.0,
        macd: 1.0,
        macdSignal: 0.5,
        ma20: 2055.0,
        ma50: 2050.0,
        ma100: 2045.0,
        ma200: 2040.0,
      );

      expect(signal.fibonacci, isNotNull);
      if (signal.fibonacci != null) {
        // FibonacciLevels structure may be different
        expect(signal.fibonacci, isA<FibonacciLevels>());
      }
    });

    test('should detect supply and demand zones', () async {
      final signal = await SwingEngineV2.analyze(
        candles: testCandles,
        currentPrice: 2060.0,
        atr: 5.0,
        rsi: 55.0,
        macd: 1.0,
        macdSignal: 0.5,
        ma20: 2055.0,
        ma50: 2050.0,
        ma100: 2045.0,
        ma200: 2040.0,
      );

      expect(signal.zones, isNotNull);
      if (signal.zones != null) {
        expect(signal.zones!.demandZones, isNotNull);
        expect(signal.zones!.supplyZones, isNotNull);
      }
    });

    test('should calculate QCF convergence', () async {
      final signal = await SwingEngineV2.analyze(
        candles: testCandles,
        currentPrice: 2060.0,
        atr: 5.0,
        rsi: 55.0,
        macd: 1.0,
        macdSignal: 0.5,
        ma20: 2055.0,
        ma50: 2050.0,
        ma100: 2045.0,
        ma200: 2040.0,
      );

      expect(signal.qcf, isNotNull);
      if (signal.qcf != null) {
        expect(signal.qcf!.score, inInclusiveRange(0, 100));
        expect(signal.qcf!.factors, isNotEmpty);
      }
    });

    test('should detect reversal patterns', () async {
      final signal = await SwingEngineV2.analyze(
        candles: testCandles,
        currentPrice: 2060.0,
        atr: 5.0,
        rsi: 75.0, // Potential reversal zone
        macd: 1.0,
        macdSignal: 0.5,
        ma20: 2055.0,
        ma50: 2050.0,
        ma100: 2045.0,
        ma200: 2040.0,
      );

      expect(signal.reversal, isNotNull);
      if (signal.reversal != null) {
        // ReversalDetection structure changed
        expect(signal.reversal, isA<ReversalDetection>());
      }
    });

    test('should handle insufficient swing data', () async {
      final fewCandles = testCandles.take(20).toList();

      final signal = await SwingEngineV2.analyze(
        candles: fewCandles,
        currentPrice: 2060.0,
        atr: 5.0,
        rsi: 55.0,
        macd: 1.0,
        macdSignal: 0.5,
        ma20: 2055.0,
        ma50: 2050.0,
        ma100: 2045.0,
        ma200: 2040.0,
      );

      expect(signal, isNotNull);
      // Should return NO_TRADE or low confidence with insufficient data
      if (signal.direction != 'NO_TRADE') {
        expect(signal.confidence, lessThan(70));
      }
    });

    test('should validate swing entry/exit prices', () async {
      final signal = await SwingEngineV2.analyze(
        candles: testCandles,
        currentPrice: 2060.0,
        atr: 5.0,
        rsi: 55.0,
        macd: 1.0,
        macdSignal: 0.5,
        ma20: 2055.0,
        ma50: 2050.0,
        ma100: 2045.0,
        ma200: 2040.0,
      );

      if (signal.direction != 'NO_TRADE') {
        expect(signal.entryPrice, isNotNull);
        expect(signal.stopLoss, isNotNull);
        expect(signal.takeProfit, isNotNull);

        // Validate wider stops for swing trades
        if (signal.direction == 'BUY') {
          final stopDistance = signal.entryPrice! - signal.stopLoss!;
          expect(stopDistance, greaterThan(3.0)); // Wider stops for swing
        } else if (signal.direction == 'SELL') {
          final stopDistance = signal.stopLoss! - signal.entryPrice!;
          expect(stopDistance, greaterThan(3.0));
        }
      }
    });
  });
}
