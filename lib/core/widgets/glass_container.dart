// lib/core/widgets/glass_container.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import '../design/elite_color_system.dart';

/// Container زجاجي متقدم مع تأثيرات احترافية
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final Border? border;
  final List<BoxShadow>? shadows;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  
  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 20.0,
    this.opacity = 0.15,
    this.borderRadius,
    this.gradient,
    this.border,
    this.shadows,
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blur,
          sigmaY: blur,
          tileMode: TileMode.clamp,
        ),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            gradient: gradient ??
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: opacity),
                    Colors.white.withValues(alpha: opacity * 0.5),
                  ],
                ),
            borderRadius: borderRadius ?? BorderRadius.circular(24),
            border: border ??
                Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
            boxShadow: shadows ??
                [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// بطاقة زجاجية متقدمة
class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final Color? glowColor;
  
  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.width,
    this.height,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(20),
      blur: 25,
      opacity: 0.1,
      borderRadius: BorderRadius.circular(28),
      shadows: glowColor != null
          ? [
              BoxShadow(
                color: glowColor!.withValues(alpha: 0.3),
                blurRadius: 40,
                offset: const Offset(0, 15),
              ),
            ]
          : null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          splashColor: Colors.white.withValues(alpha: 0.1),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          child: child,
        ),
      ),
    );
  }
}

/// تأثير النيون الملون
class NeonGlow extends StatelessWidget {
  final Widget child;
  final Color color;
  final double blurRadius;
  final double spreadRadius;
  
  const NeonGlow({
    super.key,
    required this.child,
    required this.color,
    this.blurRadius = 20,
    this.spreadRadius = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.6),
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: blurRadius * 2,
            spreadRadius: spreadRadius * 2,
          ),
        ],
      ),
      child: child,
    );
  }
}

