/// 🔐 Environment Configuration
///
/// نظام إدارة البيئات المتقدم (Development, Staging, Production)
/// يدعم Feature Flags و Build Flavors
///
/// **Usage:**
/// ```dart
/// // Check environment
/// if (EnvironmentConfig.isProd) {
///   // Production code
/// }
///
/// // Get API URL
/// final apiUrl = EnvironmentConfig.apiBaseUrl;
///
/// // Check feature flags
/// if (EnvironmentConfig.enableAnalytics) {
///   // Initialize analytics
/// }
/// ```
///
/// **Build Commands:**
/// ```shell
/// # Development
/// flutter run --dart-define=FLAVOR=dev
///
/// # Staging
/// flutter run --dart-define=FLAVOR=staging
///
/// # Production
/// flutter run --dart-define=FLAVOR=prod --release
/// ```

import '../utils/logger.dart';

class EnvironmentConfig {
  EnvironmentConfig._(); // Private constructor

  // ============================================================================
  // ENVIRONMENT DETECTION
  // ============================================================================

  /// Current build flavor (dev, staging, prod)
  static const String _flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'dev',
  );

  /// Check if running in development environment
  static bool get isDev => _flavor == 'dev';

  /// Check if running in staging environment
  static bool get isStaging => _flavor == 'staging';

  /// Check if running in production environment
  static bool get isProd => _flavor == 'prod';

  /// Get current environment name
  static String get environmentName => _flavor.toUpperCase();

  // ============================================================================
  // API CONFIGURATION
  // ============================================================================

  /// Base API URL based on environment
  static String get apiBaseUrl {
    switch (_flavor) {
      case 'prod':
        return 'https://api.goldnightmare.com';
      case 'staging':
        return 'https://staging-api.goldnightmare.com';
      default:
        return 'https://dev-api.goldnightmare.com';
    }
  }

  /// Anthropic API base URL
  static String get anthropicBaseUrl => 'https://api.anthropic.com/v1';

  /// Gold API base URL
  static String get goldApiBaseUrl => 'https://www.goldapi.io/api';

  /// API timeout duration (in seconds)
  static Duration get apiTimeout {
    switch (_flavor) {
      case 'prod':
        return const Duration(seconds: 30);
      case 'staging':
        return const Duration(seconds: 45);
      default:
        return const Duration(seconds: 60); // Longer for debugging
    }
  }

  /// API retry attempts
  static int get apiRetryAttempts {
    switch (_flavor) {
      case 'prod':
        return 3;
      case 'staging':
        return 2;
      default:
        return 1; // No retry in dev for faster debugging
    }
  }

  // ============================================================================
  // FEATURE FLAGS
  // ============================================================================

  /// Enable Firebase Analytics
  static bool get enableAnalytics => isProd || isStaging;

  /// Enable Firebase Crashlytics
  static bool get enableCrashlytics => isProd;

  /// Enable debug logging
  static bool get enableDebugLogs => isDev || isStaging;

  /// Enable verbose logging (very detailed)
  static bool get enableVerboseLogs => isDev;

  /// Enable performance monitoring
  static bool get enablePerformanceMonitoring => isProd || isStaging;

  /// Enable error reporting to external services
  static bool get enableErrorReporting => isProd;

  /// Enable A/B testing
  static bool get enableABTesting => isProd || isStaging;

  /// Enable beta features
  static bool get enableBetaFeatures => isDev || isStaging;

  /// Enable offline mode
  static bool get enableOfflineMode => true; // Always enabled

  /// Enable auto-refresh
  static bool get enableAutoRefresh => true; // Always enabled

  /// Auto-refresh interval (in seconds)
  static int get autoRefreshInterval {
    switch (_flavor) {
      case 'prod':
        return 60; // 1 minute
      case 'staging':
        return 45; // 45 seconds
      default:
        return 30; // 30 seconds for faster testing
    }
  }

  // ============================================================================
  // CACHE CONFIGURATION
  // ============================================================================

  /// Cache expiry duration (in minutes)
  static int get cacheExpiryMinutes {
    switch (_flavor) {
      case 'prod':
        return 5;
      case 'staging':
        return 3;
      default:
        return 1; // Short cache for dev
    }
  }

  /// Maximum cache size (in MB)
  static int get maxCacheSizeMB {
    switch (_flavor) {
      case 'prod':
        return 50;
      case 'staging':
        return 30;
      default:
        return 10;
    }
  }

  // ============================================================================
  // RATE LIMITING
  // ============================================================================

  /// Maximum API requests per minute
  static int get maxRequestsPerMinute {
    switch (_flavor) {
      case 'prod':
        return 20;
      case 'staging':
        return 30;
      default:
        return 60; // Higher limit for dev testing
    }
  }

  /// Minimum interval between API requests (in seconds)
  static int get minRequestIntervalSeconds {
    switch (_flavor) {
      case 'prod':
        return 2;
      case 'staging':
        return 1;
      default:
        return 0; // No limit in dev
    }
  }

  // ============================================================================
  // APP CONFIGURATION
  // ============================================================================

  /// App name with environment suffix
  static String get appName {
    switch (_flavor) {
      case 'prod':
        return 'الكابوس الملكي';
      case 'staging':
        return 'الكابوس الملكي (Staging)';
      default:
        return 'الكابوس الملكي (Dev)';
    }
  }

  /// App bundle ID
  static String get bundleId {
    switch (_flavor) {
      case 'prod':
        return 'com.goldnightmare.pro';
      case 'staging':
        return 'com.goldnightmare.pro.staging';
      default:
        return 'com.goldnightmare.pro.dev';
    }
  }

  /// Show debug banner
  static bool get showDebugBanner => isDev;

  /// Show performance overlay
  static bool get showPerformanceOverlay => isDev;

  // ============================================================================
  // VALIDATION
  // ============================================================================

  /// Validate environment configuration
  static bool validate() {
    // Check if flavor is valid
    if (!['dev', 'staging', 'prod'].contains(_flavor)) {
      throw Exception(
          'Invalid FLAVOR: $_flavor. Must be dev, staging, or prod');
    }

    return true;
  }

  /// Print environment info (for debugging)
  static void printInfo() {
    if (!enableDebugLogs) return;

    AppLogger.info('');
    AppLogger.info(
        '╔════════════════════════════════════════════════════════╗');
    AppLogger.info(
        '║         ENVIRONMENT CONFIGURATION                      ║');
    AppLogger.info(
        '╠════════════════════════════════════════════════════════╣');
    AppLogger.info('║ Environment:        $environmentName');
    AppLogger.info('║ API Base URL:       $apiBaseUrl');
    AppLogger.info(
        '║ Analytics:          ${enableAnalytics ? 'ENABLED' : 'DISABLED'}');
    AppLogger.info(
        '║ Crashlytics:        ${enableCrashlytics ? 'ENABLED' : 'DISABLED'}');
    AppLogger.info(
        '║ Debug Logs:         ${enableDebugLogs ? 'ENABLED' : 'DISABLED'}');
    AppLogger.info(
        '║ Auto-Refresh:       ${enableAutoRefresh ? 'ENABLED ($autoRefreshInterval s)' : 'DISABLED'}');
    AppLogger.info('║ Cache Expiry:       $cacheExpiryMinutes minutes');
    AppLogger.info('║ Rate Limit:         $maxRequestsPerMinute requests/min');
    AppLogger.info(
        '╚════════════════════════════════════════════════════════╝');
    AppLogger.info('');
  }
}
