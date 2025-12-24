import 'package:flutter/material.dart';
import '../../../services/support_resistance_service.dart';
import '../../../core/theme/app_colors.dart';

class SupportResistanceCard extends StatelessWidget {
  final SupportResistanceAnalysis analysis;
  final double currentPrice;

  const SupportResistanceCard({
    super.key,
    required this.analysis,
    required this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.insights, color: AppColors.info),
                const SizedBox(width: 8),
                const Text(
                  'مستويات الدعم والمقاومة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Current Price
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'السعر الحالي: ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '\$${currentPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Nearest Resistance
            if (analysis.nearestResistance != null) ...[
              _buildLevelItem(
                'أقرب مقاومة',
                analysis.nearestResistance!,
                AppColors.sell,
                isNearest: true,
              ),
              const SizedBox(height: 12),
            ],

            // Nearest Support
            if (analysis.nearestSupport != null) ...[
              _buildLevelItem(
                'أقرب دعم',
                analysis.nearestSupport!,
                AppColors.buy,
                isNearest: true,
              ),
              const SizedBox(height: 16),
            ],

            // Divider
            const Divider(),
            const SizedBox(height: 12),

            // All Resistances
            if (analysis.resistances.isNotEmpty) ...[
              _buildSectionTitle('مستويات المقاومة', Colors.red),
              const SizedBox(height: 8),
              ...analysis.resistances.take(3).map((level) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildCompactLevel(level, Colors.red),
                  )),
              const SizedBox(height: 12),
            ],

            // All Supports
            if (analysis.supports.isNotEmpty) ...[
              _buildSectionTitle('مستويات الدعم', Colors.green),
              const SizedBox(height: 8),
              ...analysis.supports.take(3).map((level) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildCompactLevel(level, Colors.green),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLevelItem(
    String label,
    SupportResistanceLevel level,
    Color color, {
    bool isNearest = false,
  }) {
    final distance = (level.price - currentPrice).abs();
    final distancePercent = (distance / currentPrice * 100);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: isNearest ? Border.all(color: color, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                '\$${level.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                level.source,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
              Text(
                '${distancePercent.toStringAsFixed(2)}% بعيد',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _buildStrengthBar(level.strength, color),
              const SizedBox(width: 8),
              Text(
                'القوة: ${level.strength}%',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLevel(SupportResistanceLevel level, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '\$${level.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
        Text(
          level.source,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 8),
        _buildStrengthBar(level.strength, color, compact: true),
      ],
    );
  }

  Widget _buildStrengthBar(int strength, Color color, {bool compact = false}) {
    return Container(
      width: compact ? 40 : 80,
      height: compact ? 4 : 6,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: strength / 100,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
