import 'package:flutter/material.dart';
import '../providers/trade_history_provider.dart';
import '../../../core/theme/app_colors.dart';
// ignore: unused_import
import '../../../core/theme/app_typography.dart';

class StatisticsCard extends StatelessWidget {
  final TradeHistoryState state;

  const StatisticsCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.goldGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.royalGold.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              const Icon(
                Icons.analytics_outlined,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'إحصائيات الأداء',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Main Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'إجمالي الربح',
                  '${state.totalProfit >= 0 ? '+' : ''}\$${state.totalProfit.toStringAsFixed(2)}',
                  state.totalProfit >= 0
                      ? Icons.trending_up
                      : Icons.trending_down,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  'معدل النجاح',
                  '${state.winRate.toStringAsFixed(1)}%',
                  Icons.percent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Secondary Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildSmallStatItem(
                  'إجمالي',
                  '${state.totalTrades}',
                  AppColors.textPrimary,
                ),
              ),
              Expanded(
                child: _buildSmallStatItem(
                  'مفتوحة',
                  '${state.openTrades}',
                  AppColors.warning,
                ),
              ),
              Expanded(
                child: _buildSmallStatItem(
                  'رابحة',
                  '${state.profitableTrades}',
                  AppColors.success,
                ),
              ),
              Expanded(
                child: _buildSmallStatItem(
                  'خاسرة',
                  '${state.lossTrades}',
                  AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Average Profit
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'متوسط الربح لكل صفقة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '\$${state.averageProfit.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ), // Column
      ), // Container
    ); // Card
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
