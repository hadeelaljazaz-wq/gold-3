/// 📊 Candle Data Model
/// نموذج بيانات الشموع اليابانية (OHLCV)
class CandleData {
  final DateTime timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final double? volume; // Optional - قد لا يكون متوفراً لجميع الأصول

  const CandleData({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.volume,
  });

  /// حساب التغير من Open إلى Close
  double get change => close - open;

  /// حساب نسبة التغير
  double get changePercent => ((close - open) / open) * 100;

  /// حساب نطاق الشمعة (Range)
  double get range => high - low;

  /// حساب نسبة الجسم إلى النطاق (Body Ratio)
  double get bodyRatio => range > 0 ? (change.abs() / range) : 0;

  /// هل الشمعة صاعدة؟
  bool get isBullish => close > open;

  /// هل الشمعة هابطة؟
  bool get isBearish => close < open;

  /// تحويل من JSON
  factory CandleData.fromJson(Map<String, dynamic> json) {
    return CandleData(
      timestamp: json['timestamp'] is DateTime
          ? json['timestamp']
          : DateTime.parse(json['timestamp']),
      open: _parseDouble(json['open']),
      high: _parseDouble(json['high']),
      low: _parseDouble(json['low']),
      close: _parseDouble(json['close']),
      volume: json['volume'] != null ? _parseDouble(json['volume']) : null,
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
    };
  }

  /// نسخ مع تعديل
  CandleData copyWith({
    DateTime? timestamp,
    double? open,
    double? high,
    double? low,
    double? close,
    double? volume,
  }) {
    return CandleData(
      timestamp: timestamp ?? this.timestamp,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      volume: volume ?? this.volume,
    );
  }

  @override
  String toString() {
    return 'CandleData(timestamp: $timestamp, O: $open, H: $high, L: $low, C: $close, V: $volume)';
  }

  /// دالة مساعدة لتحويل String/int/double إلى double
  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.parse(value);
    throw ArgumentError('Cannot parse $value to double');
  }
}

/// 📈 Market Data Response
/// استجابة بيانات السوق مع metadata
class MarketDataResponse {
  final String symbol;
  final String interval;
  final List<CandleData> candles;
  final DateTime fetchedAt;

  const MarketDataResponse({
    required this.symbol,
    required this.interval,
    required this.candles,
    required this.fetchedAt,
  });

  /// الحصول على آخر شمعة
  CandleData? get latestCandle => candles.isNotEmpty ? candles.first : null;

  /// الحصول على أقدم شمعة
  CandleData? get oldestCandle => candles.isNotEmpty ? candles.last : null;

  /// حساب متوسط السعر
  double get averageClose {
    if (candles.isEmpty) return 0;
    return candles.map((c) => c.close).reduce((a, b) => a + b) / candles.length;
  }

  /// حساب أعلى سعر
  double get highestPrice {
    if (candles.isEmpty) return 0;
    return candles.map((c) => c.high).reduce((a, b) => a > b ? a : b);
  }

  /// حساب أقل سعر
  double get lowestPrice {
    if (candles.isEmpty) return 0;
    return candles.map((c) => c.low).reduce((a, b) => a < b ? a : b);
  }

  @override
  String toString() {
    return 'MarketDataResponse(symbol: $symbol, interval: $interval, candles: ${candles.length}, latest: ${latestCandle?.close})';
  }
}
