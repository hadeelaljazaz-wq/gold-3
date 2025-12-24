import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/royal_analysis_provider.dart';

class MarketMetricsPanel extends StatelessWidget {
  final MarketMetrics metrics;

  const MarketMetricsPanel({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.royalGold.withValues(alpha: 0.15),
            AppColors.imperialPurple.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.royalGold.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: AppColors.royalGold, size: 24),
              const SizedBox(width: 8),
              Text(
                'مقاييس السوق',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Volatility
          _buildMetricRow(
            icon: Icons.trending_up,
            label: 'التذبذب (Volatility)',
            value: '${metrics.volatility.toStringAsFixed(2)}%',
            color: metrics.volatility > 2
                ? AppColors.sell
                : metrics.volatility > 1
                    ? Colors.orange
                    : AppColors.buy,
          ),

          const SizedBox(height: 12),

          // Momentum
          _buildMetricRow(
            icon: Icons.speed,
            label: 'الزخم (Momentum)',
            value: '${metrics.momentum >= 0 ? '+' : ''}${metrics.momentum.toStringAsFixed(2)}%',
            color: metrics.momentum > 0 ? AppColors.buy : AppColors.sell,
          ),

          const SizedBox(height: 12),

          // Volume
          _buildMetricRow(
            icon: Icons.bar_chart,
            label: 'متوسط الحجم',
            value: metrics.volume.toStringAsFixed(0),
            color: AppColors.textPrimary,
          ),

          const SizedBox(height: 12),

          // Trend
          _buildMetricRow(
            icon: Icons.show_chart,
            label: 'الاتجاه',
            value: _getTrendText(metrics.trend),
            color: _getTrendColor(metrics.trend),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getTrendText(String trend) {
    switch (trend) {
      case 'UP':
        return 'صاعد';
      case 'DOWN':
        return 'نازل';
      case 'SIDEWAYS':
        return 'عرضي';
      default:
        return trend;
    }
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'UP':
        return AppColors.buy;
      case 'DOWN':
        return AppColors.sell;
      case 'SIDEWAYS':
        return AppColors.textTertiary;
      default:
        return AppColors.textPrimary;
    }
  }
}


