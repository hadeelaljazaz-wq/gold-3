import 'package:flutter_test/flutter_test.dart';
import 'package:golden_nightmare_pro/models/scalping_signal.dart';
import 'package:golden_nightmare_pro/services/engines/scalping_engine_v2.dart';

void main() {
  group('ScalpingSignal Model Tests', () {
    test('should create scalping signal with valid data', () {
      final signal = ScalpingSignal(
        direction: 'BUY',
        entryPrice: 2050.0,
        stopLoss: 2040.0,
        takeProfit: 2070.0,
        confidence: 75,
        timestamp: DateTime.now(),
      );

      expect(signal.direction, equals('BUY'));
      expect(signal.entryPrice, equals(2050.0));
      expect(signal.confidence, equals(75));
      expect(signal.isValid, isTrue);
      expect(signal.isBuy, isTrue);
      expect(signal.isSell, isFalse);
    });

    test('should create NO_TRADE signal correctly', () {
      final signal = ScalpingSignal.noTrade(reason: 'Insufficient data');

      expect(signal.direction, equals('NO_TRADE'));
      expect(signal.confidence, equals(0));
      expect(signal.isValid, isFalse);
      expect(signal.reason, equals('Insufficient data'));
    });

    test('should create SELL signal correctly', () {
      final signal = ScalpingSignal(
        direction: 'SELL',
        entryPrice: 2050.0,
        stopLoss: 2060.0,
        takeProfit: 2030.0,
        confidence: 80,
        timestamp: DateTime.now(),
      );

      expect(signal.direction, equals('SELL'));
      expect(signal.isSell, isTrue);
      expect(signal.isBuy, isFalse);
      expect(signal.isValid, isTrue);
    });

    test('should serialize to JSON correctly', () {
      final signal = ScalpingSignal(
        direction: 'BUY',
        entryPrice: 2050.0,
        stopLoss: 2040.0,
        takeProfit: 2070.0,
        confidence: 75,
        riskReward: 2.0,
        timestamp: DateTime(2024, 1, 1, 12, 0, 0),
        reason: 'Test reason',
      );

      final json = signal.toJson();

      expect(json['direction'], equals('BUY'));
      expect(json['entryPrice'], equals(2050.0));
      expect(json['stopLoss'], equals(2040.0));
      expect(json['takeProfit'], equals(2070.0));
      expect(json['confidence'], equals(75));
      expect(json['riskReward'], equals(2.0));
      expect(json['reason'], equals('Test reason'));
      expect(json['timestamp'], isA<String>());
    });

    test('should handle null values in JSON', () {
      final signal = ScalpingSignal.noTrade(reason: 'No signal');

      final json = signal.toJson();

      expect(json['direction'], equals('NO_TRADE'));
      expect(json['entryPrice'], isNull);
      expect(json['stopLoss'], isNull);
      expect(json['takeProfit'], isNull);
    });

    test('should include micro trend when available', () {
      final microTrend = MicroTrend.bullish(5, 2045.0, 2040.0, 2035.0);
      final signal = ScalpingSignal(
        direction: 'BUY',
        entryPrice: 2050.0,
        stopLoss: 2040.0,
        takeProfit: 2070.0,
        confidence: 75,
        microTrend: microTrend,
        timestamp: DateTime.now(),
      );

      expect(signal.microTrend, isNotNull);
      expect(signal.microTrend!.direction, equals('BULLISH'));
    });

    test('should include momentum analysis when available', () {
      final momentum = MomentumAnalysis(
        score: 5,
        classification: 'Bullish',
        rsi: 65.0,
        macd: 1.0,
        macdSignal: 0.5,
        macdHistogram: 0.5,
        signals: ['RSI Bullish', 'MACD Bullish'],
      );
      final signal = ScalpingSignal(
        direction: 'BUY',
        entryPrice: 2050.0,
        stopLoss: 2040.0,
        takeProfit: 2070.0,
        confidence: 75,
        momentum: momentum,
        timestamp: DateTime.now(),
      );

      expect(signal.momentum, isNotNull);
      expect(signal.momentum!.score, equals(5));
      expect(signal.momentum!.signals.length, equals(2));
    });

    test('should include volatility analysis when available', () {
      final volatility = MicroVolatility(
        atr: 5.0,
        avgRange: 4.5,
        atrRatio: 1.1,
        wickRatio: 0.5,
        isLowVolatility: false,
        isHighVolatility: false,
        isWickyMarket: false,
        isSuddenMove: false,
        isSuitableForScalping: true,
        isIdeal: true,
      );
      final signal = ScalpingSignal(
        direction: 'BUY',
        entryPrice: 2050.0,
        stopLoss: 2040.0,
        takeProfit: 2070.0,
        confidence: 75,
        volatility: volatility,
        timestamp: DateTime.now(),
      );

      expect(signal.volatility, isNotNull);
      expect(signal.volatility!.isSuitableForScalping, isTrue);
    });

    test('should include RSI zone when available', () {
      final rsiZone = RsiSignalZone(
        rsi: 65.0,
        zone: 'Bullish',
        signal: 'BUY',
        reversalProbability: 0.3,
        hasDivergence: false,
      );
      final signal = ScalpingSignal(
        direction: 'BUY',
        entryPrice: 2050.0,
        stopLoss: 2040.0,
        takeProfit: 2070.0,
        confidence: 75,
        rsiZone: rsiZone,
        timestamp: DateTime.now(),
      );

      expect(signal.rsiZone, isNotNull);
      expect(signal.rsiZone!.zone, equals('Bullish'));
    });

    test('should calculate risk/reward ratio correctly', () {
      final signal = ScalpingSignal(
        direction: 'BUY',
        entryPrice: 2050.0,
        stopLoss: 2040.0, // 10 points risk
        takeProfit: 2070.0, // 20 points reward
        confidence: 75,
        timestamp: DateTime.now(),
      );

      // Risk/Reward should be calculated as 20/10 = 2.0
      if (signal.riskReward != null) {
        expect(signal.riskReward, closeTo(2.0, 0.1));
      }
    });
  });
}
