import 'package:flutter/material.dart';
import '../../../models/scalping_signal.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/scalping_signal_model.dart';

class ComparisonCard extends StatelessWidget {
  final ScalpingSignal royalScalp;
  final ScalpingSignalModel advancedScalp;

  const ComparisonCard({
    super.key,
    required this.royalScalp,
    required this.advancedScalp,
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
            agreementColor.withValues(alpha: 0.1),
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
                'مقارنة النتائج',
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
            royalScalp.direction,
            advancedScalp.direction,
          ),
          const SizedBox(height: 12),
          _buildComparisonRow(
            'الثقة',
            '${royalScalp.confidence}%',
            '${advancedScalp.confidence.toStringAsFixed(0)}%',
          ),
          const SizedBox(height: 12),
          _buildComparisonRow(
            'Risk/Reward',
            '1:${(royalScalp.riskReward ?? 1.0).toStringAsFixed(2)}',
            '1:${advancedScalp.riskReward.toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }

  String _checkAgreement() {
    if (royalScalp.direction == advancedScalp.direction) {
      return 'AGREE';
    } else if (royalScalp.direction == 'NO_TRADE' ||
        advancedScalp.direction == 'NO_TRADE') {
      return 'PARTIAL';
    } else {
      return 'DISAGREE';
    }
  }

  Widget _buildComparisonRow(
    String label,
    String royalValue,
    String advancedValue,
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
              'Royal: $royalValue',
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
              'Advanced: $advancedValue',
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
