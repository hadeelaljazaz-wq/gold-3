import 'package:flutter/material.dart';
import '../../../models/swing_signal.dart';
import '../../../core/theme/royal_colors.dart';
import '../../../core/theme/royal_typography.dart';
import '../../../widgets/neon_glow_container.dart';
import '../../../widgets/glass_card.dart';
import '../../../core/utils/logger.dart';

class RoyalSwingCard extends StatelessWidget {
  final SwingSignal signal;

  const RoyalSwingCard({
    super.key,
    required this.signal,
  });

  @override
  Widget build(BuildContext context) {
    // 🔍 DEBUG: Log what we're displaying
    AppLogger.info('📊 RoyalSwingCard Display:');
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
    
    // Use appropriate neon glow based on signal
    final isHold = signal.direction.toUpperCase() == 'HOLD' ||
        signal.direction.toUpperCase() == 'NO_TRADE';

    return SignalNeonGlow(
      signal: isHold ? 'HOLD' : signal.direction,
      animated: signal.isValid && !isHold,
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with enhanced design
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: RoyalColors.purpleGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: RoyalColors.purpleNeonGlow,
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: RoyalColors.royalGold,
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
                            RoyalColors.shimmerGradient.createShader(bounds),
                        child: Text(
                          '📊 SWING SIGNAL',
                          style: RoyalTypography.h3.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        'H1-H4 • Macro Trend • Fibonacci • QCF',
                        style: RoyalTypography.labelSmall.copyWith(
                          color: RoyalColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildConfidenceCircle(signal.confidence),
              ],
            ),
            const SizedBox(height: 20),

            // Direction Badge
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
                    gradient: RoyalColors.shimmerGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: RoyalColors.purpleNeonGlow,
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
                  color: RoyalColors.amberGlow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: RoyalColors.amberGlow.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.pause_circle_outline,
                      color: RoyalColors.amberGlow,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'HOLD / NO TRADE',
                      style: RoyalTypography.h3.copyWith(
                        color: RoyalColors.amberGlow,
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

  Widget _buildConfidenceCircle(int confidence) {
    final color = confidence >= 70
        ? RoyalColors.neonGreen
        : confidence >= 50
            ? RoyalColors.amberGlow
            : RoyalColors.crimsonRed;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 3),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$confidence',
              style: RoyalTypography.numberMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '%',
              style: RoyalTypography.labelSmall.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionBadge(String direction) {
    final dirUpper = direction.toUpperCase();
    final isBuy = dirUpper == 'BUY';
    final isSell = dirUpper == 'SELL';

    Color color;
    IconData icon;

    if (isBuy) {
      color = RoyalColors.neonGreen;
      icon = Icons.arrow_upward;
    } else if (isSell) {
      color = RoyalColors.crimsonRed;
      icon = Icons.arrow_downward;
    } else {
      color = RoyalColors.amberGlow;
      icon = Icons.pause_circle_outline;
    }

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
}
