import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_nightmare_pro/features/charts/providers/chart_data_provider.dart';

void main() {
  group('Charts Interaction Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should load chart data for different timeframes', () async {
      final notifier = container.read(chartDataProvider.notifier);

      final timeframes = ['1H', '4H', '1D', '1W'];

      for (final timeframe in timeframes) {
        await notifier.loadHistoricalData(timeframe: timeframe);
        await Future.delayed(const Duration(seconds: 1));

        final state = container.read(chartDataProvider);
        expect(state.isLoading, isFalse);
      }
    });

    test('should switch between timeframes correctly', () async {
      final notifier = container.read(chartDataProvider.notifier);

      // Load 1h data
      await notifier.loadHistoricalData(timeframe: '1H');
      await Future.delayed(const Duration(seconds: 1));

      var state = container.read(chartDataProvider);
      final firstData = state.historicalData;

      // Switch to 4h
      await notifier.loadHistoricalData(timeframe: '4H');
      await Future.delayed(const Duration(seconds: 1));

      state = container.read(chartDataProvider);
      final secondData = state.historicalData;

      // Data should be different for different timeframes
      expect(firstData != secondData, isTrue);
    });

    test('should handle refresh correctly', () async {
      final notifier = container.read(chartDataProvider.notifier);

      await notifier.loadHistoricalData(timeframe: '1H');
      await Future.delayed(const Duration(seconds: 1));

      final firstData = container.read(chartDataProvider).historicalData;

      await notifier.refresh();
      await Future.delayed(const Duration(seconds: 1));

      final secondData = container.read(chartDataProvider).historicalData;

      // Data should be refreshed
      expect(firstData, isNotEmpty);
      expect(secondData, isNotEmpty);
    });

    test('should cache data appropriately', () async {
      final notifier = container.read(chartDataProvider.notifier);

      // First load
      await notifier.loadHistoricalData(timeframe: '1H');
      await Future.delayed(const Duration(seconds: 1));

      final firstData = container.read(chartDataProvider).historicalData;

      // Second load (should use cache if not stale)
      await notifier.loadHistoricalData(timeframe: '1H');
      await Future.delayed(const Duration(milliseconds: 500));

      final secondData = container.read(chartDataProvider).historicalData;

      // Should have same data if cache was used
      expect(firstData.length, equals(secondData.length));
    });
  });
}
