import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../core/utils/logger.dart';

/// 🌐 WebSocket Service for Real-time Market Updates
///
/// **Features:**
/// - ✅ Real-time gold price updates
/// - ✅ Auto-reconnection with exponential backoff
/// - ✅ Connection health monitoring
/// - ✅ Multiple data source support
/// - ✅ Event broadcasting to subscribers
/// - ✅ Bandwidth optimization
///
/// **Supported Data Sources:**
/// - Gold Price APIs (via WebSocket)
/// - Custom market data feeds
/// - News/Event streams
///
/// **Usage:**
/// ```dart
/// // Initialize
/// await WebSocketService.connect();
///
/// // Subscribe to price updates
/// WebSocketService.priceStream.listen((price) {
///   print('New price: \$${price.value}');
/// });
///
/// // Subscribe to market events
/// WebSocketService.eventStream.listen((event) {
///   print('Market event: ${event.type}');
/// });
/// ```
class WebSocketService {
  static WebSocketChannel? _channel;
  static Timer? _reconnectTimer;
  static Timer? _pingTimer;
  static Timer? _healthCheckTimer;

  // Connection state
  static ConnectionState _state = ConnectionState.disconnected;
  static DateTime? _lastMessageTime;
  static int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;

  // Reconnection delays (exponential backoff)
  static const List<Duration> _reconnectDelays = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 5),
    Duration(seconds: 10),
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 2),
    Duration(minutes: 5),
    Duration(minutes: 10),
    Duration(minutes: 30),
  ];

  // Stream controllers for broadcasting
  static final StreamController<GoldPrice> _priceController =
      StreamController<GoldPrice>.broadcast();

  static final StreamController<MarketEvent> _eventController =
      StreamController<MarketEvent>.broadcast();

  static final StreamController<ConnectionState> _stateController =
      StreamController<ConnectionState>.broadcast();

  // Public streams
  static Stream<GoldPrice> get priceStream => _priceController.stream;
  static Stream<MarketEvent> get eventStream => _eventController.stream;
  static Stream<ConnectionState> get stateStream => _stateController.stream;

  // Getters
  static ConnectionState get state => _state;
  static bool get isConnected => _state == ConnectionState.connected;
  static DateTime? get lastMessageTime => _lastMessageTime;

  /// Connect to WebSocket server
  ///
  /// **Parameters:**
  /// - [url]: WebSocket server URL (optional, uses default if not provided)
  /// - [autoReconnect]: Enable automatic reconnection on disconnect
  ///
  /// **Returns:** Future<bool> - true if connection successful
  static Future<bool> connect({
    String? url,
    bool autoReconnect = true,
  }) async {
    try {
      // Check if already connected
      if (_state == ConnectionState.connected) {
        AppLogger.warn('WebSocket already connected');
        return true;
      }

      _updateState(ConnectionState.connecting);

      // Use default URL if not provided
      final wsUrl = url ?? _getDefaultWebSocketUrl();

      AppLogger.info('Connecting to WebSocket: $wsUrl');

      // Create WebSocket connection
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Wait for connection confirmation (with timeout)
      await _channel!.ready.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('WebSocket connection timeout');
        },
      );

      _updateState(ConnectionState.connected);
      _reconnectAttempts = 0;
      _lastMessageTime = DateTime.now();

      AppLogger.success('WebSocket connected successfully');

      // Start listening to messages
      _listen();

      // Start ping/pong for keep-alive
      _startPingTimer();

      // Start health check
      _startHealthCheck();

      return true;
    } catch (e, stackTrace) {
      AppLogger.error('WebSocket connection failed', e, stackTrace);
      _updateState(ConnectionState.error);

      // Auto-reconnect if enabled
      if (autoReconnect) {
        _scheduleReconnect();
      }

      return false;
    }
  }

  /// Disconnect from WebSocket
  static Future<void> disconnect() async {
    AppLogger.info('Disconnecting WebSocket...');

    _stopTimers();

    try {
      await _channel?.sink.close(status.goingAway);
    } catch (e) {
      AppLogger.warn('Error closing WebSocket', e);
    }

    _channel = null;
    _updateState(ConnectionState.disconnected);

    AppLogger.success('WebSocket disconnected');
  }

  /// Listen to incoming messages
  static void _listen() {
    _channel?.stream.listen(
      (message) {
        _lastMessageTime = DateTime.now();
        _handleMessage(message);
      },
      onError: (error, stackTrace) {
        AppLogger.error('WebSocket stream error', error, stackTrace);
        _updateState(ConnectionState.error);
        _scheduleReconnect();
      },
      onDone: () {
        AppLogger.warn('WebSocket connection closed');
        _updateState(ConnectionState.disconnected);
        _scheduleReconnect();
      },
      cancelOnError: false,
    );
  }

  /// Handle incoming WebSocket message
  static void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String);
      final type = data['type'] as String?;

      switch (type) {
        case 'price':
          _handlePriceUpdate(data);
          break;

        case 'event':
          _handleMarketEvent(data);
          break;

        case 'pong':
          // Keep-alive response
          AppLogger.debug('Received pong');
          break;

        case 'error':
          AppLogger.error('WebSocket server error', data['message']);
          break;

        default:
          AppLogger.warn('Unknown message type: $type');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error parsing WebSocket message', e, stackTrace);
    }
  }

  /// Handle price update message
  static void _handlePriceUpdate(Map<String, dynamic> data) {
    try {
      final price = GoldPrice(
        value: (data['price'] as num).toDouble(),
        change: (data['change'] as num?)?.toDouble() ?? 0.0,
        changePercent: (data['changePercent'] as num?)?.toDouble() ?? 0.0,
        timestamp: DateTime.parse(data['timestamp'] as String),
        source: data['source'] as String? ?? 'websocket',
      );

      _priceController.add(price);
      AppLogger.debug(
          'Price update: \$${price.value} (${price.changePercent >= 0 ? '+' : ''}${price.changePercent.toStringAsFixed(2)}%)');
    } catch (e, stackTrace) {
      AppLogger.error('Error handling price update', e, stackTrace);
    }
  }

  /// Handle market event message
  static void _handleMarketEvent(Map<String, dynamic> data) {
    try {
      final event = MarketEvent(
        type: MarketEventType.values.firstWhere(
          (e) => e.name == data['eventType'],
          orElse: () => MarketEventType.other,
        ),
        title: data['title'] as String,
        description: data['description'] as String?,
        severity: MarketEventSeverity.values.firstWhere(
          (s) => s.name == data['severity'],
          orElse: () => MarketEventSeverity.low,
        ),
        timestamp: DateTime.parse(data['timestamp'] as String),
        source: data['source'] as String? ?? 'websocket',
      );

      _eventController.add(event);
      AppLogger.info(
          'Market event: ${event.title} [${event.severity.name.toUpperCase()}]');
    } catch (e, stackTrace) {
      AppLogger.error('Error handling market event', e, stackTrace);
    }
  }

  /// Send ping to keep connection alive
  static void _sendPing() {
    if (_state == ConnectionState.connected) {
      try {
        _channel?.sink.add(jsonEncode({'type': 'ping'}));
        AppLogger.debug('Sent ping');
      } catch (e) {
        AppLogger.error('Error sending ping', e);
      }
    }
  }

  /// Start ping timer (every 30 seconds)
  static void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _sendPing(),
    );
  }

  /// Start health check timer
  static void _startHealthCheck() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _checkHealth(),
    );
  }

  /// Check connection health
  static void _checkHealth() {
    if (_lastMessageTime == null) return;

    final timeSinceLastMessage = DateTime.now().difference(_lastMessageTime!);

    // If no message for 2 minutes, consider connection dead
    if (timeSinceLastMessage > const Duration(minutes: 2)) {
      AppLogger.warn(
          'No messages for ${timeSinceLastMessage.inSeconds}s - reconnecting...');
      _updateState(ConnectionState.error);
      _scheduleReconnect();
    }
  }

  /// Schedule reconnection with exponential backoff
  static void _scheduleReconnect() {
    if (_reconnectTimer != null && _reconnectTimer!.isActive) {
      return; // Already scheduled
    }

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      AppLogger.error('Max reconnection attempts reached', 'Giving up');
      _updateState(ConnectionState.failed);
      return;
    }

    final delayIndex = _reconnectAttempts.clamp(0, _reconnectDelays.length - 1);
    final delay = _reconnectDelays[delayIndex];

    _reconnectAttempts++;

    AppLogger.info(
        'Scheduling reconnect #$_reconnectAttempts in ${delay.inSeconds}s');

    _reconnectTimer = Timer(delay, () async {
      AppLogger.info('Attempting reconnection #$_reconnectAttempts...');
      await connect();
    });
  }

  /// Update connection state and notify subscribers
  static void _updateState(ConnectionState newState) {
    if (_state == newState) return;

    _state = newState;
    _stateController.add(newState);

    AppLogger.info('WebSocket state: ${newState.name}');
  }

  /// Stop all timers
  static void _stopTimers() {
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _healthCheckTimer?.cancel();

    _reconnectTimer = null;
    _pingTimer = null;
    _healthCheckTimer = null;
  }

  /// Get default WebSocket URL based on environment
  static String _getDefaultWebSocketUrl() {
    // In production, this would be your actual WebSocket server
    // For now, we'll use a mock endpoint
    return 'wss://api.goldprice.org/ws'; // Replace with actual endpoint
  }

  /// Subscribe to specific price pairs (optional filtering)
  static void subscribeToPair(String pair) {
    if (_state == ConnectionState.connected) {
      _channel?.sink.add(jsonEncode({
        'type': 'subscribe',
        'pair': pair,
      }));
      AppLogger.info('Subscribed to $pair');
    }
  }

  /// Unsubscribe from price pair
  static void unsubscribeFromPair(String pair) {
    if (_state == ConnectionState.connected) {
      _channel?.sink.add(jsonEncode({
        'type': 'unsubscribe',
        'pair': pair,
      }));
      AppLogger.info('Unsubscribed from $pair');
    }
  }

  /// Get connection metrics
  static Map<String, dynamic> getMetrics() {
    final uptime = _lastMessageTime != null
        ? DateTime.now().difference(_lastMessageTime!)
        : null;

    return {
      'state': _state.name,
      'is_connected': isConnected,
      'reconnect_attempts': _reconnectAttempts,
      'last_message_ago_seconds': uptime?.inSeconds,
      'price_subscribers': _priceController.hasListener ? 'yes' : 'no',
      'event_subscribers': _eventController.hasListener ? 'yes' : 'no',
    };
  }

  /// Print connection metrics
  static void printMetrics() {
    final metrics = getMetrics();
    AppLogger.info('═══ WEBSOCKET METRICS ═══');
    AppLogger.info('State: ${metrics['state']}');
    AppLogger.info('Connected: ${metrics['is_connected']}');
    AppLogger.info('Reconnect Attempts: ${metrics['reconnect_attempts']}');
    AppLogger.info(
        'Last Message: ${metrics['last_message_ago_seconds'] ?? 'N/A'}s ago');
    AppLogger.info('═════════════════════════');
  }

  /// Dispose all resources
  static Future<void> dispose() async {
    await disconnect();
    await _priceController.close();
    await _eventController.close();
    await _stateController.close();
    AppLogger.info('WebSocket service disposed');
  }
}

