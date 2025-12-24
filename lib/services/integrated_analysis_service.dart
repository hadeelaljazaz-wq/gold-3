import 'dart:async';
import '../core/utils/logger.dart';
import '../models/recommendation.dart';
import '../models/market_models.dart' hide GoldPrice;
import 'anthropic_service.dart' hide MarketCondition;
import 'websocket_service.dart';
import 'ml_strategy_selector.dart' as ml;

/// 🎯 Integrated Analysis Service
///
/// Combines WebSocket real-time updates, ML strategy selection, and
/// Anthropic AI analysis into a unified, intelligent trading system.
///
/// **Features:**
/// - ✅ Real-time price monitoring via WebSocket
/// - ✅ ML-powered strategy selection
/// - ✅ Adaptive AI analysis
/// - ✅ Event-driven analysis triggers
/// - ✅ Performance tracking & learning
/// - ✅ Multi-source data fusion
///
/// **Architecture:**
/// ```
/// WebSocket → Price Updates → Trigger Analysis
///     ↓
/// ML Selector → Choose Strategy → Anthropic AI → Analysis
///     ↓
/// Feedback Loop → Update ML Model
/// ```
///
/// **Usage:**
/// ```dart
/// // Initialize
/// await IntegratedAnalysisService.initialize();
///
/// // Listen to analyses
/// IntegratedAnalysisService.analysisStream.listen((analysis) {
///   print('New analysis: ${analysis.text}');
/// });
///
/// // Manual analysis
/// final analysis = await IntegratedAnalysisService.performAnalysis(...);
/// ```
class IntegratedAnalysisService {
  // ══════════════════════════════════════════════════════════
  // STATE & SUBSCRIPTIONS
  // ══════════════════════════════════════════════════════════

  static bool _isInitialized = false;
  static StreamSubscription<GoldPrice>? _priceSubscription;
  static StreamSubscription<MarketEvent>? _eventSubscription;

  // Latest market data
  static GoldPrice? _latestPrice;
  static final List<MarketEvent> _recentEvents = [];
  static const int _maxRecentEvents = 10;

  // Analysis triggers
  static DateTime? _lastAnalysisTime;
  static const Duration _minAnalysisInterval = Duration(minutes: 2);
  static double? _lastAnalyzedPrice;
  static const double _priceChangeThreshold =
      5.0; // $5 change triggers analysis

  // Stream controllers
  static final StreamController<SmartAnalysis> _analysisController =
      StreamController<SmartAnalysis>.broadcast();

  static final StreamController<AnalysisTrigger> _triggerController =
      StreamController<AnalysisTrigger>.broadcast();

  // Public streams
  static Stream<SmartAnalysis> get analysisStream => _analysisController.stream;
  static Stream<AnalysisTrigger> get triggerStream => _triggerController.stream;

  // Getters
  static bool get isInitialized => _isInitialized;
  static GoldPrice? get latestPrice => _latestPrice;
  static List<MarketEvent> get recentEvents => List.unmodifiable(_recentEvents);

  // ══════════════════════════════════════════════════════════
  // INITIALIZATION
  // ══════════════════════════════════════════════════════════

