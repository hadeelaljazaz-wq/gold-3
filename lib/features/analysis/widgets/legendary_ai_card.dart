/// 👑 Legendary AI Analysis Card
///
/// كارت تحليل الذكاء الاصطناعي الملكي
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/legendary_design_system.dart';

class LegendaryAICard extends StatelessWidget {
  final String? analysis;
  final bool isLoading;

  const LegendaryAICard({super.key, this.analysis, this.isLoading = false});

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  LegendaryDesignSystem.buildGoldenIcon(
                    Icons.psychology,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '🤖 تحليل الذكاء الاصطناعي',
                    style: LegendaryDesignSystem.headlineSmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              if (analysis != null)
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  color: LegendaryDesignSystem.royalGold,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: analysis!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم نسخ التحليل'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
            ],
          ),

          const SizedBox(height: 16),

          // المحتوى
          if (isLoading)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  LegendaryDesignSystem.goldenLoader,
                  const SizedBox(height: 16),
                  Text(
                    'جاري التحليل الأسطوري...',
                    style: LegendaryDesignSystem.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            )
          else if (analysis != null && analysis!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: LegendaryDesignSystem.royalGold.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: SelectableText(
                analysis!,
                style: LegendaryDesignSystem.bodyMedium.copyWith(
                  color: Colors.white,
                  height: 1.7,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'لا يوجد تحليل حالياً',
                  style: LegendaryDesignSystem.bodyMedium.copyWith(
                    color: Colors.white60,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