// ══════════════════════════════════════════════════════════
// MODELS
// ══════════════════════════════════════════════════════════

/// Connection state
enum ConnectionState {
  disconnected,
  connecting,
  connected,
  error,
  failed;

  String get nameAr {
    switch (this) {
      case ConnectionState.disconnected:
        return 'غير متصل';
      case ConnectionState.connecting:
        return 'جاري الاتصال...';
      case ConnectionState.connected:
        return 'متصل';
      case ConnectionState.error:
        return 'خطأ';
      case ConnectionState.failed:
        return 'فشل الاتصال';
    }
  }
}

/// Gold price update
class GoldPrice {
  final double value;
  final double change;
  final double changePercent;
  final DateTime timestamp;
  final String source;

  GoldPrice({
    required this.value,
    required this.change,
    required this.changePercent,
    required this.timestamp,
    required this.source,
  });

  bool get isPositive => change >= 0;

  String get formattedPrice => '\$${value.toStringAsFixed(2)}';

  String get formattedChange =>
      '${isPositive ? '+' : ''}${change.toStringAsFixed(2)} (${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%)';
}

/// Market event types
enum MarketEventType {
  newsRelease,
  economicData,
  centralBankDecision,
  geopolitical,
  technicalBreakout,
  volumeSpike,
  other;

