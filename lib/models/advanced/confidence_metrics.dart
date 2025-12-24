/// ConfidenceMetrics - مقاييس الثقة (5 عوامل)
class ConfidenceMetrics {
  final double overall; // الثقة الإجمالية (0-1)
  final double modelAccuracy; // دقة النموذج التاريخية
  final double marketStability; // استقرار السوق
  final double dataQuality; // جودة البيانات
  final double indicatorConsensus; // توافق المؤشرات
  final double newsImpact; // تأثير الأخبار

  ConfidenceMetrics({
    required this.overall,
    required this.modelAccuracy,
    required this.marketStability,
    required this.dataQuality,
    required this.indicatorConsensus,
    required this.newsImpact,
  });

  factory ConfidenceMetrics.empty() {
    return ConfidenceMetrics(
      overall: 0.5,
      modelAccuracy: 0.5,
      marketStability: 0.5,
      dataQuality: 0.5,
      indicatorConsensus: 0.5,
      newsImpact: 0.0,
    );
  }

  /// تحويل إلى نص وصفي
  String get description {
    if (overall > 0.8) return 'ثقة عالية جداً';
    if (overall > 0.7) return 'ثقة عالية';
    if (overall > 0.6) return 'ثقة جيدة';
    if (overall > 0.5) return 'ثقة متوسطة';
    return 'ثقة منخفضة';
  }
}

