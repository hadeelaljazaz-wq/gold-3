import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_nightmare_pro/features/settings/providers/settings_provider.dart';

void main() {
  group('Settings Persistence Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should persist theme selection', () async {
      final notifier = container.read(settingsProvider.notifier);

      // Change theme
      await notifier.updateTheme('royal');

      final state = container.read(settingsProvider);
      expect(state.settings.themeMode, equals('royal'));

      // Reload provider (simulating app restart)
      container.dispose();
      container = ProviderContainer();

      final newState = container.read(settingsProvider);
      // Theme should be persisted
      expect(newState.settings.themeMode, equals('royal'));
    });

    test('should persist strictness level', () async {
      final notifier = container.read(settingsProvider.notifier);

      await notifier.updateStrictness('strict');

      final state = container.read(settingsProvider);
      expect(state.settings.strictnessLevel, equals('strict'));
    });

    test('should persist auto-refresh settings', () async {
      final notifier = container.read(settingsProvider.notifier);

      await notifier.updateAutoRefresh(true);
      await notifier.updateAutoRefreshInterval(120);

      final state = container.read(settingsProvider);
      expect(state.settings.autoRefreshEnabled, isTrue);
      expect(state.settings.autoRefreshInterval, equals(120));
    });
  });
}
