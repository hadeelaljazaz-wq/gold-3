import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../services/kabous_pro/kabous_models.dart';

class MultitimeframeCard extends StatelessWidget {
  final MultiTimeframeResult result;

  const MultitimeframeCard({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.imperialPurple.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, color: AppColors.royalGold, size: 24),
              const SizedBox(width: 8),
              Text(
                'تحليل متعدد الأطر',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Overall Signal
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: result.overallSignal == 'BUY'
                  ? AppColors.buy.withValues(alpha: 0.2)
                  : result.overallSignal == 'SELL'
                      ? AppColors.sell.withValues(alpha: 0.2)
                      : AppColors.textTertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الإشارة الإجمالية',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  result.overallSignal,
                  style: AppTypography.titleMedium.copyWith(
                    color: result.overallSignal == 'BUY'
                        ? AppColors.buy
                        : result.overallSignal == 'SELL'
                            ? AppColors.sell
                            : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Stats
          _buildStatRow('الثقة', '${result.overallConfidence.toStringAsFixed(1)}%'),
          _buildStatRow('التوافق', '${result.alignmentScore.toStringAsFixed(1)}/10'),
          
          const SizedBox(height: 12),
          
          // Recommendation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              result.recommendation,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Timeframes
          ...result.timeframes.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildTimeframeRow(entry.key, entry.value),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

  Widget _buildTimeframeRow(String tf, TimeframeAnalysis analysis) {
    return Row(
      children: [
        Container(
          width: 40,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.textTertiary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            tf,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: analysis.signal == 'BUY'
                      ? AppColors.buy
                      : analysis.signal == 'SELL'
                          ? AppColors.sell
                          : AppColors.textTertiary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                analysis.signal,
                style: AppTypography.labelMedium.copyWith(
                  color: analysis.signal == 'BUY'
                      ? AppColors.buy
                      : analysis.signal == 'SELL'
                          ? AppColors.sell
                          : AppColors.textTertiary,
                ),
              ),
              const Spacer(),
              Text(
                '${analysis.confidence.toStringAsFixed(0)}%',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


