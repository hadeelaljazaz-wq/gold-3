import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/logger.dart';
import '../../../core/config/environment_config.dart';
import '../../../services/gold_price_service.dart';
import '../../../services/candle_generator.dart';
import '../../../services/engines/scalping_engine_v2.dart';
import '../../../services/engines/swing_engine_v2.dart';
import '../../../services/golden_nightmare/golden_nightmare_engine.dart';
import '../../../services/technical_indicators_service.dart';
import '../../../models/scalping_signal.dart';
import '../../../models/swing_signal.dart';
import '../../../models/market_models.dart';
import '../models/scalping_signal_model.dart';
import '../models/market_metrics_model.dart';
import '../../settings/providers/settings_provider.dart';
// Added for data validation, confidence calibration and telemetry
import '../../../core/utils/data_validation.dart';
import '../../../services/confidence_calibrator.dart';
import '../../../services/telemetry_service.dart';

/// Unified Analysis State - يجمع أفضل ما في النظامين
class UnifiedAnalysisState {
  final ScalpingSignal? royalScalp;
  final SwingSignal? royalSwing;
  final ScalpingSignalModel? advancedScalp;
  final MarketMetricsModel? metrics;
  final TechnicalIndicators? indicators;
  final double? currentPrice;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdate;
  final bool isAutoRefreshEnabled;

  UnifiedAnalysisState({
    this.royalScalp,
    this.royalSwing,
    this.advancedScalp,
    this.metrics,
    this.indicators,
    this.currentPrice,
    this.isLoading = false,
    this.error,
    this.lastUpdate,
    this.isAutoRefreshEnabled = false,
  });

  UnifiedAnalysisState copyWith({
    ScalpingSignal? royalScalp,
    SwingSignal? royalSwing,
    ScalpingSignalModel? advancedScalp,
    MarketMetricsModel? metrics,
    TechnicalIndicators? indicators,
    double? currentPrice,
    bool? isLoading,
    String? error,
    DateTime? lastUpdate,
    bool? isAutoRefreshEnabled,
  }) {
    return UnifiedAnalysisState(
      royalScalp: royalScalp ?? this.royalScalp,
      royalSwing: royalSwing ?? this.royalSwing,
      advancedScalp: advancedScalp ?? this.advancedScalp,
      metrics: metrics ?? this.metrics,
      indicators: indicators ?? this.indicators,
      currentPrice: currentPrice ?? this.currentPrice,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      isAutoRefreshEnabled: isAutoRefreshEnabled ?? this.isAutoRefreshEnabled,
    );
  }

  /// Check if data is stale
  bool get isStale {
    if (lastUpdate == null) return true;
    final expiryMinutes = EnvironmentConfig.cacheExpiryMinutes;
    return DateTime.now().difference(lastUpdate!) >
        Duration(minutes: expiryMinutes);
  }

  /// Check if analysis is available
  bool get hasAnalysis =>
      royalScalp != null && royalSwing != null && advancedScalp != null;
}

