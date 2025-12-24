import 'package:flutter_test/flutter_test.dart';
import 'package:golden_nightmare_pro/services/quantum_scalping/quantum_scalping_engine.dart';
import 'package:golden_nightmare_pro/services/quantum_scalping/bayesian_probability_matrix.dart';
import 'package:golden_nightmare_pro/models/candle.dart';

void main() {
  group('QuantumScalpingEngine Tests', () {
    late List<Candle> testCandles;

    setUp(() {
      final now = DateTime.now();
      testCandles = List.generate(200, (index) {
        final basePrice = 2000.0 + (index * 0.5);
        return Candle(
          time: now.subtract(Duration(hours: 200 - index)),
          open: basePrice,
          high: basePrice + 3.0,
          low: basePrice - 3.0,
          close: basePrice + (index % 2 == 0 ? 1.5 : -1.5),
          volume: 2000.0 + (index * 20),
        );
      });
    });

    test('should generate valid quantum signal', () async {
      final signal = await QuantumScalpingEngine.analyze(
        goldCandles: testCandles,
      );

      expect(signal, isNotNull);
      expect(signal.direction, isA<SignalDirection>());
      expect(signal.confidence, inInclusiveRange(0.0, 1.0));
      expect(signal.quantumScore, inInclusiveRange(0.0, 10.0));
      expect(signal.entry, greaterThan(0));
      expect(signal.stopLoss, greaterThan(0));
      expect(signal.takeProfit, greaterThan(0));
    });

    test('should calculate 7 dimensions correctly', () async {
      final signal = await QuantumScalpingEngine.analyze(
        goldCandles: testCandles,
      );

      expect(signal.dimensions, isNotNull);
      expect(signal.dimensions.length, equals(7));

      // Check all dimensions are valid
      signal.dimensions.forEach((key, value) {
        expect(value, inInclusiveRange(0.0, 10.0));
      });
    });

    test('should calculate Bayesian probability', () async {
      final signal = await QuantumScalpingEngine.analyze(
        goldCandles: testCandles,
      );

      expect(signal.confidence, isNotNull);
      expect(signal.confidence, inInclusiveRange(0.0, 1.0));
      expect(signal.expectedReturn, isNotNull);
      expect(signal.riskRewardRatio, greaterThan(0));
    });

    test('should validate entry/stop/take profit logic', () async {
      final signal = await QuantumScalpingEngine.analyze(
        goldCandles: testCandles,
      );

      if (signal.direction == SignalDirection.buy) {
        expect(signal.stopLoss, lessThan(signal.entry));
        expect(signal.takeProfit, greaterThan(signal.entry));
      } else if (signal.direction == SignalDirection.sell) {
        expect(signal.stopLoss, greaterThan(signal.entry));
        expect(signal.takeProfit, lessThan(signal.entry));
      }
    });

    test('should calculate risk/reward ratio correctly', () async {
      final signal = await QuantumScalpingEngine.analyze(
        goldCandles: testCandles,
      );

      expect(signal.riskRewardRatio, greaterThan(0));

      if (signal.direction != SignalDirection.neutral) {
        final risk = (signal.entry - signal.stopLoss).abs();
        final reward = (signal.takeProfit - signal.entry).abs();
        final calculatedRR = reward / risk;

        expect(signal.riskRewardRatio, closeTo(calculatedRR, 0.1));
      }
    });

    test('should generate reasoning', () async {
      final signal = await QuantumScalpingEngine.analyze(
        goldCandles: testCandles,
      );

      expect(signal.reasoning, isNotNull);
      expect(signal.reasoning, isNotEmpty);
    });

    test('should handle different market conditions', () async {
      // Bullish candles
      final bullishCandles = List.generate(100, (index) {
        final basePrice = 2000.0 + (index * 2.0);
        return Candle(
          time: DateTime.now().subtract(Duration(hours: 100 - index)),
          open: basePrice,
          high: basePrice + 5.0,
          low: basePrice - 1.0,
          close: basePrice + 4.0,
          volume: 2000.0,
        );
      });

      final bullishSignal = await QuantumScalpingEngine.analyze(
        goldCandles: bullishCandles,
      );

      expect(bullishSignal, isNotNull);

      // Bearish candles
      final bearishCandles = List.generate(100, (index) {
        final basePrice = 2100.0 - (index * 2.0);
        return Candle(
          time: DateTime.now().subtract(Duration(hours: 100 - index)),
          open: basePrice,
          high: basePrice + 1.0,
          low: basePrice - 5.0,
          close: basePrice - 4.0,
          volume: 2000.0,
        );
      });

      final bearishSignal = await QuantumScalpingEngine.analyze(
        goldCandles: bearishCandles,
      );

      expect(bearishSignal, isNotNull);
    });

    test('should calculate position size', () async {
      final signal = await QuantumScalpingEngine.analyze(
        goldCandles: testCandles,
      );

      expect(signal.positionSize, isNotNull);
      expect(signal.positionSize, greaterThan(0));
      expect(signal.positionSize, lessThanOrEqualTo(1.0));
    });

    test('should include alerts when needed', () async {
      final signal = await QuantumScalpingEngine.analyze(
        goldCandles: testCandles,
      );

      expect(signal.alerts, isNotNull);
      expect(signal.alerts, isA<List<String>>());
    });

    test('should calculate trade quality', () async {
      final signal = await QuantumScalpingEngine.analyze(
        goldCandles: testCandles,
      );

      expect(signal.tradeQuality, isNotNull);
      expect(signal.tradeQuality, isA<TradeQuality>());
    });

    test('should handle edge cases with minimal candles', () async {
      final fewCandles = testCandles.take(20).toList();

      final signal = await QuantumScalpingEngine.analyze(
        goldCandles: fewCandles,
      );

      expect(signal, isNotNull);
      // Should still return valid signal structure
      expect(signal.direction, isA<SignalDirection>());
    });
  });
}
