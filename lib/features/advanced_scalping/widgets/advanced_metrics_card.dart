import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class AdvancedMetricsCard extends StatelessWidget {
  final Map<String, dynamic> indicators;

  const AdvancedMetricsCard({
    super.key,
    required this.indicators,
  });

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
              Icon(Icons.show_chart, color: AppColors.royalGold, size: 24),
              const SizedBox(width: 8),
              Text(
                'المؤشرات المتقدمة',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (indicators.containsKey('rsi'))
            _buildIndicatorRow('RSI', _extractValue(indicators['rsi'])),
          if (indicators.containsKey('macd'))
            _buildIndicatorRow('MACD', _extractValue(indicators['macd'])),
          if (indicators.containsKey('atr'))
            _buildIndicatorRow('ATR', _extractValue(indicators['atr'])),
          if (indicators.containsKey('adx'))
            _buildIndicatorRow('ADX', _extractValue(indicators['adx'])),
        ],
      ),
    );
  }

  String _extractValue(dynamic value) {
    if (value is Map && value.containsKey('value')) {
      return value['value'].toStringAsFixed(2);
    }
    if (value is num) {
      return value.toStringAsFixed(2);
    }
    return value.toString();
  }

  Widget _buildIndicatorRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}


