import 'trading_recommendation.dart';

/// TrendType - نوع الاتجاه
enum TrendType {
  strongBullish,
  bullish,
  sideways,
  bearish,
  strongBearish,
}

/// TrendAnalysis - تحليل الاتجاه
class TrendAnalysis {
  final TrendType type;
  final double strength; // 0-1
  final double change; // نسبة مئوية
  final List<EntryPoint> entryPoints;
  final List<ExitPoint> exitPoints;
  final int duration; // ساعات

  TrendAnalysis({
    required this.type,
    required this.strength,
    required this.change,
    required this.entryPoints,
    required this.exitPoints,
    required this.duration,
  });

  /// نص الاتجاه
  String get trendText {
    switch (type) {
      case TrendType.strongBullish:
        return 'صاعد قوي 🚀';
      case TrendType.bullish:
        return 'صاعد 📈';
      case TrendType.sideways:
        return 'عرضي ↔️';
      case TrendType.bearish:
        return 'هابط 📉';
      case TrendType.strongBearish:
        return 'هابط قوي ⚠️';
    }
  }
}

/// PricePoint - نقطة سعر في التنبؤ
class PricePoint {
  final DateTime timestamp;
  final double price;
  final int hourOffset;

  PricePoint({
    required this.timestamp,
    required this.price,
    required this.hourOffset,
  });
}

