/// Analysis Strictness Levels
///
/// مستويات صرامة التحليل
/// يتحكم في مدى صعوبة شروط إنشاء التوصيات

enum AnalysisStrictness {
  /// صارم - شروط قوية جداً (قليل من التوصيات، عالية الجودة)
  strict,

  /// متوسط - شروط معتدلة (توازن بين الجودة والكمية)
  moderate,

  /// مرن - شروط مخففة (أكثر توصيات، قد تكون أقل جودة)
  flexible,
}

/// Settings for each strictness level
class StrictnessSettings {
  final double minZoneStrength;
  final double minConfluence;
  final double minRsiOversold;
  final double maxRsiOverbought;
  final double minLiquidityStrength;
  final int minPivotCount;

  const StrictnessSettings({
    required this.minZoneStrength,
    required this.minConfluence,
    required this.minRsiOversold,
    required this.maxRsiOverbought,
    required this.minLiquidityStrength,
    required this.minPivotCount,
  });

  /// Get settings for specific strictness level
  static StrictnessSettings forLevel(AnalysisStrictness level) {
    switch (level) {
      case AnalysisStrictness.strict:
        return const StrictnessSettings(
          minZoneStrength: 55, // قوة المنطقة - مخفف من 70
          minConfluence: 50, // التقارب - مخفف من 60
          minRsiOversold: 30, // RSI بيع مشبع - مخفف من 25
          maxRsiOverbought: 70, // RSI شراء مشبع - مخفف من 75
          minLiquidityStrength: 60, // قوة السيولة - مخفف من 75
          minPivotCount: 2, // عدد النقاط المحورية - مخفف من 3
        );

      case AnalysisStrictness.moderate:
        return const StrictnessSettings(
          minZoneStrength: 30, // متوسط - مخفف من 40
          minConfluence: 30, // مخفف من 40
          minRsiOversold: 40, // مخفف من 35
          maxRsiOverbought: 60, // مخفف من 65
          minLiquidityStrength: 40, // مخفف من 50
          minPivotCount: 1, // مخفف من 2
        );

      case AnalysisStrictness.flexible:
        return const StrictnessSettings(
          minZoneStrength: 20, // مرن جداً جداً - مخفف من 30
          minConfluence: 20, // مخفف من 30
          minRsiOversold: 45, // مخفف من 40 (أوسع جداً)
          maxRsiOverbought: 55, // مخفف من 60 (أوسع جداً)
          minLiquidityStrength: 30, // مخفف من 40
          minPivotCount: 1, // يبقى 1
        );
    }
  }
}

/// Extension to get display names
extension AnalysisStrictnessExtension on AnalysisStrictness {
  String get displayName {
    switch (this) {
      case AnalysisStrictness.strict:
        return 'صارم';
      case AnalysisStrictness.moderate:
        return 'متوسط';
      case AnalysisStrictness.flexible:
        return 'مرن';
    }
  }

  String get description {
    switch (this) {
      case AnalysisStrictness.strict:
        return 'شروط قوية - توصيات قليلة عالية الجودة';
      case AnalysisStrictness.moderate:
        return 'شروط معتدلة - توازن بين الجودة والكمية';
      case AnalysisStrictness.flexible:
        return 'شروط مخففة - توصيات أكثر';
    }
  }

  String get icon {
    switch (this) {
      case AnalysisStrictness.strict:
        return '🔒';
      case AnalysisStrictness.moderate:
        return '⚖️';
      case AnalysisStrictness.flexible:
        return '🔓';
    }
  }
}
