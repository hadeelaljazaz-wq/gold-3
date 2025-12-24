import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/candle.dart';
import '../../../models/advanced/prediction_result.dart';
import '../../../models/advanced/confidence_metrics.dart';
import '../../../models/advanced/price_level.dart';
import '../../../models/advanced/trading_recommendation.dart';
import '../../../models/advanced/news_models.dart';
import '../../../models/advanced/trend_analysis.dart';
import '../../../services/advanced_analysis/advanced_analysis_service.dart';

/// GoldAnalyticsDashboard - لوحة التحليلات المتقدمة
class GoldAnalyticsDashboard extends StatefulWidget {
  final double currentPrice;
  final List<Candle> candles;
  final Map<String, double> indicators;

  const GoldAnalyticsDashboard({
    super.key,
    required this.currentPrice,
    required this.candles,
    required this.indicators,
  });

  @override
  State<GoldAnalyticsDashboard> createState() => _GoldAnalyticsDashboardState();
}

class _GoldAnalyticsDashboardState extends State<GoldAnalyticsDashboard> {
  AdvancedPredictionResult? prediction;
  List<GoldNews> news = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      print('🔄 Loading advanced analytics...');

      final service = AdvancedAnalysisService();
      final analysis = await service.getCompleteAnalysis(
        currentPrice: widget.currentPrice,
        candles: widget.candles,
        indicators: widget.indicators,
      );

      print('✅ Analytics loaded successfully');
      print('  - Predictions: ${analysis.advancedPrediction.predictions.length}');
      print('  - News: ${analysis.news.length}');
      print('  - Confidence: ${(analysis.advancedPrediction.confidence.overall * 100).toStringAsFixed(1)}%');

