import 'package:flutter/material.dart';
import '../../core/theme/royal_theme.dart';

/// 💰 Royal Price Card
/// بطاقة السعر الملكية مع تأثيرات متحركة
class RoyalPriceCard extends StatefulWidget {
  final double price;
  final double change;
  final double changePercent;

  const RoyalPriceCard({
    super.key,
    required this.price,
    required this.change,
    required this.changePercent,
  });

  @override
  State<RoyalPriceCard> createState() => _RoyalPriceCardState();
}

class _RoyalPriceCardState extends State<RoyalPriceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _sheenController;
  late Animation<double> _sheenAnimation;

  @override
  void initState() {
    super.initState();
    _sheenController = AnimationController(
      duration: const Duration(seconds: 7),
      vsync: this,
    )..repeat();

    _sheenAnimation = Tween<double>(begin: -1.2, end: 1.2).animate(
      CurvedAnimation(parent: _sheenController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _sheenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = widget.change >= 0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - value)),
            child: Transform.scale(
              scale: 0.98 + (0.02 * value),
              child: child,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(RoyalTheme.spaceXl),
        decoration: BoxDecoration(
          gradient: RoyalTheme.royalGradient,
          borderRadius: BorderRadius.circular(RoyalTheme.radiusCard),
          border: Border.all(
            color: RoyalTheme.glassBorder,
            width: 1,
          ),
          boxShadow: RoyalTheme.hardShadow,
        ),
        child: Stack(
          children: [
            // Animated Sheen Effect
            AnimatedBuilder(
              animation: _sheenAnimation,
              builder: (context, child) {
                return Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(RoyalTheme.radiusCard),
                    child: CustomPaint(
                      painter: _SheenPainter(_sheenAnimation.value),
                    ),
                  ),
                );
              },
            ),

            // Content
            Column(
              children: [
                // Label
                Text(
                  'سعر الذهب (XAU/USD)',
                  style: RoyalTheme.bodySmall.copyWith(
                    color: const Color(0xD9d4af37),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          RoyalTheme.goldGradient.createShader(bounds),
                      child: Text(
                        '\$',
                        style: RoyalTheme.headlineStyle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.price.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        height: 1.0,
                        shadows: [
                          Shadow(
                            color: Color(0x59d4af37),
                            blurRadius: 22,
                          ),
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Change Badge
                _PriceChangeBadge(
                  change: widget.change,
                  changePercent: widget.changePercent,
                  isPositive: isPositive,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ✨ Sheen Effect Painter
class _SheenPainter extends CustomPainter {
  final double progress;

  _SheenPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          Color(0x1Fd4af37),
          Colors.transparent,
        ],
        stops: [0.4, 0.5, 0.6],
      ).createShader(Rect.fromLTWH(
        progress * size.width,
        0,
        size.width * 0.3,
        size.height,
      ))
      ..blendMode = BlendMode.screen;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_SheenPainter oldDelegate) =>
      progress != oldDelegate.progress;
}

/// 📊 Price Change Badge
class _PriceChangeBadge extends StatefulWidget {
  final double change;
  final double changePercent;
  final bool isPositive;

  const _PriceChangeBadge({
    required this.change,
    required this.changePercent,
    required this.isPositive,
  });

  @override
  State<_PriceChangeBadge> createState() => _PriceChangeBadgeState();
}

class _PriceChangeBadgeState extends State<_PriceChangeBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _arrowController;
  late Animation<double> _arrowAnimation;

  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    )..repeat(reverse: true);

    _arrowAnimation = Tween<double>(begin: 0, end: -3).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _arrowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isPositive
                ? const [
                    Color(0x23d4af37),
                    Color(0x0Ad4af37),
                  ]
                : const [
                    Color(0x26ef4444),
                    Color(0x0Def4444),
                  ],
          ),
          borderRadius: BorderRadius.circular(RoyalTheme.radiusFull),
          border: Border.all(
            color: widget.isPositive
                ? const Color(0x59d4af37)
                : const Color(0x66ef4444),
            width: 1,
          ),
          boxShadow: widget.isPositive
              ? RoyalTheme.glowGold
              : const [
                  BoxShadow(
                    color: Color(0x59ef4444),
                    blurRadius: 16,
                  ),
                  BoxShadow(
                    color: Color(0x1Aef4444),
                    blurRadius: 28,
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _arrowAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _arrowAnimation.value),
                  child: Text(
                    widget.isPositive ? '▲' : '▼',
                    style: TextStyle(
                      fontSize: 18,
                      color: widget.isPositive
                          ? RoyalTheme.imperialGold
                          : RoyalTheme.danger,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            Text(
              '${widget.isPositive ? '+' : ''}${widget.change.toStringAsFixed(2)} '
              '(${widget.changePercent > 0 ? '+' : ''}${widget.changePercent.toStringAsFixed(2)}%)',
              style: RoyalTheme.bodyMedium.copyWith(
                color: widget.isPositive
                    ? RoyalTheme.imperialGold
                    : RoyalTheme.danger,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
