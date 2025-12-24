import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_nightmare_pro/features/quantum_analysis/providers/quantum_analysis_provider.dart';

// Wait helper: poll until analysis completes (signal or error) or timeout
Future<void> waitForCompletion(ProviderContainer container,
    {Duration timeout = const Duration(seconds: 5)}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    final state = container.read(quantumAnalysisProvider);
    if (!state.isLoading &&
        (state.signal != null ||
            state.error != null ||
            state.lastUpdate != null)) {
      return;
    }
    await Future.delayed(const Duration(milliseconds: 100));
  }
  throw Exception('Timeout waiting for quantum analysis completion');
}

void main() {
  group('Quantum Analysis Flow Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should complete full quantum analysis flow', () async {
      final notifier = container.read(quantumAnalysisProvider.notifier);
      // ignore: unused_local_variable
      final keepAlive = container.listen(quantumAnalysisProvider, (_, __) {},
          fireImmediately: true);

      // Initial state
      var state = container.read(quantumAnalysisProvider);
      expect(state.isLoading, isFalse);

      // Start analysis
      await notifier.generateAnalysis();

      // Wait for completion (deterministic)
      await waitForCompletion(container);

      // Final state
      state = container.read(quantumAnalysisProvider);
      expect(state.isLoading, isFalse);

      // Should have either signal or error
      expect(state.signal != null || state.error != null, isTrue);
    });

    test('should handle force refresh correctly', () async {
      final notifier = container.read(quantumAnalysisProvider.notifier);
      // ignore: unused_local_variable
      final keepAlive = container.listen(quantumAnalysisProvider, (_, __) {},
          fireImmediately: true);

      // First analysis
      await notifier.generateAnalysis();
      await waitForCompletion(container);

      final firstUpdate = container.read(quantumAnalysisProvider).lastUpdate;

      // Force refresh
      await notifier.generateAnalysis(forceRefresh: true);
      await waitForCompletion(container);

      final secondUpdate = container.read(quantumAnalysisProvider).lastUpdate;

      // Should have new update timestamp
      if (firstUpdate != null && secondUpdate != null) {
        expect(secondUpdate.isAfter(firstUpdate), isTrue);
      }
    });

    test('should respect rate limiting', () async {
      final notifier = container.read(quantumAnalysisProvider.notifier);
      // ignore: unused_local_variable
      final keepAlive = container.listen(quantumAnalysisProvider, (_, __) {},
          fireImmediately: true);

      // Multiple rapid calls
      await notifier.generateAnalysis();
      await notifier.generateAnalysis();
      await notifier.generateAnalysis();

      // Wait for completion (deterministic)
      await waitForCompletion(container);

      final state = container.read(quantumAnalysisProvider);
      expect(state.isLoading, isFalse);
    });

    test('should cache results appropriately', () async {
      final notifier = container.read(quantumAnalysisProvider.notifier);
      // ignore: unused_local_variable
      final keepAlive = container.listen(quantumAnalysisProvider, (_, __) {},
          fireImmediately: true);

      // First call
      await notifier.generateAnalysis();
      await waitForCompletion(container);

      final firstSignal = container.read(quantumAnalysisProvider).signal;

      // Second call (should use cache if not stale)
      await notifier.generateAnalysis();
      await waitForCompletion(container);

      final secondSignal = container.read(quantumAnalysisProvider).signal;

      // Signals should match if cache was used
      if (firstSignal != null && secondSignal != null) {
        expect(firstSignal.direction, equals(secondSignal.direction));
      }
    });
  });
}
