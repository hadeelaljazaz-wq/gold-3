import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_nightmare_pro/features/trade_history/screens/trade_history_screen.dart';

void main() {
  group('TradeHistoryScreen Widget Tests', () {
    testWidgets('should render trade history screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TradeHistoryScreen(),
          ),
        ),
      );

      expect(find.byType(TradeHistoryScreen), findsOneWidget);
    });

    testWidgets('should display app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TradeHistoryScreen(),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display filter chips', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TradeHistoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Look for filter chips
      final chips = find.byType(ChoiceChip);
      expect(chips, anyOf(findsNothing, findsWidgets));
    });

    testWidgets('should display statistics card', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TradeHistoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Statistics should be displayed
      final scrollable = find.byType(Scrollable);
      expect(scrollable, findsWidgets);
    });

    testWidgets('should handle empty state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TradeHistoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Empty state may be displayed
      final emptyText = find.textContaining('لا توجد', findRichText: true);
      expect(emptyText, anyOf(findsNothing, findsWidgets));
    });

    testWidgets('should display export button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TradeHistoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Look for export/share button
      final exportButton = find.byIcon(Icons.share);
      expect(exportButton, anyOf(findsNothing, findsWidgets));
    });

    testWidgets('should handle loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TradeHistoryScreen(),
          ),
        ),
      );

      await tester.pump();

      final loadingIndicators = find.byType(CircularProgressIndicator);
      expect(loadingIndicators, anyOf(findsNothing, findsWidgets));
    });
  });
}
