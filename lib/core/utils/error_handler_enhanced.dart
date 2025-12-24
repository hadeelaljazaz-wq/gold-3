/// 🛡️ Enhanced Error Handler
///
/// Comprehensive error handling system with user-friendly messages
/// and error reporting capabilities.
///
/// **Usage:**
/// ```dart
/// try {
///   // Risky operation
/// } catch (e, stackTrace) {
///   ErrorHandler.handle(e, stackTrace, context: 'API Call');
/// }
/// ```

import '../utils/logger.dart';

class ErrorHandler {
  ErrorHandler._();

  /// Handle error with context
  ///
  /// Provides user-friendly error messages and logs errors.
  ///
  /// **Parameters:**
  /// - [error]: Error object
  /// - [stackTrace]: Stack trace (optional)
  /// - [context]: Context where error occurred
  /// - [showToUser]: Whether to show error to user (default: true)
  ///
  /// **Returns:**
  /// User-friendly error message
  static String handle(
    Object error,
    StackTrace? stackTrace, {
    String? context,
    bool showToUser = true,
  }) {
    // Log error
    AppLogger.error(
      context != null ? 'Error in $context' : 'Error occurred',
      error,
      stackTrace,
    );

    // Get user-friendly message
    final message = _getUserFriendlyMessage(error);

    // Report to analytics if enabled
    _reportError(error, stackTrace, context);

    return message;
  }

  /// Get user-friendly error message
  ///
  /// Converts technical errors to user-friendly messages.
  static String _getUserFriendlyMessage(Object error) {
    final errorString = error.toString().toLowerCase();

    // Network errors
    if (errorString.contains('socket') ||
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'خطأ في الاتصال بالإنترنت. يرجى التحقق من اتصالك والمحاولة مرة أخرى.';
    }

    // Timeout errors
    if (errorString.contains('timeout')) {
      return 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى.';
    }

    // API errors
    if (errorString.contains('api') || errorString.contains('server')) {
      return 'خطأ في الخادم. يرجى المحاولة لاحقاً.';
    }

    // Authentication errors
    if (errorString.contains('auth') ||
        errorString.contains('unauthorized') ||
        errorString.contains('forbidden')) {
      return 'خطأ في المصادقة. يرجى التحقق من بيانات الدخول.';
    }

    // Rate limit errors
    if (errorString.contains('rate limit') ||
        errorString.contains('too many requests')) {
      return 'تم تجاوز الحد المسموح. يرجى الانتظار قليلاً والمحاولة مرة أخرى.';
    }

    // Generic error
    return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
  }

  /// Report error to analytics
  ///
  /// Reports error to analytics service if enabled.
  static void _reportError(
    Object error,
    StackTrace? stackTrace,
    String? context,
  ) {
    // TODO: Integrate with Firebase Crashlytics or similar
    // if (EnvironmentConfig.enableErrorReporting) {
    //   FirebaseCrashlytics.instance.recordError(
    //     error,
    //     stackTrace,
    //     reason: context,
    //   );
    // }
  }

  /// Handle API error specifically
  ///
  /// Handles API-specific errors with retry logic.
  ///
  /// **Parameters:**
  /// - [error]: Error object
  /// - [retryCallback]: Callback to retry the operation
  /// - [maxRetries]: Maximum retry attempts (default: 3)
  ///
  /// **Returns:**
  /// True if operation succeeded after retry, false otherwise
  static Future<bool> handleApiError(
    Object error,
    Future<void> Function() retryCallback, {
    int maxRetries = 3,
  }) async {
    int retries = 0;

    while (retries < maxRetries) {
      try {
        await retryCallback();
        return true;
      } catch (e) {
        retries++;
        if (retries >= maxRetries) {
          AppLogger.error('API call failed after $maxRetries retries', e);
          return false;
        }
        // Wait before retry (exponential backoff)
        await Future.delayed(Duration(seconds: retries * 2));
      }
    }

    return false;
  }
}
