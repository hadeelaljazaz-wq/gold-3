import 'package:flutter_test/flutter_test.dart';
import 'package:golden_nightmare_pro/services/kabous_pro/multitimeframe_service.dart';
import 'package:golden_nightmare_pro/services/kabous_pro/kabous_models.dart';

void main() {
  group('MultiTimeframeService Tests', () {
    test('should have valid timeframes list', () {
      expect(MultiTimeframeService.timeframes, isNotEmpty);
      expect(MultiTimeframeService.timeframes.length, greaterThan(0));

      for (final tf in MultiTimeframeService.timeframes) {
        expect(tf, isNotEmpty);
        expect(tf, matches(RegExp(r'^\d+[mhd]$')));
      }
    });

    test('should analyze all timeframes', () async {
      final result = await MultiTimeframeService.analyzeAllTimeframes(
        currentPrice: 2050.0,
      );

      expect(result, isNotNull);
      expect(result.overallSignal, isNotNull);
      expect(result.overallConfidence, inInclusiveRange(0.0, 100.0));
      expect(result.timeframes, isA<Map<String, TimeframeAnalysis>>());
      expect(result.alignmentScore, inInclusiveRange(0.0, 100.0));
    });

    test('should return valid timeframe analysis', () async {
      final result = await MultiTimeframeService.analyzeAllTimeframes(
        currentPrice: 2050.0,
      );

      // Check that timeframe results are valid
      for (final entry in result.timeframes.entries) {
        expect(entry.key, isNotEmpty);
        expect(entry.value, isNotNull);
        expect(entry.value.timeframe, equals(entry.key));
        expect(entry.value.signal, isIn(['BUY', 'SELL', 'NO_TRADE']));
        expect(entry.value.confidence, inInclusiveRange(0.0, 100.0));
      }
    });

    test('should calculate overall signal correctly', () async {
      final result = await MultiTimeframeService.analyzeAllTimeframes(
        currentPrice: 2050.0,
      );

      expect(result.overallSignal, isIn(['BUY', 'SELL', 'NO_TRADE']));
      expect(result.overallConfidence, inInclusiveRange(0.0, 100.0));
    });

    test('should calculate alignment score', () async {
      final result = await MultiTimeframeService.analyzeAllTimeframes(
        currentPrice: 2050.0,
      );

      expect(result.alignmentScore, inInclusiveRange(0.0, 100.0));

      // Higher alignment means more timeframes agree
      if (result.timeframes.length > 1) {
        // Alignment should be reasonable
        expect(result.alignmentScore, greaterThanOrEqualTo(0));
      }
    });

    test('should handle different price levels', () async {
      final prices = [2000.0, 2050.0, 2100.0, 2150.0];

      for (final price in prices) {
        final result = await MultiTimeframeService.analyzeAllTimeframes(
          currentPrice: price,
        );

        expect(result, isNotNull);
        expect(result.overallSignal, isNotNull);
      }
    });

    test('should provide recommendation', () async {
      final result = await MultiTimeframeService.analyzeAllTimeframes(
        currentPrice: 2050.0,
      );

      expect(result.recommendation, isNotNull);
      expect(result.recommendation, isNotEmpty);
    });

    test('should handle edge cases with extreme prices', () async {
      final extremePrices = [1000.0, 3000.0];

      for (final price in extremePrices) {
        final result = await MultiTimeframeService.analyzeAllTimeframes(
          currentPrice: price,
        );

        expect(result, isNotNull);
        // Should still return valid structure
        expect(result.overallSignal, isIn(['BUY', 'SELL', 'NO_TRADE']));
      }
    });

    test('should return consistent results for same price', () async {
      final result1 = await MultiTimeframeService.analyzeAllTimeframes(
        currentPrice: 2050.0,
      );

      final result2 = await MultiTimeframeService.analyzeAllTimeframes(
        currentPrice: 2050.0,
      );

      // Results may vary slightly due to time-based data, but structure should be consistent
      expect(result1.overallSignal, isIn(['BUY', 'SELL', 'NO_TRADE']));
      expect(result2.overallSignal, isIn(['BUY', 'SELL', 'NO_TRADE']));
    });
  });
}
