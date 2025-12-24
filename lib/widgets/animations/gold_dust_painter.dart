import 'package:flutter/material.dart';
import '../../core/theme/royal_colors.dart';

/// 👑 Gold Dust Painter
///
/// رسام جزيئات ذهبية متحركة للخلفيات الملكية
class GoldDustPainter extends CustomPainter {
  final Animation<double> animation;

  GoldDustPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = RoyalColors.goldPrimary.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 30; i++) {
      double x = (i * 37 + animation.value * size.width) % size.width;
      double y = (i * 47 + animation.value * size.height * 0.5) % size.height;
      double radius = (i % 3) + 1.0;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
