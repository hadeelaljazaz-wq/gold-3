/// AlertType - نوع التنبيه
enum AlertType {
  priceAbove,
  priceBelow,
  priceBreakAbove,
  priceBreakBelow,
}

/// AlertPriority - أولوية التنبيه
enum AlertPriority {
  low,
  medium,
  high,
  critical,
}

/// PriceAlert - تنبيه سعر
class PriceAlert {
  final double price;
  final AlertType type;
  final String label;
  final DateTime createdAt;
  bool triggered = false;

  PriceAlert({
    required this.price,
    required this.type,
    required this.label,
    required this.createdAt,
  });
}

/// Alert - تنبيه تم إطلاقه
class Alert {
  final String title;
  final String message;
  final AlertType type;
  final DateTime timestamp;
  final AlertPriority priority;

  Alert({
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.priority,
  });
}

