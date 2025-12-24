/// 🚦 API Rate Limiter
///
/// Advanced rate limiting system to prevent API abuse and ensure
/// fair usage of API resources.
///
/// **Usage:**
/// ```dart
/// final limiter = ApiRateLimiter(
///   maxRequests: 20,
///   windowDuration: Duration(minutes: 1),
/// );
///
/// if (await limiter.canMakeRequest()) {
///   // Make API call
///   await limiter.recordRequest();
/// }
/// ```

import 'dart:collection';

class ApiRateLimiter {
  final int maxRequests;
  final Duration windowDuration;
  final Queue<DateTime> _requestTimes = Queue<DateTime>();

  ApiRateLimiter({
    required this.maxRequests,
    required this.windowDuration,
  });

  /// Check if a request can be made
  ///
  /// Returns true if under rate limit, false otherwise.
  ///
  /// **Returns:**
  /// True if request can be made, false if rate limit exceeded
  bool canMakeRequest() {
    _cleanOldRequests();
    return _requestTimes.length < maxRequests;
  }

  /// Record a request
  ///
  /// Records that a request was made. Should be called after
  /// successful API call.
  void recordRequest() {
    _cleanOldRequests();
    _requestTimes.add(DateTime.now());
  }

  /// Get remaining requests in current window
  ///
  /// **Returns:**
  /// Number of requests that can still be made
  int getRemainingRequests() {
    _cleanOldRequests();
    return maxRequests - _requestTimes.length;
  }

  /// Get time until next request can be made
  ///
  /// Returns null if requests can be made immediately.
  ///
  /// **Returns:**
  /// Duration until next request can be made, or null
  Duration? getTimeUntilNextRequest() {
    _cleanOldRequests();

    if (_requestTimes.length < maxRequests) {
      return null;
    }

    final oldestRequest = _requestTimes.first;
    final nextAvailable = oldestRequest.add(windowDuration);
    final now = DateTime.now();

    if (nextAvailable.isBefore(now)) {
      return null;
    }

    return nextAvailable.difference(now);
  }

  /// Reset rate limiter
  ///
  /// Clears all request history.
  void reset() {
    _requestTimes.clear();
  }

  /// Clean old requests outside the window
  void _cleanOldRequests() {
    final cutoff = DateTime.now().subtract(windowDuration);
    while (_requestTimes.isNotEmpty && _requestTimes.first.isBefore(cutoff)) {
      _requestTimes.removeFirst();
    }
  }
}
