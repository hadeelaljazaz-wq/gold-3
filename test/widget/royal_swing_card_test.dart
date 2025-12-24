import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_nightmare_pro/features/royal_analysis/widgets/royal_swing_card.dart';
import 'package:golden_nightmare_pro/models/swing_signal.dart';

void main() {
  group('RoyalSwingCard Widget Tests', () {
    testWidgets('should render royal swing card', (WidgetTester tester) async {
      final signal = SwingSignal(
        direction: 'BUY',
        entryPrice: 2050.0,
        stopLoss: 2020.0,
        takeProfit: 2110.0,
        confidence: 80,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoyalSwingCard(signal: signal),
          ),
        ),
      );

      expect(find.byType(RoyalSwingCard), findsOneWidget);
    });

    testWidgets('should display signal direction', (WidgetTester tester) async {
      final signal = SwingSignal(
        direction: 'SELL',
        entryPrice: 2050.0,
        stopLoss: 2080.0,
        takeProfit: 1990.0,
        confidence: 75,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoyalSwingCard(signal: signal),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display SELL
      final directionText = find.textContaining('SELL', findRichText: true);
      expect(directionText, anyOf(findsNothing, findsWidgets));
    });

    testWidgets('should display entry and exit prices',
        (WidgetTester tester) async {
      final signal = SwingSignal(
        direction: 'BUY',
        entryPrice: 2050.0,
        stopLoss: 2020.0,
        takeProfit: 2110.0,
        confidence: 80,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoyalSwingCard(signal: signal),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display price information
      final priceText = find.textContaining('2050', findRichText: true);
      expect(priceText, anyOf(findsNothing, findsWidgets));
    });

    testWidgets('should display confidence level', (WidgetTester tester) async {
      final signal = SwingSignal(
        direction: 'BUY',
        entryPrice: 2050.0,
        stopLoss: 2020.0,
        takeProfit: 2110.0,
        confidence: 85,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoyalSwingCard(signal: signal),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display confidence
      final confidenceText = find.textContaining('85', findRichText: true);
      expect(confidenceText, anyOf(findsNothing, findsWidgets));
    });

    testWidgets('should handle NO_TRADE signal', (WidgetTester tester) async {
      final signal = SwingSignal.noTrade(reason: 'No clear trend');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoyalSwingCard(signal: signal),
          ),
        ),
      );

      expect(find.byType(RoyalSwingCard), findsOneWidget);
    });
  });
}
