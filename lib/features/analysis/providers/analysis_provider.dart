import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/recommendation.dart';
import '../../../models/market_models.dart';
import '../../../services/gold_price_service.dart';
import '../../../services/candle_generator.dart';
import '../../../services/technical_indicators_service.dart';
import '../../../services/support_resistance_service.dart';
import '../../../services/anthropic_service.dart';
import '../../../services/golden_nightmare/golden_nightmare_engine.dart';
import '../../../services/golden_nightmare/zone_detector.dart';
import '../../../core/utils/logger.dart';
import '../../settings/providers/settings_provider.dart';
import 'strictness_provider.dart';

/// Analysis State with Enhanced Features
class AnalysisState {
  final Recommendation? scalp;
  final Recommendation? swing;
  final TechnicalIndicators? indicators;
  final SupportResistanceAnalysis? supportResistance;
  final String? aiAnalysis;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdate;
  final bool isAutoRefreshEnabled;
  final bool useLegendaryMode;

  AnalysisState({
    this.scalp,
    this.swing,
    this.indicators,
    this.supportResistance,
    this.aiAnalysis,
    this.isLoading = false,
    this.error,
    this.lastUpdate,
    this.isAutoRefreshEnabled = false,
    this.useLegendaryMode = false,
  });

  AnalysisState copyWith({
    Recommendation? scalp,
    Recommendation? swing,
    TechnicalIndicators? indicators,
    SupportResistanceAnalysis? supportResistance,
    String? aiAnalysis,
    bool? isLoading,
    String? error,
    DateTime? lastUpdate,
    bool? isAutoRefreshEnabled,
    bool? useLegendaryMode,
  }) {
    return AnalysisState(
      scalp: scalp ?? this.scalp,
      swing: swing ?? this.swing,
      indicators: indicators ?? this.indicators,
      supportResistance: supportResistance ?? this.supportResistance,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      isAutoRefreshEnabled: isAutoRefreshEnabled ?? this.isAutoRefreshEnabled,
      useLegendaryMode: useLegendaryMode ?? this.useLegendaryMode,
    );
  }

  /// Check if data is stale (older than 5 minutes)
  bool get isStale {
    if (lastUpdate == null) return true;
    return DateTime.now().difference(lastUpdate!) > const Duration(minutes: 5);
  }
}

/// Enhanced Analysis Provider with Caching & Auto-Refresh
class AnalysisNotifier extends StateNotifier<AnalysisState> {
  final Ref ref;
  Timer? _autoRefreshTimer;
  Timer? _debounceTimer;
  static const Duration _analysisTimeout = Duration(seconds: 8);

  // Cache for preventing duplicate API calls
  DateTime? _lastApiCall;
  static const Duration _minApiInterval = Duration(seconds: 30);
  static const Duration _debounceDelay = Duration(milliseconds: 500);

  // Cache expiry (5 minutes) - reserved for future use
  // ignore: unused_field
  static const Duration _cacheExpiry = Duration(minutes: 5);

  AnalysisNotifier(this.ref) : super(AnalysisState()) {
    AppLogger.info('AnalysisNotifier initialized');
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    _debounceTimer?.cancel();
    _debounceTimer = null;
    super.dispose();
  }

  /// Generate analysis with caching, debouncing, and error recovery
  Future<void> generateAnalysis(
      {bool forceRefresh = false, bool isInitialCall = false}) async {
    // Cancel any pending debounced calls
    _debounceTimer?.cancel();

    // For initial call or force refresh, execute immediately without debounce
    if (forceRefresh || isInitialCall) {
      await _executeAnalysis(
          forceRefresh: forceRefresh, skipRateLimit: isInitialCall);
      return;
    }

    // Debounce: Wait for a short delay before executing (only for manual refreshes)
    _debounceTimer = Timer(_debounceDelay, () {
      _executeAnalysis(forceRefresh: forceRefresh);
    });
  }

