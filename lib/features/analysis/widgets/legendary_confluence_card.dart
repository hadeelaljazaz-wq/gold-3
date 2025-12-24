/// 👑 Legendary Confluence Card
///
/// كارت نقاط التقاء الاستراتيجيات
library;

import 'package:flutter/material.dart';
import '../../../core/theme/legendary_design_system.dart';

class LegendaryConfluenceCard extends StatelessWidget {
  final double confluenceScore;

  const LegendaryConfluenceCard({super.key, required this.confluenceScore});

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
              LegendaryDesignSystem.buildGoldenIcon(Icons.hub, size: 24),
              const SizedBox(width: 12),
              Text(
                '🎚️ نقاط التقاء الاستراتيجيات',
                style: LegendaryDesignSystem.headlineSmall.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // شريط التقدم
          LegendaryDesignSystem.buildConfidenceBar(confluenceScore),

          const SizedBox(height: 12),

          // الوصف
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getConfluenceDescription(confluenceScore),
                style: LegendaryDesignSystem.bodyMedium.copyWith(
                  color: Colors.white70,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getConfluenceColor(confluenceScore).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getConfluenceColor(confluenceScore),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  '${confluenceScore.toStringAsFixed(0)}%',
                  style: LegendaryDesignSystem.bodyLarge.copyWith(
                    color: _getConfluenceColor(confluenceScore),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // عدد الاستراتيجيات المتفقة
          Text(
            'التقاء من ${_getStrategyCount(confluenceScore)} استراتيجيات',
            style: LegendaryDesignSystem.bodySmall.copyWith(
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  String _getConfluenceDescription(double score) {
    if (score >= 85) return 'اتفاق قوي جداً - فرصة ممتازة';
    if (score >= 70) return 'اتفاق قوي - فرصة جيدة';
    if (score >= 60) return 'اتفاق متوسط';
    if (score >= 50) return 'اتفاق ضعيف';
    return 'لا يوجد اتفاق واضح';
  }

  Color _getConfluenceColor(double score) {
    if (score >= 85) return LegendaryDesignSystem.emeraldGreen;
    if (score >= 70) return LegendaryDesignSystem.royalGold;
    if (score >= 60) return LegendaryDesignSystem.amberWarning;
    return LegendaryDesignSystem.rubyRed;
  }

  String _getStrategyCount(double score) {
    if (score >= 85) return '5-6';
    if (score >= 70) return '4-5';
    if (score >= 60) return '3-4';
    return '2-3';
  }
}
