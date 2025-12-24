import 'package:flutter/foundation.dart';
import '../constants/api_keys.dart';

/// Professional Logging System with Production Support
///
/// نظام تسجيل احترافي للتطبيق
/// - يدعم مستويات مختلفة من السجلات (debug, info, warn, error, fatal)
/// - يعرض السجلات بألوان في وضع التطوير
/// - يحفظ السجلات المهمة في وضع الإنتاج
/// - جاهز للتكامل مع Firebase Crashlytics, Sentry
class AppLogger {
  AppLogger._(); // منع الإنشاء

  /// Enable/Disable logging
  static bool get enabled {
    try {
      return Environment.enableLogging;
    } catch (e) {
      return true; // Default to enabled if Environment not loaded
    }
  }

  /// Production logs buffer (for critical errors)
  static final List<LogEntry> _productionLogs = [];

  /// Debug log (lowest priority)
  static void debug(String message, [Object? data]) {
    if (!enabled || kReleaseMode) return;
    _log(LogLevel.debug, message, data);
  }

  /// Info log
  static void info(String message, [Object? data]) {
    if (!enabled) return;
    _log(LogLevel.info, message, data);
  }

  /// Success log
  static void success(String message, [Object? data]) {
    if (!enabled) return;
    _log(LogLevel.success, message, data);
  }

  /// Warning log
  static void warn(String message, [Object? data]) {
    if (!enabled) return;
    _log(LogLevel.warning, message, data);
    _addToProductionLog(LogLevel.warning, message, data);
  }

  /// Error log
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (!enabled) return;
    _log(LogLevel.error, message, error);
    _addToProductionLog(LogLevel.error, message, error, stackTrace);

    if (stackTrace != null && kDebugMode) {
      debugPrint('Stack Trace:\n$stackTrace');
    }

    // TODO: Send to crash analytics in production
    // if (Environment.isProduction) {
    //   FirebaseCrashlytics.instance.recordError(error, stackTrace);
    // }
  }

  /// Fatal error log (highest priority)
  static void fatal(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.fatal, message, error);
    _addToProductionLog(LogLevel.fatal, message, error, stackTrace);

    if (stackTrace != null) {
      debugPrint('Stack Trace:\n$stackTrace');
    }

    // TODO: Send to crash analytics immediately
    // if (Environment.isProduction) {
    //   FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
    // }
  }

  /// Private log method
  static void _log(LogLevel level, String message, [Object? data]) {
    final timestamp = DateTime.now().toIso8601String();
    final emoji = _getEmoji(level);
    final levelName = level.name.toUpperCase();
    final logMessage = '[$timestamp] $emoji $levelName: $message';

    debugPrint(logMessage);

    if (data != null) {
      debugPrint('  └─ Data: $data');
    }
  }

  /// Add important logs to production buffer
  static void _addToProductionLog(LogLevel level, String message, Object? data,
      [StackTrace? stackTrace]) {
    // معطّل في هذا الإصدار لتجنب أي أخطاء تهيئة بيئة
    return;
  }

  /// Get emoji for log level
  static String _getEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔵';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.success:
        return '✅';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.fatal:
        return '🔴';
    }
  }

  /// Log API call
  static void api(String method, String url, {int? statusCode, Object? data}) {
    if (!enabled) return;
    final status = statusCode != null ? ' ($statusCode)' : '';
    _log(LogLevel.info, '🌐 API: $method $url$status', data);
  }

  /// Log database operation
  static void db(String operation, {Object? data}) {
    if (!enabled) return;
    _log(LogLevel.info, '💾 DB: $operation', data);
  }

  /// Log navigation
  static void nav(String route, {Object? data}) {
    if (!enabled) return;
    _log(LogLevel.info, '🗺️ NAV: Navigating to: $route', data);
  }

  /// Log analysis engine operation
  static void analysis(String engine, String operation, {Object? data}) {
    if (!enabled) return;
    _log(LogLevel.info, '🔥 ANALYSIS [$engine]: $operation', data);
  }

  /// Log signal generation
  static void signal(String type, String action, {Object? data}) {
    if (!enabled) return;
    _log(LogLevel.success, '📊 SIGNAL [$type]: $action', data);
  }

  /// Get production logs (for error reporting)
  static List<LogEntry> getProductionLogs() {
    return List.unmodifiable(_productionLogs);
  }

  /// Clear production logs
  static void clearProductionLogs() {
    _productionLogs.clear();
  }

  /// Export logs as string (for debugging)
  static String exportLogs() {
    return _productionLogs
        .map((e) => '[${e.timestamp}] ${e.level.name}: ${e.message}')
        .join('\n');
  }
}

/// Log levels
enum LogLevel {
  debug,
  info,
  success,
  warning,
  error,
  fatal,
}

/// Log entry for production logging
class LogEntry {
  final LogLevel level;
  final String message;
  final Object? data;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  LogEntry({
    required this.level,
    required this.message,
    this.data,
    this.stackTrace,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'level': level.name,
        'message': message,
        'data': data?.toString(),
        'stackTrace': stackTrace?.toString(),
        'timestamp': timestamp.toIso8601String(),
      };
}
