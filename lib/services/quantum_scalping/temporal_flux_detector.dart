import 'dart:math';
import '../../models/candle.dart';
import '../../core/utils/logger.dart';

/// ⏰ Temporal Flux Detector
/// يكتشف "تدفق الزمن" - السرعة التي يتحرك بها السعر عبر الزمن
class TemporalFluxDetector {
  /// كشف التدفق الزمني
  static TemporalFlux detect(List<Candle> candles) {
    if (candles.length < 100) {
      throw Exception('Need at least 100 candles for temporal analysis');
    }

    AppLogger.info('⏰ Detecting temporal flux...');

    // 1. حساب السرعة (Velocity) في أطر زمنية مختلفة
    final velocityM1 = _calculateVelocity(candles.sublist(candles.length - 10));
    final velocityM5 = _calculateVelocity(candles.sublist(candles.length - 50));
    final velocityM15 = _calculateVelocity(candles);

    // 2. حساب التسارع (Acceleration)
    final acceleration = _calculateAcceleration(candles);

    // 3. حساب الزخم (Momentum)
    final momentum = _calculateMomentum(candles);

    // 4. كشف نقطة الانفجار (Breakout Point)
    final breakoutProbability = _calculateBreakoutProbability(
      velocityM1,
      velocityM5,
      velocityM15,
      acceleration,
      momentum,
    );

    // 5. تحديد اتجاه التدفق
    final fluxDirection = _determineFluxDirection(
      velocityM1,
      velocityM5,
      velocityM15,
    );

    // 6. حساب قوة التدفق
    final fluxStrength = _calculateFluxStrength(
      velocityM1,
      velocityM5,
      velocityM15,
      acceleration,
    );

    final flux = TemporalFlux(
      velocityM1: velocityM1,
      velocityM5: velocityM5,
      velocityM15: velocityM15,
      acceleration: acceleration,
      momentum: momentum,
      breakoutProbability: breakoutProbability,
      fluxDirection: fluxDirection,
      fluxStrength: fluxStrength,
      timestamp: DateTime.now(),
    );

    AppLogger.success(
      '✅ Temporal Flux: ${fluxDirection.name} (strength: ${(fluxStrength * 100).toStringAsFixed(1)}%)',
    );

    return flux;
  }

  /// حساب السرعة (Velocity)
  /// Velocity = (Price Change) / (Time Change) × (Volume Weight)
  static double _calculateVelocity(List<Candle> candles) {
    if (candles.isEmpty) return 0.0;

    final firstPrice = candles.first.close;
    final lastPrice = candles.last.close;
    final priceChange = lastPrice - firstPrice;
    final timeChange = candles.length.toDouble();

    // حساب متوسط الحجم
    final avgVolume =
        candles.map((c) => c.volume).reduce((a, b) => a + b) / candles.length;
    final volumeWeight = min(avgVolume / 1000000, 2.0); // Max weight = 2.0

    final velocity = (priceChange / timeChange) * volumeWeight;

    return velocity;
  }

  /// حساب التسارع (Acceleration)
  /// Acceleration = (Current Velocity - Previous Velocity) / Time
  static double _calculateAcceleration(List<Candle> candles) {
    final recent = candles.sublist(candles.length - 50);
    final previous = candles.sublist(candles.length - 100, candles.length - 50);

    final recentVelocity = _calculateVelocity(recent);
    final previousVelocity = _calculateVelocity(previous);

    final acceleration = (recentVelocity - previousVelocity) / 50;

    return acceleration;
  }

  /// حساب الزخم (Momentum)
  /// Momentum = Sum of (Price × Volume) for last N candles
  static double _calculateMomentum(List<Candle> candles) {
    final recent = candles.sublist(candles.length - 20);

    double momentum = 0.0;
    for (var candle in recent) {
      final priceChange = candle.close - candle.open;
      momentum += priceChange * candle.volume;
    }

    // Normalize
    return momentum / 1000000;
  }

