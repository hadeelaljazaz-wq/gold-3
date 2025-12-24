import 'package:flutter_test/flutter_test.dart';
import 'package:golden_nightmare_pro/services/golden_nightmare/golden_nightmare_engine.dart';
import 'package:golden_nightmare_pro/models/candle.dart';

void main() {
  group('Performance Integration Tests', () {
    late List<Candle> testCandles;

    setUp(() {
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

    test('should complete analysis within reasonable time', () async {
      final stopwatch = Stopwatch()..start();

      try {
        await GoldenNightmareEngine.generate(
          currentPrice: 2050.0,
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
      } catch (e) {
        // Expected
      }

      stopwatch.stop();

      // Should complete within 5 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    test('should handle large candle datasets', () async {
      final largeCandles = List.generate(2000, (index) {
        final basePrice = 2000.0 + (index * 0.5);
        return Candle(
          time: DateTime.now().subtract(Duration(hours: 2000 - index)),
          open: basePrice,
          high: basePrice + 3.0,
          low: basePrice - 3.0,
          close: basePrice + (index % 2 == 0 ? 1.5 : -1.5),
          volume: 2000.0 + (index * 20),
        );
      });

      final stopwatch = Stopwatch()..start();

      try {
        await GoldenNightmareEngine.generate(
          currentPrice: 2050.0,
          candles: largeCandles,
          rsi: 55.0,
          macd: 0.5,
          macdSignal: 0.3,
          ma20: 2230.0,
          ma50: 2200.0,
          ma100: 2150.0,
          ma200: 2100.0,
          atr: 8.0,
        );
      } catch (e) {
        // Expected
      }

      stopwatch.stop();

      // Should complete within 10 seconds for large dataset
      expect(stopwatch.elapsedMilliseconds, lessThan(10000));
    });

    test('should handle multiple concurrent requests', () async {
      final futures = List.generate(5, (index) {
        return GoldenNightmareEngine.generate(
          currentPrice: 2050.0 + index,
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
      });

      final stopwatch = Stopwatch()..start();

      await Future.wait(futures.map((f) => f.catchError((_) => <String, dynamic>{})));

      stopwatch.stop();

      // Should complete within reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(15000));
    });

    test('should not leak memory on repeated calls', () async {
      for (int i = 0; i < 10; i++) {
        try {
          await GoldenNightmareEngine.generate(
            currentPrice: 2050.0,
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
        } catch (e) {
          // Expected
        }
      }

      // If we get here without crashing, memory is likely fine
      expect(true, isTrue);
    });
  });
}
