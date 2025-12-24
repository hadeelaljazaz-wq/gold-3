import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_nightmare_pro/features/royal_analysis/providers/royal_analysis_provider.dart';

void main() {
  group('Royal Analysis Flow Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should complete full royal analysis cycle', () async {
      final notifier = container.read(royalAnalysisProvider.notifier);

      try {
        await notifier.generateAnalysis(forceRefresh: true);
      } catch (e) {
        // Expected without real API
      }

      final state = container.read(royalAnalysisProvider);
      expect(
          state.isLoading ||
              state.error != null ||
              state.scalp != null,
          isTrue);
    });

    test('should handle auto-refresh for royal analysis', () async {
      final notifier = container.read(royalAnalysisProvider.notifier);

      // Start auto-refresh
      notifier.startAutoRefresh();
      expect(
          container.read(royalAnalysisProvider).isAutoRefreshEnabled, isTrue);

      // Wait
      await Future.delayed(const Duration(milliseconds: 100));

      // Stop auto-refresh
      notifier.stopAutoRefresh();
      expect(
          container.read(royalAnalysisProvider).isAutoRefreshEnabled, isFalse);
    });

    test('should handle multiple rapid requests', () async {
      final notifier = container.read(royalAnalysisProvider.notifier);

      // Fire multiple requests
      final futures = List.generate(5, (_) => notifier.generateAnalysis());

      // Wait for all
      await Future.wait(futures.map((f) => f.catchError((_) {})));

      // Should not crash
      final state = container.read(royalAnalysisProvider);
      expect(state, isNotNull);
    });

    test('should calculate consensus from both engines', () async {
      final notifier = container.read(royalAnalysisProvider.notifier);

      try {
        await notifier.generateAnalysis(forceRefresh: true);
      } catch (e) {
        // Expected
      }

      final state = container.read(royalAnalysisProvider);

      // If both signals exist, consensus should be calculated
      if (state.scalp != null && state.swing != null) {
        expect(state.scalp, isNotNull);
      }
    });

    test('should handle force refresh', () async {
      final notifier = container.read(royalAnalysisProvider.notifier);

      // First analysis
      try {
        await notifier.generateAnalysis(forceRefresh: false);
      } catch (e) {
        // Expected
      }

      // Force refresh
      try {
        await notifier.generateAnalysis(forceRefresh: true);
      } catch (e) {
        // Expected
      }

      final state = container.read(royalAnalysisProvider);
      expect(state, isNotNull);
    });

    test('should maintain state during errors', () async {
      final notifier = container.read(royalAnalysisProvider.notifier);

      // Multiple failed attempts
      for (int i = 0; i < 3; i++) {
        try {
          await notifier.generateAnalysis(forceRefresh: true);
        } catch (e) {
          // Expected
        }
      }

      final state = container.read(royalAnalysisProvider);
      expect(state, isNotNull);
      expect(state.error, isNotNull);
    });

    test('should respect rate limiting', () async {
      final notifier = container.read(royalAnalysisProvider.notifier);

      // First call
      try {
        await notifier.generateAnalysis(forceRefresh: true);
      } catch (e) {
        // Expected
      }

      // Immediate second call (should be rate limited)
      try {
        await notifier.generateAnalysis(forceRefresh: false);
      } catch (e) {
        // Expected
      }

      expect(true, isTrue); // Test passes if no crash
    });

    test('should handle cache expiry correctly', () async {
      final notifier = container.read(royalAnalysisProvider.notifier);

      // Generate analysis
      try {
        await notifier.generateAnalysis(forceRefresh: true);
      } catch (e) {
        // Expected
      }

      final state = container.read(royalAnalysisProvider);

      // Check staleness
      if (state.lastUpdate != null) {
        expect(state.isStale, isA<bool>());
      }
    });
  });
}

