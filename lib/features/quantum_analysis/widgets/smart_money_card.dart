import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/quantum_scalping/smart_money_tracker.dart';

/// 💰 Smart Money Card
/// بطاقة عرض تدفق الأموال الذكية
class SmartMoneyCard extends StatelessWidget {
  final SmartMoneyFlow smartMoneyFlow;

  const SmartMoneyCard({
    super.key,
    required this.smartMoneyFlow,
  });

  @override
  Widget build(BuildContext context) {
    final directionColor =
        _getDirectionColor(smartMoneyFlow.smartMoneyDirection);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.cyan,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smart Money Flow',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        'Institutional Money Tracking',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                if (smartMoneyFlow.isActive)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.buy.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'ACTIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.buy,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // Direction & Strength
            Row(
              children: [
                Expanded(
                  child: _buildDirectionBox(
                    context,
                    smartMoneyFlow.smartMoneyDirection,
                    directionColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStrengthBox(
                    context,
                    smartMoneyFlow.smartMoneyStrength,
                    smartMoneyFlow.confidence,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Volume Delta
            _buildMetricRow(
              context,
              'Volume Delta',
              '\$${smartMoneyFlow.volumeDelta.toStringAsFixed(1)}M',
              smartMoneyFlow.volumeDelta,
              AppColors.cyan,
            ),

            const SizedBox(height: 12),

            // Order Flow Imbalance
            _buildMetricRow(
              context,
              'Order Flow Imbalance',
              '${smartMoneyFlow.orderFlowImbalance.toStringAsFixed(2)}',
              (smartMoneyFlow.orderFlowImbalance - 1).abs() /
                  2, // Normalize to 0-1
              smartMoneyFlow.orderFlowImbalance > 1
                  ? AppColors.buy
                  : AppColors.sell,
            ),

            const SizedBox(height: 12),

            // Accumulation/Distribution
            _buildMetricRow(
              context,
              'Accumulation/Distribution',
              '\$${smartMoneyFlow.accumulationDistribution.toStringAsFixed(1)}M',
              smartMoneyFlow.accumulationDistribution.abs() / 100, // Normalize
              smartMoneyFlow.accumulationDistribution > 0
                  ? AppColors.buy
                  : AppColors.sell,
            ),

            const SizedBox(height: 16),

            // Whale Activity Section
            if (smartMoneyFlow.hasWhales) ...[
              const Divider(),
              const SizedBox(height: 12),
              _buildWhaleActivity(context, smartMoneyFlow.whaleActivity),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionBox(
      BuildContext context, SmartMoneyDirection direction, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            direction == SmartMoneyDirection.buying
                ? Icons.trending_up
                : direction == SmartMoneyDirection.selling
                    ? Icons.trending_down
                    : Icons.trending_flat,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            direction.name.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            'Direction',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthBox(
      BuildContext context, double strength, double confidence) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.imperialPurple.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            '${(strength * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.imperialPurple,
            ),
          ),
          Text(
            'Strength',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: confidence,
              backgroundColor: AppColors.backgroundPrimary,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.cyan),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Confidence: ${(confidence * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 9,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context,
    String label,
    String value,
    double progress,
    Color color,
  ) {
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
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: AppColors.backgroundSecondary,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildWhaleActivity(
      BuildContext context, WhaleActivity whaleActivity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '🐋',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Text(
              'Whale Activity Detected',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Whale Stats
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cyan.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildWhaleStatColumn(
                    context,
                    'Total Whales',
                    whaleActivity.totalWhales.toString(),
                    AppColors.cyan,
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: AppColors.backgroundSecondary,
                  ),
                  _buildWhaleStatColumn(
                    context,
                    'Bullish',
                    whaleActivity.bullishWhales.toString(),
                    AppColors.buy,
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: AppColors.backgroundSecondary,
                  ),
                  _buildWhaleStatColumn(
                    context,
                    'Bearish',
                    whaleActivity.bearishWhales.toString(),
                    AppColors.sell,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: whaleActivity.areBullish
                      ? AppColors.buy.withValues(alpha: 0.2)
                      : whaleActivity.areBearish
                          ? AppColors.sell.withValues(alpha: 0.2)
                          : AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      whaleActivity.areBullish
                          ? Icons.arrow_upward
                          : whaleActivity.areBearish
                              ? Icons.arrow_downward
                              : Icons.remove,
                      size: 16,
                      color: whaleActivity.areBullish
                          ? AppColors.buy
                          : whaleActivity.areBearish
                              ? AppColors.sell
                              : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      whaleActivity.areBullish
                          ? 'Whales are BULLISH'
                          : whaleActivity.areBearish
                              ? 'Whales are BEARISH'
                              : 'Whales are NEUTRAL',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: whaleActivity.areBullish
                            ? AppColors.buy
                            : whaleActivity.areBearish
                                ? AppColors.sell
                                : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWhaleStatColumn(
      BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
        ),
      ],
    );
  }

  Color _getDirectionColor(SmartMoneyDirection direction) {
    switch (direction) {
      case SmartMoneyDirection.buying:
        return AppColors.buy;
      case SmartMoneyDirection.selling:
        return AppColors.sell;
      case SmartMoneyDirection.neutral:
        return AppColors.textSecondary;
    }
  }
}
