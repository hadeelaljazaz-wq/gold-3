/// Custom Exceptions for Trading System
///
/// هذا الملف يحتوي على جميع الاستثناءات المخصصة للنظام
/// لتسهيل معالجة الأخطاء وتوفير رسائل واضحة
library custom_exceptions;

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

// ============================================================================
// BASE EXCEPTION
// ============================================================================

/// الاستثناء الأساسي لجميع استثناءات النظام
@immutable
abstract class TradingException implements Exception {
  /// رسالة الخطأ بالإنجليزية (للـ logging)
  final String message;

  /// رسالة الخطأ بالعربية (للمستخدم)
  final String arabicMessage;

  /// السبب الأصلي للخطأ (إن وجد)
  final Object? cause;

  /// Stack trace (إن وجد)
  final StackTrace? stackTrace;

  /// وقت حدوث الخطأ
  final DateTime timestamp;

  const TradingException({
    required this.message,
    required this.arabicMessage,
    this.cause,
    this.stackTrace,
    required this.timestamp,
  });

  factory TradingException.now({
    required String message,
    required String arabicMessage,
    Object? cause,
    StackTrace? stackTrace,
  }) = _TradingExceptionImpl;

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('$runtimeType: $message');
    if (cause != null) {
      buffer.write('\nCause: $cause');
    }
    return buffer.toString();
  }

  /// Get user-friendly message
  String getUserMessage() => arabicMessage;

  /// Get technical message for logging
  String getTechnicalMessage() => message;
}

/// Implementation of base exception
class _TradingExceptionImpl extends TradingException {
  _TradingExceptionImpl({
    required super.message,
    required super.arabicMessage,
    super.cause,
    super.stackTrace,
  }) : super(timestamp: DateTime.now());
}

// ============================================================================
// NETWORK EXCEPTIONS
// ============================================================================

/// استثناء الشبكة العام
class NetworkException extends TradingException {
  const NetworkException({
    required super.message,
    required super.arabicMessage,
    super.cause,
    super.stackTrace,
    required super.timestamp,
  });

  factory NetworkException.now({
    required String message,
    required String arabicMessage,
    Object? cause,
    StackTrace? stackTrace,
  }) = _NetworkExceptionImpl;
}

class _NetworkExceptionImpl extends NetworkException {
  _NetworkExceptionImpl({
    required super.message,
    required super.arabicMessage,
    super.cause,
    super.stackTrace,
  }) : super(timestamp: DateTime.now());
}

/// استثناء انتهاء المهلة
class TimeoutException extends NetworkException {
  const TimeoutException({
    String message = 'Request timeout',
    String arabicMessage = 'انتهت مهلة الاتصال. الرجاء المحاولة مرة أخرى.',
    super.cause,
    super.stackTrace,
    required super.timestamp,
  }) : super(message: message, arabicMessage: arabicMessage);

  factory TimeoutException.now({
    String? message,
    String? arabicMessage,
    Object? cause,
    StackTrace? stackTrace,
  }) = _TimeoutExceptionImpl;
}

class _TimeoutExceptionImpl extends TimeoutException {
  _TimeoutExceptionImpl({
    String? message,
    String? arabicMessage,
    super.cause,
    super.stackTrace,
  }) : super(
          message: message ?? 'Request timeout',
          arabicMessage:
              arabicMessage ?? 'انتهت مهلة الاتصال. الرجاء المحاولة مرة أخرى.',
          timestamp: DateTime.now(),
        );
}

/// استثناء فشل الاتصال
class ConnectionException extends NetworkException {
  const ConnectionException({
    String message = 'Connection failed',
    String arabicMessage = 'فشل الاتصال بالإنترنت. الرجاء التحقق من الاتصال.',
    super.cause,
    super.stackTrace,
    required super.timestamp,
  }) : super(message: message, arabicMessage: arabicMessage);

  factory ConnectionException.now({
    String? message,
    String? arabicMessage,
    Object? cause,
    StackTrace? stackTrace,
  }) = _ConnectionExceptionImpl;
}

