/// KABOUS PRO Provider
/// ====================
/// Provider for KABOUS PRO system with Backtest and Multi-timeframe

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/logger.dart';
import '../../../core/config/environment_config.dart';
import '../../../services/gold_price_service.dart';
import '../../../services/candle_generator.dart';
import '../../../services/kabous_pro/kabous_backend_service.dart';
import '../../../services/kabous_pro/kabous_models.dart';
import '../../../services/kabous_pro/multitimeframe_service.dart';
import '../../../services/kabous_pro/backtest_service.dart';

/// KABOUS PRO State
class KabousProState {
  final KabousAnalysisResult? analysis;
  final MultiTimeframeResult? multiTimeframe;
  final BacktestResult? backtestResult;
  final double? currentPrice;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdate;
  final bool isAutoRefreshEnabled;

  // Analysis modes
  final bool showBacktest;
  final bool showMultiTimeframe;

  KabousProState({
    this.analysis,
    this.multiTimeframe,
    this.backtestResult,
    this.currentPrice,
    this.isLoading = false,
    this.error,
    this.lastUpdate,
    this.isAutoRefreshEnabled = false,
    this.showBacktest = false,
    this.showMultiTimeframe = false,
  });

  KabousProState copyWith({
    KabousAnalysisResult? analysis,
    MultiTimeframeResult? multiTimeframe,
    BacktestResult? backtestResult,
    double? currentPrice,
    bool? isLoading,
    String? error,
    DateTime? lastUpdate,
    bool? isAutoRefreshEnabled,
    bool? showBacktest,
    bool? showMultiTimeframe,
  }) {
    return KabousProState(
      analysis: analysis ?? this.analysis,
      multiTimeframe: multiTimeframe ?? this.multiTimeframe,
      backtestResult: backtestResult ?? this.backtestResult,
      currentPrice: currentPrice ?? this.currentPrice,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      isAutoRefreshEnabled: isAutoRefreshEnabled ?? this.isAutoRefreshEnabled,
      showBacktest: showBacktest ?? this.showBacktest,
      showMultiTimeframe: showMultiTimeframe ?? this.showMultiTimeframe,
    );
  }

  bool get isStale {
    if (lastUpdate == null) return true;
    final expiryMinutes = EnvironmentConfig.cacheExpiryMinutes;
    return DateTime.now().difference(lastUpdate!) >
        Duration(minutes: expiryMinutes);
  }

  bool get hasAnalysis => analysis != null;
}

/// KABOUS PRO Provider Notifier
class KabousProNotifier extends StateNotifier<KabousProState> {
  Timer? _autoRefreshTimer;
  Timer? _debounceTimer;
  DateTime? _lastApiCall;

  // ✅ Cache للتوصيات بناءً على السعر الفعلي
  double? _lastAnalyzedPrice;
  static const double _priceChangeThreshold = 0.3; // 0.3% تغيير في السعر

  static const Duration _debounceDelay = Duration(milliseconds: 500);

  KabousProNotifier() : super(KabousProState()) {
    AppLogger.info('🔥 KABOUS PRO Provider initialized');
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    _debounceTimer?.cancel();
    _debounceTimer = null;
    super.dispose();
  }

  /// Generate KABOUS Analysis
  Future<void> generateAnalysis({bool forceRefresh = false}) async {
    _debounceTimer?.cancel();

    if (!forceRefresh) {
      _debounceTimer = Timer(_debounceDelay, () {
        _executeAnalysis(forceRefresh: forceRefresh);
      });
      return;
    }

    await _executeAnalysis(forceRefresh: forceRefresh);
  }

