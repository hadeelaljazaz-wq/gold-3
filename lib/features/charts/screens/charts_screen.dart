import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/chart_data_provider.dart';
import '../widgets/candlestick_chart.dart';
import '../widgets/indicators_chart.dart';
import '../../../widgets/shared_widgets.dart';
import '../../../widgets/animations/slide_in_card.dart';
import '../../royal_analysis/providers/royal_analysis_provider.dart';

class ChartsScreen extends ConsumerStatefulWidget {
  const ChartsScreen({super.key});

  @override
  ConsumerState<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends ConsumerState<ChartsScreen> {
  String selectedTimeframe = '1H';
  String selectedIndicator = 'RSI';

  @override
  Widget build(BuildContext context) {
    final chartState = ref.watch(chartDataProvider);
    final royalState = ref.watch(royalAnalysisProvider);

    // Extract Support/Resistance levels from Royal Analysis
    final supportResistanceLevels = _extractSupportResistanceLevels(royalState);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.goldGradient.createShader(bounds),
              child: const Text(
                'الرسوم البيانية',
                style: AppTypography.titleLarge,
              ),
            ),
            Text(
              'Charts & Technical Analysis',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: chartState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textPrimary,
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: chartState.isLoading
                ? null
                : () {
                    ref.read(chartDataProvider.notifier).refresh();
                  },
          ),
        ],
      ),
      body: chartState.error != null
          ? ErrorStateWidget(
              message: chartState.error!,
              onRetry: () {
                ref.read(chartDataProvider.notifier).refresh();
              },
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Timeframe Selector
                  SlideInCard(
                    delay: const Duration(milliseconds: 100),
                    child: _buildTimeframeSelector(),
                  ),
                  const SizedBox(height: 16),

                  // Main Candlestick Chart
                  SlideInCard(
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      height: 400,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: chartState.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : CandlestickChart(
                              data: chartState.historicalData,
                              title: 'XAUUSD - ${chartState.timeframe}',
                              supportResistanceLevels: supportResistanceLevels,
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Indicator Selector
                  SlideInCard(
                    delay: const Duration(milliseconds: 300),
                    child: _buildIndicatorSelector(),
                  ),
                  const SizedBox(height: 16),

                  // Indicator Chart
                  SlideInCard(
                    delay: const Duration(milliseconds: 400),
                    child: IndicatorsChart(
                      data: chartState.historicalData,
                      indicator: selectedIndicator,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Chart Info
                  SlideInCard(
                    delay: const Duration(milliseconds: 500),
                    child: _buildChartInfo(chartState),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildTimeframeSelector() {
    final timeframes = ['1H', '4H', '1D', '1W', '1M'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الإطار الزمني',
            style: AppTypography.titleSmall,
          ),
          Text(
            'Timeframe',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: timeframes.map((tf) {
              final isSelected = tf == selectedTimeframe;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedTimeframe = tf;
                      });
                      ref.read(chartDataProvider.notifier).changeTimeframe(tf);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.royalGold.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.royalGold
                              : AppColors.borderColor,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          tf,
                          style: AppTypography.bodyMedium.copyWith(
                            color: isSelected
                                ? AppColors.royalGold
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorSelector() {
    final indicators = ['RSI', 'MACD', 'Volume'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المؤشرات الفنية',
            style: AppTypography.titleSmall,
          ),
          Text(
            'Technical Indicators',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: indicators.map((ind) {
              final isSelected = ind == selectedIndicator;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedIndicator = ind;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.royalGold.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.royalGold
                              : AppColors.borderColor,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          ind,
                          style: AppTypography.bodyMedium.copyWith(
                            color: isSelected
                                ? AppColors.royalGold
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChartInfo(ChartDataState state) {
    if (state.historicalData.isEmpty) {
      return const SizedBox.shrink();
    }

    final latestPoint = state.historicalData.last;
    final change = latestPoint.close - latestPoint.open;
    final changePercent = (change / latestPoint.open) * 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات السوق',
            style: AppTypography.titleSmall,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                  'Open', '\$${latestPoint.open.toStringAsFixed(2)}'),
              _buildInfoItem(
                  'High', '\$${latestPoint.high.toStringAsFixed(2)}'),
              _buildInfoItem('Low', '\$${latestPoint.low.toStringAsFixed(2)}'),
              _buildInfoItem(
                  'Close', '\$${latestPoint.close.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                'Change',
                '${change >= 0 ? '+' : ''}\$${change.toStringAsFixed(2)}',
                color: change >= 0 ? AppColors.success : AppColors.error,
              ),
              _buildInfoItem(
                'Change %',
                '${changePercent >= 0 ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
                color: changePercent >= 0 ? AppColors.success : AppColors.error,
              ),
              _buildInfoItem('Data Points', '${state.historicalData.length}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: color ?? AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Extract Support/Resistance levels from Royal Analysis
  List<SupportResistanceLevel> _extractSupportResistanceLevels(
      RoyalAnalysisState royalState) {
    final levels = <SupportResistanceLevel>[];

    // Check if analysis is available
    if (!royalState.hasAnalysis) return levels;

    final scalpSignal = royalState.scalp!;
    final swingSignal = royalState.swing!;

    // Extract from SCALP signal (if valid)
    if (scalpSignal.isValid && scalpSignal.entryPrice != null) {
      // Entry level
      levels.add(SupportResistanceLevel(
        price: scalpSignal.entryPrice!,
        isSupport: scalpSignal.isBuy,
        label: 'Scalp Entry',
        strength: 0.7,
      ));

      // Stop Loss
      if (scalpSignal.stopLoss != null) {
        levels.add(SupportResistanceLevel(
          price: scalpSignal.stopLoss!,
          isSupport: scalpSignal.isSell,
          label: 'Scalp SL',
          strength: 0.8,
        ));
      }

      // Take Profit
      if (scalpSignal.takeProfit != null) {
        levels.add(SupportResistanceLevel(
          price: scalpSignal.takeProfit!,
          isSupport: scalpSignal.isBuy,
          label: 'Scalp TP',
          strength: 0.9,
        ));
      }
    }

    // Extract from SWING signal (if valid)
    if (swingSignal.isValid && swingSignal.entryPrice != null) {
      // Entry level
      levels.add(SupportResistanceLevel(
        price: swingSignal.entryPrice!,
        isSupport: swingSignal.isBuy,
        label: 'Swing Entry',
        strength: 0.6,
      ));

      // Stop Loss
      if (swingSignal.stopLoss != null) {
        levels.add(SupportResistanceLevel(
          price: swingSignal.stopLoss!,
          isSupport: swingSignal.isSell,
          label: 'Swing SL',
          strength: 0.7,
        ));
      }

      // Take Profit
      if (swingSignal.takeProfit != null) {
        levels.add(SupportResistanceLevel(
          price: swingSignal.takeProfit!,
          isSupport: swingSignal.isBuy,
          label: 'Swing TP',
          strength: 0.8,
        ));
      }
    }

    return levels;
  }
}
