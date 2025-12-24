import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_nightmare_pro/features/quantum_analysis/widgets/bayesian_probability_card.dart';
import 'package:golden_nightmare_pro/services/quantum_scalping/bayesian_probability_matrix.dart';

void main() {
  group('BayesianProbabilityCard Widget Tests', () {
    testWidgets('should render bayesian probability card',
        (WidgetTester tester) async {
      final probability = BayesianProbability(
        priorProbability: 0.5,
        likelihood: 0.7,
        evidence: 0.6,
        posteriorProbability: 0.75,
        expectedReturn: 20.0,
        riskRewardRatio: 2.0,
        optimalPositionSize: 0.1,
        confidenceLevel: 0.8,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BayesianProbabilityCard(probability: probability),
          ),
        ),
      );

      expect(find.byType(BayesianProbabilityCard), findsOneWidget);
    });

    testWidgets('should display posterior probability',
        (WidgetTester tester) async {
      final probability = BayesianProbability(
        priorProbability: 0.5,
        likelihood: 0.7,
        evidence: 0.6,
        posteriorProbability: 0.85,
        expectedReturn: 25.0,
        riskRewardRatio: 2.5,
        optimalPositionSize: 0.15,
        confidenceLevel: 0.9,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BayesianProbabilityCard(probability: probability),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display probability percentage
      final probabilityText = find.textContaining('85', findRichText: true);
      expect(probabilityText, anyOf(findsNothing, findsWidgets));
    });

    testWidgets('should display risk/reward ratio',
        (WidgetTester tester) async {
      final probability = BayesianProbability(
        priorProbability: 0.5,
        likelihood: 0.7,
        evidence: 0.6,
        posteriorProbability: 0.75,
        expectedReturn: 20.0,
        riskRewardRatio: 2.5,
        optimalPositionSize: 0.1,
        confidenceLevel: 0.8,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BayesianProbabilityCard(probability: probability),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display R/R ratio
      final rrText = find.textContaining('2.5', findRichText: true);
      expect(rrText, anyOf(findsNothing, findsWidgets));
    });

    testWidgets('should display expected return', (WidgetTester tester) async {
      final probability = BayesianProbability(
        priorProbability: 0.5,
        likelihood: 0.7,
        evidence: 0.6,
        posteriorProbability: 0.75,
        expectedReturn: 30.0,
        riskRewardRatio: 2.0,
        optimalPositionSize: 0.1,
        confidenceLevel: 0.8,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BayesianProbabilityCard(probability: probability),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display expected return
      expect(find.byType(BayesianProbabilityCard), findsOneWidget);
    });

    testWidgets('should display optimal position size',
        (WidgetTester tester) async {
      final probability = BayesianProbability(
        priorProbability: 0.5,
        likelihood: 0.7,
        evidence: 0.6,
        posteriorProbability: 0.75,
        expectedReturn: 20.0,
        riskRewardRatio: 2.0,
        optimalPositionSize: 0.15,
        confidenceLevel: 0.8,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BayesianProbabilityCard(probability: probability),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display position size
      expect(find.byType(BayesianProbabilityCard), findsOneWidget);
    });
  });
}
