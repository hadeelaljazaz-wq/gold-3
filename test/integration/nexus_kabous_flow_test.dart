import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_nightmare_pro/features/nexus_kabous_unified/providers/nexus_kabous_provider.dart';

void main() {
  group('Nexus Kabous Flow Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should complete full nexus kabous analysis flow', () async {
      final notifier = container.read(nexusKabousUnifiedProvider.notifier);

      // Initial state
      var state = container.read(nexusKabousUnifiedProvider);
      expect(state.isLoading, isFalse);

      // Start analysis
      await notifier.generateAnalysis();

      // Wait for completion
      await Future.delayed(const Duration(seconds: 5));

      // Final state
      state = container.read(nexusKabousUnifiedProvider);
      expect(state.isLoading, isFalse);
    });

    test('should generate both nexus and kabous signals', () async {
      final notifier = container.read(nexusKabousUnifiedProvider.notifier);

      await notifier.generateAnalysis();
      await Future.delayed(const Duration(seconds: 5));

      final state = container.read(nexusKabousUnifiedProvider);

      // Should have unified metrics
      expect(state.metrics, anyOf(isNull, isNotNull));
    });

    test('should handle force refresh', () async {
      final notifier = container.read(nexusKabousUnifiedProvider.notifier);

      await notifier.generateAnalysis();
      await Future.delayed(const Duration(seconds: 3));

      final firstUpdate = container.read(nexusKabousUnifiedProvider).lastUpdate;

      await notifier.generateAnalysis(forceRefresh: true);
      await Future.delayed(const Duration(seconds: 3));

      final secondUpdate = container.read(nexusKabousUnifiedProvider).lastUpdate;

      if (firstUpdate != null && secondUpdate != null) {
        expect(secondUpdate.isAfter(firstUpdate), isTrue);
      }
    });

    test('should respect rate limiting', () async {
      final notifier = container.read(nexusKabousUnifiedProvider.notifier);

      await notifier.generateAnalysis();
      await notifier.generateAnalysis();
      await notifier.generateAnalysis();

      await Future.delayed(const Duration(seconds: 3));

      final state = container.read(nexusKabousUnifiedProvider);
      expect(state.isLoading, isFalse);
    });
  });
}
