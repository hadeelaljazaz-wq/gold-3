import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/nexus_signal_model.dart';
import '../../../core/utils/logger.dart';

class NexusSignalCard extends StatelessWidget {
  final NexusSignalModel signal;
  final String title;

  const NexusSignalCard({super.key, required this.signal, required this.title});

  @override
  Widget build(BuildContext context) {
    // 🔍 DEBUG: Log nexus signal display
    AppLogger.info('📊 NexusSignalCard Display ($title):');
    AppLogger.info('   Direction: ${signal.direction}');
    AppLogger.info('   Entry: \$${signal.entryPrice}');
    AppLogger.info('   Stop Loss: \$${signal.stopLoss}');
    AppLogger.info('   Take Profit: \$${signal.takeProfit}');
    
    // Validate logic
    if (signal.isValid && signal.stopLoss != null && signal.takeProfit != null) {
      final entry = signal.entryPrice;
      final sl = signal.stopLoss!;
      final tp = signal.takeProfit!;
      
      if (signal.direction == 'BUY' && !(sl < entry && tp > entry)) {
        AppLogger.error('❌ NEXUS BUY signal but prices wrong: SL($sl) should be < Entry($entry) < TP($tp)');
      } else if (signal.direction == 'SELL' && !(sl > entry && tp < entry)) {
        AppLogger.error('❌ NEXUS SELL signal but prices wrong: TP($tp) should be < Entry($entry) < SL($sl)');
      } else {
        AppLogger.success('✅ NEXUS Signal prices are logically correct');
      }
    }
    
    final isBuy = signal.isBuy;
    final color = isBuy ? AppColors.buy : AppColors.sell;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.imperialPurple.withValues(alpha: 0.2),
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
                      Icons.auto_awesome,
                      color: AppColors.royalGold,
                      size: 20,
                    ),
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
                        'Quantum Engine • 11 Layers',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _buildNexusScoreBadge(signal.nexusScore),
            ],
          ),
          const SizedBox(height: 16),
          _buildDirectionBadge(signal.direction, color),
          if (signal.isValid) ...[
            const SizedBox(height: 16),
            _buildPriceRow(
              'سعر الدخول',
              signal.entryPrice,
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
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundTertiary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'NEXUS Score',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${signal.nexusScore.toStringAsFixed(1)}/10',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.royalGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundTertiary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Risk/Reward',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '1:${signal.riskReward.toStringAsFixed(2)}',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.royalGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNexusScoreBadge(double score) {
    Color badgeColor;
    if (score >= 8) {
      badgeColor = AppColors.buy;
    } else if (score >= 6) {
      badgeColor = AppColors.royalGold;
    } else {
      badgeColor = AppColors.sell;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor, width: 1.5),
      ),
      child: Text(
        '${score.toStringAsFixed(1)}/10',
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
