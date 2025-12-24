import 'dart:io' show Platform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/app_settings.dart';
import '../../../core/utils/logger.dart';

/// ⚙️ Settings State
class SettingsState {
  final AppSettings settings;
  final bool isLoading;
  final String? error;

  SettingsState({
    required this.settings,
    this.isLoading = false,
    this.error,
  });

  SettingsState copyWith({
    AppSettings? settings,
    bool? isLoading,
    String? error,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// ⚙️ Settings Notifier
///
/// Provider لإدارة إعدادات التطبيق مع الحفظ المحلي
class SettingsNotifier extends StateNotifier<SettingsState> {
  static const String _boxName = 'app_settings';
  static const String _settingsKey = 'settings';

  SettingsNotifier() : super(SettingsState(settings: AppSettings.defaults())) {
    _init();
  }

  /// Initialize and load settings
  Future<void> _init() async {
    try {
      // Skip settings initialization in test environment to avoid Hive path requirements
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        AppLogger.info('Skipping Settings initialization during tests');
        return;
      }

      AppLogger.info('Initializing Settings Provider...');
      await loadSettings();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize settings', e, stackTrace);
      state = state.copyWith(error: e.toString());
    }
  }

  /// Load settings from Hive
  Future<void> loadSettings() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Ensure Hive is initialized (mobile release guard)
      try {
        await Hive.initFlutter();
      } catch (_) {
        // ignore if already initialized
      }

      final box = await Hive.openBox(_boxName);
      final settingsJson = box.get(_settingsKey);

      if (settingsJson != null) {
        final settings =
            AppSettings.fromJson(Map<String, dynamic>.from(settingsJson));
        state = state.copyWith(settings: settings, isLoading: false);
        AppLogger.success('Settings loaded: $settings');
      } else {
        // First time - save defaults
        await _saveSettings(AppSettings.defaults());
        state =
            state.copyWith(settings: AppSettings.defaults(), isLoading: false);
        AppLogger.info('Default settings created');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load settings', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        settings: AppSettings.defaults(),
      );
    }
  }

