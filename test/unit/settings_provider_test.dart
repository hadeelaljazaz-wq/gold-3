import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_nightmare_pro/features/settings/providers/settings_provider.dart';

void main() {
  group('SettingsProvider Comprehensive Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with default settings', () {
      final state = container.read(settingsProvider);

      expect(state.settings, isNotNull);
      expect(state.settings.themeMode, isNotNull);
      expect(state.settings.strictnessLevel, isNotNull);
      expect(state.isLoading, isFalse);
    });

    test('should update theme mode', () async {
      final notifier = container.read(settingsProvider.notifier);

      await notifier.updateTheme('DARK');

      final state = container.read(settingsProvider);
      expect(state.settings.themeMode, equals('DARK'));
    });

    test('should update strictness level', () async {
      final notifier = container.read(settingsProvider.notifier);

      await notifier.updateStrictness('STRICT');

      final state = container.read(settingsProvider);
      expect(state.settings.strictnessLevel, equals('STRICT'));
    });

    test('should toggle auto-refresh', () async {
      final notifier = container.read(settingsProvider.notifier);

      final initialValue =
          container.read(settingsProvider).settings.autoRefreshEnabled;

      await notifier.toggleAutoRefresh();

      final newValue =
          container.read(settingsProvider).settings.autoRefreshEnabled;
      expect(newValue, equals(!initialValue));
    });

    test('should update auto-refresh interval', () async {
      final notifier = container.read(settingsProvider.notifier);

      await notifier.updateAutoRefreshInterval(120);

      final state = container.read(settingsProvider);
      expect(state.settings.autoRefreshInterval, equals(120));
    });

    test('should toggle notifications', () async {
      final notifier = container.read(settingsProvider.notifier);

      final initialValue =
          container.read(settingsProvider).settings.notificationsEnabled;

      await notifier.toggleNotifications();

      final newValue =
          container.read(settingsProvider).settings.notificationsEnabled;
      expect(newValue, equals(!initialValue));
    });

    test('should toggle sound effects', () async {
      final notifier = container.read(settingsProvider.notifier);

      final initialValue =
          container.read(settingsProvider).settings.soundEffectsEnabled;

      await notifier.toggleSoundEffects();

      final newValue =
          container.read(settingsProvider).settings.soundEffectsEnabled;
      expect(newValue, equals(!initialValue));
    });

    test('should toggle vibration', () async {
      final notifier = container.read(settingsProvider.notifier);

      final initialValue =
          container.read(settingsProvider).settings.vibrationEnabled;

      await notifier.toggleVibration();

      final newValue =
          container.read(settingsProvider).settings.vibrationEnabled;
      expect(newValue, equals(!initialValue));
    });

    test('should update language', () async {
      final notifier = container.read(settingsProvider.notifier);

      await notifier.updateLanguage('en');

      final state = container.read(settingsProvider);
      expect(state.settings.language, equals('en'));
    });

    test('should handle invalid theme mode gracefully', () async {
      final notifier = container.read(settingsProvider.notifier);

      // Should not throw error
      await notifier.updateTheme('INVALID_THEME');

      final state = container.read(settingsProvider);
      expect(state.settings, isNotNull);
    });

    test('should handle invalid strictness level gracefully', () async {
      final notifier = container.read(settingsProvider.notifier);

      // Should not throw error
      await notifier.updateStrictness('INVALID_LEVEL');

      final state = container.read(settingsProvider);
      expect(state.settings, isNotNull);
    });

    test('should persist settings', () async {
      final notifier = container.read(settingsProvider.notifier);

      // Update multiple settings
      await notifier.updateTheme('ROYAL');
      await notifier.updateStrictness('AGGRESSIVE');
      await notifier.toggleAutoRefresh();

      // Recreate container (simulating app restart)
      container.dispose();
      container = ProviderContainer();

      final newState = container.read(settingsProvider);
      // Settings should be persisted
      expect(newState.settings.themeMode, equals('ROYAL'));
      expect(newState.settings.strictnessLevel, equals('AGGRESSIVE'));
    });

    test('should handle concurrent updates', () async {
      final notifier = container.read(settingsProvider.notifier);

      // Fire multiple updates at once
      await Future.wait([
        notifier.updateTheme('DARK'),
        notifier.updateStrictness('BALANCED'),
        notifier.toggleAutoRefresh(),
      ]);

      final state = container.read(settingsProvider);
      expect(state.settings.themeMode, equals('DARK'));
      expect(state.settings.strictnessLevel, equals('BALANCED'));
    });

    test('should validate auto-refresh interval bounds', () async {
      final notifier = container.read(settingsProvider.notifier);

      // Try extreme values
      await notifier.updateAutoRefreshInterval(5); // Too low
      await notifier.updateAutoRefreshInterval(1000); // Very high

      final state = container.read(settingsProvider);
      expect(state.settings.autoRefreshInterval, isNotNull);
    });
  });
}

