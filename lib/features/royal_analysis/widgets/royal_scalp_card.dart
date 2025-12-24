import 'package:flutter/material.dart';
import '../../../models/scalping_signal.dart';
import '../../../core/theme/royal_colors.dart';
import '../../../core/theme/royal_typography.dart';
import '../../../widgets/neon_glow_container.dart';
import '../../../widgets/glass_card.dart';
import '../../../core/utils/logger.dart';

class RoyalScalpCard extends StatelessWidget {
  final ScalpingSignal signal;

  const RoyalScalpCard({
    super.key,
    required this.signal,
  });

  @override
  Widget build(BuildContext context) {
    // 🔍 DEBUG: Log what we're displaying
    AppLogger.info('📊 RoyalScalpCard Display:');
    AppLogger.info('   Direction from signal: ${signal.direction}');
    AppLogger.info('   Entry: \$${signal.entryPrice}');
    AppLogger.info('   Stop Loss: \$${signal.stopLoss}');
    AppLogger.info('   Take Profit: \$${signal.takeProfit}');
    
    // Validate logic
    if (signal.isValid && signal.entryPrice != null && signal.stopLoss != null && signal.takeProfit != null) {
      final entry = signal.entryPrice!;
      final sl = signal.stopLoss!;
      final tp = signal.takeProfit!;
      
      if (signal.direction == 'BUY' && !(sl < entry && tp > entry)) {
        AppLogger.error('❌ BUY signal but prices wrong: SL($sl) should be < Entry($entry) < TP($tp)');
      } else if (signal.direction == 'SELL' && !(sl > entry && tp < entry)) {
        AppLogger.error('❌ SELL signal but prices wrong: TP($tp) should be < Entry($entry) < SL($sl)');
      } else {
        AppLogger.success('✅ Signal prices are logically correct');
      }
    }
    
    // Use SignalNeonGlow for animated neon effect
    return SignalNeonGlow(
      signal: signal.direction,
      animated: signal.isValid,
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Icon and Confidence
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
                    Icons.flash_on,
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
                          '🎯 SCALPING SIGNAL',
                          style: RoyalTypography.h3.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        'Micro-Trend • 5m-15m Timeframe',
                        style: RoyalTypography.labelSmall.copyWith(
                          color: RoyalColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                // Confidence Circle
                _buildConfidenceCircle(signal.confidence),
              ],
            ),
            const SizedBox(height: 20),

            // Direction Badge with Enhanced Design
            _buildDirectionBadge(signal.direction),
            const SizedBox(height: 20),

            // Signal Content
            if (signal.isValid) ...[
              // Entry/Stop/Target in Modern Layout
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: RoyalColors.glassSurface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: RoyalColors.deepPurple.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _buildPriceRow(
                        'ENTRY', signal.entryPrice ?? 0, RoyalColors.royalGold),
                    const SizedBox(height: 12),
                    Divider(
                        color: RoyalColors.deepPurple.withValues(alpha: 0.3),
                        height: 1),
                    const SizedBox(height: 12),
                    _buildPriceRow('STOP LOSS', signal.stopLoss ?? 0,
                        RoyalColors.crimsonRed),
                    const SizedBox(height: 12),
                    Divider(
                        color: RoyalColors.deepPurple.withValues(alpha: 0.3),
                        height: 1),
                    const SizedBox(height: 12),
                    _buildPriceRow('TAKE PROFIT', signal.takeProfit ?? 0,
                        RoyalColors.neonGreen),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Risk/Reward Badge
              if (signal.riskReward != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: RoyalColors.goldGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: RoyalColors.goldNeonGlow,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'RISK : REWARD',
                        style: RoyalTypography.labelLarge.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        '1 : ${signal.riskReward!.toStringAsFixed(2)}',
                        style: RoyalTypography.numberLarge.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
            ] else ...[
              // NO-TRADE Message with Modern Design
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: RoyalColors.crimsonRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: RoyalColors.crimsonRed.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.pause_circle_outline,
                      color: RoyalColors.crimsonRed,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'NO TRADE SIGNAL',
                      style: RoyalTypography.h3.copyWith(
                        color: RoyalColors.crimsonRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (signal.reason != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        signal.reason!,
                        style: RoyalTypography.bodySmall.copyWith(
                          color: RoyalColors.secondaryText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceCircle(int confidence) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: RoyalColors.royalGold,
          width: 3,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$confidence',
              style: RoyalTypography.numberMedium.copyWith(
                color: RoyalColors.royalGold,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '%',
              style: RoyalTypography.labelSmall.copyWith(
                color: RoyalColors.royalGold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionBadge(String direction) {
    final isBuy = direction.toUpperCase() == 'BUY';
    final isSell = direction.toUpperCase() == 'SELL';

    if (!isBuy && !isSell) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: RoyalColors.amberGlow.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: RoyalColors.amberGlow, width: 2),
        ),
        child: Center(
          child: Text(
            'NO SIGNAL',
            style: RoyalTypography.h2.copyWith(
              color: RoyalColors.amberGlow,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    final color = isBuy ? RoyalColors.neonGreen : RoyalColors.crimsonRed;
    final icon = isBuy ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Text(
            direction.toUpperCase(),
            style: RoyalTypography.h1.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double price, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: RoyalTypography.labelLarge.copyWith(
            color: RoyalColors.secondaryText,
            letterSpacing: 1,
          ),
        ),
        Text(
          '\$${price.toStringAsFixed(2)}',
          style: RoyalTypography.entryPrice.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
