import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../services/kabous_pro/kabous_models.dart';

class BacktestResultsCard extends StatelessWidget {
  final BacktestResult result;

  const BacktestResultsCard({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.darkGradient,
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
              Icon(Icons.analytics, color: AppColors.royalGold, size: 24),
              const SizedBox(width: 8),
              Text(
                'نتائج Backtesting',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Performance Stats
          _buildStatRow('إجمالي الصفقات', result.totalTrades.toString()),
          _buildStatRow('نسبة الفوز', '${result.winRate.toStringAsFixed(1)}%'),
          _buildStatRow('الربح الإجمالي', '\$${result.totalPnl.toStringAsFixed(2)}'),
          _buildStatRow('العائد', '${result.totalPnlPercentage >= 0 ? '+' : ''}${result.totalPnlPercentage.toStringAsFixed(2)}%'),
          
          const Divider(height: 24, color: AppColors.textTertiary),
          
          // Risk Metrics
          _buildStatRow('Max Drawdown', '${result.maxDrawdown.toStringAsFixed(2)}%'),
          _buildStatRow('Sharpe Ratio', result.sharpeRatio.toStringAsFixed(2)),
          _buildStatRow('Profit Factor', result.profitFactor.toStringAsFixed(2)),
          
          const Divider(height: 24, color: AppColors.textTertiary),
          
          // Win/Loss Stats
          _buildStatRow('متوسط الربح', '\$${result.avgWin.toStringAsFixed(2)}'),
          _buildStatRow('متوسط الخسارة', '\$${result.avgLoss.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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