  String get nameAr {
    switch (this) {
      case MarketEventType.newsRelease:
        return 'خبر عاجل';
      case MarketEventType.economicData:
        return 'بيانات اقتصادية';
      case MarketEventType.centralBankDecision:
        return 'قرار بنك مركزي';
      case MarketEventType.geopolitical:
        return 'حدث جيوسياسي';
      case MarketEventType.technicalBreakout:
        return 'اختراق فني';
      case MarketEventType.volumeSpike:
        return 'قفزة حجم';
      case MarketEventType.other:
        return 'أخرى';
    }
  }
}

/// Market event severity
enum MarketEventSeverity {
  low,
  medium,
  high,
  critical;

  String get nameAr {
    switch (this) {
      case MarketEventSeverity.low:
        return 'منخفض';
      case MarketEventSeverity.medium:
        return 'متوسط';
      case MarketEventSeverity.high:
        return 'عالي';
      case MarketEventSeverity.critical:
        return 'حرج';
    }
  }

  String get emoji {
    switch (this) {
      case MarketEventSeverity.low:
        return 'ℹ️';
      case MarketEventSeverity.medium:
        return '⚠️';
      case MarketEventSeverity.high:
        return '🔴';
      case MarketEventSeverity.critical:
        return '🚨';
    }
  }
}

/// Market event
class MarketEvent {
  final MarketEventType type;
  final String title;
  final String? description;
  final MarketEventSeverity severity;
  final DateTime timestamp;
  final String source;

  MarketEvent({
    required this.type,
    required this.title,
    this.description,
    required this.severity,
    required this.timestamp,
    required this.source,
  });

  String get formattedTimestamp {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }
}
