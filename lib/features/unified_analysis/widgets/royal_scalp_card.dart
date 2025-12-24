import 'package:flutter/material.dart';
import '../../../models/scalping_signal.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/logger.dart';

class RoyalScalpCard extends StatelessWidget {
  final ScalpingSignal signal;
  final String title;

  const RoyalScalpCard({
    super.key,
    required this.signal,
    this.title = 'Royal Scalping',
  });

  @override
  Widget build(BuildContext context) {
    // 🔍 DEBUG: Log unified analysis display
    AppLogger.info('📊 UnifiedAnalysis RoyalScalpCard Display:');
    AppLogger.info('   Direction: ${signal.direction}');
    AppLogger.info('   Entry: \$${signal.entryPrice}');
    AppLogger.info('   Stop Loss: \$${signal.stopLoss}');
    AppLogger.info('   Take Profit: \$${signal.takeProfit}');
    
    final isBuy = signal.direction == 'BUY';
    final color = isBuy ? AppColors.buy : AppColors.sell;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.flash_on, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Micro-Trend • 5m-15m',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _buildConfidenceBadge(signal.confidence),
            ],
          ),
          const SizedBox(height: 16),
          _buildDirectionBadge(signal.direction, color),
          if (signal.isValid) ...[
            const SizedBox(height: 16),
            _buildPriceRow(
              'سعر الدخول',
              signal.entryPrice ?? 0,
              AppColors.textPrimary,
            ),
            if (signal.stopLoss != null) ...[
              const SizedBox(height: 12),
              _buildPriceRow('وقف الخسارة', signal.stopLoss!, AppColors.sell),
            ],
            if (signal.takeProfit != null) ...[
              const SizedBox(height: 12),
              _buildPriceRow('جني الأرباح', signal.takeProfit!, AppColors.buy),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundTertiary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Risk/Reward',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '1:${(signal.riskReward ?? 1.0).toStringAsFixed(2)}',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.royalGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfidenceBadge(int confidence) {
    Color badgeColor;
    if (confidence >= 80) {
      badgeColor = AppColors.buy;
    } else if (confidence >= 60) {
      badgeColor = AppColors.royalGold;
    } else {
      badgeColor = AppColors.sell;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$confidence%',
        style: AppTypography.labelMedium.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDirectionBadge(String direction, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            direction == 'BUY' ? Icons.trending_up : Icons.trending_down,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            direction,
            style: AppTypography.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double price, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          '\$${price.toStringAsFixed(2)}',
          style: AppTypography.bodyLarge.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
