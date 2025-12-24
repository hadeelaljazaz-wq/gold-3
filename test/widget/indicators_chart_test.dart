import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_nightmare_pro/features/charts/widgets/indicators_chart.dart';
import 'package:golden_nightmare_pro/features/charts/providers/chart_data_provider.dart';

void main() {
  group('IndicatorsChart Widget Tests', () {
    late List<PricePoint> testData;

    setUp(() {
      final now = DateTime.now();
      testData = List.generate(100, (index) {
        return PricePoint(
          timestamp: now.subtract(Duration(hours: 100 - index)),
          open: 2000.0 + index * 0.5,
          high: 2000.0 + index * 0.5 + 2,
          low: 2000.0 + index * 0.5 - 2,
          close: 2000.0 + index * 0.5 + 1,
          volume: 1000.0 + index * 10,
        );
      });
    });

    testWidgets('should render RSI chart', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IndicatorsChart(
              data: testData,
              indicator: 'RSI',
            ),
          ),
        ),
      );

      expect(find.text('RSI (14)'), findsOneWidget);
    });

    testWidgets('should render Volume chart', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IndicatorsChart(
              data: testData,
              indicator: 'Volume',
            ),
          ),
        ),
      );

      expect(find.text('Volume'), findsOneWidget);
    });

    testWidgets('should render MACD chart', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IndicatorsChart(
              data: testData,
              indicator: 'MACD',
            ),
          ),
        ),
      );

      expect(find.text('MACD'), findsOneWidget);
    });

    testWidgets('should show empty state when no data', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IndicatorsChart(
              data: [],
              indicator: 'RSI',
            ),
          ),
        ),
      );

      expect(find.text('لا توجد بيانات'), findsOneWidget);
    });
  });
}