  /// Internal method to execute analysis
  Future<void> _executeAnalysis(
      {bool forceRefresh = false, bool skipRateLimit = false}) async {
    // Prevent multiple simultaneous calls
    if (state.isLoading) {
      AppLogger.warn('Analysis already in progress, skipping');
      return;
    }

    // Check cache (unless force refresh or initial call)
    if (!forceRefresh && !state.isStale && state.scalp != null) {
      AppLogger.info(
          'Using cached analysis data (age: ${DateTime.now().difference(state.lastUpdate!).inSeconds}s)');
      return;
    }

    // Rate limiting (skip for initial call when no data exists)
    if (!skipRateLimit &&
        _lastApiCall != null &&
        DateTime.now().difference(_lastApiCall!) < _minApiInterval) {
      final remainingSeconds = _minApiInterval.inSeconds -
          DateTime.now().difference(_lastApiCall!).inSeconds;
      AppLogger.warn(
          'Rate limit: Please wait ${remainingSeconds}s before next call');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    AppLogger.analysis('GoldenNightmare', 'Starting analysis generation');

    try {
      await _runWithTimeout(
        () => _runAnalysisFlow(),
        _analysisTimeout,
      );
    } on TimeoutException catch (e) {
      AppLogger.error(
        'Analysis generation timed out',
        e,
        StackTrace.current,
      );
      state = state.copyWith(
        isLoading: false,
        error: 'انتهت مهلة التحليل، حاول مرة أخرى.',
      );
      return;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to generate analysis', e, stackTrace);

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    } finally {
      if (state.isLoading) {
        // Safety guard to avoid sticky loader
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> _runAnalysisFlow() async {
    // Get strictness settings
    final strictnessSettings = ref.read(strictnessSettingsProvider);
    final strictnessLevel = ref.read(strictnessProvider);
    AppLogger.debug('Strictness level: ${strictnessLevel.name}');

    // Update ZoneDetector with ALL strictness settings
    ZoneDetector.minZoneStrength = strictnessSettings.minZoneStrength;
    ZoneDetector.minConfluence = strictnessSettings.minConfluence;
    ZoneDetector.minRsiOversold = strictnessSettings.minRsiOversold;
    ZoneDetector.maxRsiOverbought = strictnessSettings.maxRsiOverbought;
    ZoneDetector.minLiquidityStrength = strictnessSettings.minLiquidityStrength;
    ZoneDetector.minPivotCount = strictnessSettings.minPivotCount;

    // 1. Get current price from API (السعر الحقيقي)
    AppLogger.info('🔄 جلب سعر الذهب الحقيقي...');
    final goldPrice = await GoldPriceService.getCurrentPrice();
    final currentPrice = goldPrice.price;
    AppLogger.success('💰 السعر الحقيقي: \$${currentPrice.toStringAsFixed(2)}');
    _lastApiCall = DateTime.now();

    // 2. توليد الشموع التاريخية
    AppLogger.info('Generating historical candles...');
    final candles = CandleGenerator.generate(
      currentPrice: currentPrice,
      timeframe: '15m',
      count: 500,
    );

    if (candles.isEmpty) {
      throw Exception('لا توجد بيانات تاريخية متاحة');
    }
    AppLogger.success('Generated ${candles.length} candles');

    // 3. Calculate indicators
    AppLogger.info('Calculating technical indicators...');
    final indicators = TechnicalIndicatorsService.calculateAll(candles);

    // Validate ATR
    if (indicators.atr <= 0 || indicators.atr.isNaN) {
      throw Exception('خطأ في حساب ATR');
    }
    AppLogger.success(
        'Indicators calculated: RSI=${indicators.rsi.toStringAsFixed(2)}, ATR=${indicators.atr.toStringAsFixed(2)}');

    // 3.5 Calculate Support/Resistance levels
    AppLogger.info('Calculating support/resistance levels...');
    final supportResistance =
        SupportResistanceService.calculate(candles, currentPrice);
    AppLogger.success(
        'S/R levels: ${supportResistance.supports.length} supports, ${supportResistance.resistances.length} resistances');

    // 4. Generate recommendations using Golden Nightmare Engine
    AppLogger.info('Running Golden Nightmare Engine...');
    final result = await GoldenNightmareEngine.generate(
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

    if (result.isEmpty ||
        !result.containsKey('SCALP') ||
        !result.containsKey('SWING')) {
      throw Exception('فشل في توليد التوصيات');
    }

    final scalp = Recommendation.fromMap(result['SCALP']);
    final swing = Recommendation.fromMap(result['SWING']);

    AppLogger.signal('SCALP',
        '${scalp.directionText} - Confidence: ${scalp.confidenceText}');
    AppLogger.signal('SWING',
        '${swing.directionText} - Confidence: ${swing.confidenceText}');

    state = state.copyWith(
      scalp: scalp,
      swing: swing,
      indicators: indicators,
      supportResistance: supportResistance,
      isLoading: false,
      error: null,
      lastUpdate: DateTime.now(),
    );

    AppLogger.success('Analysis generation completed successfully');

    // Play feedback for strong signals
    _playFeedbackForSignal(scalp);
  }

  Future<void> _runWithTimeout(
    Future<void> Function() action,
    Duration timeout,
  ) async {
    await Future.any([
      action(),
      Future.delayed(
        timeout,
        () => throw TimeoutException(
          'Analysis timed out after ${timeout.inSeconds}s',
        ),
      ),
    ]);
  }

  /// Generate AI analysis with rate limiting
  Future<void> generateAIAnalysis() async {
    if (state.scalp == null ||
        state.swing == null ||
        state.indicators == null) {
      AppLogger.warn('Cannot generate AI analysis: Missing required data');
      return;
    }

    state = state.copyWith(isLoading: true);
    AppLogger.info('Generating AI analysis with Anthropic...');

    try {
      final goldPrice = await GoldPriceService.getCurrentPrice();

      final aiAnalysis = await AnthropicServicePro.getAnalysis(
        scalp: state.scalp!,
        swing: state.swing!,
        indicators: state.indicators!,
        currentPrice: goldPrice.price,
      );

      state = state.copyWith(
        aiAnalysis: aiAnalysis,
        isLoading: false,
      );

      AppLogger.success('AI analysis generated successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to generate AI analysis', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to generate AI analysis',
      );
    }
  }

  /// Enable auto-refresh (every 60 seconds)
  void startAutoRefresh() {
    if (state.isAutoRefreshEnabled) {
      AppLogger.warn('Auto-refresh already enabled');
      return;
    }

    AppLogger.info('Starting auto-refresh (60s interval)');
    state = state.copyWith(isAutoRefreshEnabled: true);

    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) {
        // Only refresh if data is stale
        if (state.isStale) {
          generateAnalysis();
        } else {
          AppLogger.debug('Skipping auto-refresh: data is still fresh');
        }
      },
    );
  }

  /// Disable auto-refresh
  void stopAutoRefresh() {
    _stopAutoRefresh();
    state = state.copyWith(isAutoRefreshEnabled: false);
    AppLogger.info('Auto-refresh stopped');
  }

  void _stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  /// Clear cache and force refresh
  Future<void> forceRefresh() async {
    AppLogger.info('Force refresh requested');
    await generateAnalysis(forceRefresh: true, isInitialCall: false);
  }

  /// Toggle Legendary Mode
  void toggleLegendaryMode() {
    state = state.copyWith(
      useLegendaryMode: !state.useLegendaryMode,
    );
    AppLogger.info('Legendary mode toggled: ${state.useLegendaryMode}');
  }

  /// Play feedback for signal based on settings
  void _playFeedbackForSignal(Recommendation recommendation) {
    try {
      final settings = ref.read(settingsProvider).settings;
      final direction = recommendation.directionText;
      final confidence = recommendation.confidenceValue; // Use numeric value

      // Play sound if enabled
      if (settings.soundEffectsEnabled && confidence >= 70) {
        if (confidence >= 85) {
          SystemSound.play(SystemSoundType.alert);
          AppLogger.info('🔊 Played STRONG signal alert');
        } else {
          SystemSound.play(SystemSoundType.click);
          AppLogger.info('🔊 Played signal click');
        }
      }

      // Vibrate if enabled
      if (settings.vibrationEnabled && confidence >= 80) {
        HapticFeedback.heavyImpact();
        AppLogger.info('📳 Vibrated for ${direction.toUpperCase()} signal');

        // Double vibration for very strong signals
        if (confidence >= 90) {
          Future.delayed(const Duration(milliseconds: 100), () {
            HapticFeedback.heavyImpact();
          });
        }
      }
    } catch (e) {
      AppLogger.warn('Failed to play feedback: $e');
    }
  }
}

final analysisProvider =
    StateNotifierProvider.autoDispose<AnalysisNotifier, AnalysisState>((ref) {
  return AnalysisNotifier(ref);
});
