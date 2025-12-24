import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/unified_metrics_model.dart';

class UnifiedMetricsCard extends StatelessWidget {
  final UnifiedMetricsModel metrics;

  const UnifiedMetricsCard({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
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
              Icon(
                Icons.analytics_outlined,
                color: AppColors.royalGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'مؤشرات موحدة',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'التقلب',
                  '${metrics.volatility.toStringAsFixed(2)}%',
                  Icons.show_chart,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'الزخم',
                  '${metrics.momentum.toStringAsFixed(2)}%',
                  Icons.speed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'NEXUS Score',
                  '${metrics.nexusScore.toStringAsFixed(1)}/10',
                  Icons.auto_awesome,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'KABOUS ML',
                  '${metrics.kabousMLScore.toStringAsFixed(0)}%',
                  Icons.psychology,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: metrics.agreement == 'AGREE'
                  ? AppColors.buy.withValues(alpha: 0.1)
                  : metrics.agreement == 'DISAGREE'
                      ? AppColors.sell.withValues(alpha: 0.1)
                      : AppColors.royalGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  metrics.agreement == 'AGREE'
                      ? Icons.check_circle
                      : metrics.agreement == 'DISAGREE'
                          ? Icons.cancel
                          : Icons.help_outline,
                  color: metrics.agreement == 'AGREE'
                      ? AppColors.buy
                      : metrics.agreement == 'DISAGREE'
                          ? AppColors.sell
                          : AppColors.royalGold,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  metrics.agreement == 'AGREE'
                      ? 'اتفاق بين النظامين'
                      : metrics.agreement == 'DISAGREE'
                          ? 'اختلاف بين النظامين'
                          : 'اتفاق جزئي',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.royalGold),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
