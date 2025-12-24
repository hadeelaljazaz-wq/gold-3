import 'package:flutter/material.dart';
import '../../../core/theme/royal_colors.dart';
import '../../../core/theme/royal_typography.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/animations/pulse_animation.dart';
import '../../../services/gold_price_service.dart';

/// 👑 Hero Price Section
///
/// قسم السعر الرئيسي البطولي
///
/// **الميزات:**
/// - سعر حالي بحجم 48px مع تدرج ذهبي
/// - نسبة التغيير 32px أخضر/أحمر
/// - أنيميشن نبض حسب الحركة
/// - تأثير glassmorphism مع توهج نيون
class HeroPriceSection extends StatelessWidget {
  const HeroPriceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: GoldPriceService.getCurrentPrice(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingState();
        }

        final price = snapshot.data!;
        final isPositive = price.change >= 0;

        return GlassCard(
          customShadows:
              isPositive ? RoyalColors.greenNeonGlow : RoyalColors.redNeonGlow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Label
              Text(
                'GOLD PRICE (XAU/USD)',
                style: RoyalTypography.labelMedium.copyWith(
                  color: RoyalColors.secondaryText,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),

              // Main Price with Pulse Animation
              PulseAnimation(
                isPositive: isPositive,
                enabled: price.change != 0,
                child: ShaderMask(
                  shaderCallback: (bounds) =>
                      RoyalColors.goldGradient.createShader(bounds),
                  child: Text(
                    '\$${price.price.toStringAsFixed(2)}',
                    style: RoyalTypography.priceDisplay.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Change Amount & Percentage
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Change Icon
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isPositive
                        ? RoyalColors.neonGreen
                        : RoyalColors.crimsonRed,
                    size: 28,
                  ),
                  const SizedBox(width: 8),

                  // Change Amount
                  Text(
                    '${isPositive ? '+' : ''}${price.change.toStringAsFixed(2)}',
                    style: RoyalTypography.numberHero.copyWith(
                      color: isPositive
                          ? RoyalColors.neonGreen
                          : RoyalColors.crimsonRed,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Change Percentage in Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: (isPositive
                              ? RoyalColors.neonGreen
                              : RoyalColors.crimsonRed)
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isPositive
                            ? RoyalColors.neonGreen
                            : RoyalColors.crimsonRed,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      '${isPositive ? '+' : ''}${price.changePercent.toStringAsFixed(2)}%',
                      style: RoyalTypography.riskReward.copyWith(
                        color: isPositive
                            ? RoyalColors.neonGreen
                            : RoyalColors.crimsonRed,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Timestamp
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: RoyalColors.mutedText,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Live Price',
                    style: RoyalTypography.labelSmall.copyWith(
                      color: RoyalColors.mutedText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const GlassCard(
      child: Center(
        child: CircularProgressIndicator(
          color: RoyalColors.royalGold,
        ),
      ),
    );
  }
}
