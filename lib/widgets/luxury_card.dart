import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/royal_colors.dart';

/// 👑 Luxury Card Widget
///
/// بطاقة فاخرة ملكية مع تأثيرات glassmorphism وتدرجات ملكية
class LuxuryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Gradient gradient;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const LuxuryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.gradient,
    required this.child,
    this.padding,
    this.borderRadius = 25,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: RoyalColors.goldPrimary.withValues(alpha: 0.1),
            blurRadius: 30,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: RoyalColors.goldPrimary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: padding ?? const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: RoyalColors.obsidian.withValues(alpha: 0.4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              RoyalColors.goldPrimary.withValues(alpha: 0.3),
                              RoyalColors.goldShimmer.withValues(alpha: 0.1),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon,
                            color: RoyalColors.goldPrimary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              RoyalColors.goldLight,
                              RoyalColors.champagne
                            ],
                          ).createShader(bounds),
                          child: Text(
                            title,
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 👑 Royal Price Row Widget
///
/// صف عرض السعر الملكي
class RoyalPriceRow extends StatelessWidget {
  final String label;
  final String price;
  final Color color;

  const RoyalPriceRow({
    super.key,
    required this.label,
    required this.price,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            color: RoyalColors.champagne.withValues(alpha: 0.8),
            fontSize: 14,
          ),
        ),
        Text(
          price,
          style: GoogleFonts.orbitron(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// 👑 Royal Metric Item Widget
///
/// عنصر مقياس ملكي
class RoyalMetricItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const RoyalMetricItem({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            color: RoyalColors.champagne.withValues(alpha: 0.6),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.orbitron(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// 👑 Royal Level Item Widget
///
/// عنصر مستوى ملكي (للدعوم والمقاومات)
class RoyalLevelItem extends StatelessWidget {
  final String percentage;
  final String price;
  final Color color;

  const RoyalLevelItem({
    super.key,
    required this.percentage,
    required this.price,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              percentage,
              style: GoogleFonts.orbitron(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            price,
            style: GoogleFonts.orbitron(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 👑 Royal Indicator Row Widget
///
/// صف مؤشر ملكي
class RoyalIndicatorRow extends StatelessWidget {
  final String name;
  final String value;
  final String status;
  final Color statusColor;

  const RoyalIndicatorRow({
    super.key,
    required this.name,
    required this.value,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RoyalColors.obsidian.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: GoogleFonts.orbitron(
                color: RoyalColors.champagne,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: GoogleFonts.orbitron(
                color: RoyalColors.goldPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: GoogleFonts.cairo(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 👑 Diamond FAB Widget
///
/// Floating Action Button بتصميم الماس الملكي
class DiamondFAB extends StatelessWidget {
  final VoidCallback? onPressed;

  const DiamondFAB({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 70,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glowing Effect
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    RoyalColors.goldPrimary.withValues(alpha: 0.5),
                    RoyalColors.goldPrimary.withValues(alpha: 0.0),
                  ],
                ),
                shape: BoxShape.circle,
              ),
            ),

            // Diamond Shape Button
            Transform.rotate(
              angle: 0.785398, // 45 degrees
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [RoyalColors.goldPrimary, RoyalColors.goldShimmer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: RoyalColors.goldPrimary.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: RoyalColors.obsidian,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Transform.rotate(
                  angle: -0.785398, // Rotate back the icon
                  child: Icon(
                    Icons.refresh,
                    color: RoyalColors.obsidian,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