  Future<void> _executeAnalysis({bool forceRefresh = false}) async {
    if (state.isLoading) {
      AppLogger.warn('KABOUS PRO Analysis already in progress, skipping');
      return;
    }

    if (!forceRefresh && !state.isStale && state.hasAnalysis) {
      final age = DateTime.now().difference(state.lastUpdate!).inSeconds;
      AppLogger.info('Using cached KABOUS PRO data (age: ${age}s)');
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
    AppLogger.analysis('KABOUS PRO', 'Starting analysis');

    try {
      // 1. Get current price (clear cache first to ensure fresh data)
      AppLogger.info('🔄 جلب سعر الذهب...');
      GoldPriceService.clearCache(); // Force fresh API call
      final goldPrice = await GoldPriceService.getCurrentPrice();
      final currentPrice = goldPrice.price;
      AppLogger.success('💰 السعر: \$${currentPrice.toStringAsFixed(2)}');
      _lastApiCall = DateTime.now();

      // ✅ التحقق: هل السعر تغير كفاية لإعادة التحليل؟
      if (_lastAnalyzedPrice != null && !forceRefresh) {
        final priceChangePercent =
            ((currentPrice - _lastAnalyzedPrice!).abs() / _lastAnalyzedPrice!) *
                100;

        if (priceChangePercent < _priceChangeThreshold) {
          AppLogger.info(
              '💡 السعر لم يتغير كثيراً (${priceChangePercent.toStringAsFixed(2)}%) - '
              'استخدام التحليل السابق');
          // تحديث السعر الحالي فقط بدون إعادة التحليل
          state = state.copyWith(
            currentPrice: currentPrice,
            isLoading: false,
          );
          return;
        }
        AppLogger.info(
            '📊 السعر تغير بنسبة ${priceChangePercent.toStringAsFixed(2)}% - '
            'إعادة التحليل');
      }

      // حفظ السعر الذي سيتم التحليل عليه
      _lastAnalyzedPrice = currentPrice;

      // 2. Check backend health
      final isHealthy = await KabousBackendService.healthCheck();

      KabousAnalysisResult? analysis;
      if (isHealthy) {
        // Use backend if available
        try {
          analysis = await KabousBackendService.analyze(
            timeframe: '5m',
            accountBalance: 10000,
          );
          AppLogger.success('✅ KABOUS Backend analysis completed');
        } catch (e) {
          AppLogger.warn('Backend analysis failed, using fallback');
        }
      }

      // 3. Multi-timeframe analysis (always run)
      MultiTimeframeResult? multiTimeframe;
      if (state.showMultiTimeframe) {
        try {
          multiTimeframe = await MultiTimeframeService.analyzeAllTimeframes(
            currentPrice: currentPrice,
          );
          AppLogger.success('✅ Multi-Timeframe analysis completed');
        } catch (e) {
          AppLogger.warn('Multi-Timeframe analysis failed: $e');
        }
      }

      // 4. Backtest (if enabled)
      BacktestResult? backtestResult;
      if (state.showBacktest) {
        try {
          final candles = CandleGenerator.generate(
            currentPrice: currentPrice,
            timeframe: '15m',
            count: 1000,
          );

          if (candles.length >= 500) {
            backtestResult = await BacktestService.runBacktest(
              candles: candles,
              initialBalance: 10000,
              riskPerTrade: 0.02,
            );
            AppLogger.success('✅ Backtest completed');
          }
        } catch (e) {
          AppLogger.warn('Backtest failed: $e');
        }
      }

      state = state.copyWith(
        analysis: analysis,
        multiTimeframe: multiTimeframe,
        backtestResult: backtestResult,
        currentPrice: currentPrice,
        isLoading: false,
        error: null,
        lastUpdate: DateTime.now(),
      );

      AppLogger.success('✅ KABOUS PRO Analysis completed successfully');
    } catch (e, stackTrace) {
      AppLogger.error('KABOUS PRO Analysis failed', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Toggle Backtest Mode
  void toggleBacktest(bool enabled) {
    state = state.copyWith(showBacktest: enabled);
    if (enabled && state.backtestResult == null) {
      generateAnalysis(forceRefresh: true);
    }
  }

  /// Toggle Multi-Timeframe Mode
  void toggleMultiTimeframe(bool enabled) {
    state = state.copyWith(showMultiTimeframe: enabled);
    if (enabled && state.multiTimeframe == null) {
      generateAnalysis(forceRefresh: true);
    }
  }

  /// Start Auto-refresh
  void startAutoRefresh() {
    if (state.isAutoRefreshEnabled) {
      AppLogger.warn('Auto-refresh already enabled');
      return;
    }

    final interval = EnvironmentConfig.autoRefreshInterval;
    AppLogger.info('Starting KABOUS PRO auto-refresh (${interval}s interval)');
    state = state.copyWith(isAutoRefreshEnabled: true);

    _autoRefreshTimer = Timer.periodic(Duration(seconds: interval), (_) {
      if (state.isStale) {
        generateAnalysis();
      } else {
        AppLogger.debug('Skipping auto-refresh: data is still fresh');
      }
    });
  }

  /// Stop Auto-refresh
  void stopAutoRefresh() {
    _stopAutoRefresh();
    state = state.copyWith(isAutoRefreshEnabled: false);
    AppLogger.info('KABOUS PRO auto-refresh stopped');
  }

  void _stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  /// Force Refresh
  Future<void> forceRefresh() async {
    AppLogger.info('KABOUS PRO force refresh requested');
    await generateAnalysis(forceRefresh: true);
  }
}

/// KABOUS PRO Provider Instance
final kabousProProvider =
    StateNotifierProvider.autoDispose<KabousProNotifier, KabousProState>((ref) {
  return KabousProNotifier();
});
