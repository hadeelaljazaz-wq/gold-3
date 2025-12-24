import 'package:flutter/foundation.dart';

/// 📝 نظام تسجيل الأحداث مع مستويات قابلة للتخصيص
enum LogLevel {
  none,    // لا تسجيل
  error,   // أخطاء فقط
  warn,    // تحذيرات وأخطاء
  info,    // معلومات وتحذيرات وأخطاء
  debug,   // كل شيء بالتفصيل
  success, // نجاح ومعلومات وتحذيرات وأخطاء
}

class AppLogger {
  static LogLevel _currentLevel = LogLevel.info;

  /// تعيين مستوى التسجيل
  static void setLevel(LogLevel level) {
    _currentLevel = level;
    if (kDebugMode) {
      print('🔧 Log level set to: ${level.name}');
    }
  }

  /// رسالة نجاح ✅
  static void success(String message) {
    if (!kDebugMode) return;
    if (_shouldLog(LogLevel.success)) {
      print('✅ SUCCESS: $message');
    }
  }

  /// رسالة تحذير ⚠️
  static void warn(String message) {
    if (!kDebugMode) return;
    if (_shouldLog(LogLevel.warn)) {
      print('⚠️ WARNING: $message');
    }
  }

  /// رسالة خطأ ❌
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (!kDebugMode) return;
    if (_shouldLog(LogLevel.error)) {
      print('❌ ERROR: $message');
      if (error != null) {
        print('   Details: $error');
      }
      if (stackTrace != null) {
        print('   Stack: $stackTrace');
      }
    }
  }

  /// رسالة معلومات ℹ️
  static void info(String message) {
    if (!kDebugMode) return;
    if (_shouldLog(LogLevel.info)) {
      print('ℹ️ INFO: $message');
    }
  }

  /// رسالة تصحيح 🐛
  static void debug(String message) {
    if (!kDebugMode) return;
    if (_shouldLog(LogLevel.debug)) {
      print('🐛 DEBUG: $message');
    }
  }

  /// التحقق من إمكانية التسجيل حسب المستوى
  static bool _shouldLog(LogLevel messageLevel) {
    if (_currentLevel == LogLevel.none) return false;
    if (_currentLevel == LogLevel.debug) return true;
    
    // ترتيب الأولويات: error < warn < info < success < debug
    final levelPriority = {
      LogLevel.error: 1,
      LogLevel.warn: 2,
      LogLevel.info: 3,
      LogLevel.success: 3,
      LogLevel.debug: 4,
    };
    
    return (levelPriority[messageLevel] ?? 0) <= (levelPriority[_currentLevel] ?? 0);
  }
}
