import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/logger.dart';
import '../../../widgets/shared_widgets.dart';
import '../../../services/gold_price_service.dart';
import '../../../models/market_models.dart';
import '../../../widgets/animations/pulse_animation.dart';
import '../../../widgets/animations/slide_in_card.dart';
import '../../../features/settings/providers/settings_provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/kabous_pro_provider.dart';
import '../widgets/backtest_results_card.dart';
import '../widgets/multitimeframe_card.dart';
import '../widgets/advanced_metrics_card.dart';

class AdvancedScalpingScreen extends ConsumerStatefulWidget {
  const AdvancedScalpingScreen({super.key});

  @override
  ConsumerState<AdvancedScalpingScreen> createState() =>
      _AdvancedScalpingScreenState();
}

class _AdvancedScalpingScreenState
    extends ConsumerState<AdvancedScalpingScreen> {
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    // Auto-generate analysis with timeout protection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ref.read(kabousProProvider).analysis == null) {
        // Add timeout protection for faster loading
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted && ref.read(kabousProProvider).isLoading) {
            AppLogger.warn(
              'KABOUS PRO analysis taking longer than expected, but continuing...',
            );
          }
        });
        ref.read(kabousProProvider.notifier).generateAnalysis();
      }
      // Setup auto-refresh based on settings
      _setupAutoRefresh();
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  void _setupAutoRefresh() {
    final settings = ref.read(settingsProvider).settings;
    if (settings.autoRefreshEnabled) {
      AppLogger.info('Auto-refresh enabled: ${settings.autoRefreshInterval}s');
      _autoRefreshTimer?.cancel();
      _autoRefreshTimer = Timer.periodic(
        Duration(seconds: settings.autoRefreshInterval),
        (_) {
          if (mounted) {
            AppLogger.info('Auto-refreshing KABOUS PRO Analysis...');
            ref.read(kabousProProvider.notifier).generateAnalysis();
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(kabousProProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.goldGradient.createShader(bounds),
              child: const Text(
                'KABOUS PRO',
                style: AppTypography.titleLarge,
              ),
            ),
            Text(
              'نظام احترافي متكامل - Backtest & Multi-TF',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: analysisState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textPrimary,
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: analysisState.isLoading
                ? null
                : () async {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('جاري تحديث التحليل...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      await ref
                          .read(kabousProProvider.notifier)
                          .generateAnalysis();
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('خطأ في التحديث: ${e.toString()}'),
                            backgroundColor: AppColors.error,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              context.push('/history');
            },
          ),
          IconButton(
            icon: const Icon(Icons.show_chart),
            onPressed: () {
              context.push('/charts');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: analysisState.isLoading,
        message: 'جاري التحليل بنظام KABOUS PRO...',
        child: analysisState.error != null
            ? ErrorStateWidget(
                message: analysisState.error!,
                onRetry: () {
                  ref.read(kabousProProvider.notifier).generateAnalysis();
                },
              )
            : RefreshIndicator(
                onRefresh: () async {
                  try {
                    await ref
                        .read(kabousProProvider.notifier)
                        .generateAnalysis();
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('خطأ في التحديث: ${e.toString()}'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                    rethrow;
                  }
                },
                child: analysisState.analysis == null
                    ? _buildEmptyState()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 🆕 Version & Debug Info Button
                            _buildVersionDebugButton(),
                            const SizedBox(height: 12),

                            // Current Price & Time
                            _buildHeader(),
                            const SizedBox(height: 16),

                            // Multi-Timeframe Card
                            if (analysisState.multiTimeframe != null)
                              SlideInCard(
                                delay: const Duration(milliseconds: 100),
                                child: MultitimeframeCard(
                                  result: analysisState.multiTimeframe!,
                                ),
                              ),
                            const SizedBox(height: 16),

                            // Backtest Results Card
                            if (analysisState.backtestResult != null)
                              SlideInCard(
                                delay: const Duration(milliseconds: 200),
                                child: BacktestResultsCard(
                                  result: analysisState.backtestResult!,
                                ),
                              ),
                            const SizedBox(height: 16),

                            // Advanced Metrics Card
                            if (analysisState.analysis != null)
                              SlideInCard(
                                delay: const Duration(milliseconds: 300),
                                child: AdvancedMetricsCard(
                                  indicators:
                                      analysisState.analysis!.indicators,
                                ),
                              ),
                            const SizedBox(height: 16),

                            // Additional Info Card
                            SlideInCard(
                              delay: const Duration(milliseconds: 400),
                              child: _buildInfoCard(analysisState),
                            ),
                          ],
                        ),
                      ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    final analysisState = ref.watch(kabousProProvider);

    // ALWAYS fetch fresh price - no cache, no Provider dependency
    return FutureBuilder(
      key: ValueKey('fresh_price_${DateTime.now().millisecondsSinceEpoch}'),
      future: _getFreshPrice(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const ShimmerLoading(width: double.infinity, height: 80);
        }

        final price = snapshot.data!;
        return _buildPriceDisplay(
          price: price.price,
          change: price.change,
          changePercent: price.changePercent,
          analysisState: analysisState,
        );
      },
    );
  }

  // Get FRESH price - clear cache EVERY time
  Future<GoldPrice> _getFreshPrice() async {
    GoldPriceService.clearCache();
    return await GoldPriceService.getCurrentPrice();
  }

  Widget _buildPriceDisplay({
    required double price,
    required double change,
    required double changePercent,
    required KabousProState analysisState,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.imperialPurple.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
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
                    'سعر الذهب',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  PulseAnimation(
                    isPositive: change >= 0,
                    enabled: change != 0,
                    child: ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.goldGradient.createShader(bounds),
                      child: Text(
                        '\$${price.toStringAsFixed(2)}',
                        style: AppTypography.displaySmall,
                      ),
                    ),
                  ),
                ],
              ),
              if (change != 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: change >= 0
                        ? AppColors.buy.withValues(alpha: 0.2)
                        : AppColors.sell.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)} (${changePercent.toStringAsFixed(2)}%)',
                    style: AppTypography.labelMedium.copyWith(
                      color: change >= 0 ? AppColors.buy : AppColors.sell,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (analysisState.lastUpdate != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  'آخر تحديث: ${_formatTime(analysisState.lastUpdate!)}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(KabousProState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.royalGold.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.royalGold, size: 20),
              const SizedBox(width: 8),
              Text(
                'معلومات إضافية',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (state.analysis != null) ...[
            _buildInfoRow('الاتجاه', state.analysis!.signal),
            const SizedBox(height: 8),
            _buildInfoRow(
              'الثقة',
              '${state.analysis!.confidence.toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Risk/Reward',
              '1:${state.analysis!.riskReward.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Confluence Score',
              '${state.analysis!.confluenceScore.toStringAsFixed(1)}/10',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up,
            size: 64,
            color: AppColors.royalGold.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل التحليل...',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // 🆕 Version & Debug Info Button
  Widget _buildVersionDebugButton() {
    return GestureDetector(
      onTap: () async {
        final goldPrice = await GoldPriceService.getCurrentPrice();
        if (!mounted) return;

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.backgroundSecondary,
            title: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.royalGold),
                SizedBox(width: 8),
                Text(
                  'معلومات التطبيق',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.royalGold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('📦 الإصدار', 'v3.1.0 (Build 31)'),
                SizedBox(height: 8),
                _buildInfoRow('💰 السعر الحالي',
                    '\$${goldPrice.price.toStringAsFixed(2)}'),
                SizedBox(height: 8),
                _buildInfoRow(
                    '🔄 التحديث', DateTime.now().toString().substring(0, 19)),
                SizedBox(height: 8),
                _buildInfoRow('🌐 API', 'goldapi.io + metals.live'),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.buy.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '✅ جميع التحديثات مفعّلة\n✅ Clear Cache قبل كل استدعاء\n✅ API مزدوج للموثوقية',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    Text('حسناً', style: TextStyle(color: AppColors.royalGold)),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.royalGold.withValues(alpha: 0.2),
              AppColors.imperialPurple.withValues(alpha: 0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.royalGold.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified, color: AppColors.royalGold, size: 20),
            SizedBox(width: 8),
            Text(
              'v3.1.0 • تحديثات جديدة مفعّلة',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.royalGold,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.touch_app, color: AppColors.royalGold, size: 16),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return 'منذ ${difference.inDays} يوم';
    }
  }
}
