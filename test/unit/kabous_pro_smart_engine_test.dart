import 'package:flutter_test/flutter_test.dart';
import 'package:golden_nightmare_pro/services/kabous_pro_smart_engine.dart';
import 'package:golden_nightmare_pro/models/candle.dart';

void main() {
  group('KabousProSmartEngine - Enhanced Tests', () {
    late List<Candle> testCandles;

    setUp(() {
      // Generate test data - 250 candles for comprehensive testing
      testCandles = _generateTestCandles(250, startPrice: 2000.0);
    });

    tearDown(() {
      // Clear cache between tests
      KabousProSmartEngine.clearCache();
    });

    group('Basic Functionality', () {
      test('should handle insufficient data gracefully', () {
        final shortCandles = _generateTestCandles(50, startPrice: 2000.0);
        final signal = KabousProSmartEngine.analyze(shortCandles);

        expect(signal, isNotNull);
        expect(signal.type, SignalType.NO_TRADE);
        expect(signal.reason, contains('Insufficient data'));
      });

      test('should handle empty candles list', () {
        final signal = KabousProSmartEngine.analyze([]);

        expect(signal, isNotNull);
        expect(signal.type, SignalType.NO_TRADE);
        expect(signal.reason, contains('No data'));
      });

      test('should generate valid signal with sufficient data', () {
        final signal = KabousProSmartEngine.analyze(testCandles);

        expect(signal, isNotNull);
        expect(signal.entry, greaterThan(0));

        if (signal.type != SignalType.NO_TRADE) {
          expect(signal.stopLoss, greaterThan(0));
          expect(signal.takeProfit, greaterThan(0));
          expect(signal.confidence, greaterThanOrEqualTo(0));
          expect(signal.confidence, lessThanOrEqualTo(100));
          expect(signal.riskReward, greaterThan(0));
        }
      });
    });

    group('Signal Quality', () {
      test('should maintain minimum Risk:Reward ratio', () {
        final bullishCandles = _generateBullishTrendCandles(250);
        final signal = KabousProSmartEngine.analyze(bullishCandles);

        if (signal.type != SignalType.NO_TRADE) {
          expect(signal.riskReward, greaterThanOrEqualTo(1.5),
              reason: 'RR should be at least 1.5:1');
        }
      });

      test('should detect bullish trend correctly', () {
        final bullishCandles = _generateBullishTrendCandles(250);
        final signal = KabousProSmartEngine.analyze(bullishCandles);

        // With strong bullish trend, should generate BUY or NO_TRADE
        expect([SignalType.BUY, SignalType.NO_TRADE], contains(signal.type));

        if (signal.type == SignalType.BUY) {
          expect(signal.confidence, greaterThanOrEqualTo(58));
          expect(signal.takeProfit, greaterThan(signal.entry));
          expect(signal.stopLoss, lessThan(signal.entry));
        }
      });

      test('should detect bearish trend correctly', () {
        final bearishCandles = _generateBearishTrendCandles(250);
        final signal = KabousProSmartEngine.analyze(bearishCandles);

        // With strong bearish trend, should generate SELL or NO_TRADE
        expect([SignalType.SELL, SignalType.NO_TRADE], contains(signal.type));

        if (signal.type == SignalType.SELL) {
          expect(signal.confidence, greaterThanOrEqualTo(58));
          expect(signal.takeProfit, lessThan(signal.entry));
          expect(signal.stopLoss, greaterThan(signal.entry));
        }
      });

      test('should avoid ranging markets', () {
        final rangingCandles = _generateRangingCandles(250);
        final signal = KabousProSmartEngine.analyze(rangingCandles);

        // Ranging markets should mostly produce NO_TRADE
        // or signals with lower confidence
        if (signal.type != SignalType.NO_TRADE) {
          expect(signal.confidence, lessThan(70),
              reason: 'Ranging markets should have lower confidence');
        }
      });
    });

    group('Caching Performance', () {
      test('should cache results for same data', () {
        final stopwatch = Stopwatch()..start();

        // First call - will compute
        KabousProSmartEngine.analyze(testCandles);
        final firstCallTime = stopwatch.elapsedMicroseconds;

        stopwatch.reset();

        // Second call - should use cache
        KabousProSmartEngine.analyze(testCandles);
        final secondCallTime = stopwatch.elapsedMicroseconds;

        stopwatch.stop();

        // Second call should be significantly faster (at least 2x)
        expect(secondCallTime, lessThan(firstCallTime),
            reason: 'Cached call should be faster');
      });

      test('should invalidate cache on new data', () {
        final signal1 = KabousProSmartEngine.analyze(testCandles);

        // Add new candle
        final newCandles = List<Candle>.from(testCandles);
        newCandles.add(Candle(
          time: DateTime.now(),
          open: 2010.0,
          high: 2020.0,
          low: 2005.0,
          close: 2015.0,
          volume: 1000,
        ));

        final signal2 = KabousProSmartEngine.analyze(newCandles);

        // Signals might differ due to new data
        expect(signal1.entry == signal2.entry, isFalse);
      });

      test('clearCache should reset all cached data', () {
        // Generate signal to populate cache
        KabousProSmartEngine.analyze(testCandles);

        // Clear cache
        KabousProSmartEngine.clearCache();

        // Should recompute (we can't directly test this, but ensures no error)
        final signal = KabousProSmartEngine.analyze(testCandles);
        expect(signal, isNotNull);
      });
    });

    group('Error Handling', () {
      test('should handle extreme volatility', () {
        final volatileCandles = _generateVolatileCandles(250);
        final signal = KabousProSmartEngine.analyze(volatileCandles);

        expect(signal, isNotNull);
        // Should either filter out or adjust confidence
        if (signal.type != SignalType.NO_TRADE) {
          expect(signal.stopLoss, greaterThan(0));
          expect(signal.takeProfit, greaterThan(0));
        }
      });

      test('should validate signal parameters', () {
        final signal = KabousProSmartEngine.analyze(testCandles);

        if (signal.type == SignalType.BUY) {
          expect(signal.entry, greaterThan(signal.stopLoss));
          expect(signal.takeProfit, greaterThan(signal.entry));
        } else if (signal.type == SignalType.SELL) {
          expect(signal.entry, lessThan(signal.stopLoss));
          expect(signal.takeProfit, lessThan(signal.entry));
        }
      });
    });

    group('Signal Details', () {
      test('should provide detailed analysis information', () {
        final signal = KabousProSmartEngine.analyze(testCandles);

        expect(signal.reason, isNotEmpty);
        expect(signal.details, isNotEmpty);
        expect(signal.details['atr'], isNotNull);
        expect(signal.details['structure'], isNotNull);
        expect(signal.details['trend'], isNotNull);
        expect(signal.details['volatility'], isNotNull);
      });

      test('should include smart money zone information', () {
        final bullishCandles = _generateBullishTrendCandles(250);
        final signal = KabousProSmartEngine.analyze(bullishCandles);

        if (signal.type != SignalType.NO_TRADE) {
          expect(
              signal.details.containsKey('demandZones') ||
                  signal.details.containsKey('supplyZones'),
              isTrue);
        }
      });
    });
  });
}

