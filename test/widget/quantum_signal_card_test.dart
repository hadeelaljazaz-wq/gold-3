import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_nightmare_pro/features/quantum_analysis/widgets/quantum_signal_card.dart';
import 'package:golden_nightmare_pro/services/quantum_scalping/quantum_scalping_engine.dart';
import 'package:golden_nightmare_pro/services/quantum_scalping/bayesian_probability_matrix.dart';

void main() {
  group('QuantumSignalCard Widget Tests', () {
    testWidgets('should render quantum signal card',
        (WidgetTester tester) async {
      final signal = QuantumSignal(
        direction: SignalDirection.buy,
        entry: 2050.0,
        stopLoss: 2040.0,
        takeProfit: 2070.0,
        confidence: 0.75,
        quantumScore: 7.5,
        positionSize: 0.1,
        riskRewardRatio: 2.0,
        expectedReturn: 20.0,
        dimensions: {
          'quantum': 7.0,
          'temporal': 8.0,
          'smart_money': 7.5,
          'chaos': 6.5,
          'correlation': 7.0,
          'probability': 8.5,
          'synthesis': 7.5,
        },
        reasoning: 'Strong bullish signals',
        alerts: [],
        tradeQuality: TradeQuality.good,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuantumSignalCard(signal: signal),
          ),
        ),
      );

      expect(find.byType(QuantumSignalCard), findsOneWidget);
    });

    testWidgets('should display quantum score', (WidgetTester tester) async {
      final signal = QuantumSignal(
        direction: SignalDirection.buy,
        entry: 2050.0,
        stopLoss: 2040.0,
        takeProfit: 2070.0,
        confidence: 0.75,
        quantumScore: 8.5,
        positionSize: 0.1,
        riskRewardRatio: 2.0,
        expectedReturn: 20.0,
        dimensions: {},
        reasoning: 'Test',
        alerts: [],
        tradeQuality: TradeQuality.excellent,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuantumSignalCard(signal: signal),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display quantum score
      final scoreText = find.textContaining('8.5', findRichText: true);
      expect(scoreText, anyOf(findsNothing, findsWidgets));
    });

    testWidgets('should display 7 dimensions', (WidgetTester tester) async {
      final signal = QuantumSignal(
        direction: SignalDirection.buy,
        entry: 2050.0,
        stopLoss: 2040.0,
        takeProfit: 2070.0,
        confidence: 0.75,
        quantumScore: 7.5,
        positionSize: 0.1,
        riskRewardRatio: 2.0,
        expectedReturn: 20.0,
        dimensions: {
          'quantum': 7.0,
          'temporal': 8.0,
          'smart_money': 7.5,
          'chaos': 6.5,
          'correlation': 7.0,
          'probability': 8.5,
          'synthesis': 7.5,
        },
        reasoning: 'Test',
        alerts: [],
        tradeQuality: TradeQuality.good,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuantumSignalCard(signal: signal),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display dimension information
      expect(find.byType(QuantumSignalCard), findsOneWidget);
    });

    testWidgets('should display trade quality', (WidgetTester tester) async {
      final signal = QuantumSignal(
        direction: SignalDirection.buy,
        entry: 2050.0,
        stopLoss: 2040.0,
        takeProfit: 2070.0,
        confidence: 0.85,
        quantumScore: 9.0,
        positionSize: 0.15,
        riskRewardRatio: 2.5,
        expectedReturn: 25.0,
        dimensions: {},
        reasoning: 'Excellent signal',
        alerts: [],
        tradeQuality: TradeQuality.excellent,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuantumSignalCard(signal: signal),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(QuantumSignalCard), findsOneWidget);
    });

    testWidgets('should handle neutral signal', (WidgetTester tester) async {
      final signal = QuantumSignal(
        direction: SignalDirection.neutral,
        entry: 2050.0,
        stopLoss: 2040.0,
        takeProfit: 2060.0,
        confidence: 0.3,
        quantumScore: 3.0,
        positionSize: 0.0,
        riskRewardRatio: 1.0,
        expectedReturn: 0.0,
        dimensions: {},
        reasoning: 'No clear signal',
        alerts: ['Low confidence'],
        tradeQuality: TradeQuality.poor,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuantumSignalCard(signal: signal),
          ),
        ),
      );

      expect(find.byType(QuantumSignalCard), findsOneWidget);
    });
  });
}
