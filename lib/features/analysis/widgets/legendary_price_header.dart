/// 👑 Legendary Price Header
///
/// رأس السعر الملكي
library;

import 'package:flutter/material.dart';
import '../../../core/theme/legendary_design_system.dart';

class LegendaryPriceHeader extends StatelessWidget {
  final double currentPrice;
  final double priceChange;
  final double priceChangePercent;

  const LegendaryPriceHeader({
    super.key,
    required this.currentPrice,
    required this.priceChange,
    required this.priceChangePercent,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = priceChange >= 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: LegendaryDesignSystem.buildRoyalCard(),
      child: Column(
        children: [
          // العنوان
          LegendaryDesignSystem.buildGoldenText(
            '👑 سعر الذهب 👑',
            style: LegendaryDesignSystem.headlineMedium,
          ),

          const SizedBox(height: 16),

          // السعر الرئيسي
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LegendaryDesignSystem
                    .royalGoldGradient
                    .createShader(bounds),
                child: Text(
                  '\$${currentPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // التغير
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: isPositive
                    ? LegendaryDesignSystem.emeraldGreen
                    : LegendaryDesignSystem.rubyRed,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${isPositive ? "+" : ""}${priceChange.toStringAsFixed(2)}\$',
                style: TextStyle(
                  color: isPositive
                      ? LegendaryDesignSystem.emeraldGreen
                      : LegendaryDesignSystem.rubyRed,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color:
                      (isPositive
                              ? LegendaryDesignSystem.emeraldGreen
                              : LegendaryDesignSystem.rubyRed)
                          .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${isPositive ? "+" : ""}${priceChangePercent.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: isPositive
                        ? LegendaryDesignSystem.emeraldGreen
                        : LegendaryDesignSystem.rubyRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