  /// حساب احتمال الانفجار (Breakout Probability)
  static double _calculateBreakoutProbability(
    double velocityM1,
    double velocityM5,
    double velocityM15,
    double acceleration,
    double momentum,
  ) {
    double score = 0.0;

    // 1. السرعة تتزايد في جميع الأطر الزمنية
    if (velocityM1.abs() > velocityM5.abs() &&
        velocityM5.abs() > velocityM15.abs()) {
      score += 0.3;
    }

    // 2. التسارع إيجابي وقوي (10x more sensitive)
    if (acceleration.abs() > 0.001) {
      score += 0.3;
    }

    // 3. الزخم قوي (10x more sensitive)
    if (momentum.abs() > 1.0) {
      score += 0.2;
    }

    // 4. السرعة في M1 قوية جداً (5x more sensitive)
    if (velocityM1.abs() > 0.1) {
      score += 0.2;
    }

    return min(score, 1.0);
  }

  /// تحديد اتجاه التدفق
  static FluxDirection _determineFluxDirection(
    double velocityM1,
    double velocityM5,
    double velocityM15,
  ) {
    final avgVelocity = (velocityM1 + velocityM5 + velocityM15) / 3;

    if (avgVelocity > 0.1) {
      return FluxDirection.upward;
    } else if (avgVelocity < -0.1) {
      return FluxDirection.downward;
    } else {
      return FluxDirection.sideways;
    }
  }

  /// حساب قوة التدفق
  static double _calculateFluxStrength(
    double velocityM1,
    double velocityM5,
    double velocityM15,
    double acceleration,
  ) {
    // القوة = متوسط السرعات + التسارع (normalized better)
    final avgVelocity =
        (velocityM1.abs() + velocityM5.abs() + velocityM15.abs()) / 3;

    // Normalize to 0-1 range with better scaling
    final velocityStrength = min(avgVelocity * 5.0, 1.0); // 5x amplification
    final accelerationStrength =
        min(acceleration.abs() * 50.0, 1.0); // 50x amplification

    final strength = (velocityStrength * 0.7) + (accelerationStrength * 0.3);

    return min(strength, 1.0);
  }
}

/// ⏰ Temporal Flux Model
class TemporalFlux {
  final double velocityM1; // السرعة في M1
  final double velocityM5; // السرعة في M5
  final double velocityM15; // السرعة في M15
  final double acceleration; // التسارع
  final double momentum; // الزخم
  final double breakoutProbability; // احتمال الانفجار (0-1)
  final FluxDirection fluxDirection; // اتجاه التدفق
  final double fluxStrength; // قوة التدفق (0-1)
  final DateTime timestamp;

  TemporalFlux({
    required this.velocityM1,
    required this.velocityM5,
    required this.velocityM15,
    required this.acceleration,
    required this.momentum,
    required this.breakoutProbability,
    required this.fluxDirection,
    required this.fluxStrength,
    required this.timestamp,
  });

  /// هل التدفق قوي؟
  bool get isStrong => fluxStrength > 0.6;

  /// هل يوجد احتمال انفجار؟
  bool get hasBreakoutPotential => breakoutProbability > 0.7;

  /// هل السرعة تتزايد؟
  bool get isAccelerating => acceleration > 0;

  @override
  String toString() {
    return 'TemporalFlux('
        'M1: ${velocityM1.toStringAsFixed(3)}, '
        'M5: ${velocityM5.toStringAsFixed(3)}, '
        'M15: ${velocityM15.toStringAsFixed(3)}, '
        'acceleration: ${acceleration.toStringAsFixed(3)}, '
        'momentum: ${momentum.toStringAsFixed(1)}, '
        'breakout: ${(breakoutProbability * 100).toStringAsFixed(1)}%, '
        'direction: ${fluxDirection.name}, '
        'strength: ${(fluxStrength * 100).toStringAsFixed(1)}%'
        ')';
  }
}

/// اتجاه التدفق
enum FluxDirection {
  upward,
  downward,
  sideways,
}