class _ConnectionExceptionImpl extends ConnectionException {
  _ConnectionExceptionImpl({
    String? message,
    String? arabicMessage,
    super.cause,
    super.stackTrace,
  }) : super(
          message: message ?? 'Connection failed',
          arabicMessage: arabicMessage ??
              'فشل الاتصال بالإنترنت. الرجاء التحقق من الاتصال.',
          timestamp: DateTime.now(),
        );
}

// ============================================================================
// API EXCEPTIONS
// ============================================================================

/// استثناء API العام
class ApiException extends TradingException {
  final int? statusCode;

  const ApiException({
    required super.message,
    required super.arabicMessage,
    this.statusCode,
    super.cause,
    super.stackTrace,
    required super.timestamp,
  });

  factory ApiException.now({
    required String message,
    required String arabicMessage,
    int? statusCode,
    Object? cause,
    StackTrace? stackTrace,
  }) = _ApiExceptionImpl;

  /// Create from DioException
  factory ApiException.fromDioException(DioException error) {
    final statusCode = error.response?.statusCode;
    String message = 'API Error';
    String arabicMessage = 'خطأ في الاتصال بالخادم';

    if (statusCode != null) {
      if (statusCode >= 500) {
        message = 'Server Error $statusCode';
        arabicMessage = 'خطأ في الخادم. الرجاء المحاولة لاحقاً.';
      } else if (statusCode == 401 || statusCode == 403) {
        message = 'Unauthorized $statusCode';
        arabicMessage = 'غير مصرح. الرجاء التحقق من بيانات الاعتماد.';
      } else if (statusCode == 429) {
        message = 'Rate Limit Exceeded';
        arabicMessage = 'تم تجاوز الحد المسموح. الرجاء المحاولة لاحقاً.';
      } else {
        message = 'API Error $statusCode';
        arabicMessage = 'خطأ في الاتصال بالخادم ($statusCode)';
      }
    }

    return ApiException.now(
      message: message,
      arabicMessage: arabicMessage,
      statusCode: statusCode,
      cause: error,
      stackTrace: error.stackTrace,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('$runtimeType: $message');
    if (statusCode != null) {
      buffer.write(' (Status Code: $statusCode)');
    }
    if (cause != null) {
      buffer.write('\nCause: $cause');
    }
    return buffer.toString();
  }
}

class _ApiExceptionImpl extends ApiException {
  _ApiExceptionImpl({
    required super.message,
    required super.arabicMessage,
    super.statusCode,
    super.cause,
    super.stackTrace,
  }) : super(timestamp: DateTime.now());
}

/// استثناء خطأ الخادم
class ServerException extends ApiException {
  const ServerException({
    String message = 'Server error',
    String arabicMessage = 'خطأ في الخادم. الرجاء المحاولة لاحقاً.',
    super.statusCode,
    super.cause,
    super.stackTrace,
    required super.timestamp,
  }) : super(message: message, arabicMessage: arabicMessage);

  factory ServerException.now({
    String? message,
    String? arabicMessage,
    int? statusCode,
    Object? cause,
    StackTrace? stackTrace,
  }) = _ServerExceptionImpl;
}

class _ServerExceptionImpl extends ServerException {
  _ServerExceptionImpl({
    String? message,
    String? arabicMessage,
    super.statusCode,
    super.cause,
    super.stackTrace,
  }) : super(
          message: message ?? 'Server error',
          arabicMessage:
              arabicMessage ?? 'خطأ في الخادم. الرجاء المحاولة لاحقاً.',
          timestamp: DateTime.now(),
        );
}

// ============================================================================
// DATA EXCEPTIONS
// ============================================================================

/// استثناء البيانات العام
class DataException extends TradingException {
  const DataException({
    required super.message,
    required super.arabicMessage,
    super.cause,
    super.stackTrace,
    required super.timestamp,
  });

  factory DataException.now({
    required String message,
    required String arabicMessage,
    Object? cause,
    StackTrace? stackTrace,
  }) = _DataExceptionImpl;
}

class _DataExceptionImpl extends DataException {
  _DataExceptionImpl({
    required super.message,
    required super.arabicMessage,
    super.cause,
    super.stackTrace,
  }) : super(timestamp: DateTime.now());
}

/// استثناء تحليل البيانات
class DataParsingException extends DataException {
  const DataParsingException({
    String message = 'Data parsing failed',
    String arabicMessage = 'فشل تحليل البيانات. البيانات المستلمة غير صالحة.',
    super.cause,
    super.stackTrace,
    required super.timestamp,
  }) : super(message: message, arabicMessage: arabicMessage);

