import 'package:flutter/material.dart';
import '../../../models/market_models.dart';
import '../../../core/theme/app_colors.dart';

class MarketIndicatorsCard extends StatelessWidget {
  final TechnicalIndicators indicators;

  const MarketIndicatorsCard({super.key, required this.indicators});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insights, color: AppColors.info),
                const SizedBox(width: 8),
                Text(
                  'المؤشرات الفنية',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildIndicator(
              context,
              'RSI',
              indicators.rsi.toStringAsFixed(2),
              indicators.rsiLevel,
              _getRSIColor(indicators.rsi),
            ),
            const Divider(height: 24),
            _buildIndicator(
              context,
              'MACD',
              indicators.macd.toStringAsFixed(2),
              indicators.macdTrend,
              indicators.macdBullish ? AppColors.buy : AppColors.sell,
            ),
            const Divider(height: 24),
            Text(
              'المتوسطات المتحركة',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMA('MA20', indicators.ma20, context),
                _buildMA('MA50', indicators.ma50, context),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMA('MA100', indicators.ma100, context),
                _buildMA('MA200', indicators.ma200, context),
              ],
            ),
            const Divider(height: 24),
            _buildIndicator(
              context,
              'ATR',
              indicators.atr.toStringAsFixed(2),
              'Volatility',
              AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(
    BuildContext context,
    String label,
    String value,
    String status,
    Color color,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  Widget _buildMA(String label, double value, BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Color _getRSIColor(double rsi) {
    if (rsi > 70) return AppColors.sell;
    if (rsi < 30) return AppColors.buy;
    return AppColors.info;
  }
}
