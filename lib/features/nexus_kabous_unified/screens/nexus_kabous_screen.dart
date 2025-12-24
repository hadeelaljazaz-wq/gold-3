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
import '../providers/nexus_kabous_provider.dart';
import '../widgets/nexus_signal_card.dart';
import '../widgets/kabous_signal_card.dart';
import '../widgets/unified_comparison_card.dart';
import '../widgets/unified_metrics_card.dart';

class NexusKabousScreen extends ConsumerStatefulWidget {
  const NexusKabousScreen({super.key});

  @override
  ConsumerState<NexusKabousScreen> createState() => _NexusKabousScreenState();
}

class _NexusKabousScreenState extends ConsumerState<NexusKabousScreen> {
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ref.read(nexusKabousUnifiedProvider).nexusScalp == null) {
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted && ref.read(nexusKabousUnifiedProvider).isLoading) {
            AppLogger.warn(
              'NEXUS+KABOUS analysis taking longer than expected, but continuing...',
            );
          }
        });
        ref.read(nexusKabousUnifiedProvider.notifier).generateAnalysis();
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
            AppLogger.info('Auto-refreshing NEXUS+KABOUS Analysis...');
            ref.read(nexusKabousUnifiedProvider.notifier).generateAnalysis();
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(nexusKabousUnifiedProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.goldGradient.createShader(bounds),
              child: const Text(
                'NEXUS + KABOUS',
                style: AppTypography.titleLarge,
              ),
            ),
            Text(
              'نظام التحليل الموحد المتقدم',
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
                          .read(nexusKabousUnifiedProvider.notifier)
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
        message: 'جاري التحليل بـ NEXUS + KABOUS...',
        child: analysisState.error != null
            ? ErrorStateWidget(
                message: analysisState.error!,
                onRetry: () {
                  ref
                      .read(nexusKabousUnifiedProvider.notifier)
                      .generateAnalysis();
                },
              )
            : RefreshIndicator(
                onRefresh: () async {
                  try {
                    await ref
                        .read(nexusKabousUnifiedProvider.notifier)
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
                child: analysisState.nexusScalp == null
                    ? _buildEmptyState()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Current Price & Time
                            _buildHeader(),
                            const SizedBox(height: 16),

                            // Unified Metrics Card
                            if (analysisState.metrics != null)
                              SlideInCard(
                                delay: const Duration(milliseconds: 50),
                                child: UnifiedMetricsCard(
                                  metrics: analysisState.metrics!,
                                ),
                              ),
                            const SizedBox(height: 16),

                            // Unified Comparison Card
                            if (analysisState.nexusScalp != null &&
                                analysisState.kabousScalp != null)
                              SlideInCard(
                                delay: const Duration(milliseconds: 100),
                                child: UnifiedComparisonCard(
                                  nexusScalp: analysisState.nexusScalp!,
                                  kabousScalp: analysisState.kabousScalp!,
                                ),
                              ),
                            const SizedBox(height: 16),

                            // NEXUS Scalp Signal Card
                            if (analysisState.nexusScalp != null)
                              SlideInCard(
                                delay: const Duration(milliseconds: 200),
                                child: NexusSignalCard(
                                  signal: analysisState.nexusScalp!,
                                  title: 'NEXUS Quantum Scalping',
                                ),
                              ),
                            const SizedBox(height: 16),

                            // KABOUS Scalp Signal Card
                            if (analysisState.kabousScalp != null)
                              SlideInCard(
                                delay: const Duration(milliseconds: 300),
                                child: KabousSignalCard(
                                  signal: analysisState.kabousScalp!,
                                  title: 'KABOUS Elite Scalping',
                                ),
                              ),
                            const SizedBox(height: 16),

                            // NEXUS Swing Signal Card
                            if (analysisState.nexusSwing != null)
                              SlideInCard(
                                delay: const Duration(milliseconds: 400),
                                child: NexusSignalCard(
                                  signal: analysisState.nexusSwing!,
                                  title: 'NEXUS Quantum Swing',
                                ),
                              ),
                            const SizedBox(height: 16),

                            // KABOUS Swing Signal Card
                            if (analysisState.kabousSwing != null)
                              SlideInCard(
                                delay: const Duration(milliseconds: 500),
                                child: KabousSignalCard(
                                  signal: analysisState.kabousSwing!,
                                  title: 'KABOUS Elite Swing',
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
        final analysisState = ref.watch(nexusKabousUnifiedProvider);

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
