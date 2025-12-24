/// 📊 Performance Metrics
///
/// System for tracking and analyzing application performance metrics.
/// Provides insights into app performance, API calls, and user interactions.
///
/// **Usage:**
/// ```dart
/// // Track API call duration
/// final stopwatch = PerformanceMetrics.startTimer('api_call');
/// await makeApiCall();
/// PerformanceMetrics.endTimer('api_call', stopwatch);
///
/// // Get metrics
/// final metrics = PerformanceMetrics.getMetrics();
/// ```

import '../utils/logger.dart';

class PerformanceMetrics {
  PerformanceMetrics._();

  static final Map<String, _Metric> _metrics = {};
  static final List<_TimingEvent> _timingEvents = [];

  /// Start a performance timer
  ///
  /// Starts tracking time for a specific operation.
  ///
  /// **Parameters:**
  /// - [name]: Metric name
  ///
  /// **Returns:**
  /// Stopwatch instance
  static Stopwatch startTimer(String name) {
    final stopwatch = Stopwatch()..start();
    AppLogger.debug('Started timer: $name');
    return stopwatch;
  }

  /// End a performance timer
  ///
  /// Stops tracking time and records the duration.
  ///
  /// **Parameters:**
  /// - [name]: Metric name
  /// - [stopwatch]: Stopwatch instance from startTimer
  static void endTimer(String name, Stopwatch stopwatch) {
    stopwatch.stop();
    final duration = stopwatch.elapsedMilliseconds;

    _recordTiming(name, duration);
    AppLogger.debug('Ended timer: $name (${duration}ms)');
  }

  /// Record a timing event
  ///
  /// Records a timing measurement directly.
  ///
  /// **Parameters:**
  /// - [name]: Metric name
  /// - [durationMs]: Duration in milliseconds
  static void recordTiming(String name, int durationMs) {
    _recordTiming(name, durationMs);
  }

  /// Record a counter metric
  ///
  /// Increments a counter metric.
  ///
  /// **Parameters:**
  /// - [name]: Metric name
  /// - [value]: Value to add (default: 1)
  static void incrementCounter(String name, {int value = 1}) {
    final metric = _metrics[name] ?? _Metric(counter: 0, timings: []);
    _metrics[name] = _Metric(
      counter: metric.counter + value,
      timings: metric.timings,
    );
    AppLogger.debug('Incremented counter: $name (+$value)');
  }

  /// Record a gauge metric
  ///
  /// Records a current value (e.g., memory usage, cache size).
  ///
  /// **Parameters:**
  /// - [name]: Metric name
  /// - [value]: Current value
  static void recordGauge(String name, double value) {
    final metric = _metrics[name] ?? _Metric(counter: 0, timings: []);
    _metrics[name] = _Metric(
      counter: metric.counter,
      timings: metric.timings,
      gauge: value,
    );
    AppLogger.debug('Recorded gauge: $name = $value');
  }

  /// Get all metrics
  ///
  /// **Returns:**
  /// Map with all recorded metrics
  static Map<String, dynamic> getMetrics() {
    final result = <String, dynamic>{};

    for (final entry in _metrics.entries) {
      final metric = entry.value;
      result[entry.key] = {
        'counter': metric.counter,
        'avgTiming': metric.avgTiming,
        'minTiming': metric.minTiming,
        'maxTiming': metric.maxTiming,
        'timingCount': metric.timings.length,
        'gauge': metric.gauge,
      };
    }

    return result;
  }

  /// Get metric summary
  ///
  /// Returns a summary of all metrics.
  ///
  /// **Returns:**
  /// Formatted metric summary
  static String getSummary() {
    final buffer = StringBuffer();
    buffer.writeln('📊 Performance Metrics Summary');
    buffer.writeln('=' * 50);

    for (final entry in _metrics.entries) {
      final metric = entry.value;
      buffer.writeln('\n${entry.key}:');
      buffer.writeln('  Counter: ${metric.counter}');
      if (metric.timings.isNotEmpty) {
        buffer.writeln('  Avg Timing: ${metric.avgTiming}ms');
        buffer.writeln('  Min Timing: ${metric.minTiming}ms');
        buffer.writeln('  Max Timing: ${metric.maxTiming}ms');
        buffer.writeln('  Timing Count: ${metric.timings.length}');
      }
      if (metric.gauge != null) {
        buffer.writeln('  Gauge: ${metric.gauge}');
      }
    }

    return buffer.toString();
  }

  /// Clear all metrics
  ///
  /// Removes all recorded metrics.
  static void clear() {
    _metrics.clear();
    _timingEvents.clear();
    AppLogger.info('Cleared all performance metrics');
  }

  /// Record timing internally
  static void _recordTiming(String name, int durationMs) {
    final metric = _metrics[name] ?? _Metric(counter: 0, timings: []);
    final timings = [...metric.timings, durationMs];
    _metrics[name] = _Metric(counter: metric.counter, timings: timings);

    _timingEvents.add(_TimingEvent(
      name: name,
      durationMs: durationMs,
      timestamp: DateTime.now(),
    ));

    // Keep only last 1000 events
    if (_timingEvents.length > 1000) {
      _timingEvents.removeAt(0);
    }
  }
}

/// Metric data structure
class _Metric {
  final int counter;
  final List<int> timings;
  final double? gauge;

  _Metric({
    required this.counter,
    required this.timings,
    this.gauge,
  });

  double get avgTiming {
    if (timings.isEmpty) return 0;
    return timings.reduce((a, b) => a + b) / timings.length;
  }

  int get minTiming {
    if (timings.isEmpty) return 0;
    return timings.reduce((a, b) => a < b ? a : b);
  }

  int get maxTiming {
    if (timings.isEmpty) return 0;
    return timings.reduce((a, b) => a > b ? a : b);
  }
}

/// Timing event
class _TimingEvent {
  final String name;
  final int durationMs;
  final DateTime timestamp;

  _TimingEvent({
    required this.name,
    required this.durationMs,
    required this.timestamp,
  });
}
