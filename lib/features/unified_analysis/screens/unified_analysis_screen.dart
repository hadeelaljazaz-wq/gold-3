import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/logger.dart';
import '../../../widgets/shared_widgets.dart';
import '../../../services/gold_price_service.dart';
import '../../../widgets/animations/pulse_animation.dart';
import '../../../widgets/animations/slide_in_card.dart';
import '../../../features/settings/providers/settings_provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/unified_analysis_provider.dart';
import '../widgets/royal_scalp_card.dart';
import '../widgets/royal_swing_card.dart';
import '../widgets/advanced_scalp_card.dart';
import '../widgets/comparison_card.dart';
import '../widgets/market_metrics_card.dart';

class UnifiedAnalysisScreen extends ConsumerStatefulWidget {
  const UnifiedAnalysisScreen({super.key});

  @override
  ConsumerState<UnifiedAnalysisScreen> createState() =>
      _UnifiedAnalysisScreenState();
}

class _UnifiedAnalysisScreenState extends ConsumerState<UnifiedAnalysisScreen> {
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ref.read(unifiedAnalysisProvider).royalScalp == null) {
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted && ref.read(unifiedAnalysisProvider).isLoading) {
            AppLogger.warn(
              'Unified analysis taking longer than expected, but continuing...',
            );
          }
        });
        ref.read(unifiedAnalysisProvider.notifier).generateAnalysis();
      }
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
            AppLogger.info('Auto-refreshing Unified Analysis...');
            ref.read(unifiedAnalysisProvider.notifier).generateAnalysis();
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(unifiedAnalysisProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.goldGradient.createShader(bounds),
              child: const Text(
                'التحليل الموحد',
                style: AppTypography.titleLarge,
              ),
            ),
            Text(
              'Royal + Advanced Scalping',
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
                          .read(unifiedAnalysisProvider.notifier)
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
        message: 'جاري التحليل بالنظامين الموحدين...',
        child: analysisState.error != null
            ? ErrorStateWidget(
                message: analysisState.error!,
                onRetry: () {
                  ref.read(unifiedAnalysisProvider.notifier).generateAnalysis();
                },
              )
            : RefreshIndicator(
                onRefresh: () async {
                  try {
                    await ref
                        .read(unifiedAnalysisProvider.notifier)
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
                child: analysisState.royalScalp == null
                    ? _buildEmptyState()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Current Price & Time
                            _buildHeader(),
                            const SizedBox(height: 16),

                            // Market Metrics Card
                            if (analysisState.metrics != null)
                              SlideInCard(
                                delay: const Duration(milliseconds: 50),
                                child: MarketMetricsCard(
                                  metrics: analysisState.metrics!,
                                ),
                              ),
                            const SizedBox(height: 16),

                            // Comparison Card
                            if (analysisState.royalScalp != null &&
                                analysisState.advancedScalp != null)
                              SlideInCard(
                                delay: const Duration(milliseconds: 100),
                                child: ComparisonCard(
                                  royalScalp: analysisState.royalScalp!,
                                  advancedScalp: analysisState.advancedScalp!,
                                ),
                              ),
                            const SizedBox(height: 16),

                            // Royal Scalp Signal Card
                            if (analysisState.royalScalp != null)
                              SlideInCard(
                                delay: const Duration(milliseconds: 200),
                                child: RoyalScalpCard(
                                  signal: analysisState.royalScalp!,
                                  title: 'Royal Scalping Engine',
                                ),
                              ),
                            const SizedBox(height: 16),

                            // Advanced Scalp Signal Card
                            if (analysisState.advancedScalp != null)
                              SlideInCard(
                                delay: const Duration(milliseconds: 300),
                                child: AdvancedScalpCard(
                                  signal: analysisState.advancedScalp!,
                                  title: 'Advanced Scalping Engine',
                                ),
                              ),
                            const SizedBox(height: 16),

                            // Royal Swing Signal Card
                            if (analysisState.royalSwing != null)
                              SlideInCard(
                                delay: const Duration(milliseconds: 400),
                                child: RoyalSwingCard(
                                  signal: analysisState.royalSwing!,
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return FutureBuilder(
      future: GoldPriceService.getCurrentPrice(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const ShimmerLoading(width: double.infinity, height: 80);
        }

        final price = snapshot.data!;
        final analysisState = ref.watch(unifiedAnalysisProvider);

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
                        isPositive: price.change >= 0,
                        enabled: price.change != 0,
                        child: ShaderMask(
                          shaderCallback: (bounds) =>
                              AppColors.goldGradient.createShader(bounds),
                          child: Text(
                            '\$${price.price.toStringAsFixed(2)}',
                            style: AppTypography.displaySmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: price.change >= 0
                          ? AppColors.buy.withValues(alpha: 0.2)
                          : AppColors.sell.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${price.change >= 0 ? '+' : ''}${price.change.toStringAsFixed(2)} (${price.changePercent.toStringAsFixed(2)}%)',
                      style: AppTypography.labelMedium.copyWith(
                        color:
                            price.change >= 0 ? AppColors.buy : AppColors.sell,
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
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.merge_type,
            size: 64,
            color: AppColors.royalGold.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل التحليل الموحد...',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
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
