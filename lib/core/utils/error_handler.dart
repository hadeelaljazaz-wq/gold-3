import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../constants/error_messages.dart';
import '../constants/retry_settings.dart';
import 'logger.dart';

/// Centralized Error Handler
class ErrorHandler {
  const ErrorHandler._();

  /// Handle any error with logging and context
  static Future<void> handle(
    dynamic error,
    StackTrace stackTrace, {
    String? context,
    bool silent = false,
  }) async {
    final errorMessage = _getErrorMessage(error);
    final fullContext = context != null ? '[$context] ' : '';

    if (!silent) {
      AppLogger.error('$fullContext$errorMessage', error, stackTrace);
    }

    // You can add additional error reporting here (e.g., Crashlytics, Sentry)
  }

  /// Get user-friendly error message
  static String _getErrorMessage(dynamic error) {
    if (error is DioException) {
      return _getDioErrorMessage(error);
    } else if (error is TimeoutException) {
      return '${ErrorMessages.timeoutError}. ${ErrorMessages.tryAgainLater}';
    } else if (error is FormatException) {
      return '${ErrorMessages.parsingError}. ${ErrorMessages.tryAgainLater}';
    } else if (error is Exception) {
      final errorString = error.toString().toLowerCase();
      if (errorString.contains('connection') ||
          errorString.contains('socket')) {
        return '${ErrorMessages.connectionError}. تحقق من اتصالك بالإنترنت';
      } else if (errorString.contains('network') ||
          errorString.contains('host')) {
        return '${ErrorMessages.networkError}. تحقق من اتصالك بالإنترنت';
      } else if (errorString.contains('api') || errorString.contains('key')) {
        return '${ErrorMessages.apiError}. تحقق من إعدادات API';
      } else if (errorString.contains('permission') ||
          errorString.contains('access')) {
        return 'خطأ في الصلاحيات. تحقق من إعدادات التطبيق';
      }
      // Return a more user-friendly message
      final cleanMessage =
          error.toString().replaceAll(RegExp(r'Exception:?\s*'), '');
      return cleanMessage.isNotEmpty
          ? cleanMessage
          : ErrorMessages.unknownError;
    }
    return ErrorMessages.unknownError;
  }

  /// Get Dio-specific error message
  static String _getDioErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ErrorMessages.timeoutError;

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 429) {
          return ErrorMessages.rateLimitExceeded;
        } else if (statusCode != null && statusCode >= 500) {
          return ErrorMessages.serviceUnavailable;
        }
        return ErrorMessages.invalidResponse;

      case DioExceptionType.connectionError:
        return ErrorMessages.connectionError;

      case DioExceptionType.badCertificate:
        return 'خطأ في شهادة الأمان';

      case DioExceptionType.cancel:
        return 'تم إلغاء الطلب';

      default:
        return ErrorMessages.networkError;
    }
  }

  /// Retry a function with exponential backoff and recovery
  static Future<T> retry<T>({
    required Future<T> Function() function,
    int maxAttempts = RetrySettings.maxRetries,
    bool Function(dynamic error)? retryIf,
    T? Function(dynamic error)? recover,
  }) async {
    int attempt = 0;

    while (true) {
      try {
        return await function();
      } catch (error, stackTrace) {
        attempt++;

        // Try recovery if available
        if (recover != null) {
          final recovered = recover(error);
          if (recovered != null) {
            AppLogger.info('Error recovered using recovery function');
            return recovered;
          }
        }

        final shouldRetry =
            retryIf?.call(error) ?? RetrySettings.isRetryable(error);

        if (attempt >= maxAttempts || !shouldRetry) {
          await handle(error, stackTrace,
              context: 'Retry failed after $attempt attempts');
          rethrow;
        }

        final delay = RetrySettings.getDelayForAttempt(attempt);
        AppLogger.warn(
            'Retry attempt $attempt/$maxAttempts after ${delay.inMilliseconds}ms');
        await Future.delayed(delay);
      }
    }
  }

  /// Show user-friendly error dialog
  static void showErrorDialog(
    BuildContext context,
    String message, {
    String? title,
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'خطأ'),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('إعادة المحاولة'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}