  /// Save settings to Hive
  Future<void> _saveSettings(AppSettings settings) async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(_settingsKey, settings.toJson());
      AppLogger.success('Settings saved');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save settings', e, stackTrace);
      throw Exception('فشل حفظ الإعدادات');
    }
  }

  /// Update theme mode
  Future<void> updateTheme(String themeMode) async {
    try {
      AppLogger.info('Updating theme to: $themeMode');
      final newSettings = state.settings.copyWith(themeMode: themeMode);
      await _saveSettings(newSettings);
      state = state.copyWith(settings: newSettings);
      AppLogger.success('Theme updated to $themeMode');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update theme', e, stackTrace);
      state = state.copyWith(error: e.toString());
    }
  }

  /// Update strictness level
  Future<void> updateStrictness(String strictnessLevel) async {
    try {
      AppLogger.info('Updating strictness to: $strictnessLevel');
      final newSettings =
          state.settings.copyWith(strictnessLevel: strictnessLevel);
      await _saveSettings(newSettings);
      state = state.copyWith(settings: newSettings);
      AppLogger.success('Strictness updated to $strictnessLevel');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update strictness', e, stackTrace);
      state = state.copyWith(error: e.toString());
    }
  }

  /// Update auto-refresh enabled
  Future<void> updateAutoRefresh(bool enabled) async {
    try {
      AppLogger.info('Updating auto-refresh to: $enabled');
      final newSettings = state.settings.copyWith(autoRefreshEnabled: enabled);
      await _saveSettings(newSettings);
      state = state.copyWith(settings: newSettings);
      AppLogger.success('Auto-refresh updated to $enabled');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update auto-refresh', e, stackTrace);
      state = state.copyWith(error: e.toString());
    }
  }

  /// Toggle auto-refresh
  Future<void> toggleAutoRefresh() async {
    try {
      final newValue = !state.settings.autoRefreshEnabled;
      await updateAutoRefresh(newValue);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to toggle auto-refresh', e, stackTrace);
      state = state.copyWith(error: e.toString());
    }
  }

  /// Update auto-refresh interval
  Future<void> updateAutoRefreshInterval(int seconds) async {
    try {
      AppLogger.info('Updating auto-refresh interval to: ${seconds}s');
      final newSettings = state.settings.copyWith(autoRefreshInterval: seconds);
      await _saveSettings(newSettings);
      state = state.copyWith(settings: newSettings);
      AppLogger.success('Auto-refresh interval updated to ${seconds}s');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update auto-refresh interval', e, stackTrace);
      state = state.copyWith(error: e.toString());
    }
  }

  /// Toggle notifications
  Future<void> toggleNotifications() async {
    try {
      final newValue = !state.settings.notificationsEnabled;
      AppLogger.info('Toggling notifications to: $newValue');
      final newSettings =
          state.settings.copyWith(notificationsEnabled: newValue);
      await _saveSettings(newSettings);
      state = state.copyWith(settings: newSettings);
      AppLogger.success('Notifications toggled to $newValue');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to toggle notifications', e, stackTrace);
      state = state.copyWith(error: e.toString());
    }
  }

  /// Toggle signal notifications
  Future<void> toggleSignalNotifications() async {
    try {
      final newValue = !state.settings.signalNotificationsEnabled;
      AppLogger.info('Toggling signal notifications to: $newValue');
      final newSettings =
          state.settings.copyWith(signalNotificationsEnabled: newValue);
      await _saveSettings(newSettings);
      state = state.copyWith(settings: newSettings);
      AppLogger.success('Signal notifications toggled to $newValue');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to toggle signal notifications', e, stackTrace);
      state = state.copyWith(error: e.toString());
    }
  }

  /// Toggle price alerts
  Future<void> togglePriceAlerts() async {
    try {
      final newValue = !state.settings.priceAlertsEnabled;
      AppLogger.info('Toggling price alerts to: $newValue');
      final newSettings = state.settings.copyWith(priceAlertsEnabled: newValue);
      await _saveSettings(newSettings);
      state = state.copyWith(settings: newSettings);
      AppLogger.success('Price alerts toggled to $newValue');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to toggle price alerts', e, stackTrace);
      state = state.copyWith(error: e.toString());
    }
  }

  /// Update language
  Future<void> updateLanguage(String language) async {
    try {
      AppLogger.info('Updating language to: $language');
      final newSettings = state.settings.copyWith(language: language);
      await _saveSettings(newSettings);
      state = state.copyWith(settings: newSettings);
      AppLogger.success('Language updated to $language');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update language', e, stackTrace);
      state = state.copyWith(error: e.toString());
    }
  }

  /// Toggle AI Analysis by default
  Future<void> toggleAIAnalysisByDefault() async {
    try {
      final newValue = !state.settings.showAIAnalysisByDefault;
      AppLogger.info('Toggling AI Analysis by default to: $newValue');
      final newSettings =
          state.settings.copyWith(showAIAnalysisByDefault: newValue);
      await _saveSettings(newSettings);
      state = state.copyWith(settings: newSettings);
      AppLogger.success('AI Analysis by default toggled to $newValue');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to toggle AI Analysis by default', e, stackTrace);
      state = state.copyWith(error: e.toString());
    }
  }

  /// Toggle sound effects
  Future<void> toggleSoundEffects() async {
    try {
      final newValue = !state.settings.soundEffectsEnabled;
      AppLogger.info('Toggling sound effects to: $newValue');
      final newSettings =
          state.settings.copyWith(soundEffectsEnabled: newValue);
      await _saveSettings(newSettings);
      state = state.copyWith(settings: newSettings);
      AppLogger.success('Sound effects toggled to $newValue');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to toggle sound effects', e, stackTrace);
      state = state.copyWith(error: e.toString());
    }
  }

  /// Toggle vibration
  Future<void> toggleVibration() async {
    try {
      final newValue = !state.settings.vibrationEnabled;
      AppLogger.info('Toggling vibration to: $newValue');
      final newSettings = state.settings.copyWith(vibrationEnabled: newValue);
      await _saveSettings(newSettings);
      state = state.copyWith(settings: newSettings);
      AppLogger.success('Vibration toggled to $newValue');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to toggle vibration', e, stackTrace);
      state = state.copyWith(error: e.toString());
    }
  }

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    try {
      AppLogger.info('Resetting settings to defaults');
      final defaultSettings = AppSettings.defaults();
      await _saveSettings(defaultSettings);
      state = state.copyWith(settings: defaultSettings);
      AppLogger.success('Settings reset to defaults');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to reset settings', e, stackTrace);
      state = state.copyWith(error: e.toString());
    }
  }
}

/// ⚙️ Settings Provider Instance
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