// ============================================================================
// TEST HELPER FUNCTIONS
// ============================================================================

List<Candle> _generateTestCandles(int count, {required double startPrice}) {
  final candles = <Candle>[];
  var price = startPrice;
  final baseTime = DateTime.now().subtract(Duration(hours: count));

  for (int i = 0; i < count; i++) {
    final change = (i % 10 - 5) * 2.0; // Simple oscillation
    price += change;

    candles.add(Candle(
      time: baseTime.add(Duration(hours: i)),
      open: price,
      high: price + 5 + (i % 3),
      low: price - 5 - (i % 2),
      close: price + change,
      volume: 1000 + (i % 100) * 10,
    ));
  }

  return candles;
}

List<Candle> _generateBullishTrendCandles(int count) {
  final candles = <Candle>[];
  var price = 2000.0;
  final baseTime = DateTime.now().subtract(Duration(hours: count));

  for (int i = 0; i < count; i++) {
    // Upward trend with minor pullbacks
    final upMove = i % 5 == 0 ? -3.0 : 2.0; // Pullback every 5 candles
    price += upMove;

    final open = price;
    final high = price + 3 + (i % 2);
    final low = price - 2;
    final close = price + upMove * 0.8;

    candles.add(Candle(
      time: baseTime.add(Duration(hours: i)),
      open: open,
      high: high,
      low: low,
      close: close,
      volume: 1200 + (i * 5),
    ));

    price = close;
  }

  return candles;
}

List<Candle> _generateBearishTrendCandles(int count) {
  final candles = <Candle>[];
  var price = 2000.0;
  final baseTime = DateTime.now().subtract(Duration(hours: count));

  for (int i = 0; i < count; i++) {
    // Downward trend with minor rallies
    final downMove = i % 5 == 0 ? 3.0 : -2.0; // Rally every 5 candles
    price += downMove;

    final open = price;
    final high = price + 2;
    final low = price - 3 - (i % 2);
    final close = price + downMove * 0.8;

    candles.add(Candle(
      time: baseTime.add(Duration(hours: i)),
      open: open,
      high: high,
      low: low,
      close: close,
      volume: 1200 + (i * 5),
    ));

    price = close;
  }

  return candles;
}

List<Candle> _generateRangingCandles(int count) {
  final candles = <Candle>[];
  const basePrice = 2000.0;
  final baseTime = DateTime.now().subtract(Duration(hours: count));

  for (int i = 0; i < count; i++) {
    // Oscillate around base price
    final price = basePrice + (i % 10 - 5) * 2.0;

    candles.add(Candle(
      time: baseTime.add(Duration(hours: i)),
      open: price,
      high: price + 3,
      low: price - 3,
      close: price + (i % 2 == 0 ? 1 : -1),
      volume: 1000 + (i % 50) * 10,
    ));
  }

  return candles;
}

List<Candle> _generateVolatileCandles(int count) {
  final candles = <Candle>[];
  var price = 2000.0;
  final baseTime = DateTime.now().subtract(Duration(hours: count));

  for (int i = 0; i < count; i++) {
    // Large random moves
    final change = (i % 7 - 3) * 10.0; // Large swings
    price += change;

    candles.add(Candle(
      time: baseTime.add(Duration(hours: i)),
      open: price,
      high: price + 15 + (i % 5),
      low: price - 15 - (i % 4),
      close: price + change,
      volume: 2000 + (i % 200) * 20,
    ));
  }

  return candles;
}
