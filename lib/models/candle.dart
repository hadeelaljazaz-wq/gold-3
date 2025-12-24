import 'package:flutter/foundation.dart';
import '../core/utils/type_converter.dart';

/// Candle Model - OHLCV Data
@immutable
class Candle {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  Candle({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  // From JSON
  factory Candle.fromJson(Map<String, dynamic> json) {
    return Candle(
      time: DateTime.parse(json['timestamp'] ?? json['time']),
      open: TypeConverter.safeToDouble(json['open']) ?? 0.0,
      high: TypeConverter.safeToDouble(json['high']) ?? 0.0,
      low: TypeConverter.safeToDouble(json['low']) ?? 0.0,
      close: TypeConverter.safeToDouble(json['close']) ?? 0.0,
      volume: TypeConverter.safeToDouble(json['volume']) ?? 0.0,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'timestamp': time.toIso8601String(),
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
    };
  }

  // From CSV row
  factory Candle.fromCsv(List<String> row) {
    return Candle(
      time: DateTime.parse(row[0]),
      open: double.parse(row[1]),
      high: double.parse(row[2]),
      low: double.parse(row[3]),
      close: double.parse(row[4]),
      volume: double.parse(row[5]),
    );
  }

  // Helper: Is Bullish?
  bool get isBullish => close > open;

  // Helper: Is Bearish?
  bool get isBearish => close < open;

  // Helper: Body size
  double get bodySize => (close - open).abs();

  // Helper: Wick sizes
  double get upperWick => high - (isBullish ? close : open);
  double get lowerWick => (isBearish ? close : open) - low;

  // Helper: Range
  double get range => high - low;

  @override
  String toString() {
    return 'Candle(time: $time, O: $open, H: $high, L: $low, C: $close, V: $volume)';
  }
}
