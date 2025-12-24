import 'package:flutter/material.dart';
import '../../../models/swing_signal.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/logger.dart';

class RoyalSwingCard extends StatelessWidget {
  final SwingSignal signal;

  const RoyalSwingCard({super.key, required this.signal});

  @override
  Widget build(BuildContext context) {
    // 🔍 DEBUG: Log unified swing signal display
    AppLogger.info('📊 UnifiedAnalysis RoyalSwingCard Display:');
    AppLogger.info('   Direction: ${signal.direction}');
    AppLogger.info('   Entry: \$${signal.entryPrice}');
    AppLogger.info('   Stop Loss: \$${signal.stopLoss}');
    AppLogger.info('   Take Profit: \$${signal.takeProfit}');
    
    // Validate logic
    if (signal.isValid && signal.entryPrice != null && signal.stopLoss != null && signal.takeProfit != null) {
      final entry = signal.entryPrice!;
      final sl = signal.stopLoss!;
      final tp = signal.takeProfit!;
      
      if (signal.direction == 'BUY' && !(sl < entry && tp > entry)) {
        AppLogger.error('❌ SWING BUY signal but prices wrong: SL($sl) should be < Entry($entry) < TP($tp)');
      } else if (signal.direction == 'SELL' && !(sl > entry && tp < entry)) {
        AppLogger.error('❌ SWING SELL signal but prices wrong: TP($tp) should be < Entry($entry) < SL($sl)');
      } else {
        AppLogger.success('✅ SWING Signal prices are logically correct');
      }
    }
    
    final isBuy = signal.direction == 'BUY';
    final isHold = signal.direction == 'HOLD' || signal.direction == 'NO_TRADE';
    final color = isHold
        ? AppColors.textSecondary
        : (isBuy ? AppColors.buy : AppColors.sell);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.imperialPurple.withValues(alpha: 0.15),
            AppColors.imperialPurple.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.imperialPurple.withValues(alpha: 0.3),
          width: 1.5,
        ),
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
                      gradient: AppColors.purpleGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.trending_up,
                      color: AppColors.royalGold,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Swing Trading',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'H1-H4 • Macro Trend',
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
            direction == 'BUY'
                ? Icons.trending_up
                : direction == 'SELL'
                    ? Icons.trending_down
                    : Icons.pause,
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
