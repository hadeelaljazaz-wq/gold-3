/// 👑 Legendary Scalping Card
///
/// كارت السكالبينج الملكي
library;

import 'package:flutter/material.dart';
import '../../../models/legendary/legendary_signal.dart';
import '../../../core/theme/legendary_design_system.dart';

class LegendaryScalpCard extends StatelessWidget {
  final LegendarySignal signal;

  const LegendaryScalpCard({super.key, required this.signal});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: signal.isBuy
          ? LegendaryDesignSystem.buildBuyCard()
          : signal.isSell
          ? LegendaryDesignSystem.buildSellCard()
          : LegendaryDesignSystem.buildNeutralCard(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Row(
            children: [
              LegendaryDesignSystem.buildGoldenIcon(Icons.flash_on, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '⚡ توصية السكالبينج (15 دقيقة)',
                  style: LegendaryDesignSystem.headlineMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // الاتجاه
          if (signal.isBuy)
            LegendaryDesignSystem.buildBuyBadge('شراء 🟢')
          else if (signal.isSell)
            LegendaryDesignSystem.buildSellBadge('بيع 🔴')
          else
            LegendaryDesignSystem.buildWaitBadge('انتظار ⏸️'),

          const SizedBox(height: 16),

          // التفاصيل
          if (!signal.isWait) ...[
            _buildDetailRow(
              '📍 الدخول',
              '\$${signal.entryPrice.toStringAsFixed(2)}',
            ),
            _buildDetailRow(
              '🛑 وقف الخسارة',
              '\$${signal.stopLoss.toStringAsFixed(2)} (${signal.riskAmount.toStringAsFixed(2)}\$)',
            ),
            _buildDetailRow(
              '🎯 الهدف الأول',
              '\$${signal.takeProfit1.toStringAsFixed(2)} (R:R 1:${signal.riskReward1.toStringAsFixed(1)})',
            ),
            _buildDetailRow(
              '🎯 الهدف الثاني',
              '\$${signal.takeProfit2.toStringAsFixed(2)} (R:R 1:${signal.riskReward2.toStringAsFixed(1)})',
            ),
          ],

          const SizedBox(height: 16),

          // نسبة الثقة
          LegendaryDesignSystem.buildConfidenceBar(signal.confidence),

          const SizedBox(height: 16),

          // السبب
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: LegendaryDesignSystem.royalGold.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    signal.reasoning,
                    style: LegendaryDesignSystem.bodyMedium.copyWith(
                      height: 1.6,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // التأكيدات
          if (signal.confirmations.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Colors.white60,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'التأكيدات (${signal.confirmations.length})',
                        style: LegendaryDesignSystem.bodySmall.copyWith(
                          color: Colors.white60,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...signal.confirmations
                      .take(3)
                      .map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(left: 26, top: 4),
                          child: Text(
                            '• $c',
                            style: LegendaryDesignSystem.bodySmall.copyWith(
                              color: Colors.white60,
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: LegendaryDesignSystem.bodyMedium.copyWith(
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: LegendaryDesignSystem.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
