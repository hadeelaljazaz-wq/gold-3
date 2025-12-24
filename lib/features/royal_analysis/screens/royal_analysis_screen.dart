import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/logger.dart';
import '../providers/royal_analysis_provider.dart';
import '../widgets/royal_scalp_card.dart';
import '../widgets/royal_swing_card.dart';
import '../widgets/market_metrics_panel.dart';
import '../../../widgets/shared_widgets.dart';
import '../../../services/gold_price_service.dart';
import '../../../models/market_models.dart';
import '../../../widgets/animations/pulse_animation.dart';
import '../../../widgets/animations/slide_in_card.dart';
import '../../../features/settings/providers/settings_provider.dart';
import 'package:go_router/go_router.dart';

class RoyalAnalysisScreen extends ConsumerStatefulWidget {
  const RoyalAnalysisScreen({super.key});

  @override
  ConsumerState<RoyalAnalysisScreen> createState() =>
      _RoyalAnalysisScreenState();
}

class _RoyalAnalysisScreenState extends ConsumerState<RoyalAnalysisScreen> {
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    // Auto-generate analysis with timeout protection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ref.read(royalAnalysisProvider).scalp == null) {
        // Add timeout protection for faster loading
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted && ref.read(royalAnalysisProvider).isLoading) {
            AppLogger.warn(
                'Royal analysis taking longer than expected, but continuing...');
          }
        });
        ref.read(royalAnalysisProvider.notifier).generateAnalysis();
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
            AppLogger.info('Auto-refreshing Royal Analysis...');
            ref.read(royalAnalysisProvider.notifier).generateAnalysis();
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(royalAnalysisProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.goldGradient.createShader(bounds),
              child: const Text(
                'التحليل الملكي',
                style: AppTypography.titleLarge,
              ),
            ),
            Text(
              'محركات متقدمة الإصدار 2.0',
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
                          .read(royalAnalysisProvider.notifier)
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
        message: 'جاري التحليل بالمحركات الملكية...',
        child: analysisState.error != null
            ? ErrorStateWidget(
                message: analysisState.error!,
                onRetry: () {
                  ref.read(royalAnalysisProvider.notifier).generateAnalysis();
                },
              )
            : RefreshIndicator(
                onRefresh: () async {
                  try {
                    await ref
                        .read(royalAnalysisProvider.notifier)
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
                child: analysisState.scalp == null
                    ? _buildEmptyState()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Current Price & Time
                            _buildHeader(),
                            const SizedBox(height: 16),

                            // Market Metrics Panel
                            if (analysisState.marketMetrics != null)
                              SlideInCard(
                                delay: const Duration(milliseconds: 50),
                                child: MarketMetricsPanel(
                                  metrics: analysisState.marketMetrics!,
                                ),
                              ),
                            const SizedBox(height: 16),

                            // Scalp Signal Card with Animation
                            if (analysisState.scalp != null)
                              SlideInCard(
                                delay: const Duration(milliseconds: 100),
                                child: RoyalScalpCard(
                                  signal: analysisState.scalp!,
                                ),
                              ),
                            const SizedBox(height: 16),

                            // Swing Signal Card with Animation
                            if (analysisState.swing != null)
                              SlideInCard(
                                delay: const Duration(milliseconds: 200),
                                child: RoyalSwingCard(
                                  signal: analysisState.swing!,
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
    final analysisState = ref.watch(royalAnalysisProvider);
    
    return FutureBuilder(
      key: ValueKey('fresh_price_${DateTime.now().millisecondsSinceEpoch}'),
      future: _getFreshPrice(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const ShimmerLoading(
            width: double.infinity,
            height: 80,
          );
        }

        final price = snapshot.data!;

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
            Icons.auto_awesome,
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

  // Get FRESH price - clear cache EVERY time
  Future<GoldPrice> _getFreshPrice() async {
    GoldPriceService.clearCache();
    return await GoldPriceService.getCurrentPrice();
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
