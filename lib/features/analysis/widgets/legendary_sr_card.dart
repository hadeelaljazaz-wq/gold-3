/// 👑 Legendary Support/Resistance Card
///
/// كارت الدعوم والمقاومات الملكي
library;

import 'package:flutter/material.dart';
import '../../../core/theme/legendary_design_system.dart';

class LegendarySRCard extends StatelessWidget {
  final List<double> supports;
  final List<double> resistances;
  final double? currentPrice;

  const LegendarySRCard({
    super.key,
    required this.supports,
    required this.resistances,
    this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: LegendaryDesignSystem.buildRoyalCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Row(
            children: [
              LegendaryDesignSystem.buildGoldenIcon(Icons.analytics, size: 24),
              const SizedBox(width: 12),
              Text(
                '🎯 مستويات رئيسية',
                style: LegendaryDesignSystem.headlineSmall.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // المقاومات
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: LegendaryDesignSystem.rubyRed,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '🔴 المقاومات',
                style: LegendaryDesignSystem.bodyMedium.copyWith(
                  color: LegendaryDesignSystem.rubyRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ...resistances
              .take(3)
              .map(
                (level) => _buildLevelRow(
                  level,
                  LegendaryDesignSystem.rubyRed,
                  currentPrice,
                ),
              ),

          const SizedBox(height: 20),

          // الدعوم
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: LegendaryDesignSystem.emeraldGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '🟢 الدعوم',
                style: LegendaryDesignSystem.bodyMedium.copyWith(
                  color: LegendaryDesignSystem.emeraldGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ...supports
              .take(3)
              .map(
                (level) => _buildLevelRow(
                  level,
                  LegendaryDesignSystem.emeraldGreen,
                  currentPrice,
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildLevelRow(double level, Color color, double? currentPrice) {
    final distance = currentPrice != null ? (level - currentPrice).abs() : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '\$${level.toStringAsFixed(2)}',
            style: LegendaryDesignSystem.bodyLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (currentPrice != null)
            Text(
              '${distance.toStringAsFixed(2)}\$ away',
              style: LegendaryDesignSystem.bodySmall.copyWith(
                color: Colors.white60,
              ),
            ),
        ],
      ),
    );
  }
}
