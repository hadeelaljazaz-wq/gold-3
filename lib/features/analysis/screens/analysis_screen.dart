import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../providers/analysis_provider.dart';
import '../providers/strictness_provider.dart';
import '../widgets/scalp_card.dart';
import '../widgets/swing_card.dart';
import '../widgets/ai_analysis_card.dart';
import '../widgets/support_resistance_card.dart';
import '../widgets/strictness_selector.dart';
import '../../../widgets/shared_widgets.dart';
import '../../../services/gold_price_service.dart';
import '../../../widgets/animations/slide_in_card.dart';
import '../../../features/settings/providers/settings_provider.dart';
import 'package:go_router/go_router.dart';

class AnalysisScreen extends ConsumerStatefulWidget {
  const AnalysisScreen({super.key});

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    // Auto-generate analysis immediately when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentState = ref.read(analysisProvider);
        // Only trigger if no analysis exists (initial load)
        if (currentState.scalp == null && !currentState.isLoading) {
          AppLogger.info('Auto-generating analysis on screen init...');
          // Use isInitialCall=true to skip debounce and rate limiting
          ref
              .read(analysisProvider.notifier)
              .generateAnalysis(isInitialCall: true);
        }
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
            AppLogger.info('Auto-refreshing Golden Nightmare Analysis...');
            ref.read(analysisProvider.notifier).generateAnalysis();
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(analysisProvider);

    // Listen to strictness changes and regenerate analysis
    ref.listen(strictnessProvider, (previous, next) {
      if (previous != null && previous != next) {
        ref.read(analysisProvider.notifier).generateAnalysis();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.goldGradient.createShader(bounds),
              child: const Text(
                'الكابوس الذهبي',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Text(
              'تحليل متقدم من 10 طبقات',
              style: TextStyle(
                fontSize: 11,
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
                          .read(analysisProvider.notifier)
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
        message: 'جاري تحليل السوق...',
        child: analysisState.error != null
            ? ErrorStateWidget(
                message: analysisState.error!,
                onRetry: () {
                  ref.read(analysisProvider.notifier).generateAnalysis();
                },
              )
            : RefreshIndicator(
                onRefresh: () async {
                  try {
                    await ref
                        .read(analysisProvider.notifier)
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

                            // Strictness Selector
                            const StrictnessSelector(),
                            const SizedBox(height: 16),

                            // Support/Resistance Levels with Animation
                            if (analysisState.supportResistance != null)
                              SlideInCard(
                                delay: const Duration(milliseconds: 100),
                                child: FutureBuilder(
                                  future: GoldPriceService.getCurrentPrice(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return SupportResistanceCard(
                                        analysis:
                                            analysisState.supportResistance!,
                                        currentPrice: snapshot.data!.price,
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                            const SizedBox(height: 16),

                            // Scalp Recommendation with Animation
                            if (analysisState.scalp != null)
                              SlideInCard(
                                delay: const Duration(milliseconds: 200),
                                child: ScalpCard(
                                  recommendation: analysisState.scalp!,
                                ),
                              ),
                            const SizedBox(height: 16),

                            // Swing Recommendation with Animation
                            if (analysisState.swing != null)
                              SlideInCard(
                                delay: const Duration(milliseconds: 300),
                                child: SwingCard(
                                  recommendation: analysisState.swing!,
                                ),
                              ),
                            const SizedBox(height: 16),

                            // AI Analysis with Animation
                            if (analysisState.aiAnalysis != null)
                              SlideInCard(
                                delay: const Duration(milliseconds: 400),
                                child: AiAnalysisCard(
                                  analysis: analysisState.aiAnalysis!,
                                ),
                              )
                            else
                              _buildAIAnalysisButton(),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'التحليل جاهز',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'آخر تحديث: ${TimeOfDay.now().format(context)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.buy.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppColors.buy,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAnalysisButton() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.psychology_outlined,
              size: 48,
              color: AppColors.imperialPurple,
            ),
            const SizedBox(height: 16),
            Text(
              'تحليل بالذكاء الاصطناعي',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'دع Claude AI يحلل السوق ويقدم رؤى احترافية',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(analysisProvider.notifier).generateAIAnalysis();
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('إنشاء تحليل بالذكاء الاصطناعي'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.imperialPurple,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      title: 'لا يوجد تحليل بعد',
      message: 'اضغط الزر أدناه لإنشاء أول تحليل',
      icon: Icons.analytics_outlined,
      onAction: () {
        ref.read(analysisProvider.notifier).generateAnalysis();
      },
      actionLabel: 'إنشاء تحليل',
    );
  }
}
