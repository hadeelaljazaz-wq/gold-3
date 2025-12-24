import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/nexus_signal_model.dart';
import '../models/kabous_signal_model.dart';

class UnifiedComparisonCard extends StatelessWidget {
  final NexusSignalModel nexusScalp;
  final KabousSignalModel kabousScalp;

  const UnifiedComparisonCard({
    super.key,
    required this.nexusScalp,
    required this.kabousScalp,
  });

  @override
  Widget build(BuildContext context) {
    final agreement = _checkAgreement();
    final agreementColor = agreement == 'AGREE'
        ? AppColors.buy
        : agreement == 'DISAGREE'
            ? AppColors.sell
            : AppColors.royalGold;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            agreementColor.withValues(alpha: 0.15),
            agreementColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: agreementColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.compare_arrows, color: agreementColor, size: 24),
              const SizedBox(width: 12),
              Text(
                'مقارنة NEXUS vs KABOUS',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: agreementColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  agreement == 'AGREE'
                      ? Icons.check_circle
                      : agreement == 'DISAGREE'
                          ? Icons.cancel
                          : Icons.help_outline,
                  color: agreementColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  agreement == 'AGREE'
                      ? 'اتفاق في الاتجاه'
                      : agreement == 'DISAGREE'
                          ? 'اختلاف في الاتجاه'
                          : 'اتجاهات مختلفة',
                  style: AppTypography.titleMedium.copyWith(
                    color: agreementColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildComparisonRow(
            'الاتجاه',
            nexusScalp.direction,
            kabousScalp.direction,
          ),
          const SizedBox(height: 12),
          _buildComparisonRow(
            'NEXUS Score',
            '${nexusScalp.nexusScore.toStringAsFixed(1)}/10',
            '${kabousScalp.mlScore.toStringAsFixed(0)}% ML',
          ),
          const SizedBox(height: 12),
          _buildComparisonRow(
            'Risk/Reward',
            '1:${nexusScalp.riskReward.toStringAsFixed(2)}',
            '1:${kabousScalp.riskReward.toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }

  String _checkAgreement() {
    if (nexusScalp.direction == kabousScalp.direction) {
      return 'AGREE';
    } else if (nexusScalp.direction == 'NO_TRADE' ||
        kabousScalp.direction == 'NO_TRADE') {
      return 'PARTIAL';
    } else {
      return 'DISAGREE';
    }
  }

  Widget _buildComparisonRow(
    String label,
    String nexusValue,
    String kabousValue,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.imperialPurple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'NEXUS: $nexusValue',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.royalGold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'KABOUS: $kabousValue',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
