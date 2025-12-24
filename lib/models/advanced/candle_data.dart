import '../candle.dart';

/// CandleData - Adapter للتوافق مع نموذج Candle الموجود
class CandleData {
  final DateTime timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  CandleData({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  /// تحويل من Candle الموجود
  factory CandleData.fromCandle(Candle candle) {
    return CandleData(
      timestamp: candle.time,
      open: candle.open,
      high: candle.high,
      low: candle.low,
      close: candle.close,
      volume: candle.volume,
    );
  }

  /// تحويل إلى Candle
  Candle toCandle() {
    return Candle(
      time: timestamp,
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume,
    );
  }
}

