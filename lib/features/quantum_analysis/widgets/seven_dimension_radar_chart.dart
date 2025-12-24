import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 📊 Seven Dimension Radar Chart
/// رسم بياني راداري للأبعاد السبعة
class SevenDimensionRadarChart extends StatelessWidget {
  final Map<String, double> dimensions;

  const SevenDimensionRadarChart({
    super.key,
    required this.dimensions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.imperialPurple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.radar,
                    color: AppColors.imperialPurple,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '7-Dimension Analysis',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        'Multi-Dimensional Market View',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Radar Chart
            AspectRatio(
              aspectRatio: 1.0,
              child: CustomPaint(
                painter: RadarChartPainter(dimensions),
              ),
            ),

            const SizedBox(height: 20),

            // Dimension Legend
            _buildDimensionLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDimensionLegend(BuildContext context) {
    final dimensionColors = _getDimensionColors();

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: dimensions.entries.map((entry) {
        final color = dimensionColors[entry.key] ?? AppColors.textSecondary;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _formatDimensionName(entry.key),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 11,
                    ),
              ),
              const SizedBox(width: 4),
              Text(
                '${(entry.value * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatDimensionName(String key) {
    switch (key) {
      case 'temporal':
        return 'Temporal';
      case 'momentum':
        return 'Momentum';
      case 'volume':
        return 'Volume';
      case 'volatility':
        return 'Volatility';
      case 'sentiment':
        return 'Sentiment';
      case 'probability':
        return 'Probability';
      case 'correlation':
        return 'Correlation';
      default:
        return key;
    }
  }

  Map<String, Color> _getDimensionColors() {
    return {
      'temporal': AppColors.cyan,
      'momentum': AppColors.buy,
      'volume': AppColors.imperialPurple,
      'volatility': AppColors.warning,
      'sentiment': const Color(0xFFFF6B9D),
      'probability': const Color(0xFF00D9FF),
      'correlation': const Color(0xFF9D50BB),
    };
  }
}

/// Radar Chart Painter
class RadarChartPainter extends CustomPainter {
  final Map<String, double> dimensions;

  RadarChartPainter(this.dimensions);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 20;
    final dimensionCount = dimensions.length;

    if (dimensionCount == 0) return;

    // Draw background circles (0%, 25%, 50%, 75%, 100%)
    _drawBackgroundCircles(canvas, center, radius);

    // Draw axis lines
    _drawAxisLines(canvas, center, radius, dimensionCount);

    // Draw axis labels
    _drawAxisLabels(canvas, center, radius, dimensionCount);

    // Draw data polygon
    _drawDataPolygon(canvas, center, radius, dimensionCount);

    // Draw data points
    _drawDataPoints(canvas, center, radius, dimensionCount);
  }

  void _drawBackgroundCircles(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = AppColors.backgroundSecondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * i / 4, paint);
    }
  }

  void _drawAxisLines(Canvas canvas, Offset center, double radius, int count) {
    final paint = Paint()
      ..color = AppColors.backgroundSecondary
      ..strokeWidth = 1;

    for (int i = 0; i < count; i++) {
      final angle = (2 * pi * i / count) - pi / 2;
      final endPoint = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(center, endPoint, paint);
    }
  }

  void _drawAxisLabels(Canvas canvas, Offset center, double radius, int count) {
    final labels = dimensions.keys.toList();
    final colors = _getDimensionColors();

    for (int i = 0; i < count; i++) {
      final angle = (2 * pi * i / count) - pi / 2;
      final labelRadius = radius + 30;
      final labelPoint = Offset(
        center.dx + labelRadius * cos(angle),
        center.dy + labelRadius * sin(angle),
      );

      final label = labels[i];
      final color = colors[label] ?? AppColors.textPrimary;

      // Draw small colored circle
      final circlePaint = Paint()..color = color;
      canvas.drawCircle(labelPoint, 4, circlePaint);

      // Draw label text
      final textPainter = TextPainter(
        text: TextSpan(
          text: _formatLabel(label),
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Adjust text position based on angle
      double dx = labelPoint.dx - textPainter.width / 2;
      double dy = labelPoint.dy - textPainter.height / 2;

      if (angle > -pi / 2 && angle < pi / 2) {
        dx += 15; // Right side
      } else {
        dx -= 15 + textPainter.width; // Left side
      }

      textPainter.paint(canvas, Offset(dx, dy));
    }
  }

  void _drawDataPolygon(
      Canvas canvas, Offset center, double radius, int count) {
    final values = dimensions.values.toList();
    final colors = _getDimensionColors();
    final labels = dimensions.keys.toList();

    // Create path
    final path = Path();
    bool firstPoint = true;

    for (int i = 0; i < count; i++) {
      final value = values[i].clamp(0.0, 1.0);
      final angle = (2 * pi * i / count) - pi / 2;
      final point = Offset(
        center.dx + radius * value * cos(angle),
        center.dy + radius * value * sin(angle),
      );

      if (firstPoint) {
        path.moveTo(point.dx, point.dy);
        firstPoint = false;
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    // Fill with gradient
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.imperialPurple.withValues(alpha: 0.3),
          AppColors.cyan.withValues(alpha: 0.1),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    // Draw colored segments
    for (int i = 0; i < count; i++) {
      final value = values[i].clamp(0.0, 1.0);
      final nextValue = values[(i + 1) % count].clamp(0.0, 1.0);
      final angle = (2 * pi * i / count) - pi / 2;
      final nextAngle = (2 * pi * (i + 1) / count) - pi / 2;

      final point1 = Offset(
        center.dx + radius * value * cos(angle),
        center.dy + radius * value * sin(angle),
      );
      final point2 = Offset(
        center.dx + radius * nextValue * cos(nextAngle),
        center.dy + radius * nextValue * sin(nextAngle),
      );

      final segmentPaint = Paint()
        ..color = colors[labels[i]] ?? AppColors.cyan
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      canvas.drawLine(point1, point2, segmentPaint);
    }
  }

  void _drawDataPoints(Canvas canvas, Offset center, double radius, int count) {
    final values = dimensions.values.toList();
    final colors = _getDimensionColors();
    final labels = dimensions.keys.toList();

    for (int i = 0; i < count; i++) {
      final value = values[i].clamp(0.0, 1.0);
      final angle = (2 * pi * i / count) - pi / 2;
      final point = Offset(
        center.dx + radius * value * cos(angle),
        center.dy + radius * value * sin(angle),
      );

      final color = colors[labels[i]] ?? AppColors.cyan;

      // Outer glow
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, 8, glowPaint);

      // Inner point
      final pointPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, 5, pointPaint);

      // White center
      final centerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, 2, centerPaint);
    }
  }

  String _formatLabel(String key) {
    switch (key) {
      case 'temporal':
        return 'TMP';
      case 'momentum':
        return 'MOM';
      case 'volume':
        return 'VOL';
      case 'volatility':
        return 'VTL';
      case 'sentiment':
        return 'SNT';
      case 'probability':
        return 'PRB';
      case 'correlation':
        return 'COR';
      default:
        return key.substring(0, 3).toUpperCase();
    }
  }

  Map<String, Color> _getDimensionColors() {
    return {
      'temporal': AppColors.cyan,
      'momentum': AppColors.buy,
      'volume': AppColors.imperialPurple,
      'volatility': AppColors.warning,
      'sentiment': const Color(0xFFFF6B9D),
      'probability': const Color(0xFF00D9FF),
      'correlation': const Color(0xFF9D50BB),
    };
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
