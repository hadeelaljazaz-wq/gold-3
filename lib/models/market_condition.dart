/// Market Condition Model
///
/// Unified market condition enum used across all services
/// to avoid conflicts between different implementations.
library;

/// Market condition types
enum MarketCondition {
  strongTrend,
  ranging,
  volatile,
  consolidation,
  uncertain;

  /// Get Arabic name
  String get nameAr {
    switch (this) {
      case MarketCondition.strongTrend:
        return '🎯 اتجاه قوي';
      case MarketCondition.ranging:
        return '↔️ سوق عرضي';
      case MarketCondition.volatile:
        return '⚡ تقلب عالي';
      case MarketCondition.consolidation:
        return '🔄 تماسك';
      case MarketCondition.uncertain:
        return '❓ غير واضح';
    }
  }

  /// Get English name
  String get nameEn {
    switch (this) {
      case MarketCondition.strongTrend:
        return 'Strong Trend';
      case MarketCondition.ranging:
        return 'Ranging';
      case MarketCondition.volatile:
        return 'Volatile';
      case MarketCondition.consolidation:
        return 'Consolidation';
      case MarketCondition.uncertain:
        return 'Uncertain';
    }
  }
}
















