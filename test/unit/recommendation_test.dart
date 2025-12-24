import 'package:flutter_test/flutter_test.dart';
import 'package:golden_nightmare_pro/models/recommendation.dart';

void main() {
  group('Recommendation Model Tests', () {
    test('should create recommendation with valid data', () {
      final recommendation = Recommendation(
        direction: Direction.buy,
        entry: 2050.0,
        stopLoss: 2040.0,
        takeProfit: 2070.0,
        confidence: Confidence.high,
        reasoning: 'Strong bullish signal',
        timestamp: DateTime.now(),
      );

      expect(recommendation.direction, equals(Direction.buy));
      expect(recommendation.entry, equals(2050.0));
      expect(recommendation.confidence, equals(Confidence.high));
    });

    test('should parse direction correctly from map', () {
      final buyMap = {'direction': 'BUY', 'confidence': 'HIGH'};
      final sellMap = {'direction': 'SELL', 'confidence': 'HIGH'};
      final noTradeMap = {'direction': 'NO_TRADE', 'confidence': 'LOW'};
      final nullMap = {'direction': null, 'confidence': 'LOW'};
      final invalidMap = {'direction': 'INVALID', 'confidence': 'LOW'};

      expect(Recommendation.fromMap(buyMap).direction, equals(Direction.buy));
      expect(Recommendation.fromMap(sellMap).direction, equals(Direction.sell));
      expect(Recommendation.fromMap(noTradeMap).direction,
          equals(Direction.noTrade));
      expect(
          Recommendation.fromMap(nullMap).direction, equals(Direction.noTrade));
      expect(Recommendation.fromMap(invalidMap).direction,
          equals(Direction.noTrade));
    });

    test('should parse confidence correctly from map', () {
      final veryHighMap = {'direction': 'BUY', 'confidence': 'VERY HIGH'};
      final highMap = {'direction': 'BUY', 'confidence': 'HIGH'};
      final mediumMap = {'direction': 'BUY', 'confidence': 'MEDIUM'};
      final lowMap = {'direction': 'BUY', 'confidence': 'LOW'};
      final nullMap = {'direction': 'BUY', 'confidence': null};
      final invalidMap = {'direction': 'BUY', 'confidence': 'INVALID'};

      expect(Recommendation.fromMap(veryHighMap).confidence,
          equals(Confidence.veryHigh));
      expect(
          Recommendation.fromMap(highMap).confidence, equals(Confidence.high));
      expect(Recommendation.fromMap(mediumMap).confidence,
          equals(Confidence.medium));
      expect(Recommendation.fromMap(lowMap).confidence, equals(Confidence.low));
      expect(
          Recommendation.fromMap(nullMap).confidence, equals(Confidence.low));
      expect(Recommendation.fromMap(invalidMap).confidence,
          equals(Confidence.low));
    });

    test('should create from map correctly', () {
      final map = {
        'direction': 'BUY',
        'entry': 2050.0,
        'stopLoss': 2040.0,
        'takeProfit': 2070.0,
        'confidence': 85,
        'reasoning': 'Test reasoning',
      };

      final recommendation = Recommendation.fromMap(map);

      expect(recommendation.direction, equals(Direction.buy));
      expect(recommendation.entry, equals(2050.0));
      expect(recommendation.stopLoss, equals(2040.0));
      expect(recommendation.takeProfit, equals(2070.0));
      expect(recommendation.confidence, equals(Confidence.high));
      expect(recommendation.reasoning, equals('Test reasoning'));
    });

    test('should parse price from string format', () {
      final map1 = {
        'direction': 'BUY',
        'entry': '\$2050.50',
        'confidence': 80,
        'reasoning': 'Test',
      };

      final rec1 = Recommendation.fromMap(map1);
      expect(rec1.entry, equals(2050.50));

      final map2 = {
        'direction': 'BUY',
        'entry': '2050.50',
        'confidence': 80,
        'reasoning': 'Test',
      };

      final rec2 = Recommendation.fromMap(map2);
      expect(rec2.entry, equals(2050.50));
    });

    test('should parse price range correctly', () {
      final map = {
        'direction': 'BUY',
        'entry': '2050-2060',
        'confidence': 80,
        'reasoning': 'Test',
      };

      final recommendation = Recommendation.fromMap(map);
      expect(recommendation.entry, equals(2055.0)); // Midpoint
    });

    test('should calculate potential profit correctly for BUY', () {
      final recommendation = Recommendation(
        direction: Direction.buy,
        entry: 2050.0,
        takeProfit: 2070.0,
        confidence: Confidence.high,
        reasoning: 'Test',
        timestamp: DateTime.now(),
      );

      expect(recommendation.potentialProfit, equals(20.0));
    });

    test('should calculate potential profit correctly for SELL', () {
      final recommendation = Recommendation(
        direction: Direction.sell,
        entry: 2050.0,
        takeProfit: 2030.0,
        confidence: Confidence.high,
        reasoning: 'Test',
        timestamp: DateTime.now(),
      );

      expect(recommendation.potentialProfit, equals(20.0));
    });

    test('should calculate potential loss correctly for BUY', () {
      final recommendation = Recommendation(
        direction: Direction.buy,
        entry: 2050.0,
        stopLoss: 2040.0,
        confidence: Confidence.high,
        reasoning: 'Test',
        timestamp: DateTime.now(),
      );

      expect(recommendation.potentialLoss, equals(10.0));
    });

    test('should calculate potential loss correctly for SELL', () {
      final recommendation = Recommendation(
        direction: Direction.sell,
        entry: 2050.0,
        stopLoss: 2060.0,
        confidence: Confidence.high,
        reasoning: 'Test',
        timestamp: DateTime.now(),
      );

      expect(recommendation.potentialLoss, equals(10.0));
    });

    test('should return null for potential profit when missing data', () {
      final recommendation = Recommendation(
        direction: Direction.buy,
        entry: null,
        confidence: Confidence.high,
        reasoning: 'Test',
        timestamp: DateTime.now(),
      );

      expect(recommendation.potentialProfit, isNull);
    });

    test('should return confidence value correctly', () {
      expect(Confidence.veryHigh.displayName, equals('Very High'));
      expect(Confidence.high.displayName, equals('High'));
      expect(Confidence.medium.displayName, equals('Medium'));
      expect(Confidence.low.displayName, equals('Low'));
    });

    test('should return direction display name correctly', () {
      expect(Direction.buy.displayName, equals('BUY'));
      expect(Direction.sell.displayName, equals('SELL'));
      expect(Direction.noTrade.displayName, equals('NO TRADE'));
    });

    test('should format risk/reward ratio correctly', () {
      final recommendation = Recommendation(
        direction: Direction.buy,
        entry: 2050.0,
        stopLoss: 2040.0,
        takeProfit: 2070.0,
        confidence: Confidence.high,
        reasoning: 'Test',
        timestamp: DateTime.now(),
        riskRewardRatio: 2.5,
      );

      expect(recommendation.rrText, equals('1:2.5'));
    });

    test('should return N/A for risk/reward when missing', () {
      final recommendation = Recommendation(
        direction: Direction.buy,
        confidence: Confidence.high,
        reasoning: 'Test',
        timestamp: DateTime.now(),
      );

      expect(recommendation.rrText, equals('N/A'));
    });

    test('should return confidence value as number', () {
      final rec1 = Recommendation(
        direction: Direction.buy,
        confidence: Confidence.veryHigh,
        reasoning: 'Test',
        timestamp: DateTime.now(),
      );
      expect(rec1.confidenceValue, equals(95.0));

      final rec2 = Recommendation(
        direction: Direction.buy,
        confidence: Confidence.high,
        reasoning: 'Test',
        timestamp: DateTime.now(),
      );
      expect(rec2.confidenceValue, equals(80.0));
    });
  });
}
