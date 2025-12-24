import 'confidence_metrics.dart';
import 'price_level.dart';
import 'trend_analysis.dart';
import 'trading_recommendation.dart';
import 'market_context.dart';

/// AdvancedPredictionResult - نتيجة التنبؤ المتقدم الكاملة
class AdvancedPredictionResult {
  final List<PricePoint> predictions;
  final ConfidenceMetrics confidence;
  final List<PriceLevel> supportLevels;
  final List<PriceLevel> resistanceLevels;
  final TrendAnalysis trend;
  final List<TradingRecommendation> recommendations;
  final MarketContext marketContext;
  final DateTime timestamp;
  final String modelVersion;

  PredictionOutcome? actualOutcome; // يتم ملؤه لاحقاً للتحقق

  AdvancedPredictionResult({
    required this.predictions,
    required this.confidence,
    required this.supportLevels,
    required this.resistanceLevels,
    required this.trend,
    required this.recommendations,
    required this.marketContext,
    required this.timestamp,
    required this.modelVersion,
    this.actualOutcome,
  });

  /// أفضل توصية
  TradingRecommendation? get topRecommendation {
    if (recommendations.isEmpty) return null;
    return recommendations.first;
  }

  /// متوسط السعر المتوقع
  double get averagePredictedPrice {
    if (predictions.isEmpty) return 0.0;
    return predictions.map((p) => p.price).reduce((a, b) => a + b) / predictions.length;
  }
}

/// PredictionOutcome - النتيجة الفعلية (للتحقق من الدقة)
class PredictionOutcome {
  final bool direction; // true = up, false = down
  final double actualPrice;
  final double accuracy;

  PredictionOutcome({
    required this.direction,
    required this.actualPrice,
    required this.accuracy,
  });
}

