/// مستوى دعم أو مقاومة حقيقي من البيانات التاريخية
class SupportResistanceLevel {
  final double price;
  final String type; // 'SUPPORT' or 'RESISTANCE'
  final int strength; // عدد مرات الاختبار
  final DateTime lastTest; // آخر مرة تم اختبار المستوى
  final bool isStrong; // هل المستوى قوي (3+ touches)
  final String? note; // ملاحظات إضافية

  SupportResistanceLevel({
    required this.price,
    required this.type,
    required this.strength,
    required this.lastTest,
    required this.isStrong,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'price': price,
        'type': type,
        'strength': strength,
        'lastTest': lastTest.toIso8601String(),
        'isStrong': isStrong,
        'note': note,
      };

  factory SupportResistanceLevel.fromJson(Map<String, dynamic> json) =>
      SupportResistanceLevel(
        price: json['price'],
        type: json['type'],
        strength: json['strength'],
        lastTest: DateTime.parse(json['lastTest']),
        isStrong: json['isStrong'],
        note: json['note'],
      );
}

/// نموذج مستويات الدعم والمقاومة
class RealSupportResistance {
  final List<SupportResistanceLevel> supports;
  final List<SupportResistanceLevel> resistances;
  final DateTime extractedAt;
  final int totalPivotsAnalyzed;

  RealSupportResistance({
    required this.supports,
    required this.resistances,
    required this.extractedAt,
    required this.totalPivotsAnalyzed,
  });

  /// الحصول على أقرب دعم
  SupportResistanceLevel? getClosestSupport(double currentPrice) {
    final below = supports.where((s) => s.price < currentPrice).toList();
    if (below.isEmpty) return null;

    below.sort((a, b) => b.price.compareTo(a.price)); // الأقرب أولاً
    return below.first;
  }

  /// الحصول على أقرب مقاومة
  SupportResistanceLevel? getClosestResistance(double currentPrice) {
    final above = resistances.where((r) => r.price > currentPrice).toList();
    if (above.isEmpty) return null;

    above.sort((a, b) => a.price.compareTo(b.price)); // الأقرب أولاً
    return above.first;
  }

  /// الحصول على أقوى المستويات فقط
  List<SupportResistanceLevel> getStrongLevels() {
    return [...supports, ...resistances].where((l) => l.isStrong).toList()
      ..sort((a, b) => b.strength.compareTo(a.strength));
  }

  Map<String, dynamic> toJson() => {
        'supports': supports.map((s) => s.toJson()).toList(),
        'resistances': resistances.map((r) => r.toJson()).toList(),
        'extractedAt': extractedAt.toIso8601String(),
        'totalPivotsAnalyzed': totalPivotsAnalyzed,
      };
}
