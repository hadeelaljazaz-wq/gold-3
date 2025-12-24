import '../core/utils/type_converter.dart';

/// Zone model for support/resistance levels
class Zone {
  final double price;
  final String type; // 'SUPPORT', 'RESISTANCE'
  final double strength;
  final int touches;
  final DateTime startTime;
  final DateTime lastTouchTime;
  final bool isActive;

  Zone({
    required this.price,
    required this.type,
    required this.strength,
    required this.touches,
    required this.startTime,
    required this.lastTouchTime,
    this.isActive = true,
  });

  /// Create from JSON
  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      price: TypeConverter.safeToDouble(json['price']) ?? 0.0,
      type: json['type'] as String,
      strength: TypeConverter.safeToDouble(json['strength']) ?? 0.0,
      touches: json['touches'] as int,
      startTime: DateTime.parse(json['startTime'] as String),
      lastTouchTime: DateTime.parse(json['lastTouchTime'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'type': type,
      'strength': strength,
      'touches': touches,
      'startTime': startTime.toIso8601String(),
      'lastTouchTime': lastTouchTime.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Copy with modifications
  Zone copyWith({
    double? price,
    String? type,
    double? strength,
    int? touches,
    DateTime? startTime,
    DateTime? lastTouchTime,
    bool? isActive,
  }) {
    return Zone(
      price: price ?? this.price,
      type: type ?? this.type,
      strength: strength ?? this.strength,
      touches: touches ?? this.touches,
      startTime: startTime ?? this.startTime,
      lastTouchTime: lastTouchTime ?? this.lastTouchTime,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Zone(price: $price, type: $type, strength: $strength, touches: $touches)';
  }
}

