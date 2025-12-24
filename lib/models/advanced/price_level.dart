/// PriceLevel - مستوى دعم أو مقاومة
class PriceLevel {
  final double price;
  final String label;
  final double strength; // 0-1

  PriceLevel(this.price, this.label, this.strength);

  @override
  String toString() => '$label: \$${price.toStringAsFixed(2)} (${(strength * 100).toStringAsFixed(0)}%)';
}

/// SupportResistanceLevels - مستويات الدعم والمقاومة
class SupportResistanceLevels {
  final List<PriceLevel> support;
  final List<PriceLevel> resistance;

  SupportResistanceLevels({
    required this.support,
    required this.resistance,
  });

  factory SupportResistanceLevels.empty() {
    return SupportResistanceLevels(
      support: [],
      resistance: [],
    );
  }
}

/// PivotPointLevels - مستويات نقاط البيفوت
class PivotPointLevels {
  final PriceLevel pivot;
  final List<PriceLevel> support;
  final List<PriceLevel> resistance;

  PivotPointLevels({
    required this.pivot,
    required this.support,
    required this.resistance,
  });
}

/// PsychologicalLevels - المستويات النفسية
class PsychologicalLevels {
  final List<PriceLevel> support;
  final List<PriceLevel> resistance;

  PsychologicalLevels({
    required this.support,
    required this.resistance,
  });
}

/// HistoricalLevels - المستويات التاريخية
class HistoricalLevels {
  final List<PriceLevel> support;
  final List<PriceLevel> resistance;

  HistoricalLevels({
    required this.support,
    required this.resistance,
  });
}

