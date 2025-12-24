import 'dart:math';
import '../../models/candle.dart';
import '../../core/utils/logger.dart';

/// 🔗 Quantum Entanglement Correlator
/// يكتشف الارتباطات الخفية بين الذهب والأسواق الأخرى
class QuantumCorrelator {
  /// تحليل الارتباطات الكمومية
  static QuantumCorrelation analyze(
    List<Candle> goldCandles,
    List<Candle>? dxyCandles,
    List<Candle>? bondsCandles,
  ) {
    AppLogger.info('🔗 Analyzing quantum correlations...');

    // 1. حساب الارتباط مع الدولار (DXY)
    final dxyCorrelation = dxyCandles != null
        ? _calculateCorrelation(goldCandles, dxyCandles)
        : null;

    // 2. حساب الارتباط مع السندات (Bonds)
    final bondsCorrelation = bondsCandles != null
        ? _calculateCorrelation(goldCandles, bondsCandles)
        : null;

    // 3. حساب قوة الارتباط الكلية
    final correlationStrength = _calculateCorrelationStrength(
      dxyCorrelation,
      bondsCorrelation,
    );

    // 4. تحديد اتجاه الارتباط
    final correlationDirection = _determineCorrelationDirection(
      dxyCorrelation,
      bondsCorrelation,
    );

    // 5. حساب احتمال التحرك المتزامن
    final synchronizedMovementProbability =
        _calculateSynchronizedMovementProbability(
      dxyCorrelation,
      bondsCorrelation,
    );

    // 6. كشف Quantum Entanglement (الترابط الكمومي)
    final isEntangled = _detectQuantumEntanglement(
      dxyCorrelation,
      bondsCorrelation,
    );

    final correlation = QuantumCorrelation(
      dxyCorrelation: dxyCorrelation,
      bondsCorrelation: bondsCorrelation,
      correlationStrength: correlationStrength,
      correlationDirection: correlationDirection,
      synchronizedMovementProbability: synchronizedMovementProbability,
      isEntangled: isEntangled,
      timestamp: DateTime.now(),
    );

    AppLogger.success(
      '✅ Quantum Correlation: ${correlationDirection.name} '
      '(strength: ${(correlationStrength * 100).toStringAsFixed(1)}%)',
    );

    return correlation;
  }

  /// حساب معامل الارتباط (Pearson Correlation Coefficient)
  static CorrelationData _calculateCorrelation(
    List<Candle> goldCandles,
    List<Candle> otherCandles,
  ) {
    // نأخذ آخر N شمعة (حيث N = أقل عدد)
    final n = min(goldCandles.length, otherCandles.length);
    final gold = goldCandles.sublist(goldCandles.length - n);
    final other = otherCandles.sublist(otherCandles.length - n);

    // حساب العوائد (returns)
    final goldReturns = <double>[];
    final otherReturns = <double>[];

    for (int i = 1; i < n; i++) {
      goldReturns.add((gold[i].close - gold[i - 1].close) / gold[i - 1].close);
      otherReturns
          .add((other[i].close - other[i - 1].close) / other[i - 1].close);
    }

    // حساب المتوسطات
    final goldMean = goldReturns.reduce((a, b) => a + b) / goldReturns.length;
    final otherMean =
        otherReturns.reduce((a, b) => a + b) / otherReturns.length;

    // حساب Covariance
    double covariance = 0;
    for (int i = 0; i < goldReturns.length; i++) {
      covariance += (goldReturns[i] - goldMean) * (otherReturns[i] - otherMean);
    }
    covariance /= goldReturns.length;

    // حساب Standard Deviations
    double goldStdDev = 0;
    double otherStdDev = 0;
    for (int i = 0; i < goldReturns.length; i++) {
      goldStdDev += pow(goldReturns[i] - goldMean, 2);
      otherStdDev += pow(otherReturns[i] - otherMean, 2);
    }
    goldStdDev = sqrt(goldStdDev / goldReturns.length);
    otherStdDev = sqrt(otherStdDev / otherReturns.length);

    // حساب Correlation Coefficient
    double correlation = 0;
    if (goldStdDev > 0 && otherStdDev > 0) {
      correlation = covariance / (goldStdDev * otherStdDev);
    }

    // حساب P-value (اختبار الدلالة الإحصائية)
    final pValue = _calculatePValue(correlation, goldReturns.length);

    // تحديد نوع الارتباط
    final type = _determineCorrelationType(correlation);

    return CorrelationData(
      coefficient: correlation,
      pValue: pValue,
      type: type,
      isSignificant: pValue < 0.05, // دال إحصائياً إذا p < 0.05
    );
  }

  /// حساب P-value
  static double _calculatePValue(double r, int n) {
    if (n < 3) return 1.0;

    // t-statistic
    final t = r * sqrt((n - 2) / (1 - r * r));

    // تقريب P-value باستخدام t-distribution
    // هذا تقريب بسيط، في الواقع نحتاج t-distribution table
    final pValue = 2 * (1 - _normalCDF(t.abs()));

    return max(0.0, min(1.0, pValue));
  }

  /// Normal CDF (تقريب)
  static double _normalCDF(double x) {
    return 0.5 * (1 + _erf(x / sqrt(2)));
  }

