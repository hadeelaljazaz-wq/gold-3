import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/royal_colors.dart';

/// 👑 Glass Card - Glassmorphism Component
///
/// مكون بتأثير الزجاج (Glassmorphism)
///
/// **الميزات:**
/// - تأثير blur للخلفية
/// - حدود شفافة بنفسجية
/// - ظلال ذهبية/بنفسجية
/// - قابل للتخصيص بالكامل
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? customShadows;
  final double blurSigma;
  final Gradient? gradient;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.5,
    this.customShadows,
    this.blurSigma = 10,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('GlassCard.build: padding=$padding, borderWidth=$borderWidth');
    return Padding(
      padding: padding ?? const EdgeInsets.all(20),
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient ??
                LinearGradient(
                  colors: [
                    (backgroundColor ?? RoyalColors.glassSurface).withValues(alpha: 0.7),
                    (backgroundColor ?? RoyalColors.glassSurface).withValues(alpha: 0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: (borderColor ?? RoyalColors.deepPurple).withValues(alpha: 0.3),
              width: borderWidth,
            ),
            boxShadow: customShadows ??
                [
                  BoxShadow(
                    color: RoyalColors.deepPurple.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// 👑 Glass Card with Gold Border
/// نسخة مع حدود ذهبية
class GoldGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const GoldGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: RoyalColors.royalGold,
      customShadows: RoyalColors.goldNeonGlow,
      borderRadius: borderRadius,
      padding: padding,
      child: child,
    );
  }
}

/// 👑 Glass Card with Purple Border
/// نسخة مع حدود بنفسجية
class PurpleGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const PurpleGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: RoyalColors.deepPurple,
      customShadows: RoyalColors.purpleNeonGlow,
      borderRadius: borderRadius,
      padding: padding,
      child: child,
    );
  }
}

/// 👑 Glass Card with Gradient Border
/// نسخة مع حدود متدرجة
class GradientBorderGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Gradient borderGradient;
  final double borderWidth;

  const GradientBorderGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
    this.borderGradient = RoyalColors.shimmerGradient,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: borderGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: RoyalColors.deepPurple.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(borderWidth),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                RoyalColors.glassSurface.withValues(alpha: 0.7),
                RoyalColors.glassSurface.withValues(alpha: 0.5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(borderRadius - borderWidth),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius - borderWidth),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: padding ?? const EdgeInsets.all(20),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 👑 Compact Glass Card
/// نسخة مدمجة مع padding أقل
class CompactGlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color? borderColor;

  const CompactGlassCard({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: borderRadius,
      borderColor: borderColor,
      borderWidth: 1,
      blurSigma: 8,
      child: child,
    );
  }
}
