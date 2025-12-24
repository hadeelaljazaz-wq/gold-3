import 'package:flutter/material.dart';
import '../../../core/theme/royal_colors.dart';
import '../../../core/theme/royal_typography.dart';
import '../../../widgets/glass_card.dart';
import '../../../models/market_models.dart';

/// 👑 Technical Indicators Panel
///
/// لوحة المؤشرات الفنية
///
/// **الميزات:**
/// - RSI مع عرض دائري
/// - MACD مع histogram صغير
/// - EMAs ملونة حسب الحالة
/// - تصميم أيقونة + رقم + شريط تقدم
class TechIndicatorsPanel extends StatelessWidget {
  final TechnicalIndicators indicators;

  const TechIndicatorsPanel({
    super.key,
    required this.indicators,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // RSI Indicator with Circular Gauge
        _buildRSIIndicator(),
        const SizedBox(height: 12),

        // MACD Indicator
        _buildMACDIndicator(),
        const SizedBox(height: 12),

        // EMAs Indicator
        _buildEMAsIndicator(),
      ],
    );
  }

  Widget _buildRSIIndicator() {
    final rsi = indicators.rsi;
    final rsiStatus = _getRSIStatus(rsi);

    return CompactGlassCard(
      borderColor: rsiStatus.color,
      child: Row(
        children: [
          // Icon & Circular Gauge
          _buildCircularGauge(
            value: rsi,
            maxValue: 100,
            color: rsiStatus.color,
            icon: Icons.trending_up,
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RSI (14)',
                  style: RoyalTypography.labelMedium.copyWith(
                    color: RoyalColors.secondaryText,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rsi.toStringAsFixed(1),
                  style: RoyalTypography.indicatorValue.copyWith(
                    color: RoyalColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: rsiStatus.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    rsiStatus.label,
                    style: RoyalTypography.labelSmall.copyWith(
                      color: rsiStatus.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Progress Bar
          SizedBox(
            width: 80,
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: rsi / 100,
                  backgroundColor: RoyalColors.glassSurface,
                  valueColor: AlwaysStoppedAnimation(rsiStatus.color),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0',
                        style: RoyalTypography.labelSmall
                            .copyWith(color: RoyalColors.mutedText)),
                    Text('100',
                        style: RoyalTypography.labelSmall
                            .copyWith(color: RoyalColors.mutedText)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMACDIndicator() {
    final histogram = indicators.macdHistogram;
    final isBullish = histogram > 0;

    return CompactGlassCard(
      borderColor: isBullish ? RoyalColors.neonGreen : RoyalColors.crimsonRed,
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  (isBullish ? RoyalColors.neonGreen : RoyalColors.crimsonRed)
                      .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.show_chart,
              color: isBullish ? RoyalColors.neonGreen : RoyalColors.crimsonRed,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MACD (12,26,9)',
                  style: RoyalTypography.labelMedium.copyWith(
                    color: RoyalColors.secondaryText,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Histogram: ',
                      style: RoyalTypography.bodySmall.copyWith(
                        color: RoyalColors.mutedText,
                      ),
                    ),
                    Text(
                      histogram.toStringAsFixed(2),
                      style: RoyalTypography.numberMedium.copyWith(
                        color: isBullish
                            ? RoyalColors.neonGreen
                            : RoyalColors.crimsonRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isBullish
                            ? RoyalColors.neonGreen
                            : RoyalColors.crimsonRed)
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isBullish ? 'BULLISH' : 'BEARISH',
                    style: RoyalTypography.labelSmall.copyWith(
                      color: isBullish
                          ? RoyalColors.neonGreen
                          : RoyalColors.crimsonRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Mini Histogram Visual
          _buildMiniHistogram(histogram),
        ],
      ),
    );
  }

  Widget _buildEMAsIndicator() {
    final ema9 = indicators.ma20; // Using MA20 as proxy for EMA9
    final ema21 = indicators.ma50; // Using MA50 as proxy for EMA21
    final ema50 = indicators.ma100; // Using MA100 as proxy for EMA50

    return CompactGlassCard(
      borderColor: RoyalColors.electricBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.moving,
                color: RoyalColors.electricBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'MOVING AVERAGES',
                style: RoyalTypography.labelMedium.copyWith(
                  color: RoyalColors.secondaryText,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildEMARow('EMA 9', ema9, RoyalColors.neonGreen),
          const SizedBox(height: 8),
          _buildEMARow('EMA 21', ema21, RoyalColors.amberGlow),
          const SizedBox(height: 8),
          _buildEMARow('EMA 50', ema50, RoyalColors.crimsonRed),
        ],
      ),
    );
  }

  Widget _buildEMARow(String label, double value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
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
            Text(
              label,
              style: RoyalTypography.labelMedium.copyWith(
                color: RoyalColors.secondaryText,
              ),
            ),
          ],
        ),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: RoyalTypography.numberSmall.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCircularGauge({
    required double value,
    required double maxValue,
    required Color color,
    required IconData icon,
  }) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Circle
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 6,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation(
              RoyalColors.glassSurface,
            ),
          ),
          // Progress Circle
          CircularProgressIndicator(
            value: value / maxValue,
            strokeWidth: 6,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation(color),
          ),
          // Icon
          Icon(
            icon,
            color: color,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniHistogram(double value) {
    final isPositive = value > 0;
    final height = (value.abs() * 2).clamp(0.0, 40.0);

    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.bottomCenter,
      child: Container(
        width: 16,
        height: height,
        decoration: BoxDecoration(
          color: isPositive ? RoyalColors.neonGreen : RoyalColors.crimsonRed,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  _RSIStatus _getRSIStatus(double rsi) {
    if (rsi >= 70) {
      return _RSIStatus('OVERBOUGHT', RoyalColors.crimsonRed);
    } else if (rsi >= 60) {
      return _RSIStatus('BULLISH', RoyalColors.neonGreen);
    } else if (rsi >= 40) {
      return _RSIStatus('NEUTRAL', RoyalColors.amberGlow);
    } else if (rsi >= 30) {
      return _RSIStatus('BEARISH', RoyalColors.crimsonRed);
    } else {
      return _RSIStatus('OVERSOLD', RoyalColors.neonGreen);
    }
  }
}

class _RSIStatus {
  final String label;
  final Color color;

  _RSIStatus(this.label, this.color);
}
