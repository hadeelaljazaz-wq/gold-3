/// 📈 Analytics Helper
///
/// Utility class for tracking user behavior and app analytics.
/// Provides event tracking, user properties, and screen tracking.
///
/// **Usage:**
/// ```dart
/// // Track screen view
/// AnalyticsHelper.trackScreenView('home_screen');
///
/// // Track event
/// AnalyticsHelper.trackEvent('button_click', {'button': 'refresh'});
///
/// // Set user property
/// AnalyticsHelper.setUserProperty('subscription_tier', 'pro');
/// ```

import '../utils/logger.dart';
import '../config/environment_config.dart';

class AnalyticsHelper {
  AnalyticsHelper._();

  static final Map<String, dynamic> _userProperties = {};
  static final List<_AnalyticsEvent> _events = [];

  /// Track screen view
  ///
  /// Records when a user views a screen.
  ///
  /// **Parameters:**
  /// - [screenName]: Name of the screen
  /// - [parameters]: Additional parameters (optional)
  static void trackScreenView(
    String screenName, {
    Map<String, dynamic>? parameters,
  }) {
    if (!EnvironmentConfig.enableAnalytics) {
      return;
    }

    final event = _AnalyticsEvent(
      name: 'screen_view',
      parameters: {
        'screen_name': screenName,
        ...?parameters,
      },
      timestamp: DateTime.now(),
    );

    _events.add(event);
    AppLogger.debug('Tracked screen view: $screenName');

    // TODO: Send to analytics service (Firebase Analytics, etc.)
    // if (EnvironmentConfig.enableAnalytics) {
    //   FirebaseAnalytics.instance.logScreenView(screenName: screenName);
    // }
  }

  /// Track custom event
  ///
  /// Records a custom event with optional parameters.
  ///
  /// **Parameters:**
  /// - [eventName]: Name of the event
  /// - [parameters]: Event parameters (optional)
  static void trackEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) {
    if (!EnvironmentConfig.enableAnalytics) {
      return;
    }

    final event = _AnalyticsEvent(
      name: eventName,
      parameters: parameters ?? {},
      timestamp: DateTime.now(),
    );

    _events.add(event);
    AppLogger.debug('Tracked event: $eventName');

    // TODO: Send to analytics service
    // if (EnvironmentConfig.enableAnalytics) {
    //   FirebaseAnalytics.instance.logEvent(
    //     name: eventName,
    //     parameters: parameters,
    //   );
    // }
  }

  /// Set user property
  ///
  /// Sets a user property for analytics.
  ///
  /// **Parameters:**
  /// - [property]: Property name
  /// - [value]: Property value
  static void setUserProperty(String property, dynamic value) {
    if (!EnvironmentConfig.enableAnalytics) {
      return;
    }

    _userProperties[property] = value;
    AppLogger.debug('Set user property: $property = $value');

    // TODO: Send to analytics service
    // if (EnvironmentConfig.enableAnalytics) {
    //   FirebaseAnalytics.instance.setUserProperty(
    //     name: property,
    //     value: value.toString(),
    //   );
    // }
  }

  /// Track analysis generation
  ///
  /// Tracks when an analysis is generated.
  ///
  /// **Parameters:**
  /// - [engine]: Engine name (e.g., 'golden_nightmare')
  /// - [durationMs]: Duration in milliseconds
  /// - [success]: Whether analysis was successful
  static void trackAnalysisGeneration(
    String engine,
    int durationMs, {
    bool success = true,
  }) {
    trackEvent(
      'analysis_generated',
      parameters: {
        'engine': engine,
        'duration_ms': durationMs,
        'success': success,
      },
    );
  }

  /// Track API call
  ///
  /// Tracks API call performance.
  ///
  /// **Parameters:**
  /// - [endpoint]: API endpoint
  /// - [durationMs]: Duration in milliseconds
  /// - [success]: Whether call was successful
  static void trackApiCall(
    String endpoint,
    int durationMs, {
    bool success = true,
  }) {
    trackEvent(
      'api_call',
      parameters: {
        'endpoint': endpoint,
        'duration_ms': durationMs,
        'success': success,
      },
    );
  }

  /// Track error
  ///
  /// Tracks application errors.
  ///
  /// **Parameters:**
  /// - [error]: Error message
  /// - [context]: Error context
  static void trackError(String error, {String? context}) {
    trackEvent(
      'error',
      parameters: {
        'error': error,
        'context': context ?? 'unknown',
      },
    );
  }

  /// Get analytics events
  ///
  /// **Returns:**
  /// List of analytics events
  static List<_AnalyticsEvent> getEvents() {
    return List.unmodifiable(_events);
  }

  /// Get user properties
  ///
  /// **Returns:**
  /// Map of user properties
  static Map<String, dynamic> getUserProperties() {
    return Map.unmodifiable(_userProperties);
  }

  /// Clear all analytics data
  ///
  /// Removes all events and user properties.
  static void clear() {
    _events.clear();
    _userProperties.clear();
    AppLogger.info('Cleared all analytics data');
  }
}

/// Analytics event
class _AnalyticsEvent {
  final String name;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;

  _AnalyticsEvent({
    required this.name,
    required this.parameters,
    required this.timestamp,
  });
}