/// Unified Analysis Provider - يجمع أفضل الميزات من النظامين
class UnifiedAnalysisProviderNotifier
    extends StateNotifier<UnifiedAnalysisState> {
  final Ref ref;
  Timer? _autoRefreshTimer;
  Timer? _debounceTimer;
  DateTime? _lastApiCall;

  // Debounce delay to prevent rapid successive calls
  static const Duration _debounceDelay = Duration(milliseconds: 500);

  UnifiedAnalysisProviderNotifier(this.ref) : super(UnifiedAnalysisState()) {
    AppLogger.info('🔀 UnifiedAnalysisProviderNotifier initialized');
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    _debounceTimer?.cancel();
    _debounceTimer = null;
    super.dispose();
  }

  /// Generate analysis with debouncing and caching
  Future<void> generateAnalysis({bool forceRefresh = false}) async {
    // Cancel any pending debounced calls
    _debounceTimer?.cancel();

    // Debounce: Wait for a short delay before executing
    if (!forceRefresh) {
      _debounceTimer = Timer(_debounceDelay, () {
        _executeAnalysis(forceRefresh: forceRefresh);
      });
      return;
    }

    // Execute immediately if force refresh
    await _executeAnalysis(forceRefresh: forceRefresh);
  }

  /// Internal method to execute analysis
  Future<void> _executeAnalysis({bool forceRefresh = false}) async {
    // Prevent multiple simultaneous calls
    if (state.isLoading) {
      AppLogger.warn('Unified Analysis already in progress, skipping');
      return;
    }

    // Check cache (unless force refresh)
    if (!forceRefresh && !state.isStale && state.hasAnalysis) {
      final age = DateTime.now().difference(state.lastUpdate!).inSeconds;
      AppLogger.info('Using cached Unified Analysis data (age: ${age}s)');
      return;
    }

    // Rate limiting
    if (_lastApiCall != null) {
      final minInterval =
          Duration(seconds: EnvironmentConfig.minRequestIntervalSeconds);
      final timeSinceLastCall = DateTime.now().difference(_lastApiCall!);
      if (timeSinceLastCall < minInterval) {
        final remainingSeconds =
            minInterval.inSeconds - timeSinceLastCall.inSeconds;
        AppLogger.warn(
            'Rate limit: Please wait ${remainingSeconds}s before next call');
        return;
      }
    }

    state = state.copyWith(isLoading: true, error: null);
    AppLogger.analysis('UnifiedAnalysis', 'Starting unified engines analysis');

    try {
      // 1. Get current price from API
      AppLogger.info('🔄 جلب سعر الذهب الحقيقي...');
      final goldPrice = await GoldPriceService.getCurrentPrice();
      final currentPrice = goldPrice.price;
      AppLogger.success(
          '💰 السعر الحقيقي: \$${currentPrice.toStringAsFixed(2)}');
      _lastApiCall = DateTime.now();

      // 2. توليد الشموع التاريخية
      AppLogger.info('Generating historical candles...');
      final rawCandles = CandleGenerator.generate(
        currentPrice: currentPrice,
        timeframe: '15m',
        count: 500,
      );

      if (rawCandles.isEmpty) {
        throw Exception('لا توجد بيانات تاريخية متاحة');
      }

      // Validate and fix missing/broken candles
      final candles = DataValidation.validateAndFixCandles(
        rawCandles,
        const Duration(minutes: 15),
        interpolateSmallGaps: true,
      );

      AppLogger.success('Loaded ${rawCandles.length} raw candles -> ${candles.length} cleaned candles');

      // 3. Calculate indicators (shared between all systems)
      AppLogger.info('Calculating technical indicators...');
      final indicators = TechnicalIndicatorsService.calculateAll(candles);

      // Validate ATR
      if (indicators.atr <= 0 || indicators.atr.isNaN) {
        throw Exception('خطأ في حساب ATR');
      }
      AppLogger.success(
          'Indicators calculated: RSI=${indicators.rsi.toStringAsFixed(2)}, ATR=${indicators.atr.toStringAsFixed(2)}');

      // 4. Generate Royal Scalping Signal (ScalpingEngineV2)
      AppLogger.info('Running Royal Scalping Engine (ScalpingEngineV2)...');
      var royalScalpSignal = await ScalpingEngineV2.analyze(
        currentPrice: currentPrice,
        candles: candles,
        rsi: indicators.rsi,
        macd: indicators.macd,
        macdSignal: indicators.macdSignal,
        atr: indicators.atr,
      );

      // Calibrate confidence (Platt-style) and record telemetry
      final rawScalpConf = royalScalpSignal.confidence.toDouble();
      final normScalp = rawScalpConf > 1 ? (rawScalpConf / 100.0) : rawScalpConf;
      final calibratedScalpProb = ConfidenceCalibrator.instance.calibrate(normScalp);
      final calibratedScalpPct = (calibratedScalpProb * 100.0).clamp(0.0, 100.0).round();

      royalScalpSignal = ScalpingSignal(
        direction: royalScalpSignal.direction,
        entryPrice: royalScalpSignal.entryPrice,
        stopLoss: royalScalpSignal.stopLoss,
        takeProfit: royalScalpSignal.takeProfit,
        confidence: calibratedScalpPct,
        riskReward: royalScalpSignal.riskReward,
        microTrend: royalScalpSignal.microTrend,
        momentum: royalScalpSignal.momentum,
        volatility: royalScalpSignal.volatility,
        rsiZone: royalScalpSignal.rsiZone,
        timestamp: royalScalpSignal.timestamp,
        reason: royalScalpSignal.reason,
      );

      TelemetryService.instance.recordSignalGenerated('scalping', 'royal', calibratedScalpProb);

      AppLogger.signal(
        'ROYAL SCALP',
        '${royalScalpSignal.direction} - Confidence: ${royalScalpSignal.confidence.toStringAsFixed(1)}%',
      );

      // 5. Generate Royal Swing Signal (SwingEngineV2)
      AppLogger.info('Running Royal Swing Engine (SwingEngineV2)...');
      var royalSwingSignal = await SwingEngineV2.analyze(
        candles: candles,
        currentPrice: currentPrice,
        atr: indicators.atr,
        rsi: indicators.rsi,
        macd: indicators.macd,
        macdSignal: indicators.macdSignal,
        ma20: indicators.ma20,
        ma50: indicators.ma50,
        ma100: indicators.ma100,
        ma200: indicators.ma200,
      );

      // Calibrate Swing confidence
      final rawSwingConf = royalSwingSignal.confidence.toDouble();
      final normSwing = rawSwingConf > 1 ? (rawSwingConf / 100.0) : rawSwingConf;
      final calibratedSwingProb = ConfidenceCalibrator.instance.calibrate(normSwing);
      final calibratedSwingPct = (calibratedSwingProb * 100.0).clamp(0.0, 100.0).round();

      royalSwingSignal = SwingSignal(
        direction: royalSwingSignal.direction,
        entryPrice: royalSwingSignal.entryPrice,
        stopLoss: royalSwingSignal.stopLoss,
        takeProfit: royalSwingSignal.takeProfit,
        confidence: calibratedSwingPct,
        riskReward: royalSwingSignal.riskReward,
        macroTrend: royalSwingSignal.macroTrend,
        marketStructure: royalSwingSignal.marketStructure,
        fibonacci: royalSwingSignal.fibonacci,
        zones: royalSwingSignal.zones,
        qcf: royalSwingSignal.qcf,
        reversal: royalSwingSignal.reversal,
        timestamp: royalSwingSignal.timestamp,
        reason: royalSwingSignal.reason,
      );

      TelemetryService.instance.recordSignalGenerated('swing', 'royal', calibratedSwingProb);

      AppLogger.signal(
        'ROYAL SWING',
        '${royalSwingSignal.direction} - Confidence: ${royalSwingSignal.confidence.toStringAsFixed(1)}%',
      );

      // 6. Generate Advanced Scalping Signal (using Golden Nightmare Engine for enhanced analysis)
      AppLogger.info('Running Advanced Scalping Engine (Golden Nightmare)...');

      // Use Golden Nightmare Engine for advanced analysis
      final goldenNightmareResult = await GoldenNightmareEngine.generate(
        currentPrice: currentPrice,
        candles: candles,
        rsi: indicators.rsi,
        macd: indicators.macd,
        macdSignal: indicators.macdSignal,
        ma20: indicators.ma20,
        ma50: indicators.ma50,
        ma100: indicators.ma100,
        ma200: indicators.ma200,
        atr: indicators.atr,
      );

      // Extract scalping signal from Golden Nightmare
      final goldenScalp =
          goldenNightmareResult['SCALP'] as Map<String, dynamic>?;

      // Convert to ScalpingSignalModel
      ScalpingSignalModel advancedScalpModel;
      if (goldenScalp != null && goldenScalp['direction'] != 'NO_TRADE') {
        advancedScalpModel = ScalpingSignalModel(
          direction: goldenScalp['direction'] ?? 'NO_TRADE',
          entryPrice:
              (goldenScalp['entry'] as num?)?.toDouble() ?? currentPrice,
          stopLoss: (goldenScalp['stopLoss'] as num?)?.toDouble(),
          takeProfit: (goldenScalp['takeProfit'] as num?)?.toDouble(),
          confidence: (goldenScalp['confidence'] as num?)?.toDouble() ?? 0.0,
          riskReward: (goldenScalp['riskReward'] as num?)?.toDouble() ?? 1.0,
          timestamp: DateTime.now(),
        );
      } else {
        // Fallback to ScalpingEngineV2 if Golden Nightmare returns NO_TRADE
        final fallbackSignal = await ScalpingEngineV2.analyze(
          currentPrice: currentPrice,
          candles: candles,
          rsi: indicators.rsi,
          macd: indicators.macd,
          macdSignal: indicators.macdSignal,
          atr: indicators.atr,
        );
        advancedScalpModel = ScalpingSignalModel(
          direction: fallbackSignal.direction,
          entryPrice: fallbackSignal.entryPrice ?? currentPrice,
          stopLoss: fallbackSignal.stopLoss,
          takeProfit: fallbackSignal.takeProfit,
          confidence: fallbackSignal.confidence.toDouble(),
          riskReward: fallbackSignal.riskReward ?? 1.0,
          timestamp: DateTime.now(),
        );
      }

      // Calibrate advanced scalp confidence
      if (advancedScalpModel.isValid) {
        final rawAdvConf = advancedScalpModel.confidence.toDouble();
        final normAdv = rawAdvConf > 1 ? (rawAdvConf / 100.0) : rawAdvConf;
        final calibratedAdvProb = ConfidenceCalibrator.instance.calibrate(normAdv);
        final calibratedAdvPct = (calibratedAdvProb * 100.0).clamp(0.0, 100.0);
        advancedScalpModel = ScalpingSignalModel(
          direction: advancedScalpModel.direction,
          entryPrice: advancedScalpModel.entryPrice,
          stopLoss: advancedScalpModel.stopLoss,
          takeProfit: advancedScalpModel.takeProfit,
          confidence: calibratedAdvPct,
          riskReward: advancedScalpModel.riskReward,
          timestamp: advancedScalpModel.timestamp,
        );

        TelemetryService.instance.recordSignalGenerated('scalping', 'advanced', calibratedAdvProb);
      }

      AppLogger.signal(
        'ADVANCED SCALP',
        '${advancedScalpModel.direction} - Confidence: ${advancedScalpModel.confidence.toStringAsFixed(1)}%',
      );

      // Apply strictness filter to signals
      final strictnessLevelStr = ref.read(settingsProvider).settings.strictnessLevel;
      final strictnessLevel = strictnessLevelStr == 'relaxed' ? 0 : (strictnessLevelStr == 'strict' ? 2 : 1);
      final threshold = 0.4 + (0.15 * strictnessLevel); // 0.4 -> 1.0

      // Helper to normalize confidence (0..1)
      double _norm(dynamic conf) => (conf is num ? conf.toDouble() : 0.0) > 1 ? (conf.toDouble() / 100.0) : conf.toDouble();

      // Filter scalp
      if (_norm(royalScalpSignal.confidence) < threshold) {
        AppLogger.warn('⚖️ Royal scalp filtered by strictness: ${(_norm(royalScalpSignal.confidence) * 100).toStringAsFixed(1)}% < ${(threshold * 100).toStringAsFixed(1)}%');
        royalScalpSignal = ScalpingSignal.noTrade(reason: 'Filtered by strictness');
        TelemetryService.instance.recordSignalFiltered('scalping', 'royal', _norm(royalScalpSignal.confidence), threshold);
      }

      // Filter swing
      if (_norm(royalSwingSignal.confidence) < threshold) {
        AppLogger.warn('⚖️ Royal swing filtered by strictness: ${(_norm(royalSwingSignal.confidence) * 100).toStringAsFixed(1)}% < ${(threshold * 100).toStringAsFixed(1)}%');
        royalSwingSignal = SwingSignal.noTrade(reason: 'Filtered by strictness');
        TelemetryService.instance.recordSignalFiltered('swing', 'royal', _norm(royalSwingSignal.confidence), threshold);
      }

      // Filter advanced scalp
      if (advancedScalpModel.isValid && _norm(advancedScalpModel.confidence) < threshold) {
        AppLogger.warn('⚖️ Advanced scalp filtered by strictness: ${(_norm(advancedScalpModel.confidence) * 100).toStringAsFixed(1)}% < ${(threshold * 100).toStringAsFixed(1)}%');
        advancedScalpModel = ScalpingSignalModel(
          direction: 'NO_TRADE',
          entryPrice: currentPrice,
          stopLoss: null,
          takeProfit: null,
          confidence: 0,
          riskReward: 1.0,
          timestamp: DateTime.now(),
        );
        TelemetryService.instance.recordSignalFiltered('scalping', 'advanced', _norm(advancedScalpModel.confidence), threshold);
      }

      // 7. Calculate Market Metrics (from Advanced Scalping)
      final metrics = MarketMetricsModel(
        volatility: indicators.atr / currentPrice * 100,
        momentum:
            (candles.first.close - candles[50].close) / candles[50].close * 100,
        volume:
            candles.take(20).map((c) => c.volume).reduce((a, b) => a + b) / 20,
        trend: advancedScalpModel.direction == 'BUY' ? 'UP' : 'DOWN',
      );

      // 8. Update state
      state = state.copyWith(
        royalScalp: royalScalpSignal,
        royalSwing: royalSwingSignal,
        advancedScalp: advancedScalpModel,
        metrics: metrics,
        indicators: indicators,
        currentPrice: currentPrice,
        isLoading: false,
        lastUpdate: DateTime.now(),
      );

      AppLogger.success('✅ Unified Analysis completed successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error in Unified Analysis', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Enable auto-refresh
  void startAutoRefresh() {
    if (state.isAutoRefreshEnabled) {
      AppLogger.warn('Auto-refresh already enabled');
      return;
    }

    final interval = EnvironmentConfig.autoRefreshInterval;
    AppLogger.info(
        'Starting Unified Analysis auto-refresh (${interval}s interval)');
    state = state.copyWith(isAutoRefreshEnabled: true);

    _autoRefreshTimer = Timer.periodic(
      Duration(seconds: interval),
      (_) {
        // Only refresh if data is stale
        if (state.isStale) {
          generateAnalysis();
        } else {
          AppLogger.debug(
              'Skipping auto-refresh: Unified Analysis data is still fresh');
        }
      },
    );
  }

  /// Disable auto-refresh
  void stopAutoRefresh() {
    _stopAutoRefresh();
    state = state.copyWith(isAutoRefreshEnabled: false);
    AppLogger.info('Unified Analysis auto-refresh stopped');
  }

  void _stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  /// Force refresh (clear cache)
  Future<void> forceRefresh() async {
    AppLogger.info('Unified Analysis force refresh requested');
    await generateAnalysis(forceRefresh: true);
  }
}

final unifiedAnalysisProvider = StateNotifierProvider.autoDispose<
    UnifiedAnalysisProviderNotifier, UnifiedAnalysisState>(
  (ref) => UnifiedAnalysisProviderNotifier(ref),
);
