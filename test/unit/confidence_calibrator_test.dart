import 'package:flutter_test/flutter_test.dart';
import 'package:golden_nightmare_pro/services/confidence_calibrator.dart';

void main() {
  test('calibrator returns values in 0..1 and monotonic', () {
    final c = ConfidenceCalibrator.instance;

    final low = c.calibrate(0.0);
    final mid = c.calibrate(0.5);
    final high = c.calibrate(1.0);

    expect(low >= 0.0 && low <= 1.0, true);
    expect(mid >= 0.0 && mid <= 1.0, true);
    expect(high >= 0.0 && high <= 1.0, true);

    expect(low <= mid && mid <= high, true);
  });

  test('fit adjusts parameters without throwing', () async {
    final c = ConfidenceCalibrator.instance;
    final before = c.params;

    // Toy dataset: higher raw -> label 1
    final raws = [0.1, 0.2, 0.4, 0.6, 0.8];
    final labels = [0, 0, 0, 1, 1];

    await c.fit(raws, labels, epochs: 50, lr: 0.1);

    final after = c.params;
    expect(after['A'] != before['A'] || after['B'] != before['B'], true);
  });
}