  factory DataParsingException.now({
    String? message,
    String? arabicMessage,
    Object? cause,
    StackTrace? stackTrace,
  }) = _DataParsingExceptionImpl;
}

class _DataParsingExceptionImpl extends DataParsingException {
  _DataParsingExceptionImpl({
    String? message,
    String? arabicMessage,
    super.cause,
    super.stackTrace,
  }) : super(
          message: message ?? 'Data parsing failed',
          arabicMessage: arabicMessage ??
              'فشل تحليل البيانات. البيانات المستلمة غير صالحة.',
          timestamp: DateTime.now(),
        );
}

/// استثناء بيانات غير كافية
class InsufficientDataException extends DataException {
  final int required;
  final int actual;

  const InsufficientDataException({
    required this.required,
    required this.actual,
    String? message,
    String? arabicMessage,
    super.cause,
    super.stackTrace,
    required super.timestamp,
  }) : super(
          message:
              message ?? 'Insufficient data: required $required, got $actual',
          arabicMessage: arabicMessage ??
              'بيانات غير كافية للتحليل. مطلوب $required، متوفر $actual.',
        );

  factory InsufficientDataException.now({
    required int required,
    required int actual,
    String? message,
    String? arabicMessage,
    Object? cause,
    StackTrace? stackTrace,
  }) = _InsufficientDataExceptionImpl;

  @override
  String toString() {
    return '$runtimeType: $message (Required: $required, Actual: $actual)';
  }
}

class _InsufficientDataExceptionImpl extends InsufficientDataException {
  _InsufficientDataExceptionImpl({
    required super.required,
    required super.actual,
    super.message,
    super.arabicMessage,
    super.cause,
    super.stackTrace,
  }) : super(timestamp: DateTime.now());
}

// ============================================================================
// ANALYSIS EXCEPTIONS
// ============================================================================

/// استثناء عدم وجود فرصة تداول
class NoTradeOpportunityException extends TradingException {
  final String reason;

  const NoTradeOpportunityException({
    required this.reason,
    String? message,
    String? arabicMessage,
    super.cause,
    super.stackTrace,
    required super.timestamp,
  }) : super(
          message: message ?? 'No trade opportunity: $reason',
          arabicMessage: arabicMessage ?? 'لا توجد فرصة تداول: $reason',
        );

  factory NoTradeOpportunityException.now({
    required String reason,
    String? message,
    String? arabicMessage,
    Object? cause,
    StackTrace? stackTrace,
  }) = _NoTradeOpportunityExceptionImpl;

  @override
  String toString() {
    return '$runtimeType: $message (Reason: $reason)';
  }
}

class _NoTradeOpportunityExceptionImpl extends NoTradeOpportunityException {
  _NoTradeOpportunityExceptionImpl({
    required super.reason,
    super.message,
    super.arabicMessage,
    super.cause,
    super.stackTrace,
  }) : super(timestamp: DateTime.now());
}

// ============================================================================
// UNEXPECTED EXCEPTION
// ============================================================================

/// استثناء غير متوقع
class UnexpectedException extends TradingException {
  const UnexpectedException({
    String message = 'Unexpected error occurred',
    String arabicMessage = 'حدث خطأ غير متوقع. الرجاء المحاولة مرة أخرى.',
    super.cause,
    super.stackTrace,
    required super.timestamp,
  }) : super(message: message, arabicMessage: arabicMessage);

  factory UnexpectedException.now({
    String? message,
    String? arabicMessage,
    Object? cause,
    StackTrace? stackTrace,
  }) = _UnexpectedExceptionImpl;
}

class _UnexpectedExceptionImpl extends UnexpectedException {
  _UnexpectedExceptionImpl({
    String? message,
    String? arabicMessage,
    super.cause,
    super.stackTrace,
  }) : super(
          message: message ?? 'Unexpected error occurred',
          arabicMessage:
              arabicMessage ?? 'حدث خطأ غير متوقع. الرجاء المحاولة مرة أخرى.',
          timestamp: DateTime.now(),
        );
}
