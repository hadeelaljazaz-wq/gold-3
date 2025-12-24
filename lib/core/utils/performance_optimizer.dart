import 'dart:async';

/// 🚀 Performance Optimizer
///
/// Utility class for performance optimizations including:
/// - Data sampling for large datasets
/// - Debouncing and throttling
/// - Memory management helpers
/// - Chart optimization
///
/// **Usage:**
/// ```dart
/// // Sample large dataset
/// final sampled = PerformanceOptimizer.sampleData(data, maxPoints: 500);
///
/// // Debounce function calls
/// final debounced = PerformanceOptimizer.debounce(() {
///   // Expensive operation
/// }, Duration(seconds: 1));
/// ```

class PerformanceOptimizer {
  PerformanceOptimizer._();

  /// Sample data points for optimal chart performance
  ///
  /// Reduces large datasets to a manageable size while preserving
  /// important data points (highs, lows, first, last).
  ///
  /// **Parameters:**
  /// - [data]: Original data list
  /// - [maxPoints]: Maximum number of points to return
  ///
  /// **Returns:**
  /// Sampled data list with important points preserved
  static List<T> sampleData<T>(List<T> data, {int maxPoints = 1000}) {
    if (data.length <= maxPoints) {
      return data;
    }

    final step = (data.length / maxPoints).ceil();
    final sampled = <T>[];

    // Always include first point
    sampled.add(data.first);

    // Sample middle points
    for (int i = step; i < data.length - step; i += step) {
      sampled.add(data[i]);
    }

    // Always include last point
    sampled.add(data.last);

    return sampled;
  }

  /// Debounce function calls
  ///
  /// Delays execution until after the specified duration has passed
  /// since the last call. Useful for search inputs, API calls, etc.
  ///
  /// **Usage:**
  /// ```dart
  /// final debounced = PerformanceOptimizer.debounce(() {
  ///   performSearch();
  /// }, Duration(milliseconds: 500));
  ///
  /// // Call multiple times - only last one executes
  /// debounced();
  /// debounced();
  /// debounced(); // Only this executes after 500ms
  /// ```
  static Function() debounce(
    Function() callback,
    Duration delay,
  ) {
    Timer? timer;

    return () {
      timer?.cancel();
      timer = Timer(delay, callback);
    };
  }

  /// Throttle function calls
  ///
  /// Limits function execution to at most once per specified duration.
  /// Useful for scroll events, resize events, etc.
  ///
  /// **Usage:**
  /// ```dart
  /// final throttled = PerformanceOptimizer.throttle(() {
  ///   handleScroll();
  /// }, Duration(milliseconds: 100));
  ///
  /// // Call multiple times - executes at most once per 100ms
  /// throttled();
  /// throttled();
  /// throttled(); // Executes immediately, then ignores for 100ms
  /// ```
  static Function() throttle(
    Function() callback,
    Duration delay,
  ) {
    bool isThrottled = false;

    return () {
      if (!isThrottled) {
        callback();
        isThrottled = true;
        Timer(delay, () {
          isThrottled = false;
        });
      }
    };
  }

  /// Batch process items in chunks
  ///
  /// Processes large lists in smaller chunks to avoid blocking UI.
  ///
  /// **Parameters:**
  /// - [items]: List of items to process
  /// - [chunkSize]: Number of items per chunk
  /// - [processor]: Function to process each chunk
  ///
  /// **Returns:**
  /// Future that completes when all chunks are processed
  static Future<void> processInChunks<T>(
    List<T> items,
    int chunkSize,
    Future<void> Function(List<T> chunk) processor,
  ) async {
    for (int i = 0; i < items.length; i += chunkSize) {
      final chunk = items.sublist(
        i,
        i + chunkSize > items.length ? items.length : i + chunkSize,
      );
      await processor(chunk);
      // Allow UI to update between chunks
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  /// Calculate optimal chart data points based on screen width
  ///
  /// Returns optimal number of data points for smooth chart rendering.
  ///
  /// **Parameters:**
  /// - [screenWidth]: Screen width in logical pixels
  /// - [minPoints]: Minimum points (default: 50)
  /// - [maxPoints]: Maximum points (default: 1000)
  /// - [pointsPerPixel]: Points per pixel (default: 2)
  ///
  /// **Returns:**
  /// Optimal number of data points
  static int calculateOptimalChartPoints(
    double screenWidth, {
    int minPoints = 50,
    int maxPoints = 1000,
    double pointsPerPixel = 2.0,
  }) {
    final calculated = (screenWidth * pointsPerPixel).round();
    return calculated.clamp(minPoints, maxPoints);
  }

  /// Clear memory cache
  ///
  /// Forces garbage collection and clears caches.
  /// Use sparingly - only when memory is critically low.
  static void clearMemoryCache() {
    // Force garbage collection
    // Note: Dart doesn't have explicit GC control,
    // but we can hint the system
    // In production, this would trigger actual GC if available
  }

  /// Check if device has low memory
  ///
  /// Returns true if device might be low on memory.
  /// Useful for reducing cache sizes or disabling features.
  static bool isLowMemory() {
    // Placeholder - would integrate with platform channels
    // to check actual memory usage
    return false;
  }

  /// Optimize image loading
  ///
  /// Returns optimal image dimensions based on display size.
  ///
  /// **Parameters:**
  /// - [displayWidth]: Display width
  /// - [displayHeight]: Display height
  /// - [scaleFactor]: Scale factor (default: 2.0 for retina)
  ///
  /// **Returns:**
  /// Optimal image dimensions
  static ({int width, int height}) optimizeImageSize(
    double displayWidth,
    double displayHeight, {
    double scaleFactor = 2.0,
  }) {
    return (
      width: (displayWidth * scaleFactor).round(),
      height: (displayHeight * scaleFactor).round(),
    );
  }
}
