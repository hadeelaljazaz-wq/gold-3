import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/quantum_scalping/bayesian_probability_matrix.dart';

/// 🎲 Bayesian Probability Card
/// بطاقة عرض احتمالات بايز
class BayesianProbabilityCard extends StatelessWidget {
  final BayesianProbability probability;

  const BayesianProbabilityCard({
    super.key,
    required this.probability,
  });

  @override
  Widget build(BuildContext context) {
    final qualityColor = _getQualityColor(probability.tradeQuality);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.imperialPurple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.casino,
                    color: AppColors.imperialPurple,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bayesian Probability',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        'Statistical Success Probability',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: qualityColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    probability.tradeQuality.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: qualityColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Main Probability Display
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.imperialPurple.withValues(alpha: 0.2),
                    AppColors.imperialPurple.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.imperialPurple.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildProbabilityColumn(
                    context,
                    'Prior',
                    probability.priorProbability,
                    AppColors.cyan,
                  ),
                  const Icon(
                    Icons.arrow_forward,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  _buildProbabilityColumn(
                    context,
                    'Likelihood',
                    probability.likelihood,
                    AppColors.warning,
                  ),
                  const Icon(
                    Icons.arrow_forward,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  _buildProbabilityColumn(
                    context,
                    'Posterior',
                    probability.posteriorProbability,
                    AppColors.imperialPurple,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Evidence
            _buildMetricRow(
              context,
              'Evidence (Signal Strength)',
              probability.evidence,
              AppColors.cyan,
            ),

            const SizedBox(height: 12),

            // Confidence Level
            _buildMetricRow(
              context,
              'Confidence Level',
              probability.confidenceLevel,
              AppColors.buy,
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Trade Metrics
            Text(
              'Trade Metrics',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 12),

            // Risk/Reward Ratio
            Row(
              children: [
                Expanded(
                  child: _buildInfoBox(
                    context,
                    'Risk/Reward',
                    '1:${probability.riskRewardRatio.toStringAsFixed(2)}',
                    AppColors.cyan,
                    Icons.balance,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoBox(
                    context,
                    'Expected Return',
                    '${probability.expectedReturn.toStringAsFixed(1)} pips',
                    probability.expectedReturn > 0
                        ? AppColors.buy
                        : AppColors.sell,
                    Icons.trending_up,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Position Size (Kelly Criterion)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.pie_chart,
                    color: AppColors.warning,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Optimal Position Size',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(probability.optimalPositionSize * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Kelly Criterion',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Trade Quality Assessment
            _buildTradeQualityAssessment(context),
          ],
            ),
          ),
        ),
    );
  }

  Widget _buildProbabilityColumn(
    BuildContext context,
    String label,
    double value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          '${(value * 100).toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 24,
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

  Widget _buildMetricRow(
    BuildContext context,
    String label,
    double value,
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
              '${(value * 100).toStringAsFixed(0)}%',
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
            value: value,
            backgroundColor: AppColors.backgroundSecondary,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeQualityAssessment(BuildContext context) {
    final quality = probability.tradeQuality;
    final qualityColor = _getQualityColor(quality);

    String message;
    IconData icon;

    switch (quality) {
      case TradeQuality.excellent:
        message = '⭐ Excellent Trade Setup - High Probability + High R/R';
        icon = Icons.star;
        break;
      case TradeQuality.good:
        message = '✅ Good Trade Setup - Favorable Probability & Risk/Reward';
        icon = Icons.check_circle;
        break;
      case TradeQuality.acceptable:
        message = '⚠️ Acceptable Trade - Proceed with Caution';
        icon = Icons.warning;
        break;
      case TradeQuality.poor:
        message = '❌ Poor Trade Setup - Not Recommended';
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: qualityColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: qualityColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: qualityColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: qualityColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getQualityColor(TradeQuality quality) {
    switch (quality) {
      case TradeQuality.excellent:
        return AppColors.buy;
      case TradeQuality.good:
        return AppColors.cyan;
      case TradeQuality.acceptable:
        return AppColors.warning;
      case TradeQuality.poor:
        return AppColors.error;
    }
  }
}
