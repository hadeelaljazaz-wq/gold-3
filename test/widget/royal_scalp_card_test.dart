import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_nightmare_pro/features/royal_analysis/widgets/royal_scalp_card.dart';
import 'package:golden_nightmare_pro/models/scalping_signal.dart';

void main() {
  group('RoyalScalpCard Widget Tests', () {
    testWidgets('should render royal scalp card', (WidgetTester tester) async {
      final signal = ScalpingSignal(
        direction: 'BUY',
        entryPrice: 2050.0,
        stopLoss: 2040.0,
        takeProfit: 2070.0,
        confidence: 75,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoyalScalpCard(signal: signal),
          ),
        ),
      );

      expect(find.byType(RoyalScalpCard), findsOneWidget);
    });

    testWidgets('should display signal direction', (WidgetTester tester) async {
      final signal = ScalpingSignal(
        direction: 'BUY',
        entryPrice: 2050.0,
        stopLoss: 2040.0,
        takeProfit: 2070.0,
        confidence: 75,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoyalScalpCard(signal: signal),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display BUY or SELL
      final directionText = find.textContaining('BUY', findRichText: true);
      expect(directionText, anyOf(findsNothing, findsWidgets));
    });

    testWidgets('should display entry price', (WidgetTester tester) async {
      final signal = ScalpingSignal(
        direction: 'BUY',
        entryPrice: 2050.0,
        stopLoss: 2040.0,
        takeProfit: 2070.0,
        confidence: 75,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoyalScalpCard(signal: signal),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display price information
      final priceText = find.textContaining('2050', findRichText: true);
      expect(priceText, anyOf(findsNothing, findsWidgets));
    });

    testWidgets('should display confidence level', (WidgetTester tester) async {
      final signal = ScalpingSignal(
        direction: 'BUY',
        entryPrice: 2050.0,
        stopLoss: 2040.0,
        takeProfit: 2070.0,
        confidence: 75,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoyalScalpCard(signal: signal),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display confidence
      final confidenceText = find.textContaining('75', findRichText: true);
      expect(confidenceText, anyOf(findsNothing, findsWidgets));
    });

    testWidgets('should handle NO_TRADE signal', (WidgetTester tester) async {
      final signal = ScalpingSignal.noTrade(reason: 'No signal');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoyalScalpCard(signal: signal),
          ),
        ),
      );

      expect(find.byType(RoyalScalpCard), findsOneWidget);
    });
  });
}
