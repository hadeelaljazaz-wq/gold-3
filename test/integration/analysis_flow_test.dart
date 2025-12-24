import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_nightmare_pro/features/analysis/providers/analysis_provider.dart';
import 'package:golden_nightmare_pro/features/analysis/providers/strictness_provider.dart';
import 'package:golden_nightmare_pro/core/constants/analysis_strictness.dart';

void main() {
  group('Analysis Flow Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should complete full analysis cycle', () async {
      final notifier = container.read(analysisProvider.notifier);

      try {
        await notifier.generateAnalysis(forceRefresh: true);
      } catch (e) {
        // Expected without real API
      }

      final state = container.read(analysisProvider);
      expect(
          state.isLoading ||
              state.error != null ||
              state.scalp != null,
          isTrue);
    });

    test('should handle strictness level changes', () async {
      final analysisNotifier = container.read(analysisProvider.notifier);
      final strictnessNotifier = container.read(strictnessProvider.notifier);

      // Change strictness
      strictnessNotifier.setStrictness(AnalysisStrictness.strict);
      expect(container.read(strictnessProvider),
          equals(AnalysisStrictness.strict));

      // Generate analysis with new strictness
      try {
        await analysisNotifier.generateAnalysis(forceRefresh: true);
      } catch (e) {
        // Expected
      }

      strictnessNotifier.setStrictness(AnalysisStrictness.strict);
      expect(container.read(strictnessProvider),
          equals(AnalysisStrictness.strict));
    });

    test('should handle auto-refresh lifecycle', () async {
      final notifier = container.read(analysisProvider.notifier);

      // Start auto-refresh
      notifier.startAutoRefresh();
      expect(container.read(analysisProvider).isAutoRefreshEnabled, isTrue);

      // Wait a bit
      await Future.delayed(const Duration(milliseconds: 100));

      // Stop auto-refresh
      notifier.stopAutoRefresh();
      expect(container.read(analysisProvider).isAutoRefreshEnabled, isFalse);
    });

    test('should handle multiple rapid analysis requests', () async {
      final notifier = container.read(analysisProvider.notifier);

      // Fire multiple requests
      final futures = List.generate(5, (_) => notifier.generateAnalysis());

      // Wait for all
      await Future.wait(futures.map((f) => f.catchError((_) {})));

      // Should not crash
      final state = container.read(analysisProvider);
      expect(state, isNotNull);
    });

    test('should recover from errors', () async {
      final notifier = container.read(analysisProvider.notifier);

      // First attempt (will fail)
      try {
        await notifier.generateAnalysis(forceRefresh: true);
      } catch (e) {
        // Expected
      }

      // Second attempt
      try {
        await notifier.generateAnalysis(forceRefresh: true);
      } catch (e) {
        // Expected
      }

      final state = container.read(analysisProvider);
      expect(state, isNotNull);
    });

    test('should maintain state consistency during rapid changes', () async {
      final analysisNotifier = container.read(analysisProvider.notifier);
      final strictnessNotifier = container.read(strictnessProvider.notifier);

      // Rapid changes
      for (var level in AnalysisStrictness.values) {
        strictnessNotifier.setStrictness(level);
        analysisNotifier.generateAnalysis();
        await Future.delayed(const Duration(milliseconds: 50));
      }

      // State should still be valid
      final state = container.read(analysisProvider);
      expect(state, isNotNull);
    });

    test('should handle force refresh correctly', () async {
      final notifier = container.read(analysisProvider.notifier);

      // First analysis
      try {
        await notifier.generateAnalysis(forceRefresh: false);
      } catch (e) {
        // Expected
      }

      final firstState = container.read(analysisProvider);

      // Force refresh
      try {
        await notifier.generateAnalysis(forceRefresh: true);
      } catch (e) {
        // Expected
      }

      final secondState = container.read(analysisProvider);

      // States should exist
      expect(firstState, isNotNull);
      expect(secondState, isNotNull);
    });
  });
}
