import 'package:flutter/material.dart';
import '../models/support_resistance_level.dart';
import '../core/theme/royal_colors.dart';
import '../core/theme/royal_typography.dart';
import '../widgets/glass_card.dart';
import 'package:intl/intl.dart';

/// 📊 Real Levels Display Widget
/// عرض مستويات الدعم والمقاومة الحقيقية من البيانات التاريخية
class RealLevelsDisplay extends StatelessWidget {
  final RealSupportResistance levels;
  final double currentPrice;

  const RealLevelsDisplay({
    super.key,
    required this.levels,
    required this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: RoyalColors.goldGradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: RoyalColors.goldNeonGlow,
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Colors.black,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          RoyalColors.goldGradient.createShader(bounds),
                      child: Text(
                        '📊 مستويات حقيقية',
                        style: RoyalTypography.h3.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      'من ${levels.totalPivotsAnalyzed} نقطة ارتداد تاريخية',
                      style: RoyalTypography.labelSmall.copyWith(
                        color: RoyalColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),

          // Resistances (المقاومات)
          if (levels.resistances.isNotEmpty) ...[
            _buildSectionHeader('🔴 مقاومات قوية', RoyalColors.crimsonRed),
            const SizedBox(height: 12),
            ...levels.resistances.take(3).map((level) => _buildLevelRow(
                  level,
                  currentPrice,
                  RoyalColors.crimsonRed,
                )),
            const SizedBox(height: 20),
          ],

          // Supports (الدعوم)
          if (levels.supports.isNotEmpty) ...[
            _buildSectionHeader('🟢 دعوم قوية', RoyalColors.neonGreen),
            const SizedBox(height: 12),
            ...levels.supports.take(3).map((level) => _buildLevelRow(
                  level,
                  currentPrice,
                  RoyalColors.neonGreen,
                )),
          ],

          // Footer info
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: RoyalColors.deepPurple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: RoyalColors.deepPurple.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: RoyalColors.royalGold,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'المستويات مستخرجة من البيانات التاريخية الحقيقية',
                    style: RoyalTypography.labelSmall.copyWith(
                      color: RoyalColors.secondaryText,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: RoyalTypography.h4.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLevelRow(
    SupportResistanceLevel level,
    double currentPrice,
    Color color,
  ) {
    final distance = (level.price - currentPrice).abs();
    final distancePercent = (distance / currentPrice) * 100;
    final dateFormat = DateFormat('dd/MM HH:mm', 'ar');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Price
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${level.price.toStringAsFixed(2)}',
                  style: RoyalTypography.h3.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${distance.toStringAsFixed(1)}\$ بعيد (${distancePercent.toStringAsFixed(2)}%)',
                  style: RoyalTypography.labelSmall.copyWith(
                    color: RoyalColors.secondaryText,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // Strength
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(
                  Icons.verified,
                  size: 16,
                  color: level.isStrong ? color : color.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  '${level.strength}×',
                  style: RoyalTypography.labelMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Last test
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'آخر اختبار:',
                  style: RoyalTypography.labelSmall.copyWith(
                    color: RoyalColors.secondaryText,
                    fontSize: 9,
                  ),
                ),
                Text(
                  dateFormat.format(level.lastTest),
                  style: RoyalTypography.labelSmall.copyWith(
                    color: color.withValues(alpha: 0.8),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

