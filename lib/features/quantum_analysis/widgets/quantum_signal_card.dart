import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/quantum_scalping/quantum_scalping_engine.dart';
import '../../../core/utils/logger.dart';

/// 🚀 Quantum Signal Card
/// البطاقة الرئيسية لعرض الإشارة الكمومية
class QuantumSignalCard extends StatelessWidget {
  final QuantumSignal signal;

  const QuantumSignalCard({
    super.key,
    required this.signal,
  });

  @override
  Widget build(BuildContext context) {
    // 🔍 DEBUG: Log quantum signal display
    AppLogger.info('📊 QuantumSignalCard Display:');
    AppLogger.info('   Direction: ${signal.direction.name}');
    AppLogger.info('   Entry: \$${signal.entry}');
    AppLogger.info('   Stop Loss: \$${signal.stopLoss}');
    AppLogger.info('   Take Profit: \$${signal.takeProfit}');
    
    // Validate logic
    final entry = signal.entry;
    final sl = signal.stopLoss;
    final tp = signal.takeProfit;
    
    if (signal.direction == SignalDirection.buy && !(sl < entry && tp > entry)) {
      AppLogger.error('❌ QUANTUM BUY signal but prices wrong: SL($sl) should be < Entry($entry) < TP($tp)');
    } else if (signal.direction == SignalDirection.sell && !(sl > entry && tp < entry)) {
      AppLogger.error('❌ QUANTUM SELL signal but prices wrong: TP($tp) should be < Entry($entry) < SL($sl)');
    } else if (signal.direction != SignalDirection.neutral) {
      AppLogger.success('✅ QUANTUM Signal prices are logically correct');
    }
    
    final directionColor = signal.direction == SignalDirection.buy
        ? AppColors.buy
        : signal.direction == SignalDirection.sell
            ? AppColors.sell
            : AppColors.textSecondary;

    final qualityColor = _getQualityColor(signal.tradeQuality);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: directionColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Direction + Quality
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Direction Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: directionColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        signal.direction == SignalDirection.buy
                            ? Icons.arrow_upward
                            : signal.direction == SignalDirection.sell
                                ? Icons.arrow_downward
                                : Icons.remove,
                        color: directionColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        signal.direction.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: directionColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Quality Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: qualityColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    signal.tradeQuality.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: qualityColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Main Metrics Grid
            Row(
              children: [
                // Entry Price
                Expanded(
                  child: _buildMetricBox(
                    context,
                    'Entry',
                    '\$${signal.entry.toStringAsFixed(2)}',
                    AppColors.cyan,
                  ),
                ),
                const SizedBox(width: 12),

                // Stop Loss
                Expanded(
                  child: _buildMetricBox(
                    context,
                    'Stop Loss',
                    '\$${signal.stopLoss.toStringAsFixed(2)}',
                    AppColors.error,
                  ),
                ),
                const SizedBox(width: 12),

                // Take Profit
                Expanded(
                  child: _buildMetricBox(
                    context,
                    'Take Profit',
                    '\$${signal.takeProfit.toStringAsFixed(2)}',
                    AppColors.buy,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Secondary Metrics
            Row(
              children: [
                // Confidence
                Expanded(
                  child: _buildProgressMetric(
                    context,
                    'Confidence',
                    signal.confidence,
                    AppColors.imperialPurple,
                  ),
                ),
                const SizedBox(width: 12),

                // Position Size
                Expanded(
                  child: _buildProgressMetric(
                    context,
                    'Position Size',
                    signal.positionSize,
                    AppColors.warning,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // R/R Ratio & Expected Return
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    context,
                    'Risk/Reward',
                    '1:${signal.riskRewardRatio.toStringAsFixed(2)}',
                    AppColors.cyan,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoRow(
                    context,
                    'Expected Return',
                    '${signal.expectedReturn.toStringAsFixed(1)} pips',
                    signal.expectedReturn > 0 ? AppColors.buy : AppColors.sell,
                  ),
                ),
              ],
            ),

            if (signal.reasoning.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // Reasoning
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      signal.reasoning,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                    ),
                  ),
                ],
              ),
            ],

            if (signal.alerts.isNotEmpty) ...[
              const SizedBox(height: 12),

              // Alerts
              ...signal.alerts.map((alert) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.warning,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              alert,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            ],

            const SizedBox(height: 16),

            // Action Recommendation
            if (signal.shouldTrade)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: signal.isStrong
                        ? [AppColors.buy, AppColors.buy.withValues(alpha: 0.7)]
                        : [
                            AppColors.cyan,
                            AppColors.cyan.withValues(alpha: 0.7)
                          ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      signal.isStrong
                          ? '✅ STRONG SIGNAL - RECOMMENDED'
                          : signal.isGood
                              ? '✅ GOOD SIGNAL - CONSIDER'
                              : '⚠️ ACCEPTABLE - USE CAUTION',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.cancel,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '❌ NOT RECOMMENDED - WAIT FOR BETTER SETUP',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBox(
      BuildContext context, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressMetric(
      BuildContext context, String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            Text(
              '${(value * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: AppColors.backgroundSecondary,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
      BuildContext context, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getQualityColor(dynamic quality) {
    final qualityName = quality.toString().split('.').last;
    switch (qualityName) {
      case 'excellent':
        return AppColors.buy;
      case 'good':
        return AppColors.cyan;
      case 'acceptable':
        return AppColors.warning;
      case 'poor':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
