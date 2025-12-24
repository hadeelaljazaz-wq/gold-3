import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_nightmare_pro/features/trade_history/widgets/statistics_card.dart';
import 'package:golden_nightmare_pro/features/trade_history/providers/trade_history_provider.dart';

void main() {
  group('StatisticsCard Widget Tests', () {
    testWidgets('should render without state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final state = ref.watch(tradeHistoryProvider);
                  return StatisticsCard(state: state);
                },
              ),
            ),
          ),
        ),
      );

      // Widget should render
      expect(find.byType(StatisticsCard), findsOneWidget);
    });

    testWidgets('should display statistics', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final state = ref.watch(tradeHistoryProvider);
                  return StatisticsCard(state: state);
                },
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Should display some content
      expect(find.byType(Card), findsWidgets);
    });
  });
}
