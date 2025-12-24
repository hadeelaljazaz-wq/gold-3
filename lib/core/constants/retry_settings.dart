/// Retry Settings for Network Requests
class RetrySettings {
  const RetrySettings._();

  // Retry Configuration
  static const int maxRetries = 3;
  static const Duration initialDelay = Duration(milliseconds: 500);
  static const Duration maxDelay = Duration(seconds: 5);
  static const double backoffMultiplier = 2.0;

  // Timeout Configuration
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 10);

  // Retry Conditions
  static const List<int> retryableStatusCodes = [408, 429, 500, 502, 503, 504];

  /// Calculate delay for retry attempt
  static Duration getDelayForAttempt(int attempt) {
    final delay = initialDelay * (backoffMultiplier * attempt);
    return delay > maxDelay ? maxDelay : delay;
  }

  /// Check if error is retryable
  static bool isRetryable(dynamic error) {
    if (error is Exception) {
      final errorString = error.toString().toLowerCase();
      return errorString.contains('timeout') ||
          errorString.contains('connection') ||
          errorString.contains('network');
    }
    return false;
  }
}
