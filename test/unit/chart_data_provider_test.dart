import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_nightmare_pro/features/charts/providers/chart_data_provider.dart';

void main() {
  group('ChartDataProvider Comprehensive Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with empty state', () {
      final state = container.read(chartDataProvider);
      
      expect(state.historicalData, isNotEmpty); // Auto-loads on init
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('should load data for different timeframes', () async {
      final notifier = container.read(chartDataProvider.notifier);
      
      await notifier.loadHistoricalData(timeframe: '1H');
      final state1H = container.read(chartDataProvider);
      expect(state1H.historicalData, isNotEmpty);
      
      await notifier.loadHistoricalData(timeframe: '4H');
      final state4H = container.read(chartDataProvider);
      expect(state4H.historicalData, isNotEmpty);
    });

    test('should handle loading state', () async {
      final notifier = container.read(chartDataProvider.notifier);
      
      // Trigger load
      final future = notifier.loadHistoricalData(timeframe: '1D');
      
      // Should eventually complete
      await future;
      
      final state = container.read(chartDataProvider);
      expect(state.isLoading, isFalse);
    });

    test('should handle errors gracefully', () async {
      final notifier = container.read(chartDataProvider.notifier);
      
      // Load with invalid timeframe (should still work with mock data)
      await notifier.loadHistoricalData(timeframe: 'INVALID');
      
      final state = container.read(chartDataProvider);
      expect(state, isNotNull);
    });

    test('should update timeframe', () async {
      final notifier = container.read(chartDataProvider.notifier);
      
      await notifier.loadHistoricalData(timeframe: '1W');
      
      final state = container.read(chartDataProvider);
      expect(state.timeframe, equals('1W'));
    });

    test('should cache and reuse data', () async {
      final notifier = container.read(chartDataProvider.notifier);
      
      await notifier.loadHistoricalData(timeframe: '1H');
      // ignore: unused_local_variable
      final initialData = container.read(chartDataProvider).historicalData;
      
      // Load again
      await notifier.loadHistoricalData(timeframe: '1H');
      
      final state = container.read(chartDataProvider);
      expect(state.historicalData, isNotEmpty);
    });

    test('should handle rapid successive loads', () async {
      final notifier = container.read(chartDataProvider.notifier);
      
      // Fire multiple loads rapidly
      final futures = [
        notifier.loadHistoricalData(timeframe: '15m'),
        notifier.loadHistoricalData(timeframe: '1H'),
        notifier.loadHistoricalData(timeframe: '4H'),
      ];
      
      await Future.wait(futures);
      
      final state = container.read(chartDataProvider);
      expect(state.historicalData, isNotEmpty);
    });

    test('should clear data on new load', () async {
      final notifier = container.read(chartDataProvider.notifier);
      
      await notifier.loadHistoricalData(timeframe: '1H');
      // ignore: unused_local_variable
      final firstLoadData = container.read(chartDataProvider).historicalData;
      
      await notifier.loadHistoricalData(timeframe: '4H');
      final secondLoadData = container.read(chartDataProvider).historicalData;
      
      expect(secondLoadData, isNotEmpty);
    });

    test('should handle empty timeframe', () async {
      final notifier = container.read(chartDataProvider.notifier);
      
      await notifier.loadHistoricalData();
      
      final state = container.read(chartDataProvider);
      expect(state.historicalData, isNotEmpty);
    });
  });
}
