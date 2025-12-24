import 'package:flutter/material.dart';
import '../core/theme/royal_colors.dart';

/// 👑 Neon Glow Container
///
/// حاوية مع تأثير توهج نيون
///
/// **الميزات:**
/// - توهج نيون متحرك
/// - ألوان قابلة للتخصيص
/// - تأثيرات متعددة الطبقات
/// - دعم الأنيميشن
class NeonGlowContainer extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double glowIntensity;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final bool animated;

  const NeonGlowContainer({
    super.key,
    required this.child,
    required this.glowColor,
    this.glowIntensity = 1.0,
    this.borderRadius = 16,
    this.padding,
    this.backgroundColor,
    this.animated = false,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? RoyalColors.glassSurface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: glowColor.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: _createGlowEffect(),
      ),
      child: child,
    );

    if (animated) {
      return _AnimatedNeonGlow(
        glowColor: glowColor,
        borderRadius: borderRadius,
        child: container,
      );
    }

    return container;
  }

  List<BoxShadow> _createGlowEffect() {
    return [
      BoxShadow(
        color: glowColor.withValues(alpha: 0.5 * glowIntensity),
        blurRadius: 20 * glowIntensity,
        spreadRadius: 2 * glowIntensity,
      ),
      BoxShadow(
        color: glowColor.withValues(alpha: 0.3 * glowIntensity),
        blurRadius: 40 * glowIntensity,
        spreadRadius: 5 * glowIntensity,
      ),
    ];
  }
}

/// 👑 Green Neon Glow (Buy Signal)
class GreenNeonGlow extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool animated;

  const GreenNeonGlow({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    return NeonGlowContainer(
      glowColor: RoyalColors.neonGreen,
      borderRadius: borderRadius,
      padding: padding,
      animated: animated,
      child: child,
    );
  }
}

/// 👑 Red Neon Glow (Sell Signal)
class RedNeonGlow extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool animated;

  const RedNeonGlow({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    return NeonGlowContainer(
      glowColor: RoyalColors.crimsonRed,
      borderRadius: borderRadius,
      padding: padding,
      animated: animated,
      child: child,
    );
  }
}

/// 👑 Gold Neon Glow (Neutral/Info)
class GoldNeonGlow extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool animated;

  const GoldNeonGlow({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding,
    this.animated = false,
  });

  @override
  Widget build(BuildContext context) {
    return NeonGlowContainer(
      glowColor: RoyalColors.royalGold,
      borderRadius: borderRadius,
      padding: padding,
      animated: animated,
      child: child,
    );
  }
}

/// 👑 Amber Neon Glow (Warning/Hold)
class AmberNeonGlow extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool animated;

  const AmberNeonGlow({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding,
    this.animated = false,
  });

  @override
  Widget build(BuildContext context) {
    return NeonGlowContainer(
      glowColor: RoyalColors.amberGlow,
      borderRadius: borderRadius,
      padding: padding,
      animated: animated,
      child: child,
    );
  }
}

/// Private: Animated Neon Glow Effect
class _AnimatedNeonGlow extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double borderRadius;

  const _AnimatedNeonGlow({
    required this.child,
    required this.glowColor,
    required this.borderRadius,
  });

  @override
  State<_AnimatedNeonGlow> createState() => _AnimatedNeonGlowState();
}

class _AnimatedNeonGlowState extends State<_AnimatedNeonGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: 0.5 * _animation.value),
                blurRadius: 20 * _animation.value,
                spreadRadius: 2 * _animation.value,
              ),
              BoxShadow(
                color: widget.glowColor.withValues(alpha: 0.3 * _animation.value),
                blurRadius: 40 * _animation.value,
                spreadRadius: 5 * _animation.value,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// 👑 Signal-Based Neon Glow
/// توهج نيون حسب نوع الإشارة
class SignalNeonGlow extends StatelessWidget {
  final Widget child;
  final String signal; // 'BUY', 'SELL', 'HOLD', 'NEUTRAL'
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool animated;

  const SignalNeonGlow({
    super.key,
    required this.child,
    required this.signal,
    this.borderRadius = 16,
    this.padding,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    switch (signal.toUpperCase()) {
      case 'BUY':
        return GreenNeonGlow(
          borderRadius: borderRadius,
          padding: padding,
          animated: animated,
          child: child,
        );
      case 'SELL':
        return RedNeonGlow(
          borderRadius: borderRadius,
          padding: padding,
          animated: animated,
          child: child,
        );
      case 'HOLD':
        return AmberNeonGlow(
          borderRadius: borderRadius,
          padding: padding,
          animated: animated,
          child: child,
        );
      default:
        return GoldNeonGlow(
          borderRadius: borderRadius,
          padding: padding,
          animated: false,
          child: child,
        );
    }
  }
}