      setState(() {
        prediction = analysis.advancedPrediction;
        news = analysis.news;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Failed to load analytics: $e');
      setState(() => isLoading = false);
      
      // عرض رسالة خطأ للمستخدم
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحميل التحليلات: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title:             Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تحليلات متقدمة',
                  style: GoogleFonts.cairo(
                    color: AppColors.goldMain,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'بيانات حقيقية 100%',
                  style: GoogleFonts.cairo(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
        backgroundColor: AppColors.bgSecondary,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (prediction != null) ...[
                    _buildConfidenceCard(prediction!.confidence),
                    const SizedBox(height: 16),
                    _buildPredictionChart(prediction!.predictions),
                    const SizedBox(height: 16),
                    _buildSupportResistanceCard(
                      prediction!.supportLevels,
                      prediction!.resistanceLevels,
                    ),
                    const SizedBox(height: 16),
                    _buildRecommendationsCard(prediction!.recommendations),
                    const SizedBox(height: 16),
                    _buildTrendCard(prediction!.trend),
                    const SizedBox(height: 16),
                  ],
                  _buildNewsWidget(news),
                  const SizedBox(height: 16),
                  if (prediction != null)
                    _buildPerformanceMetrics(prediction!.confidence),
                ],
              ),
            ),
    );
  }

  Widget _buildConfidenceCard(ConfidenceMetrics confidence) {
    return Card(
      elevation: 4,
      color: AppColors.bgSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'مستوى الثقة',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                CircleAvatar(
                  radius: 35,
                  backgroundColor: _getConfidenceColor(confidence.overall),
                  child: Text(
                    '${(confidence.overall * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildConfidenceBar('دقة النموذج', confidence.modelAccuracy),
            _buildConfidenceBar('استقرار السوق', confidence.marketStability),
            _buildConfidenceBar('جودة البيانات', confidence.dataQuality),
            _buildConfidenceBar('توافق المؤشرات', confidence.indicatorConsensus),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceBar(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(value * 100).toStringAsFixed(0)}%',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(_getConfidenceColor(value)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionChart(List<PricePoint> predictions) {
    // حساب النطاق الفعلي للأسعار
    final prices = predictions.map((p) => p.price).toList();
    final minPrice = prices.reduce(min);
    final maxPrice = prices.reduce(max);
    final priceRange = maxPrice - minPrice;
    final padding = priceRange * 0.1; // 10% padding

    return Card(
      elevation: 8,
      color: AppColors.bgSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'التنبؤ بالأسعار',
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.goldMain.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '24 ساعة قادمة',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.goldMain,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 280,
              child: LineChart(
                LineChartData(
                  minY: minPrice - padding,
                  maxY: maxPrice + padding,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: (priceRange > 50) ? 20 : 10,
                    verticalInterval: 6,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.border.withValues(alpha: 0.3),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: AppColors.border.withValues(alpha: 0.2),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        interval: (priceRange > 50) ? 20 : 10,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              '\$${value.toStringAsFixed(0)}',
                              style: GoogleFonts.robotoMono(
                                fontSize: 11,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 4,
                        getTitlesWidget: (value, meta) {
                          if (value % 4 != 0) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '+${value.toInt()}h',
                              style: GoogleFonts.robotoMono(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  lineBarsData: [
                    // خط التنبؤ الرئيسي
                    LineChartBarData(
                      spots: predictions
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value.price))
                          .toList(),
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: AppColors.goldMain,
                      barWidth: 4,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: AppColors.goldMain,
                            strokeWidth: 2,
                            strokeColor: AppColors.bgPrimary,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.goldMain.withValues(alpha: 0.3),
                            AppColors.goldMain.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      shadow: const Shadow(
                        color: Color(0x33D97706),
                        blurRadius: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // مؤشرات السعر
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPriceIndicator('الحالي', widget.currentPrice, AppColors.textPrimary),
                _buildPriceIndicator('الأدنى', minPrice, AppColors.error),
                _buildPriceIndicator('الأعلى', maxPrice, AppColors.success),
                _buildPriceIndicator(
                  'المتوقع',
                  predictions.last.price,
                  predictions.last.price > widget.currentPrice
                      ? AppColors.success
                      : AppColors.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceIndicator(String label, double price, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '\$${price.toStringAsFixed(2)}',
          style: GoogleFonts.robotoMono(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSupportResistanceCard(
    List<PriceLevel> support,
    List<PriceLevel> resistance,
  ) {
    return Card(
      elevation: 4,
      color: AppColors.bgSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الدعم والمقاومة',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'المقاومة 🔴',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            ...resistance.map((level) => _buildLevelTile(level, isResistance: true)),
            const SizedBox(height: 16),
            Text(
              'الدعم 🟢',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
            ...support.map((level) => _buildLevelTile(level, isResistance: false)),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelTile(PriceLevel level, {required bool isResistance}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                level.label,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '\$${level.price.toStringAsFixed(2)}',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (isResistance ? AppColors.error : AppColors.success)
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${(level.strength * 100).toStringAsFixed(0)}%',
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isResistance ? AppColors.error : AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(List<TradingRecommendation> recommendations) {
    return Card(
      elevation: 4,
      color: AppColors.bgSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'التوصيات',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...recommendations.map((rec) => _buildRecommendationTile(rec)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationTile(TradingRecommendation rec) {
    final actionColor = _getActionColor(rec.action);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: actionColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: actionColor.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                rec.actionText,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: actionColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: actionColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(rec.confidence * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: actionColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRecDetails('الدخول', '\$${rec.entryPrice.toStringAsFixed(2)}'),
          _buildRecDetails('الهدف', '\$${rec.targetPrice.toStringAsFixed(2)}'),
          _buildRecDetails('وقف الخسارة', '\$${rec.stopLoss.toStringAsFixed(2)}'),
          _buildRecDetails(
              'المخاطرة:العائد', '1:${rec.riskRewardRatio.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          Text(
            rec.reason,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecDetails(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard(TrendAnalysis trend) {
    return Card(
      elevation: 4,
      color: AppColors.bgSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تحليل الاتجاه',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  trend.trendText,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.goldMain,
                  ),
                ),
                Text(
                  '${trend.change > 0 ? '+' : ''}${trend.change.toStringAsFixed(2)}%',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: trend.change > 0 ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: trend.strength,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(AppColors.goldMain),
            ),
            const SizedBox(height: 8),
            Text(
              'قوة الاتجاه: ${(trend.strength * 100).toStringAsFixed(0)}%',
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsWidget(List<GoldNews> newsList) {
    return Card(
      elevation: 4,
      color: AppColors.bgSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'آخر الأخبار',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            if (newsList.isEmpty)
              Text(
                'لا توجد أخبار حالياً',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              )
            else
              ...newsList.take(5).map((article) => _buildNewsItem(article)),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsItem(GoldNews article) {
    final sentimentColor = article.sentiment?.isPositive == true
        ? AppColors.success
        : article.sentiment?.isNegative == true
            ? AppColors.error
            : AppColors.textMuted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.source,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (article.sentiment != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: sentimentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${(article.sentiment!.score * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: sentimentColor,
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: 16),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics(ConfidenceMetrics confidence) {
    return Card(
      elevation: 4,
      color: AppColors.bgSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مقاييس الأداء',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricBox(
                  'الدقة',
                  '${(confidence.modelAccuracy * 100).toStringAsFixed(0)}%',
                ),
                _buildMetricBox(
                  'الثبات',
                  '${(confidence.marketStability * 100).toStringAsFixed(0)}%',
                ),
                _buildMetricBox(
                  'التوافق',
                  '${(confidence.indicatorConsensus * 100).toStringAsFixed(0)}%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBox(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.goldMain,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence > 0.75) return AppColors.success;
    if (confidence > 0.6) return const Color(0xFFFFA500);
    return AppColors.error;
  }

  Color _getActionColor(TradeAction action) {
    switch (action) {
      case TradeAction.strongBuy:
      case TradeAction.buy:
        return AppColors.success;
      case TradeAction.strongSell:
      case TradeAction.sell:
        return AppColors.error;
      case TradeAction.hold:
        return const Color(0xFFFFA500);
    }
  }
}

