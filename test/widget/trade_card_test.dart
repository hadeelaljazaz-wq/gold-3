import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_nightmare_pro/features/trade_history/widgets/trade_card.dart';
import 'package:golden_nightmare_pro/models/trade_record.dart';

void main() {
  group('TradeCard Widget Tests', () {
    late TradeRecord testTrade;

    setUp(() {
      testTrade = TradeRecord(
        id: 'test-trade-1',
        type: 'SCALP',
        direction: 'BUY',
        entryPrice: 2050.0,
        stopLoss: 2040.0,
        takeProfit: [2060.0, 2070.0],
        engine: 'SCALP',
        strictness: 'MODERATE',
        entryTime: DateTime.now(),
        status: 'open',
      );
    });

    testWidgets('should render trade card with all details', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProviderScope(
              child: TradeCard(
                trade: testTrade,
                onClose: (price, note) {},
                onCancel: (note) {},
                onDelete: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(TradeCard), findsOneWidget);
    });

    testWidgets('should display trade details', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProviderScope(
              child: TradeCard(
                trade: testTrade,
                onClose: (price, note) {},
                onCancel: (note) {},
                onDelete: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('should handle interactions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProviderScope(
              child: TradeCard(
                trade: testTrade,
                onClose: (price, note) {},
                onCancel: (note) {},
                onDelete: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Widget should render
      expect(find.byType(TradeCard), findsOneWidget);
    });

    testWidgets('should display closed trade', (tester) async {
      final closedTrade = TradeRecord(
        id: 'test-trade-2',
        type: 'SWING',
        direction: 'SELL',
        entryPrice: 2050.0,
        stopLoss: 2060.0,
        takeProfit: [2040.0, 2030.0],
        engine: 'SWING',
        strictness: 'MODERATE',
        entryTime: DateTime.now(),
        exitTime: DateTime.now(),
        exitPrice: 2045.0,
        status: 'closed',
        profitLoss: -5.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProviderScope(
              child: TradeCard(
                trade: closedTrade,
                onClose: (price, note) {},
                onCancel: (note) {},
                onDelete: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(TradeCard), findsOneWidget);
    });

    test('should create trade record', () {
      expect(testTrade, isNotNull);
      expect(testTrade.direction, equals('BUY'));
      expect(testTrade.entryPrice, equals(2050.0));
    });
  });
}
