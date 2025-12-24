import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../providers/quantum_analysis_provider.dart';
import '../widgets/quantum_signal_card.dart';
import '../widgets/smart_money_card.dart';
import '../widgets/bayesian_probability_card.dart';
import '../widgets/seven_dimension_radar_chart.dart';
import '../../../widgets/shared_widgets.dart';
import '../../../widgets/animations/slide_in_card.dart';
import '../../../features/settings/providers/settings_provider.dart';
import 'dart:async';

/// 🚀 Quantum Analysis Screen
/// شاشة التحليل الكمومي المتقدم
class QuantumAnalysisScreen extends ConsumerStatefulWidget {
  const QuantumAnalysisScreen({super.key});

  @override
  ConsumerState<QuantumAnalysisScreen> createState() =>
      _QuantumAnalysisScreenState();
}

class _QuantumAnalysisScreenState extends ConsumerState<QuantumAnalysisScreen> {
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    // Auto-generate analysis after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ref.read(quantumAnalysisProvider).signal == null) {
        _triggerAnalysisWithTimeout();
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
            AppLogger.info('Auto-refreshing Quantum Analysis...');
            ref.read(quantumAnalysisProvider.notifier).generateAnalysis();
          }
        },
      );
    }
  }

  Future<void> _triggerAnalysisWithTimeout() async {
    try {
      // Reduced timeout to 5 seconds for faster loading
      await ref
          .read(quantumAnalysisProvider.notifier)
          .generateAnalysis()
          .timeout(
        const Duration(seconds: 5), // 5-second timeout for instant feel
        onTimeout: () {
          if (mounted) {
            // Don't throw error, just log warning
            AppLogger.warn('Quantum analysis timed out but continuing...');
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تحذير: ${e.toString()}'),
            backgroundColor: AppColors.warning,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final quantumState = ref.watch(quantumAnalysisProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.goldGradient.createShader(bounds),
              child: const Text(
                'التحليل الكمومي',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Text(
              'تحليل كمومي من 7 طبقات',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          // Refresh Button
          IconButton(
            icon: quantumState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textPrimary,
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: quantumState.isLoading
                ? null
                : () async {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('جاري تحديث التحليل الكمومي...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      await ref
                          .read(quantumAnalysisProvider.notifier)
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
          // Settings
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: quantumState.isLoading,
        message: 'جاري تحليل الأبعاد الكمومية...',
        child: quantumState.error != null
            ? ErrorStateWidget(
                message: quantumState.error!,
                onRetry: () {
                  _triggerAnalysisWithTimeout();
                },
              )
            : RefreshIndicator(
                onRefresh: () async {
                  try {
                    await ref
                        .read(quantumAnalysisProvider.notifier)
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
                child: quantumState.signal == null
                    ? _buildEmptyState()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header with Quantum Score
                            _buildHeader(quantumState),
                            const SizedBox(height: 16),

                            // Main Quantum Signal Card with Animation
                            SlideInCard(
                              delay: const Duration(milliseconds: 100),
                              child: QuantumSignalCard(
                                signal: quantumState.signal!,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 7-Dimension Radar Chart with Animation
                            if (quantumState.signal != null)
                              SlideInCard(
                                delay: const Duration(milliseconds: 200),
                                child: SevenDimensionRadarChart(
                                  dimensions: quantumState.signal!.dimensions,
                                ),
                              ),
                            const SizedBox(height: 16),

                            // Smart Money Card with Animation
                            if (quantumState.smartMoneyFlow != null)
                              SlideInCard(
                                delay: const Duration(milliseconds: 300),
                                child: SmartMoneyCard(
                                  smartMoneyFlow: quantumState.smartMoneyFlow!,
                                ),
                              ),
                            const SizedBox(height: 16),

                            // Bayesian Probability Card with Animation
                            if (quantumState.bayesianProbability != null)
                              SlideInCard(
                                delay: const Duration(milliseconds: 400),
                                child: BayesianProbabilityCard(
                                  probability:
                                      quantumState.bayesianProbability!,
                                ),
                              ),
                            const SizedBox(height: 16),

                            // Chaos Analysis Card with Animation
                            if (quantumState.chaosAnalysis != null)
                              SlideInCard(
                                delay: const Duration(milliseconds: 500),
                                child: _buildChaosAnalysisCard(quantumState),
                              ),
                            const SizedBox(height: 16),

                            // Quantum Correlation Card with Animation
                            if (quantumState.quantumCorrelation != null)
                              SlideInCard(
                                delay: const Duration(milliseconds: 600),
                                child:
                                    _buildQuantumCorrelationCard(quantumState),
                              ),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
              ),
      ),
    );
  }

  Widget _buildHeader(QuantumAnalysisState state) {
    final signal = state.signal!;
    final scoreColor = signal.quantumScore >= 8.0
        ? AppColors.buy
        : signal.quantumScore >= 6.5
            ? AppColors.warning
            : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scoreColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Title & Time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quantum Score',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'آخر تحديث: ${TimeOfDay.now().format(context)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Right: Score Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  signal.quantumScore.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
                Text(
                  '/ 10',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChaosAnalysisCard(QuantumAnalysisState state) {
    final chaos = state.chaosAnalysis!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.blur_on,
                  color: AppColors.imperialPurple,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Chaos & Volatility Analysis',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Market Condition
            _buildInfoRow(
              'Market Condition',
              chaos.marketCondition.name.toUpperCase(),
              _getConditionColor(chaos.marketCondition),
            ),
            const SizedBox(height: 8),

            // Risk Level
            _buildProgressRow(
              'Risk Level',
              chaos.riskLevel,
              chaos.isHighRisk ? AppColors.error : AppColors.buy,
            ),
            const SizedBox(height: 8),

            // Volatility
            _buildProgressRow(
              'Volatility',
              chaos.volatility,
              AppColors.warning,
            ),
            const SizedBox(height: 8),

            // Entropy
            _buildProgressRow(
              'Entropy (Randomness)',
              chaos.entropy,
              AppColors.sell,
            ),
            const SizedBox(height: 8),

            // Hurst Exponent
            _buildProgressRow(
              'Hurst Exponent',
              chaos.hurstExponent,
              chaos.isTrending ? AppColors.buy : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantumCorrelationCard(QuantumAnalysisState state) {
    final correlation = state.quantumCorrelation!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.link,
                  color: AppColors.cyan,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Quantum Correlation',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (correlation.isEntangled) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'ENTANGLED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.cyan,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Direction
            _buildInfoRow(
              'Direction',
              correlation.correlationDirection.name.toUpperCase(),
              _getCorrelationDirectionColor(correlation.correlationDirection),
            ),
            const SizedBox(height: 8),

            // Strength
            _buildProgressRow(
              'Correlation Strength',
              correlation.correlationStrength,
              AppColors.cyan,
            ),
            const SizedBox(height: 8),

            // Synchronized Movement
            _buildProgressRow(
              'Synchronized Movement',
              correlation.synchronizedMovementProbability,
              AppColors.imperialPurple,
            ),

            if (correlation.dxyCorrelation != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              _buildCorrelationDetail(
                'DXY Correlation',
                correlation.dxyCorrelation!,
              ),
            ],

            if (correlation.bondsCorrelation != null) ...[
              const SizedBox(height: 8),
              _buildCorrelationDetail(
                'Bonds Correlation',
                correlation.bondsCorrelation!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressRow(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            Text(
              '${(value * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: AppColors.backgroundSecondary,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildCorrelationDetail(String label, dynamic correlationData) {
    final coefficient = correlationData.coefficient as double;
    final isSignificant = correlationData.isSignificant as bool;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Row(
          children: [
            Text(
              coefficient.toStringAsFixed(3),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: coefficient > 0 ? AppColors.buy : AppColors.sell,
              ),
            ),
            if (isSignificant) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.buy.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'SIG',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.buy,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Color _getConditionColor(dynamic condition) {
    final conditionName = condition.toString().split('.').last;
    switch (conditionName) {
      case 'stable':
        return AppColors.buy;
      case 'trending':
        return AppColors.cyan;
      case 'meanReverting':
        return AppColors.warning;
      case 'chaotic':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getCorrelationDirectionColor(dynamic direction) {
    final directionName = direction.toString().split('.').last;
    switch (directionName) {
      case 'bullish':
        return AppColors.buy;
      case 'bearish':
        return AppColors.sell;
      case 'neutral':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      title: 'لا يوجد تحليل كمومي بعد',
      message: 'اضغط الزر أدناه لإنشاء أول تحليل',
      icon: Icons.psychology_outlined,
      onAction: () {
        _triggerAnalysisWithTimeout();
      },
      actionLabel: 'إنشاء تحليل كمومي',
    );
  }
}
