import 'dart:math' as math;
import '../core/utils/logger.dart';

/// Simple Platt-scaling style calibrator with optional gradient-fit
class ConfidenceCalibrator {
  ConfidenceCalibrator._();
  static final ConfidenceCalibrator instance = ConfidenceCalibrator._();

  // Platt parameters (initialized to sensible defaults)
  double _A = 6.0; // slope
  double _B = -3.0; // intercept

  /// Calibrate raw confidence in [0,1] to calibrated probability [0,1]
  double calibrate(double raw) {
    final x = raw.clamp(0.0, 1.0);
    final z = _A * (x - 0.5) + _B;
    final p = 1.0 / (1.0 + math.exp(-z));
    return p.clamp(0.0, 1.0);
  }

  /// Add a small SGD-based fit over observations (raw in 0..1, label 0/1)
  /// This is lightweight and safe to run in-app for incremental improvement.
  Future<void> fit(List<double> raw, List<int> labels,
      {int epochs = 200, double lr = 0.01}) async {
    if (raw.length != labels.length || raw.isEmpty) return;
    double A = _A;
    double B = _B;

    for (int e = 0; e < epochs; e++) {
      double gradA = 0.0;
      double gradB = 0.0;

      for (int i = 0; i < raw.length; i++) {
        final x = raw[i].clamp(0.0, 1.0);
        final y = labels[i].toDouble();
        final z = A * (x - 0.5) + B;
        final p = 1.0 / (1.0 + math.exp(-z));
        final err = p - y;
        gradA += err * p * (1 - p) * (x - 0.5);
        gradB += err * p * (1 - p);
      }

      A -= lr * gradA / raw.length;
      B -= lr * gradB / raw.length;
    }

    _A = A;
    _B = B;
    AppLogger.info('ConfidenceCalibrator: fitted params A=${_A.toStringAsFixed(3)}, B=${_B.toStringAsFixed(3)}');
  }

  Map<String, double> get params => {'A': _A, 'B': _B};
}
