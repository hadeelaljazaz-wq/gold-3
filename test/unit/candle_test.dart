import 'package:flutter_test/flutter_test.dart';
import 'package:golden_nightmare_pro/models/candle.dart';

void main() {
  group('Candle Model Tests', () {
    test('should create candle with valid data', () {
      final candle = Candle(
        time: DateTime.now(),
        open: 2000.0,
        high: 2010.0,
        low: 1990.0,
        close: 2005.0,
        volume: 1000.0,
      );

      expect(candle.open, equals(2000.0));
      expect(candle.high, equals(2010.0));
      expect(candle.low, equals(1990.0));
      expect(candle.close, equals(2005.0));
      expect(candle.volume, equals(1000.0));
    });

    test('should detect bullish candle correctly', () {
      final bullishCandle = Candle(
        time: DateTime.now(),
        open: 2000.0,
        high: 2010.0,
        low: 1995.0,
        close: 2005.0, // Close > Open
        volume: 1000.0,
      );

      expect(bullishCandle.isBullish, isTrue);
      expect(bullishCandle.isBearish, isFalse);
    });

    test('should detect bearish candle correctly', () {
      final bearishCandle = Candle(
        time: DateTime.now(),
        open: 2000.0,
        high: 2005.0,
        low: 1990.0,
        close: 1995.0, // Close < Open
        volume: 1000.0,
      );

      expect(bearishCandle.isBearish, isTrue);
      expect(bearishCandle.isBullish, isFalse);
    });

    test('should calculate body size correctly', () {
      final candle = Candle(
        time: DateTime.now(),
        open: 2000.0,
        high: 2010.0,
        low: 1990.0,
        close: 2005.0,
        volume: 1000.0,
      );

      expect(candle.bodySize, equals(5.0)); // |2005 - 2000|
    });

    test('should calculate wick sizes correctly', () {
      final candle = Candle(
        time: DateTime.now(),
        open: 2000.0,
        high: 2010.0,
        low: 1990.0,
        close: 2005.0, // Bullish
        volume: 1000.0,
      );

      expect(candle.upperWick, equals(5.0)); // 2010 - 2005
      expect(candle.lowerWick, equals(5.0)); // 2000 - 1990
    });

    test('should calculate range correctly', () {
      final candle = Candle(
        time: DateTime.now(),
        open: 2000.0,
        high: 2010.0,
        low: 1990.0,
        close: 2005.0,
        volume: 1000.0,
      );

      expect(candle.range, equals(20.0)); // 2010 - 1990
    });

    test('should serialize to JSON correctly', () {
      final candle = Candle(
        time: DateTime(2024, 1, 1, 12, 0, 0),
        open: 2000.0,
        high: 2010.0,
        low: 1990.0,
        close: 2005.0,
        volume: 1000.0,
      );

      final json = candle.toJson();

      expect(json['open'], equals(2000.0));
      expect(json['high'], equals(2010.0));
      expect(json['low'], equals(1990.0));
      expect(json['close'], equals(2005.0));
      expect(json['volume'], equals(1000.0));
      expect(json['timestamp'], isA<String>());
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'timestamp': '2024-01-01T12:00:00.000Z',
        'open': 2000.0,
        'high': 2010.0,
        'low': 1990.0,
        'close': 2005.0,
        'volume': 1000.0,
      };

      final candle = Candle.fromJson(json);

      expect(candle.open, equals(2000.0));
      expect(candle.high, equals(2010.0));
      expect(candle.low, equals(1990.0));
      expect(candle.close, equals(2005.0));
      expect(candle.volume, equals(1000.0));
    });

    test('should deserialize from CSV correctly', () {
      final csvRow = [
        '2024-01-01T12:00:00.000Z',
        '2000.0',
        '2010.0',
        '1990.0',
        '2005.0',
        '1000.0',
      ];

      final candle = Candle.fromCsv(csvRow);

      expect(candle.open, equals(2000.0));
      expect(candle.high, equals(2010.0));
      expect(candle.low, equals(1990.0));
      expect(candle.close, equals(2005.0));
      expect(candle.volume, equals(1000.0));
    });

    test('should handle zero body size', () {
      final candle = Candle(
        time: DateTime.now(),
        open: 2000.0,
        high: 2010.0,
        low: 1990.0,
        close: 2000.0, // Close == Open
        volume: 1000.0,
      );

      expect(candle.bodySize, equals(0.0));
      expect(candle.isBullish, isFalse);
      expect(candle.isBearish, isFalse);
    });

    test('should calculate wicks for bearish candle', () {
      final candle = Candle(
        time: DateTime.now(),
        open: 2000.0,
        high: 2010.0,
        low: 1990.0,
        close: 1995.0, // Bearish
        volume: 1000.0,
      );

      expect(candle.upperWick, equals(15.0)); // 2010 - 2000
      expect(candle.lowerWick, equals(5.0)); // 1995 - 1990
    });
  });
}