  /// Error Function (تقريب)
  static double _erf(double x) {
    // Abramowitz and Stegun approximation
    final a1 = 0.254829592;
    final a2 = -0.284496736;
    final a3 = 1.421413741;
    final a4 = -1.453152027;
    final a5 = 1.061405429;
    final p = 0.3275911;

    final sign = x < 0 ? -1 : 1;
    x = x.abs();

    final t = 1.0 / (1.0 + p * x);
    final y = 1.0 -
        (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * exp(-x * x);

    return sign * y;
  }

  /// تحديد نوع الارتباط
  static CorrelationType _determineCorrelationType(double correlation) {
    if (correlation > 0.7) {
      return CorrelationType.strongPositive;
    } else if (correlation > 0.3) {
      return CorrelationType.moderatePositive;
    } else if (correlation > -0.3) {
      return CorrelationType.weak;
    } else if (correlation > -0.7) {
      return CorrelationType.moderateNegative;
    } else {
      return CorrelationType.strongNegative;
    }
  }

  /// حساب قوة الارتباط الكلية
  static double _calculateCorrelationStrength(
    CorrelationData? dxy,
    CorrelationData? bonds,
  ) {
    double strength = 0.0;
    int count = 0;

    if (dxy != null && dxy.isSignificant) {
      strength += dxy.coefficient.abs();
      count++;
    }

    if (bonds != null && bonds.isSignificant) {
      strength += bonds.coefficient.abs();
      count++;
    }

    return count > 0 ? strength / count : 0.0;
  }

  /// تحديد اتجاه الارتباط
  static CorrelationDirection _determineCorrelationDirection(
    CorrelationData? dxy,
    CorrelationData? bonds,
  ) {
    int bullishSignals = 0;
    int bearishSignals = 0;

    // DXY عكسي مع الذهب (سالب = صعود للذهب)
    if (dxy != null && dxy.isSignificant) {
      if (dxy.coefficient < -0.5) {
        bullishSignals++;
      } else if (dxy.coefficient > 0.5) {
        bearishSignals++;
      }
    }

    // Bonds طردي مع الذهب (موجب = صعود للذهب)
    if (bonds != null && bonds.isSignificant) {
      if (bonds.coefficient > 0.5) {
        bullishSignals++;
      } else if (bonds.coefficient < -0.5) {
        bearishSignals++;
      }
    }

    if (bullishSignals > bearishSignals) {
      return CorrelationDirection.bullish;
    } else if (bearishSignals > bullishSignals) {
      return CorrelationDirection.bearish;
    } else {
      return CorrelationDirection.neutral;
    }
  }

  /// حساب احتمال التحرك المتزامن
  static double _calculateSynchronizedMovementProbability(
    CorrelationData? dxy,
    CorrelationData? bonds,
  ) {
    double probability = 0.5; // Base probability

    if (dxy != null && dxy.isSignificant) {
      probability += dxy.coefficient.abs() * 0.25;
    }

    if (bonds != null && bonds.isSignificant) {
      probability += bonds.coefficient.abs() * 0.25;
    }

    return min(probability, 1.0);
  }

  /// كشف Quantum Entanglement (الترابط الكمومي)
  /// يحدث عندما يكون الارتباط قوي جداً (> 0.8 أو < -0.8)
  static bool _detectQuantumEntanglement(
    CorrelationData? dxy,
    CorrelationData? bonds,
  ) {
    if (dxy != null && dxy.coefficient.abs() > 0.8 && dxy.isSignificant) {
      return true;
    }

    if (bonds != null && bonds.coefficient.abs() > 0.8 && bonds.isSignificant) {
      return true;
    }

    return false;
  }
}

/// 🔗 Quantum Correlation Model
class QuantumCorrelation {
  final CorrelationData? dxyCorrelation;
  final CorrelationData? bondsCorrelation;
  final double correlationStrength; // 0-1
  final CorrelationDirection correlationDirection;
  final double synchronizedMovementProbability; // 0-1
  final bool isEntangled; // ترابط كمومي قوي
  final DateTime timestamp;

  QuantumCorrelation({
    this.dxyCorrelation,
    this.bondsCorrelation,
    required this.correlationStrength,
    required this.correlationDirection,
    required this.synchronizedMovementProbability,
    required this.isEntangled,
    required this.timestamp,
  });

  /// هل الارتباط قوي؟
  bool get isStrongCorrelation => correlationStrength > 0.7;

  /// هل يدعم الصعود؟
  bool get supportsBullish =>
      correlationDirection == CorrelationDirection.bullish;

  /// هل يدعم الهبوط؟
  bool get supportsBearish =>
      correlationDirection == CorrelationDirection.bearish;

  @override
  String toString() {
    return 'QuantumCorrelation('
        'DXY: ${dxyCorrelation?.coefficient.toStringAsFixed(3) ?? 'N/A'}, '
        'Bonds: ${bondsCorrelation?.coefficient.toStringAsFixed(3) ?? 'N/A'}, '
        'strength: ${(correlationStrength * 100).toStringAsFixed(1)}%, '
        'direction: ${correlationDirection.name}, '
        'synchronized: ${(synchronizedMovementProbability * 100).toStringAsFixed(1)}%, '
        'entangled: $isEntangled'
        ')';
  }
}

/// بيانات الارتباط
class CorrelationData {
  final double coefficient; // -1 to 1
  final double pValue; // 0 to 1
  final CorrelationType type;
  final bool isSignificant; // p < 0.05

  CorrelationData({
    required this.coefficient,
    required this.pValue,
    required this.type,
    required this.isSignificant,
  });
}

/// نوع الارتباط
enum CorrelationType {
  strongPositive,
  moderatePositive,
  weak,
  moderateNegative,
  strongNegative,
}

/// اتجاه الارتباط
enum CorrelationDirection {
  bullish,
  bearish,
  neutral,
}
