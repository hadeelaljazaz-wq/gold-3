/// Error Messages Constants
class ErrorMessages {
  const ErrorMessages._();

  // Network Errors
  static const String networkError = 'فشل الاتصال بالشبكة';
  static const String timeoutError = 'انتهت مهلة الطلب';
  static const String connectionError = 'خطأ في الاتصال';

  // API Errors
  static const String apiError = 'خطأ في استدعاء API';
  static const String invalidResponse = 'استجابة غير صالحة من الخادم';
  static const String rateLimitExceeded = 'تم تجاوز حد الطلبات';

  // Data Errors
  static const String noDataAvailable = 'لا توجد بيانات متاحة';
  static const String invalidData = 'بيانات غير صالحة';
  static const String parsingError = 'خطأ في معالجة البيانات';

  // Service Errors
  static const String serviceUnavailable = 'الخدمة غير متاحة حالياً';
  static const String allServicesFailed =
      'فشلت جميع محاولات الحصول على البيانات';

  // Cache Errors
  static const String cacheError = 'خطأ في التخزين المؤقت';
  static const String cacheExpired = 'انتهت صلاحية البيانات المخزنة';

  // General Errors
  static const String unknownError = 'خطأ غير معروف';
  static const String tryAgainLater = 'الرجاء المحاولة مرة أخرى';
}
