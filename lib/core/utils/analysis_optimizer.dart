/// 🎯 Analysis Optimizer
///
/// Utility class for optimizing analysis engine performance and accuracy.
/// Provides caching, parallel processing, and result validation.
///
/// **Usage:**
/// ```dart
/// // Cache analysis results
/// AnalysisOptimizer.cacheResult('key', result);
///
/// // Get cached result
/// final cached = AnalysisOptimizer.getCached('key');
///
/// // Validate analysis result
/// if (AnalysisOptimizer.isValidResult(result)) {
///   // Use result
/// }
/// ```

import '../utils/logger.dart';

class AnalysisOptimizer {
  AnalysisOptimizer._();

  static final Map<String, _CachedAnalysis> _cache = {};
  static const Duration _defaultCacheDuration = Duration(minutes: 5);

  /// Cache analysis result
  ///
  /// Stores analysis result with optional TTL.
  ///
  /// **Parameters:**
  /// - [key]: Cache key (e.g., 'golden_nightmare_2050.0')
  /// - [result]: Analysis result to cache
  /// - [ttl]: Time to live (default: 5 minutes)
  static void cacheResult(
    String key,
    dynamic result, {
    Duration? ttl,
  }) {
    _cache[key] = _CachedAnalysis(
      result: result,
      expiresAt: DateTime.now().add(ttl ?? _defaultCacheDuration),
      timestamp: DateTime.now(),
    );
    AppLogger.debug('Cached analysis result: $key');
  }

  /// Get cached analysis result
  ///
  /// Retrieves cached result if it exists and hasn't expired.
  ///
  /// **Parameters:**
  /// - [key]: Cache key
  ///
  /// **Returns:**
  /// Cached result, or null if not found or expired
  static dynamic getCached(String key) {
    final cached = _cache[key];
    if (cached == null) {
      return null;
    }

    if (DateTime.now().isAfter(cached.expiresAt)) {
      _cache.remove(key);
      AppLogger.debug('Cache expired: $key');
      return null;
    }

    AppLogger.debug('Using cached result: $key');
    return cached.result;
  }

  /// Check if result is cached and valid
  ///
  /// **Parameters:**
  /// - [key]: Cache key
  ///
  /// **Returns:**
  /// True if result is cached and valid
  static bool hasCached(String key) {
    final cached = _cache[key];
    if (cached == null) {
      return false;
    }

    if (DateTime.now().isAfter(cached.expiresAt)) {
      _cache.remove(key);
      return false;
    }

    return true;
  }

  /// Validate analysis result
  ///
  /// Checks if analysis result is valid and complete.
  ///
  /// **Parameters:**
  /// - [result]: Analysis result to validate
  ///
  /// **Returns:**
  /// True if result is valid
  static bool isValidResult(dynamic result) {
    if (result == null) {
      return false;
    }

    // Check if result is a map (for Golden Nightmare Engine)
    if (result is Map) {
      return result.containsKey('SCALP') || result.containsKey('SWING');
    }

    // Check if result has required properties
    // This is a generic check - specific engines may have different requirements
    return true;
  }

  /// Generate cache key from parameters
  ///
  /// Creates a unique cache key from analysis parameters.
  ///
  /// **Parameters:**
  /// - [engine]: Engine name (e.g., 'golden_nightmare')
  /// - [currentPrice]: Current price
  /// - [candleCount]: Number of candles
  ///
  /// **Returns:**
  /// Cache key string
  static String generateCacheKey(
    String engine,
    double currentPrice,
    int candleCount,
  ) {
    // Round price to 2 decimal places for cache key
    final roundedPrice = currentPrice.toStringAsFixed(2);
    return '${engine}_${roundedPrice}_$candleCount';
  }

  /// Clear expired cache entries
  ///
  /// Removes all expired entries from cache.
  static void clearExpired() {
    final now = DateTime.now();
    _cache.removeWhere((key, cached) => now.isAfter(cached.expiresAt));
  }

  /// Clear all cache
  ///
  /// Removes all cached entries.
  static void clearAll() {
    _cache.clear();
    AppLogger.info('Cleared all analysis cache');
  }

  /// Get cache statistics
  ///
  /// **Returns:**
  /// Map with cache statistics
  static Map<String, dynamic> getCacheStats() {
    clearExpired();
    final timestamps = _cache.values.map((e) => e.timestamp).toList();
    return {
      'size': _cache.length,
      'keys': _cache.keys.toList(),
      'oldestEntry': timestamps.isEmpty
          ? null
          : timestamps.reduce((a, b) => a.isBefore(b) ? a : b),
      'newestEntry': timestamps.isEmpty
          ? null
          : timestamps.reduce((a, b) => a.isAfter(b) ? a : b),
    };
  }

  /// Optimize candle data for analysis
  ///
  /// Reduces candle data to optimal size for analysis while preserving
  /// important data points.
  ///
  /// **Parameters:**
  /// - [candles]: Original candle list
  /// - [maxCandles]: Maximum number of candles (default: 500)
  ///
  /// **Returns:**
  /// Optimized candle list
  static List<T> optimizeCandles<T>(List<T> candles, {int maxCandles = 500}) {
    if (candles.length <= maxCandles) {
      return candles;
    }

    // Keep first and last candles, sample middle ones
    final step = (candles.length / maxCandles).ceil();
    final optimized = <T>[];

    // Always include first candle
    optimized.add(candles.first);

    // Sample middle candles
    for (int i = step; i < candles.length - step; i += step) {
      optimized.add(candles[i]);
    }

    // Always include last candle
    optimized.add(candles.last);

    AppLogger.debug(
        'Optimized candles: ${candles.length} -> ${optimized.length}');
    return optimized;
  }

  /// Validate candles before analysis
  ///
  /// Checks if candles are valid for analysis.
  ///
  /// **Parameters:**
  /// - [candles]: Candle list to validate
  /// - [minCandles]: Minimum required candles (default: 50)
  ///
  /// **Returns:**
  /// True if candles are valid
  static bool isValidCandles<T>(List<T> candles, {int minCandles = 50}) {
    if (candles.isEmpty) {
      AppLogger.warn('Empty candle list');
      return false;
    }

    if (candles.length < minCandles) {
      AppLogger.warn('Insufficient candles: ${candles.length} < $minCandles');
      return false;
    }

    return true;
  }
}

/// Cached analysis entry
class _CachedAnalysis {
  final dynamic result;
  final DateTime expiresAt;
  final DateTime timestamp;

  _CachedAnalysis({
    required this.result,
    required this.expiresAt,
    required this.timestamp,
  });
}
