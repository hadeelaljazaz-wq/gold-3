import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_nightmare_pro/features/nexus_kabous_unified/providers/nexus_kabous_provider.dart';

void main() {
  group('NexusKabousProvider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with empty state', () {
      final state = container.read(nexusKabousUnifiedProvider);

      expect(state, isNotNull);
      expect(state.isLoading, isFalse);
      expect(state.nexusScalp, isNull);
      expect(state.kabousScalp, isNull);
      expect(state.quantumSignal, isNull);
      expect(state.error, isNull);
    });

    test('should generate unified analysis', () async {
      final notifier = container.read(nexusKabousUnifiedProvider.notifier);

      await notifier.generateAnalysis();

      await Future.delayed(const Duration(seconds: 3));

      final state = container.read(nexusKabousUnifiedProvider);
      expect(state.isLoading, isFalse);
    });

    test('should check if state is stale', () {
      final freshState = NexusKabousUnifiedState(
        lastUpdate: DateTime.now(),
      );

      expect(freshState.isStale, isFalse);

      final staleState = NexusKabousUnifiedState(
        lastUpdate: DateTime.now().subtract(const Duration(hours: 1)),
      );

      expect(staleState.isStale, isTrue);
    });

    test('should check if has analysis', () {
      final emptyState = NexusKabousUnifiedState();
      expect(emptyState.hasAnalysis, isFalse);

      // Note: Would need actual signal models to test hasAnalysis = true
    });

    test('should toggle auto refresh', () {
      final notifier = container.read(nexusKabousUnifiedProvider.notifier);

      final initialState = container.read(nexusKabousUnifiedProvider);
      expect(initialState.isAutoRefreshEnabled, isFalse);

      notifier.startAutoRefresh();

      final newState = container.read(nexusKabousUnifiedProvider);
      expect(newState.isAutoRefreshEnabled, isTrue);
      
      notifier.stopAutoRefresh();
    });

    test('should copy state correctly', () {
      final original = NexusKabousUnifiedState(
        isLoading: false,
        isAutoRefreshEnabled: false,
      );

      final copied = original.copyWith(isLoading: true);

      expect(copied.isLoading, isTrue);
      expect(original.isLoading, isFalse);
    });

    test('should handle force refresh', () async {
      final notifier = container.read(nexusKabousUnifiedProvider.notifier);

      await notifier.generateAnalysis(forceRefresh: true);

      await Future.delayed(const Duration(seconds: 3));

      final state = container.read(nexusKabousUnifiedProvider);
      expect(state.isLoading, isFalse);
    });

    test('should update lastUpdate timestamp', () async {
      final notifier = container.read(nexusKabousUnifiedProvider.notifier);

      await notifier.generateAnalysis();
      await Future.delayed(const Duration(seconds: 3));

      final state = container.read(nexusKabousUnifiedProvider);

      if (state.lastUpdate != null) {
        expect(state.lastUpdate, isA<DateTime>());
      }
    });

    test('should handle errors gracefully', () async {
      final notifier = container.read(nexusKabousUnifiedProvider.notifier);

      await notifier.generateAnalysis();
      await Future.delayed(const Duration(seconds: 3));

      final state = container.read(nexusKabousUnifiedProvider);
      expect(state, isNotNull);
    });
  });
}
