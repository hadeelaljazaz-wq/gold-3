import 'package:flutter/material.dart';
import '../../core/theme/royal_colors.dart';

/// 👑 Pulse Animation Widget
///
/// ويدجت أنيميشن النبض للأسعار الحية
///
/// **الميزات:**
/// - نبضة 800ms ناعمة
/// - تغيير اللون حسب الاتجاه (أخضر/أحمر)
/// - تأثير توهج متحرك
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final bool isPositive; // true = green, false = red
  final Duration duration;
  final bool enabled;

  const PulseAnimation({
    super.key,
    required this.child,
    required this.isPositive,
    this.duration = const Duration(milliseconds: 800),
    this.enabled = true,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulseAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    final glowColor =
        widget.isPositive ? RoyalColors.neonGreen : RoyalColors.crimsonRed;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: glowColor.withValues(alpha: _opacityAnimation.value * 0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// 👑 Price Pulse Widget
/// نبضة خاصة بالأسعار
class PricePulse extends StatelessWidget {
  final double price;
  final double change;
  final TextStyle? textStyle;

  const PricePulse({
    super.key,
    required this.price,
    required this.change,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return PulseAnimation(
      isPositive: change >= 0,
      enabled: change != 0,
      child: Text(
        '\$${price.toStringAsFixed(2)}',
        style: textStyle,
      ),
    );
  }
}
