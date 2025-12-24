import 'package:flutter_test/flutter_test.dart';
import 'package:golden_nightmare_pro/core/utils/data_validation.dart';
import 'package:golden_nightmare_pro/models/candle.dart';

void main() {
  test('validateAndFixCandles fills small gaps and fixes high/low', () {
    final now = DateTime.now();

    final c1 = Candle(time: now.subtract(const Duration(minutes: 30)), open: 100.0, high: 101.0, low: 99.0, close: 100.5, volume: 1000);
    // create gap of 30 mins where expected interval is 15 -> one missing candle
    final c2 = Candle(time: now, open: 101.0, high: 101.5, low: 100.5, close: 101.2, volume: 1200);

    final cleaned = DataValidation.validateAndFixCandles([c1, c2], const Duration(minutes: 15));

    // should insert one candle
    expect(cleaned.length, 3);

    // ensure highs/lows consistent
    expect(cleaned.every((c) => c.high >= c.low), true);
  });
}
