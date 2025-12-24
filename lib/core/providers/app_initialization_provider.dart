import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:easy_localization/easy_localization.dart'; // Not needed in provider
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/utils/logger.dart';
// import '../../features/notifications/services/notification_service.dart'; // REMOVED

/// 🚀 App Initialization State
class AppInitState {
  final bool isInitialized;
  final bool isLoading;
  final String? error;
  final Map<String, bool> features;
  final double progress; // 0.0 to 1.0

  AppInitState({
    this.isInitialized = false,
    this.isLoading = false,
    this.error,
    Map<String, bool>? features,
    this.progress = 0.0,
  }) : features = features ??
            {
              'dotenv': false,
              'localization': false,
              'hive': false,
              'notifications': false,
            };

  AppInitState copyWith({
    bool? isInitialized,
    bool? isLoading,
    String? error,
    Map<String, bool>? features,
    double? progress,
  }) {
    return AppInitState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      features: features ?? this.features,
      progress: progress ?? this.progress,
    );
  }

  /// Check if all critical features are loaded
  bool get allCriticalFeaturesLoaded {
    return features['hive'] == true; // Hive is critical
  }

  /// Check if all features are loaded
  bool get allFeaturesLoaded {
    return features.values.every((loaded) => loaded == true);
  }
}

/// 🚀 App Initialization Notifier
class AppInitNotifier extends StateNotifier<AppInitState> {
  AppInitNotifier() : super(AppInitState());

  /// Initialize all app features
  Future<void> initialize() async {
    if (state.isLoading || state.isInitialized) return;

    state = state.copyWith(isLoading: true, error: null);
    AppLogger.info('🚀 Starting app initialization...');

    try {
      final totalSteps = 4;
      var currentStep = 0;

      // Step 1: Load Environment Variables (Optional)
      try {
        AppLogger.info('📦 Loading environment variables...');
        await dotenv.load(fileName: "project.env").timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            AppLogger.warn('⚠️ dotenv.load timed out');
          },
        );
        currentStep++;
        state = state.copyWith(
          features: {...state.features, 'dotenv': true},
          progress: currentStep / totalSteps,
        );
        AppLogger.success('✅ Environment variables loaded');
      } catch (e) {
        AppLogger.warn('⚠️ No .env file found, using defaults: $e');
        currentStep++;
        state = state.copyWith(
          features: {...state.features, 'dotenv': true}, // Non-critical
          progress: currentStep / totalSteps,
        );
      }

      // Step 2: Initialize Localization (Optional - Skip for now)
      // EasyLocalization requires context, so we skip it here
      AppLogger.debug('🌍 Skipping localization (requires context)...');
      currentStep++;
      state = state.copyWith(
        features: {...state.features, 'localization': true}, // Mark as done
        progress: currentStep / totalSteps,
      );
      AppLogger.debug('✅ Localization skipped');

      // Step 3: Initialize Hive (Critical)
      try {
        AppLogger.info('💾 Initializing Hive...');
        await Hive.initFlutter().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            AppLogger.warn('⚠️ Hive.initFlutter timed out');
          },
        );
        currentStep++;
        state = state.copyWith(
          features: {...state.features, 'hive': true},
          progress: currentStep / totalSteps,
        );
        AppLogger.success('✅ Hive initialized');
      } catch (e, stackTrace) {
        AppLogger.error('❌ Hive initialization failed', e, stackTrace);
        currentStep++;
        state = state.copyWith(
          features: {...state.features, 'hive': false},
          progress: currentStep / totalSteps,
          error: 'Failed to initialize local storage',
        );
      }

      // Step 4: Notifications (Removed - feature disabled)
      AppLogger.debug('🔔 Skipping notifications (feature disabled)...');
      currentStep++;
      state = state.copyWith(
        features: {...state.features, 'notifications': true}, // Mark as done
        progress: currentStep / totalSteps,
      );
      AppLogger.debug('✅ Notifications skipped');

      // Mark as initialized
      state = state.copyWith(
        isInitialized: true,
        isLoading: false,
        progress: 1.0,
      );

      AppLogger.success('🎉 App initialization complete!');
      _logInitializationSummary();
    } catch (e, stackTrace) {
      AppLogger.error('💥 App initialization failed', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Initialization failed: $e',
      );
    }
  }

  /// Log initialization summary
  void _logInitializationSummary() {
    AppLogger.info('📊 Initialization Summary:');
    state.features.forEach((feature, loaded) {
      final status = loaded ? '✅' : '❌';
      AppLogger.info('  $status $feature: ${loaded ? "Ready" : "Failed"}');
    });
  }

  /// Reset initialization state
  void reset() {
    state = AppInitState();
  }
}

/// 🚀 App Initialization Provider
final appInitProvider =
    StateNotifierProvider<AppInitNotifier, AppInitState>((ref) {
  return AppInitNotifier();
});
