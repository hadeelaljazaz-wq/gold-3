import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_nightmare_pro/features/charts/widgets/candlestick_chart.dart';
import 'package:golden_nightmare_pro/features/charts/providers/chart_data_provider.dart';

void main() {
  group('CandlestickChart Widget Tests', () {
    late List<PricePoint> testData;

    setUp(() {
      final now = DateTime.now();
      testData = List.generate(50, (index) {
        return PricePoint(
          timestamp: now.subtract(Duration(hours: 50 - index)),
          open: 2000.0 + index,
          high: 2000.0 + index + 2,
          low: 2000.0 + index - 2,
          close: 2000.0 + index + 1,
          volume: 1000.0,
        );
      });
    });

    testWidgets('should render chart with data', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CandlestickChart(
              data: testData,
              title: 'XAUUSD',
            ),
          ),
        ),
      );

      expect(find.byType(CandlestickChart), findsOneWidget);
    });

    testWidgets('should show empty state when no data', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CandlestickChart(
              data: [],
              title: 'XAUUSD',
            ),
          ),
        ),
      );

      expect(find.text('لا توجد بيانات للعرض'), findsOneWidget);
    });

    testWidgets('should optimize data for large datasets', (tester) async {
      // Create large dataset (>1000 points)
      final largeData = List.generate(2000, (index) {
        return PricePoint(
          timestamp: DateTime.now().subtract(Duration(hours: 2000 - index)),
          open: 2000.0 + index * 0.5,
          high: 2000.0 + index * 0.5 + 2,
          low: 2000.0 + index * 0.5 - 2,
          close: 2000.0 + index * 0.5 + 1,
          volume: 1000.0,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CandlestickChart(
              data: largeData,
              title: 'XAUUSD',
            ),
          ),
        ),
      );

      // Chart should render without errors
      expect(find.byType(CandlestickChart), findsOneWidget);
    });
  });
}
