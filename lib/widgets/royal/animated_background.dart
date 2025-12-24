import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 🌌 Animated Royal Background
/// خلفية ملكية متحركة مع جزيئات
class AnimatedRoyalBackground extends StatefulWidget {
  const AnimatedRoyalBackground({super.key});

  @override
  State<AnimatedRoyalBackground> createState() =>
      _AnimatedRoyalBackgroundState();
}

class _AnimatedRoyalBackgroundState extends State<AnimatedRoyalBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 28),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Gradient
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.8, -0.8),
              radius: 1.5,
              colors: [
                Color(0xFF0f1630),
                Color(0xFF070b1a),
                Color(0xFF060812),
              ],
              stops: [0.0, 0.4, 1.0],
            ),
          ),
        ),

        // Animated Gradient Layers
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: _GradientLayersPainter(_animation.value),
              size: Size.infinite,
            );
          },
        ),

        // Particles
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: _ParticlesPainter(_animation.value),
              size: Size.infinite,
            );
          },
        ),
      ],
    );
  }
}

/// 🎨 Gradient Layers Painter
class _GradientLayersPainter extends CustomPainter {
  final double progress;

  _GradientLayersPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final dx = math.sin(progress * 2 * math.pi) * 20;
    final dy = math.cos(progress * 2 * math.pi) * -25;
    final scale = 1 + math.sin(progress * 2 * math.pi) * 0.02;

    // Purple Radial
    final purplePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(0.6 + dx / size.width, -0.6 + dy / size.height),
        radius: 1.2,
        colors: const [
          Color(0x236e3cc3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.save();
    canvas.scale(scale, scale);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      purplePaint,
    );
    canvas.restore();

    // Gold Radial
    final goldPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(-0.7 - dx / size.width, 0.6 - dy / size.height),
        radius: 1.0,
        colors: const [
          Color(0x1Ad4af37),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      goldPaint,
    );

    // Emerald Radial
    final emeraldPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
            0.8 + dx / size.width * 0.5, 0.8 + dy / size.height * 0.5),
        radius: 1.2,
        colors: const [
          Color(0x1F059669),
          Colors.transparent,
        ],
        stops: const [0.0, 0.65],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      emeraldPaint,
    );
  }

  @override
  bool shouldRepaint(_GradientLayersPainter oldDelegate) =>
      progress != oldDelegate.progress;
}

/// ✨ Particles Painter
class _ParticlesPainter extends CustomPainter {
  final double progress;

  _ParticlesPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final particles = [
      _Particle(0.22, 0.28, 1.0, const Color(0xFFd4af37), 0.25),
      _Particle(0.60, 0.72, 1.5, const Color(0xFF6e3cc3), 0.22),
      _Particle(0.52, 0.56, 1.0, Colors.white, 0.18),
      _Particle(0.82, 0.12, 1.5, const Color(0xFFd4af37), 0.22),
      _Particle(0.88, 0.66, 2.0, const Color(0xFF059669), 0.18),
    ];

    final dx = math.sin(progress * 2 * math.pi) * size.width;
    final dy = math.cos(progress * 2 * math.pi) * size.height * 0.6;

    for (var particle in particles) {
      final x = particle.x * size.width + dx * 0.2;
      final y = particle.y * size.height + dy * 0.2;

      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size * 2);

      canvas.drawCircle(
        Offset(x, y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlesPainter oldDelegate) =>
      progress != oldDelegate.progress;
}

class _Particle {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double opacity;

  _Particle(this.x, this.y, this.size, this.color, this.opacity);
}