  /// Initialize the integrated service
  ///
  /// **Steps:**
  /// 1. Connect to WebSocket for real-time data
  /// 2. Subscribe to price and event streams
  /// 3. Set up analysis triggers
  ///
  /// **Parameters:**
  /// - [enableAutoAnalysis]: Auto-trigger analysis on significant events
  /// - [wsUrl]: Custom WebSocket URL (optional)
  static Future<void> initialize({
    bool enableAutoAnalysis = true,
    String? wsUrl,
  }) async {
    if (_isInitialized) {
      AppLogger.warn('IntegratedAnalysisService already initialized');
      return;
    }

    AppLogger.info('Initializing IntegratedAnalysisService...');

    try {
      // Connect to WebSocket
      final wsConnected = await WebSocketService.connect(url: wsUrl);

      if (!wsConnected) {
        AppLogger.warn(
            'WebSocket connection failed - continuing without real-time data');
      }

      // Subscribe to price updates
      _priceSubscription = WebSocketService.priceStream.listen(
        _handlePriceUpdate,
        onError: (error) {
          AppLogger.error('Price stream error', error);
        },
      );

      // Subscribe to market events
      _eventSubscription = WebSocketService.eventStream.listen(
        _handleMarketEvent,
        onError: (error) {
          AppLogger.error('Event stream error', error);
        },
      );

      // Subscribe to XAUUSD if WebSocket supports it
      if (wsConnected) {
        WebSocketService.subscribeToPair('XAUUSD');
      }

      _isInitialized = true;
      AppLogger.success('IntegratedAnalysisService initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Failed to initialize IntegratedAnalysisService', e, stackTrace);
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════
  // SMART ANALYSIS (ML + AI Combined)
  // ══════════════════════════════════════════════════════════

  /// Perform smart analysis using ML strategy selection + AI
  ///
  /// **Algorithm:**
  /// 1. ML selects optimal strategy based on market conditions
  /// 2. Anthropic AI generates analysis using selected strategy
  /// 3. Response quality is validated
  /// 4. Feedback is recorded to improve ML model
  ///
  /// **Parameters:**
  /// - [scalp]: Scalping recommendation
  /// - [swing]: Swing trading recommendation
  /// - [indicators]: Technical indicators
  /// - [currentPrice]: Current gold price
  /// - [forceStrategy]: Force specific strategy (testing)
  /// - [useStreaming]: Use streaming response for real-time updates
  ///
  /// **Returns:** SmartAnalysis object with text, strategy, and metadata
  static Future<SmartAnalysis> performAnalysis({
    required Recommendation scalp,
    required Recommendation swing,
    required TechnicalIndicators indicators,
    required double currentPrice,
    String? forceStrategy,
    bool useStreaming = false,
  }) async {
    final startTime = DateTime.now();
    AppLogger.info('═══ SMART ANALYSIS START ═══');

    try {
      // STEP 1: Detect market condition first
      final mlMarketCondition =
          _detectMarketCondition(indicators, scalp, swing);

      // STEP 2: ML Strategy Selection
      final strategy = ml.MLStrategySelector.selectStrategy(
        indicators: indicators,
        scalp: scalp,
        swing: swing,
        marketCondition: mlMarketCondition,
        forceStrategy: forceStrategy,
      );

      AppLogger.info('ML selected strategy: ${strategy.name}');

      // STEP 2: Detect market condition (used for logging/future features)
      // final marketCondition = _detectMarketCondition(indicators, scalp, swing);

      // STEP 3: Include recent events if any
      final relevantEvents = _getRelevantEvents();

      // STEP 4: Get AI Analysis
      String analysisText;

      if (useStreaming) {
        // Streaming mode - collect all chunks
        final chunks = <String>[];
        await for (final chunk in AnthropicServicePro.streamAnalysis(
          scalp: scalp,
          swing: swing,
          indicators: indicators,
          currentPrice: currentPrice,
          marketCondition: null, // Will be detected internally
        )) {
          chunks.add(chunk);
        }
        analysisText = chunks.join();
      } else {
        // Standard mode
        analysisText = await AnthropicServicePro.getAnalysis(
          scalp: scalp,
          swing: swing,
          indicators: indicators,
          currentPrice: currentPrice,
          marketCondition: null, // Will be detected internally
        );
      }

      // STEP 5: Calculate quality score
      final qualityScore = _evaluateAnalysisQuality(analysisText);

      // STEP 6: Calculate response time
      final responseTime = DateTime.now().difference(startTime).inMilliseconds;

      // STEP 7: Auto-feedback to ML model
      ml.MLStrategySelector.recordAutoFeedback(
        strategyId: strategy.id,
        qualityScore: qualityScore,
        responseTime: responseTime.toDouble(),
      );

      // STEP 8: Create SmartAnalysis object
      final analysis = SmartAnalysis(
        text: analysisText,
        strategy: strategy,
        marketCondition: mlMarketCondition,
        qualityScore: qualityScore,
        responseTimeMs: responseTime,
        currentPrice: currentPrice,
        scalp: scalp,
        swing: swing,
        indicators: indicators,
        relevantEvents: relevantEvents,
        timestamp: DateTime.now(),
      );

      // STEP 9: Broadcast to stream
      _analysisController.add(analysis);

      AppLogger.success(
          'Smart analysis complete - Quality: ${qualityScore.toStringAsFixed(1)}/10, Time: ${responseTime}ms');
      AppLogger.info('═══ SMART ANALYSIS END ═══');

      return analysis;
    } catch (e, stackTrace) {
      AppLogger.error('Smart analysis failed', e, stackTrace);
      rethrow;
    }
  }

  /// Perform streaming smart analysis
  ///
  /// Returns a stream of SmartAnalysisChunk objects as analysis progresses
  static Stream<SmartAnalysisChunk> streamSmartAnalysis({
    required Recommendation scalp,
    required Recommendation swing,
    required TechnicalIndicators indicators,
    required double currentPrice,
    String? forceStrategy,
  }) async* {
    final startTime = DateTime.now();

    // Select strategy
    final strategy = ml.MLStrategySelector.selectStrategy(
      indicators: indicators,
      scalp: scalp,
      swing: swing,
      forceStrategy: forceStrategy,
    );

    yield SmartAnalysisChunk(
      type: ChunkType.metadata,
      data: {
        'strategy': strategy.name,
        'strategy_id': strategy.id,
      },
    );

    // Stream AI analysis
    String fullText = '';
    await for (final chunk in AnthropicServicePro.streamAnalysis(
      scalp: scalp,
      swing: swing,
      indicators: indicators,
      currentPrice: currentPrice,
      marketCondition: null, // Will be detected internally
    )) {
      fullText += chunk;
      yield SmartAnalysisChunk(
        type: ChunkType.text,
        data: {'chunk': chunk, 'fullText': fullText},
      );
    }

    // Final quality evaluation
    final qualityScore = _evaluateAnalysisQuality(fullText);
    final responseTime = DateTime.now().difference(startTime).inMilliseconds;

    yield SmartAnalysisChunk(
      type: ChunkType.complete,
      data: {
        'quality_score': qualityScore,
        'response_time_ms': responseTime,
      },
    );

    // Auto-feedback
    ml.MLStrategySelector.recordAutoFeedback(
      strategyId: strategy.id,
      qualityScore: qualityScore,
      responseTime: responseTime.toDouble(),
    );
  }

  // ══════════════════════════════════════════════════════════
  // EVENT HANDLERS
  // ══════════════════════════════════════════════════════════

  /// Handle real-time price update
  static void _handlePriceUpdate(GoldPrice price) {
    _latestPrice = price;
    AppLogger.debug(
        'Price update: ${price.formattedPrice} (${price.formattedChange})');

    // Check if price change is significant
    if (_shouldTriggerAnalysis(price)) {
      _triggerController.add(AnalysisTrigger(
        type: TriggerType.priceChange,
        reason:
            'Price changed by \$${(price.value - (_lastAnalyzedPrice ?? price.value)).abs().toStringAsFixed(2)}',
        price: price,
      ));
    }
  }

  /// Handle market event
  static void _handleMarketEvent(MarketEvent event) {
    // Add to recent events
    _recentEvents.insert(0, event);
    if (_recentEvents.length > _maxRecentEvents) {
      _recentEvents.removeLast();
    }

    AppLogger.info('Market event: ${event.title} [${event.severity.emoji}]');

    // Trigger analysis for high/critical severity events
    if (event.severity.index >= MarketEventSeverity.high.index) {
      _triggerController.add(AnalysisTrigger(
        type: TriggerType.marketEvent,
        reason: event.title,
        event: event,
      ));
    }
  }

  // ══════════════════════════════════════════════════════════
  // ANALYSIS TRIGGERS
  // ══════════════════════════════════════════════════════════

  /// Check if analysis should be triggered based on price change
  static bool _shouldTriggerAnalysis(GoldPrice price) {
    // Check time-based throttle
    if (_lastAnalysisTime != null) {
      final timeSince = DateTime.now().difference(_lastAnalysisTime!);
      if (timeSince < _minAnalysisInterval) {
        return false; // Too soon
      }
    }

    // Check price change threshold
    if (_lastAnalyzedPrice != null) {
      final priceChange = (price.value - _lastAnalyzedPrice!).abs();
      if (priceChange < _priceChangeThreshold) {
        return false; // Price hasn't moved enough
      }
    }

    return true;
  }

  /// Mark that analysis was performed (for throttling)
  static void markAnalysisPerformed(double price) {
    _lastAnalysisTime = DateTime.now();
    _lastAnalyzedPrice = price;
  }

  // ══════════════════════════════════════════════════════════
  // HELPER METHODS
  // ══════════════════════════════════════════════════════════

  /// Detect market condition
  static ml.MarketCondition _detectMarketCondition(
    TechnicalIndicators indicators,
    Recommendation scalp,
    Recommendation swing,
  ) {
    if (scalp.direction == swing.direction &&
        scalp.confidence.index >= 2 &&
        swing.confidence.index >= 2) {
      return ml.MarketCondition.strongTrend;
    }

    if ((indicators.rsi > 70 || indicators.rsi < 30) &&
        scalp.direction != swing.direction) {
      return ml.MarketCondition.volatile;
    }

    if (indicators.rsi > 45 &&
        indicators.rsi < 55 &&
        scalp.direction != swing.direction) {
      return ml.MarketCondition.ranging;
    }

    if (scalp.confidence.index < 2 && swing.confidence.index < 2) {
      return ml.MarketCondition.consolidation;
    }

    return ml.MarketCondition.uncertain;
  }

  /// Get relevant recent events
  static List<MarketEvent> _getRelevantEvents() {
    final now = DateTime.now();
    return _recentEvents.where((event) {
      final age = now.difference(event.timestamp);
      return age.inHours < 24; // Events from last 24 hours
    }).toList();
  }

  /// Evaluate analysis quality (0-10 scale)
  static double _evaluateAnalysisQuality(String analysisText) {
    double score = 10.0;

    // Length check
    if (analysisText.length < 200) score -= 3.0;
    if (analysisText.length < 100) score -= 3.0;

    // Key elements check
    if (!analysisText.contains(RegExp(r'شراء|بيع'))) score -= 2.0;
    if (!analysisText.contains(RegExp(r'وقف|إيقاف'))) score -= 1.5;
    if (!analysisText.contains(RegExp(r'هدف|ربح'))) score -= 1.5;
    if (!analysisText.contains(RegExp(r'\$|\d+\.\d{2}'))) score -= 1.0;

    // Structure indicators
    final hasStructure = analysisText.contains(RegExp(r'\*\*|##|•|─'));
    if (!hasStructure) score -= 1.0;

    // Bonus for comprehensiveness
    if (analysisText.length > 800) score += 0.5;
    if (analysisText.contains('RSI') && analysisText.contains('MACD'))
      score += 0.5;

    return score.clamp(0.0, 10.0);
  }

  // ══════════════════════════════════════════════════════════
  // USER FEEDBACK
  // ══════════════════════════════════════════════════════════

  /// Record user feedback for an analysis
  ///
  /// **Parameters:**
  /// - [analysisId]: ID of the analysis (use timestamp or custom ID)
  /// - [strategyId]: Strategy that was used
  /// - [wasHelpful]: Was the analysis helpful?
  /// - [rating]: Optional 1-5 star rating
  /// - [profitLoss]: Optional P/L if user traded based on this
  static void recordUserFeedback({
    required String strategyId,
    required bool wasHelpful,
    double? rating,
    double? profitLoss,
  }) {
    ml.MLStrategySelector.recordFeedback(
      strategyId: strategyId,
      wasSuccessful: wasHelpful,
      userRating: rating,
      profitLoss: profitLoss,
    );

    AppLogger.info('User feedback recorded: ${wasHelpful ? '👍' : '👎'}');
  }

  // ══════════════════════════════════════════════════════════
  // ANALYTICS & MONITORING
  // ══════════════════════════════════════════════════════════

  /// Get comprehensive system metrics
  static Map<String, dynamic> getSystemMetrics() {
    return {
      'websocket': WebSocketService.getMetrics(),
      'anthropic': AnthropicServicePro.getMetrics(),
      'ml_strategies': ml.MLStrategySelector.getPerformanceStats(),
      'integrated': {
        'is_initialized': _isInitialized,
        'latest_price': _latestPrice?.formattedPrice ?? 'N/A',
        'recent_events_count': _recentEvents.length,
        'last_analysis_time': _lastAnalysisTime?.toIso8601String() ?? 'N/A',
        'analysis_subscribers': _analysisController.hasListener,
        'trigger_subscribers': _triggerController.hasListener,
      },
    };
  }

  /// Print comprehensive system report
  static void printSystemReport() {
    AppLogger.info('');
    AppLogger.info('═══════════════════════════════════════════════════════');
    AppLogger.info('🎯 INTEGRATED ANALYSIS SYSTEM REPORT');
    AppLogger.info('═══════════════════════════════════════════════════════');
    AppLogger.info('');

    // WebSocket metrics
    WebSocketService.printMetrics();
    AppLogger.info('');

    // Anthropic metrics
    AnthropicServicePro.printMetrics();
    AppLogger.info('');

    // ML strategies
    ml.MLStrategySelector.printPerformanceReport();
    AppLogger.info('');

    // Integrated service status
    AppLogger.info('═══ INTEGRATED SERVICE STATUS ═══');
    AppLogger.info('Initialized: $_isInitialized');
    AppLogger.info('Latest Price: ${_latestPrice?.formattedPrice ?? 'N/A'}');
    AppLogger.info('Recent Events: ${_recentEvents.length}');
    AppLogger.info('Last Analysis: ${_lastAnalysisTime ?? 'Never'}');
    AppLogger.info('═══════════════════════════════════');
    AppLogger.info('');
  }

  // ══════════════════════════════════════════════════════════
  // CLEANUP
  // ══════════════════════════════════════════════════════════

  /// Shutdown the service and cleanup resources
  static Future<void> shutdown() async {
    AppLogger.info('Shutting down IntegratedAnalysisService...');

    await _priceSubscription?.cancel();
    await _eventSubscription?.cancel();

    await WebSocketService.disconnect();
    await _analysisController.close();
    await _triggerController.close();

    _isInitialized = false;
    _latestPrice = null;
    _recentEvents.clear();
    _lastAnalysisTime = null;
    _lastAnalyzedPrice = null;

    AppLogger.success('IntegratedAnalysisService shutdown complete');
  }

  /// Reset all services (for testing)
  static Future<void> resetAll() async {
    await shutdown();
    AnthropicServicePro.resetAll();
    ml.MLStrategySelector.resetLearning();
    AppLogger.info('All services reset');
  }
}

// ══════════════════════════════════════════════════════════
// MODELS
// ══════════════════════════════════════════════════════════

/// Smart analysis result with metadata
class SmartAnalysis {
  final String text;
  final ml.AnalysisStrategy strategy;
  final ml.MarketCondition marketCondition;
  final double qualityScore;
  final int responseTimeMs;
  final double currentPrice;
  final Recommendation scalp;
  final Recommendation swing;
  final TechnicalIndicators indicators;
  final List<MarketEvent> relevantEvents;
  final DateTime timestamp;

  SmartAnalysis({
    required this.text,
    required this.strategy,
    required this.marketCondition,
    required this.qualityScore,
    required this.responseTimeMs,
    required this.currentPrice,
    required this.scalp,
    required this.swing,
    required this.indicators,
    required this.relevantEvents,
    required this.timestamp,
  });

  String get formattedQuality => '${qualityScore.toStringAsFixed(1)}/10';
  String get formattedResponseTime => '${responseTimeMs}ms';

  bool get isHighQuality => qualityScore >= 8.0;
  bool get isFastResponse => responseTimeMs < 2000;
}

/// Analysis trigger event
class AnalysisTrigger {
  final TriggerType type;
  final String reason;
  final GoldPrice? price;
  final MarketEvent? event;
  final DateTime timestamp;

  AnalysisTrigger({
    required this.type,
    required this.reason,
    this.price,
    this.event,
  }) : timestamp = DateTime.now();
}

/// Trigger types
enum TriggerType {
  priceChange,
  marketEvent,
  manual,
  scheduled;

  String get nameAr {
    switch (this) {
      case TriggerType.priceChange:
        return 'تغير السعر';
      case TriggerType.marketEvent:
        return 'حدث سوقي';
      case TriggerType.manual:
        return 'يدوي';
      case TriggerType.scheduled:
        return 'مجدول';
    }
  }
}

/// Streaming analysis chunk
class SmartAnalysisChunk {
  final ChunkType type;
  final Map<String, dynamic> data;

  SmartAnalysisChunk({
    required this.type,
    required this.data,
  });
}

/// Chunk types for streaming
enum ChunkType {
  metadata,
  text,
  complete;
}
