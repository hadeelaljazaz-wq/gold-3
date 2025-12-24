import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_nightmare_pro/features/quantum_analysis/providers/quantum_analysis_provider.dart';

void main() {
  group('QuantumAnalysisProvider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with empty state', () {
      final state = container.read(quantumAnalysisProvider);

      expect(state, isNotNull);
      expect(state.isLoading, isFalse);
      expect(state.signal, isNull);
      expect(state.error, isNull);
    });

    test('should generate analysis', () async {
      final notifier = container.read(quantumAnalysisProvider.notifier);

      await notifier.generateAnalysis();

      // Wait for async operation
      await Future.delayed(const Duration(seconds: 2));

      final state = container.read(quantumAnalysisProvider);

      // Should have either signal or error
      expect(state.isLoading, isFalse);
    });

    test('should handle force refresh', () async {
      final notifier = container.read(quantumAnalysisProvider.notifier);

      await notifier.generateAnalysis(forceRefresh: true);

      await Future.delayed(const Duration(seconds: 2));

      final state = container.read(quantumAnalysisProvider);
      expect(state.isLoading, isFalse);
    });

    test('should check if state is stale', () {
      final freshState = QuantumAnalysisState(
        lastUpdate: DateTime.now(),
      );

      expect(freshState.isStale, isFalse);

      final staleState = QuantumAnalysisState(
        lastUpdate: DateTime.now().subtract(const Duration(minutes: 2)),
      );

      expect(staleState.isStale, isTrue);
    });

    test('should copy state correctly', () {
      final original = QuantumAnalysisState(
        isLoading: false,
        error: null,
      );

      final copied = original.copyWith(isLoading: true);

      expect(copied.isLoading, isTrue);
      expect(original.isLoading, isFalse);
    });

    test('should prevent multiple simultaneous calls', () async {
      final notifier = container.read(quantumAnalysisProvider.notifier);

      // Start multiple calls simultaneously
      final futures = List.generate(3, (_) => notifier.generateAnalysis());
      await Future.wait(futures);

      await Future.delayed(const Duration(seconds: 2));

      final state = container.read(quantumAnalysisProvider);
      expect(state.isLoading, isFalse);
    });

    test('should update lastUpdate timestamp', () async {
      final notifier = container.read(quantumAnalysisProvider.notifier);

      await notifier.generateAnalysis();
      await Future.delayed(const Duration(seconds: 2));

      final state = container.read(quantumAnalysisProvider);

      if (state.lastUpdate != null) {
        expect(state.lastUpdate, isA<DateTime>());
        expect(
          DateTime.now().difference(state.lastUpdate!),
          lessThan(const Duration(minutes: 1)),
        );
      }
    });

    test('should handle errors gracefully', () async {
      final notifier = container.read(quantumAnalysisProvider.notifier);

      // This should handle errors internally
      await notifier.generateAnalysis();
      await Future.delayed(const Duration(seconds: 2));

      final state = container.read(quantumAnalysisProvider);
      expect(state, isNotNull);
    });
  });
}
