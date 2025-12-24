import 'package:flutter_test/flutter_test.dart';
import 'package:golden_nightmare_pro/services/golden_nightmare/golden_nightmare_engine.dart';
import 'package:golden_nightmare_pro/services/engines/scalping_engine_v2.dart';
import 'package:golden_nightmare_pro/services/engines/swing_engine_v2.dart';
import 'package:golden_nightmare_pro/services/quantum_scalping/quantum_scalping_engine.dart';
import 'package:golden_nightmare_pro/services/candle_generator.dart';
import 'package:golden_nightmare_pro/models/candle.dart';

void main() {
  group('Multi-Engine Comparison Integration Tests', () {
    late List<Candle> testCandles;

    setUp(() {
      // Generate test candles
      testCandles = CandleGenerator.generate(
        currentPrice: 2050.0,
        count: 500,
      );
    });

    test('should generate signals from all engines', () async {
      // Golden Nightmare Engine
      final gnResult = await GoldenNightmareEngine.generate(
        currentPrice: 2050.0,
        candles: testCandles,
        rsi: 55.0,
        macd: 0.5,
        macdSignal: 0.3,
        ma20: 2030.0,
        ma50: 2020.0,
        ma100: 2010.0,
        ma200: 2000.0,
        atr: 8.0,
      );

      expect(gnResult, isNotNull);
      expect(gnResult.containsKey('SCALP'), isTrue);
      expect(gnResult.containsKey('SWING'), isTrue);

      // Scalping Engine V2
      final scalpSignal = await ScalpingEngineV2.analyze(
        currentPrice: 2050.0,
        candles: testCandles,
        rsi: 55.0,
        macd: 0.5,
        macdSignal: 0.3,
        atr: 5.0,
      );

      expect(scalpSignal, isNotNull);
      expect(scalpSignal.direction, isIn(['BUY', 'SELL', 'NO_TRADE']));

      // Swing Engine V2
      final swingSignal = await SwingEngineV2.analyze(
        currentPrice: 2050.0,
        candles: testCandles,
        rsi: 55.0,
        macd: 0.5,
        macdSignal: 0.3,
        atr: 10.0,
        ma20: 2030.0,
        ma50: 2020.0,
        ma100: 2010.0,
        ma200: 2000.0,
      );

      expect(swingSignal, isNotNull);
      expect(swingSignal.direction, isIn(['BUY', 'SELL', 'NO_TRADE']));

      // Quantum Scalping Engine
      final quantumSignal = await QuantumScalpingEngine.analyze(
        goldCandles: testCandles,
      );

      expect(quantumSignal, isNotNull);
      expect(quantumSignal.direction, isA<SignalDirection>());
    });

    test('should compare signal consistency across engines', () async {
      final scalpSignal = await ScalpingEngineV2.analyze(
        currentPrice: 2050.0,
        candles: testCandles,
        rsi: 55.0,
        macd: 0.5,
        macdSignal: 0.3,
        atr: 5.0,
      );

      final swingSignal = await SwingEngineV2.analyze(
        currentPrice: 2050.0,
        candles: testCandles,
        rsi: 55.0,
        macd: 0.5,
        macdSignal: 0.3,
        atr: 10.0,
        ma20: 2030.0,
        ma50: 2020.0,
        ma100: 2010.0,
        ma200: 2000.0,
      );

      // Both should generate valid signals (may differ in direction)
      expect(
          scalpSignal.isValid || scalpSignal.direction == 'NO_TRADE', isTrue);
      expect(
          swingSignal.isValid || swingSignal.direction == 'NO_TRADE', isTrue);
    });

    test('should handle different market conditions', () async {
      // Bullish market
      final bullishCandles = List.generate(200, (index) {
        final basePrice = 2000.0 + (index * 2.0);
        return Candle(
          time: DateTime.now().subtract(Duration(hours: 200 - index)),
          open: basePrice,
          high: basePrice + 5.0,
          low: basePrice - 1.0,
          close: basePrice + 4.0,
          volume: 2000.0,
        );
      });

      final bullishScalp = await ScalpingEngineV2.analyze(
        currentPrice: 2400.0,
        candles: bullishCandles,
        rsi: 65.0,
        macd: 1.5,
        macdSignal: 1.0,
        atr: 5.0,
      );

      expect(bullishScalp, isNotNull);

      // Bearish market
      final bearishCandles = List.generate(200, (index) {
        final basePrice = 2100.0 - (index * 2.0);
        return Candle(
          time: DateTime.now().subtract(Duration(hours: 200 - index)),
          open: basePrice,
          high: basePrice + 1.0,
          low: basePrice - 5.0,
          close: basePrice - 4.0,
          volume: 2000.0,
        );
      });

      final bearishScalp = await ScalpingEngineV2.analyze(
        currentPrice: 1700.0,
        candles: bearishCandles,
        rsi: 35.0,
        macd: -1.5,
        macdSignal: -1.0,
        atr: 5.0,
      );

      expect(bearishScalp, isNotNull);
    });

    test('should complete analysis within reasonable time', () async {
      final stopwatch = Stopwatch()..start();

      await ScalpingEngineV2.analyze(
        currentPrice: 2050.0,
        candles: testCandles,
        rsi: 55.0,
        macd: 0.5,
        macdSignal: 0.3,
        atr: 5.0,
      );

      await SwingEngineV2.analyze(
        currentPrice: 2050.0,
        candles: testCandles,
        rsi: 55.0,
        macd: 0.5,
        macdSignal: 0.3,
        atr: 10.0,
        ma20: 2030.0,
        ma50: 2020.0,
        ma100: 2010.0,
        ma200: 2000.0,
      );

      await QuantumScalpingEngine.analyze(
        goldCandles: testCandles,
      );

      stopwatch.stop();

      // All engines should complete within 5 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });
  });
}
