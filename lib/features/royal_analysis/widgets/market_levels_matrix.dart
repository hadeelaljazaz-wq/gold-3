import 'package:flutter/material.dart';
import '../../../core/theme/royal_colors.dart';
import '../../../core/theme/royal_typography.dart';
import '../../../widgets/glass_card.dart';
import '../../../services/pivot_point_calculator.dart';

/// 👑 Market Levels Matrix
///
/// مصفوفة مستويات السوق (الدعم والمقاومة)
///
/// **الميزات:**
/// - عرض مزدوج: المقاومات | الدعوم
/// - حدود بنفسجية متدرجة
/// - عرض المسافة من السعر الحالي
/// - مستويات من PivotPointCalculator
class MarketLevelsMatrix extends StatelessWidget {
  final PivotPointsResult pivotResult;
  final double currentPrice;

  const MarketLevelsMatrix({
    super.key,
    required this.pivotResult,
    required this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Resistance Card (Left)
        Expanded(
          child: PurpleGlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: RoyalColors.crimsonRed,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'RESISTANCE',
                      style: RoyalTypography.labelLarge.copyWith(
                        color: RoyalColors.crimsonRed,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: RoyalColors.deepPurple, thickness: 1),
                const SizedBox(height: 12),

                // Resistance Levels
                if (pivotResult.resistances.isEmpty)
                  Text(
                    'No nearby levels',
                    style: RoyalTypography.bodySmall.copyWith(
                      color: RoyalColors.mutedText,
                    ),
                  )
                else
                  ...pivotResult.resistances.map(
                    (level) => _buildLevelRow(
                      level.name,
                      level.price,
                      level.distanceFromPrice,
                      RoyalColors.crimsonRed,
                      true,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Support Card (Right)
        Expanded(
          child: PurpleGlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.trending_down,
                      color: RoyalColors.neonGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SUPPORT',
                      style: RoyalTypography.labelLarge.copyWith(
                        color: RoyalColors.neonGreen,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: RoyalColors.deepPurple, thickness: 1),
                const SizedBox(height: 12),

                // Support Levels
                if (pivotResult.supports.isEmpty)
                  Text(
                    'No nearby levels',
                    style: RoyalTypography.bodySmall.copyWith(
                      color: RoyalColors.mutedText,
                    ),
                  )
                else
                  ...pivotResult.supports.map(
                    (level) => _buildLevelRow(
                      level.name,
                      level.price,
                      level.distanceFromPrice,
                      RoyalColors.neonGreen,
                      false,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelRow(
    String name,
    double price,
    double distance,
    Color color,
    bool isResistance,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Level Name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
            ),
            child: Text(
              name,
              style: RoyalTypography.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Price & Distance
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${price.toStringAsFixed(2)}',
                style: RoyalTypography.numberMedium.copyWith(
                  color: RoyalColors.primaryText,
                ),
              ),
              Text(
                '${isResistance ? '+' : '-'}${distance.toStringAsFixed(1)} USD',
                style: RoyalTypography.labelSmall.copyWith(
                  color: RoyalColors.mutedText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 👑 Pivot Point Display Widget
/// عرض نقطة البيفوت الرئيسية
class PivotPointDisplay extends StatelessWidget {
  final double pivotPrice;
  final double currentPrice;

  const PivotPointDisplay({
    super.key,
    required this.pivotPrice,
    required this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    final isAbovePivot = currentPrice > pivotPrice;

    return CompactGlassCard(
      borderColor: RoyalColors.royalGold,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.adjust,
                color: RoyalColors.royalGold,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'PIVOT POINT',
                style: RoyalTypography.labelMedium.copyWith(
                  color: RoyalColors.royalGold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    RoyalColors.goldGradient.createShader(bounds),
                child: Text(
                  '\$${pivotPrice.toStringAsFixed(2)}',
                  style: RoyalTypography.numberLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isAbovePivot ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 12,
                    color: isAbovePivot
                        ? RoyalColors.neonGreen
                        : RoyalColors.crimsonRed,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isAbovePivot ? 'Above Pivot' : 'Below Pivot',
                    style: RoyalTypography.labelSmall.copyWith(
                      color: isAbovePivot
                          ? RoyalColors.neonGreen
                          : RoyalColors.crimsonRed,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
