// 🧠 AI Analytics Screen - شاشة التحليل بالذكاء الاصطناعي
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/ai/real_time_ai_service.dart';
import '../../../services/ai/gold_ai_engine.dart';

class AIAnalyticsScreen extends StatefulWidget {
  const AIAnalyticsScreen({super.key});

  @override
  State<AIAnalyticsScreen> createState() => _AIAnalyticsScreenState();
}

class _AIAnalyticsScreenState extends State<AIAnalyticsScreen> {
  final _aiService = RealTimeAIService();
  
  bool _isLoading = true;
  AIGoldPrediction? _prediction;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPrediction();
  }

  Future<void> _loadPrediction() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prediction = await _aiService.getCurrentPrediction(forceRefresh: true);
      setState(() {
        _prediction = prediction;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Text('🧠 ', style: TextStyle(fontSize: 24)),
            Text(
              'تحليل الذكاء الاصطناعي',
              style: GoogleFonts.cairo(
                color: AppColors.goldMain,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.goldMain),
            onPressed: _loadPrediction,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.goldMain),
            const SizedBox(height: 20),
            Text(
              'جاري تحليل السوق بالذكاء الاصطناعي...',
              style: GoogleFonts.cairo(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: AppColors.error),
            const SizedBox(height: 20),
            Text(
              'حدث خطأ',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _error!,
              style: GoogleFonts.cairo(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadPrediction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldMain,
              ),
              child: Text(
                'إعادة المحاولة',
                style: GoogleFonts.cairo(color: Colors.black),
              ),
            ),
          ],
        ),
      );
    }

    if (_prediction == null) {
      return const Center(child: Text('لا توجد بيانات'));
    }

    return RefreshIndicator(
      onRefresh: _loadPrediction,
      color: AppColors.goldMain,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeaderCard(),
            const SizedBox(height: 16),
            
            // Recommendations
            _buildRecommendationsSection(),
            const SizedBox(height: 16),
            
            // Price Predictions Chart
            _buildPredictionsCard(),
            const SizedBox(height: 16),
            
            // Confidence Metrics
            _buildConfidenceCard(),
            const SizedBox(height: 16),
            
            // Support/Resistance Levels
            _buildLevelsCard(),
            const SizedBox(height: 16),
            
            // Trend Analysis
            _buildTrendCard(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    final p = _prediction!;
    final directionColor = _getDirectionColor(p.direction);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.bgSecondary,
            directionColor.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: directionColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'السعر الحالي',
                    style: GoogleFonts.cairo(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '\$${p.currentPrice.toStringAsFixed(2)}',
                    style: GoogleFonts.robotoMono(
                      color: AppColors.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: directionColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: directionColor),
                ),
                child: Column(
                  children: [
                    Text(
                      _getDirectionEmoji(p.direction),
                      style: const TextStyle(fontSize: 28),
                    ),
                    Text(
                      _getDirectionText(p.direction),
                      style: GoogleFonts.cairo(
                        color: directionColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('الثقة', '${(p.confidence.overall * 100).toStringAsFixed(0)}%', AppColors.goldMain),
              _buildMiniStat('القوة', '${(p.strength * 100).toStringAsFixed(0)}%', directionColor),
              _buildMiniStat('النموذج', 'v3.0', AppColors.info),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.robotoMono(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsSection() {
    final recommendations = _prediction!.recommendations;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('💡 ', style: TextStyle(fontSize: 20)),
            Text(
              'التوصيات النشطة',
              style: GoogleFonts.cairo(
                color: AppColors.goldMain,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...recommendations.map((rec) => _buildRecommendationCard(rec)),
      ],
    );
  }

  Widget _buildRecommendationCard(AIRecommendation rec) {
    final actionColor = _getActionColor(rec.action);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: actionColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: actionColor.withValues(alpha: 0.5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: actionColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      rec.actionText,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    rec.timeframe,
                    style: GoogleFonts.cairo(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.goldMain.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(rec.confidence * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.robotoMono(
                    color: AppColors.goldMain,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Price Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPriceDetail('الدخول', rec.entryPrice, AppColors.textPrimary),
              _buildPriceDetail('الهدف', rec.targetPrice, AppColors.success),
              _buildPriceDetail('الإيقاف', rec.stopLoss, AppColors.error),
              _buildPriceDetail('R:R', '1:${rec.riskRewardRatio.toStringAsFixed(1)}', AppColors.info),
            ],
          ),
          
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.textSecondary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rec.reason,
                    style: GoogleFonts.cairo(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDetail(String label, dynamic value, Color color) {
    final displayValue = value is double ? '\$${value.toStringAsFixed(2)}' : value.toString();
    
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        Text(
          displayValue,
          style: GoogleFonts.robotoMono(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionsCard() {
    final predictions = _prediction!.predictions;
    if (predictions.isEmpty) return const SizedBox();
    
    final firstPrice = predictions.first.price;
    final lastPrice = predictions.last.price;
    final change = ((lastPrice - firstPrice) / firstPrice) * 100;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('📊 ', style: TextStyle(fontSize: 18)),
                  Text(
                    'التنبؤات (24 ساعة)',
                    style: GoogleFonts.cairo(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (change >= 0 ? AppColors.success : AppColors.error).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%',
                  style: GoogleFonts.robotoMono(
                    color: change >= 0 ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Simple prediction display
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: predictions.length,
              itemBuilder: (context, index) {
                final pred = predictions[index];
                final isUp = pred.price > firstPrice;
                
                return Container(
                  width: 70,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isUp ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (isUp ? AppColors.success : AppColors.error).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '+${pred.hourOffset}h',
                        style: GoogleFonts.cairo(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        isUp ? Icons.trending_up : Icons.trending_down,
                        color: isUp ? AppColors.success : AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pred.price.toStringAsFixed(0),
                        style: GoogleFonts.robotoMono(
                          color: isUp ? AppColors.success : AppColors.error,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceCard() {
    final c = _prediction!.confidence;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📈 ', style: TextStyle(fontSize: 18)),
              Text(
                'مقاييس الثقة',
                style: GoogleFonts.cairo(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildConfidenceBar('الثقة الكلية', c.overall, AppColors.goldMain),
          _buildConfidenceBar('دقة النموذج', c.modelAccuracy, AppColors.info),
          _buildConfidenceBar('قوة الاتجاه', c.trendStrength, AppColors.success),
          _buildConfidenceBar('جودة البيانات', c.dataQuality, AppColors.warning),
          _buildConfidenceBar('استقرار التقلب', c.volatilityConfidence, AppColors.error),
          _buildConfidenceBar('وضوح الإشارة', c.signalClarity, AppColors.imperialPurple),
        ],
      ),
    );
  }

  Widget _buildConfidenceBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.cairo(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: value.clamp(0, 1),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '${(value * 100).toStringAsFixed(0)}%',
              style: GoogleFonts.robotoMono(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelsCard() {
    final support = _prediction!.supportLevels;
    final resistance = _prediction!.resistanceLevels;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📍 ', style: TextStyle(fontSize: 18)),
              Text(
                'مستويات الدعم والمقاومة',
                style: GoogleFonts.cairo(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resistance
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔴 المقاومة',
                      style: GoogleFonts.cairo(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...resistance.take(3).map((level) => _buildLevelTile(level, true)),
                    if (resistance.isEmpty)
                      Text(
                        'لا توجد مقاومات قريبة',
                        style: GoogleFonts.cairo(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Support
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🟢 الدعم',
                      style: GoogleFonts.cairo(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...support.take(3).map((level) => _buildLevelTile(level, false)),
                    if (support.isEmpty)
                      Text(
                        'لا توجد دعوم قريبة',
                        style: GoogleFonts.cairo(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelTile(AIPriceLevel level, bool isResistance) {
    final color = isResistance ? AppColors.error : AppColors.success;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                level.label,
                style: GoogleFonts.cairo(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
              Text(
                '\$${level.price.toStringAsFixed(2)}',
                style: GoogleFonts.robotoMono(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            '${(level.strength * 100).toStringAsFixed(0)}%',
            style: GoogleFonts.robotoMono(
              color: color,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard() {
    final trend = _prediction!.trend;
    final trendColor = _getTrendColor(trend.type);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.bgSecondary,
            trendColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: trendColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📉 ', style: TextStyle(fontSize: 18)),
              Text(
                'تحليل الاتجاه',
                style: GoogleFonts.cairo(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Center(
            child: Column(
              children: [
                Text(
                  trend.trendText,
                  style: GoogleFonts.cairo(
                    color: trendColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTrendStat('القوة', '${(trend.strength * 100).toStringAsFixed(0)}%'),
                    const SizedBox(width: 20),
                    _buildTrendStat('الزخم', trend.momentum > 0 ? '↑ ${trend.momentum.toStringAsFixed(2)}' : '↓ ${trend.momentum.abs().toStringAsFixed(2)}'),
                    const SizedBox(width: 20),
                    _buildTrendStat('التغير', '${trend.change >= 0 ? '+' : ''}${trend.change.toStringAsFixed(2)}%'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.robotoMono(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Helper methods
  Color _getDirectionColor(String direction) {
    switch (direction) {
      case 'STRONG_BULLISH':
      case 'BULLISH':
        return AppColors.success;
      case 'STRONG_BEARISH':
      case 'BEARISH':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  String _getDirectionEmoji(String direction) {
    switch (direction) {
      case 'STRONG_BULLISH': return '🚀';
      case 'BULLISH': return '📈';
      case 'STRONG_BEARISH': return '📉';
      case 'BEARISH': return '↘️';
      default: return '↔️';
    }
  }

  String _getDirectionText(String direction) {
    switch (direction) {
      case 'STRONG_BULLISH': return 'صعود قوي';
      case 'BULLISH': return 'صعود';
      case 'STRONG_BEARISH': return 'هبوط قوي';
      case 'BEARISH': return 'هبوط';
      default: return 'محايد';
    }
  }

  Color _getActionColor(AITradeAction action) {
    switch (action) {
      case AITradeAction.strongBuy:
      case AITradeAction.buy:
        return AppColors.success;
      case AITradeAction.strongSell:
      case AITradeAction.sell:
        return AppColors.error;
      case AITradeAction.hold:
        return AppColors.warning;
    }
  }

  Color _getTrendColor(AITrendType type) {
    switch (type) {
      case AITrendType.strongBullish:
      case AITrendType.bullish:
        return AppColors.success;
      case AITrendType.strongBearish:
      case AITrendType.bearish:
        return AppColors.error;
      case AITrendType.neutral:
        return AppColors.warning;
    }
  }
}

