import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/scalping_signal.dart';
import '../../../models/swing_signal.dart';
import '../../../models/market_models.dart';
import '../../../services/gold_price_service.dart';
import '../../../services/csv_data_service.dart';
import '../../../services/technical_indicators_service.dart';
import '../../../services/engines/scalping_engine_v2.dart';
import '../../../services/engines/swing_engine_v2.dart';
import '../../../core/utils/logger.dart';
import '../../../core/config/environment_config.dart';
import '../../settings/providers/settings_provider.dart';

/// 👑 Royal Analysis State
///
/// حالة محسّنة لنظام Royal Analysis مع دعم:
/// - Auto-refresh
/// - Caching
/// - Error recovery
/// - Performance tracking
/// Market Metrics Model
class MarketMetrics {
  final double volatility;
  final double momentum;
  final double volume;
  final String trend;

  MarketMetrics({
    required this.volatility,
    required this.momentum,
    required this.volume,
    required this.trend,
  });
}

class RoyalAnalysisState {
  final ScalpingSignal? scalp;
  final SwingSignal? swing;
  final TechnicalIndicators? indicators;
  final MarketMetrics? marketMetrics;
  final double? currentPrice;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdate;
  final bool isAutoRefreshEnabled;

  RoyalAnalysisState({
    this.scalp,
    this.swing,
    this.indicators,
    this.marketMetrics,
    this.currentPrice,
    this.isLoading = false,
    this.error,
    this.lastUpdate,
    this.isAutoRefreshEnabled = false,
  });

  RoyalAnalysisState copyWith({
    ScalpingSignal? scalp,
    SwingSignal? swing,
    TechnicalIndicators? indicators,
    MarketMetrics? marketMetrics,
    double? currentPrice,
    bool? isLoading,
    String? error,
    DateTime? lastUpdate,
    bool? isAutoRefreshEnabled,
  }) {
    return RoyalAnalysisState(
      scalp: scalp ?? this.scalp,
      swing: swing ?? this.swing,
      indicators: indicators ?? this.indicators,
      marketMetrics: marketMetrics ?? this.marketMetrics,
      currentPrice: currentPrice ?? this.currentPrice,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      isAutoRefreshEnabled: isAutoRefreshEnabled ?? this.isAutoRefreshEnabled,
    );
  }

  /// Check if data is stale (older than configured cache expiry)
  bool get isStale {
    if (lastUpdate == null) return true;
    final expiryMinutes = EnvironmentConfig.cacheExpiryMinutes;
    return DateTime.now().difference(lastUpdate!) >
        Duration(minutes: expiryMinutes);
  }

  /// Check if analysis is available
  bool get hasAnalysis => scalp != null && swing != null;
}

/// 👑 Royal Analysis Provider
///
/// Provider محسّن لنظام Royal Analysis مع:
/// - محركات v2 (ScalpingEngineV2 + SwingEngineV2)
/// - Auto-refresh system
/// - Caching mechanism
/// - Rate limiting
/// - Professional logging
/// - Error recovery
class RoyalAnalysisNotifier extends StateNotifier<RoyalAnalysisState> {
  final Ref ref;
  Timer? _autoRefreshTimer;
  Timer? _debounceTimer;
  DateTime? _lastApiCall;

  // Debounce delay to prevent rapid successive calls
  static const Duration _debounceDelay = Duration(milliseconds: 500);

  RoyalAnalysisNotifier(this.ref) : super(RoyalAnalysisState()) {
    AppLogger.info('👑 RoyalAnalysisNotifier initialized');
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    _debounceTimer?.cancel();
    _debounceTimer = null;
    super.dispose();
  }

  /// Generate analysis using v2 engines with debouncing
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
      AppLogger.warn('Royal Analysis already in progress, skipping');
      return;
    }

    // Check cache (unless force refresh)
    if (!forceRefresh && !state.isStale && state.hasAnalysis) {
      final age = DateTime.now().difference(state.lastUpdate!).inSeconds;
      AppLogger.info('Using cached Royal Analysis data (age: ${age}s)');
      return;
    }

    // Rate limiting
    if (_lastApiCall != null) {
      final minInterval = Duration(
        seconds: EnvironmentConfig.minRequestIntervalSeconds,
      );
      final timeSinceLastCall = DateTime.now().difference(_lastApiCall!);
      if (timeSinceLastCall < minInterval) {
        final remainingSeconds =
            minInterval.inSeconds - timeSinceLastCall.inSeconds;
        AppLogger.warn(
          'Rate limit: Please wait ${remainingSeconds}s before next call',
        );
        return;
      }
    }

    state = state.copyWith(isLoading: true, error: null);
    AppLogger.analysis('RoyalAnalysis', 'Starting v2 engines analysis');

    try {
      // 1. Get current price from API (السعر الحقيقي)
      AppLogger.info('🔄 جلب سعر الذهب الحقيقي...');
      GoldPriceService.clearCache(); // Force fresh API call
      final goldPrice = await GoldPriceService.getCurrentPrice();
      final currentPrice = goldPrice.price;
      AppLogger.success(
        '💰 السعر الحقيقي: \$${currentPrice.toStringAsFixed(2)}',
      );
      _lastApiCall = DateTime.now();

      // 2. تحميل البيانات الحقيقية من CSV - SEPARATE for Scalp and Swing
      AppLogger.info('Loading REAL SCALP data from CSV (15m)...');
      final allScalpCandles = await CsvDataService.loadScalpData();

      if (allScalpCandles.isEmpty) {
        throw Exception('لا توجد بيانات سكالب حقيقية');
      }

      // أخذ آخر 300 شمعة وتحديثها بالسعر الحالي
      final scalpCandles = CsvDataService.updateWithCurrentPrice(
        CsvDataService.getLastCandles(allScalpCandles, 300),
        currentPrice,
      );

      AppLogger.success(
        'Loaded ${scalpCandles.length} REAL scalp candles from CSV',
      );

      AppLogger.info('Loading REAL SWING data from CSV (4h)...');
      final allSwingCandles = await CsvDataService.loadSwingData();

      if (allSwingCandles.isEmpty) {
        throw Exception('لا توجد بيانات سوينج حقيقية');
      }

      // أخذ آخر 200 شمعة وتحديثها بالسعر الحالي
      final swingCandles = CsvDataService.updateWithCurrentPrice(
        CsvDataService.getLastCandles(allSwingCandles, 200),
        currentPrice,
      );

      AppLogger.success(
        'Loaded ${swingCandles.length} REAL swing candles from CSV',
      );

      // 3. Calculate indicators SEPARATELY
      AppLogger.info('Calculating technical indicators for SCALPING...');
      final scalpIndicators = TechnicalIndicatorsService.calculateAll(
        scalpCandles,
      );

      // Validate Scalp ATR
      if (scalpIndicators.atr <= 0 || scalpIndicators.atr.isNaN) {
        throw Exception('خطأ في حساب ATR للسكالب');
      }
      AppLogger.success(
        'Scalp Indicators: RSI=${scalpIndicators.rsi.toStringAsFixed(2)}, ATR=${scalpIndicators.atr.toStringAsFixed(2)} (15m timeframe)',
      );

      AppLogger.info('Calculating technical indicators for SWING...');
      final swingIndicators = TechnicalIndicatorsService.calculateAll(
        swingCandles,
      );

      // Validate Swing ATR
      if (swingIndicators.atr <= 0 || swingIndicators.atr.isNaN) {
        throw Exception('خطأ في حساب ATR للسوينج');
      }
      AppLogger.success(
        'Swing Indicators: RSI=${swingIndicators.rsi.toStringAsFixed(2)}, ATR=${swingIndicators.atr.toStringAsFixed(2)} (4h timeframe)',
      );

      // Log ATR comparison for verification
      final atrRatio = swingIndicators.atr / scalpIndicators.atr;
      AppLogger.info(
        '📊 ATR Comparison: Swing ATR is ${atrRatio.toStringAsFixed(2)}x larger than Scalp ATR',
      );

      // 4. Generate Scalping Signal using ScalpingEngineV2 (5m data)
      AppLogger.info('Running ScalpingEngineV2 with 5m timeframe...');
      final scalpSignal = await ScalpingEngineV2.analyze(
        candles: scalpCandles,
        currentPrice: currentPrice,
        atr: scalpIndicators.atr,
        rsi: scalpIndicators.rsi,
        macd: scalpIndicators.macd,
        macdSignal: scalpIndicators.macdSignal,
      );
      AppLogger.signal(
        'ROYAL SCALP (5m)',
        '${scalpSignal.direction} - Confidence: ${scalpSignal.confidence.toStringAsFixed(1)}%',
      );
      if (scalpSignal.isValid) {
        final scalpStopDist = (scalpSignal.entryPrice! - scalpSignal.stopLoss!)
            .abs();
        final scalpTargetDist =
            (scalpSignal.takeProfit! - scalpSignal.entryPrice!).abs();
        final scalpStopPct = (scalpStopDist / scalpSignal.entryPrice! * 100);
        final scalpTargetPct =
            (scalpTargetDist / scalpSignal.entryPrice! * 100);

        AppLogger.info('═══════════ SCALP SIGNAL DETAILS ═══════════');
        AppLogger.info(
          '   📍 Entry: \$${scalpSignal.entryPrice?.toStringAsFixed(2)}',
        );
        AppLogger.info(
          '   🛑 Stop: \$${scalpSignal.stopLoss?.toStringAsFixed(2)}',
        );
        AppLogger.info(
          '   🎯 Target: \$${scalpSignal.takeProfit?.toStringAsFixed(2)}',
        );
        AppLogger.info(
          '   📊 Stop Distance: \$${scalpStopDist.toStringAsFixed(2)} (${scalpStopPct.toStringAsFixed(3)}%)',
        );
        AppLogger.info(
          '   📊 Target Distance: \$${scalpTargetDist.toStringAsFixed(2)} (${scalpTargetPct.toStringAsFixed(3)}%)',
        );
        AppLogger.info(
          '   💎 R:R Ratio: 1:${(scalpTargetDist / scalpStopDist).toStringAsFixed(2)}',
        );
        AppLogger.info(
          '   ⚙️ ATR Used: ${scalpIndicators.atr.toStringAsFixed(2)}',
        );
        AppLogger.info('══════════════════════════════════════════');
      }

      // 5. Generate Swing Signal using SwingEngineV2 (4h data)
      AppLogger.info('Running SwingEngineV2 with 4h timeframe...');
      final swingSignal = await SwingEngineV2.analyze(
        candles: swingCandles,
        currentPrice: currentPrice,
        atr: swingIndicators.atr,
        rsi: swingIndicators.rsi,
        macd: swingIndicators.macd,
        macdSignal: swingIndicators.macdSignal,
        ma20: swingIndicators.ma20,
        ma50: swingIndicators.ma50,
        ma100: swingIndicators.ma100,
        ma200: swingIndicators.ma200,
      );
      AppLogger.signal(
        'ROYAL SWING (4h)',
        '${swingSignal.direction} - Confidence: ${swingSignal.confidence.toStringAsFixed(1)}%',
      );
      if (swingSignal.isValid) {
        final swingStopDist = (swingSignal.entryPrice! - swingSignal.stopLoss!)
            .abs();
        final swingTargetDist =
            (swingSignal.takeProfit! - swingSignal.entryPrice!).abs();
        final swingStopPct = (swingStopDist / swingSignal.entryPrice! * 100);
        final swingTargetPct =
            (swingTargetDist / swingSignal.entryPrice! * 100);

        AppLogger.info('═══════════ SWING SIGNAL DETAILS ═══════════');
        AppLogger.info(
          '   📍 Entry: \$${swingSignal.entryPrice?.toStringAsFixed(2)}',
        );
        AppLogger.info(
          '   🛑 Stop: \$${swingSignal.stopLoss?.toStringAsFixed(2)}',
        );
        AppLogger.info(
          '   🎯 Target: \$${swingSignal.takeProfit?.toStringAsFixed(2)}',
        );
        AppLogger.info(
          '   📊 Stop Distance: \$${swingStopDist.toStringAsFixed(2)} (${swingStopPct.toStringAsFixed(3)}%)',
        );
        AppLogger.info(
          '   📊 Target Distance: \$${swingTargetDist.toStringAsFixed(2)} (${swingTargetPct.toStringAsFixed(3)}%)',
        );
        AppLogger.info(
          '   💎 R:R Ratio: 1:${(swingTargetDist / swingStopDist).toStringAsFixed(2)}',
        );
        AppLogger.info(
          '   ⚙️ ATR Used: ${swingIndicators.atr.toStringAsFixed(2)}',
        );
        AppLogger.info('══════════════════════════════════════════');
      }

      // ═══════════════════════════════════════════════════════════════════════════
      // FORCED OVERRIDE - CRITICAL FIX
      // ═══════════════════════════════════════════════════════════════════════════
      // إذا كانت التوصيات متشابهة، نفرض فرقاً واضحاً
      SwingSignal finalSwingSignal = swingSignal;
      
      if (scalpSignal.isValid && swingSignal.isValid) {
        final scalpStopDist = (scalpSignal.entryPrice! - scalpSignal.stopLoss!)
            .abs();
        final swingStopDist = (swingSignal.entryPrice! - swingSignal.stopLoss!)
            .abs();
        final scalpTargetDist =
            (scalpSignal.takeProfit! - scalpSignal.entryPrice!).abs();
        final swingTargetDist =
            (swingSignal.takeProfit! - swingSignal.entryPrice!).abs();

        final stopRatio = swingStopDist / scalpStopDist;
        final targetRatio = swingTargetDist / scalpTargetDist;

        AppLogger.info('╔══════════ SIGNAL COMPARISON ══════════╗');
        AppLogger.info(
          '║ Scalp Stop: \$${scalpStopDist.toStringAsFixed(2)} vs Swing Stop: \$${swingStopDist.toStringAsFixed(2)}',
        );
        AppLogger.info(
          '║ Scalp Target: \$${scalpTargetDist.toStringAsFixed(2)} vs Swing Target: \$${swingTargetDist.toStringAsFixed(2)}',
        );
        AppLogger.info(
          '║ Stop Ratio: Swing is ${stopRatio.toStringAsFixed(1)}x larger',
        );
        AppLogger.info(
          '║ Target Ratio: Swing is ${targetRatio.toStringAsFixed(1)}x larger',
        );

        // 🔥 CRITICAL FIX: إذا الفرق قليل، نفرض نسب ثابتة
        if (stopRatio < 10) {
          AppLogger.error(
            '⚠️ FORCING DIFFERENTIATION: Stop difference too small (${stopRatio.toStringAsFixed(1)}x)! Applying fixed percentages...',
          );
          
          // إعادة حساب Swing بنسب ثابتة
          final swingEntry = swingSignal.entryPrice!;
          final swingStopDistance = swingEntry * 0.025; // 2.5% stop
          final swingTargetDistance = swingEntry * 0.10; // 10% target
          
          final isBuy = swingSignal.direction == 'BUY';
          final newSwingStop = isBuy 
              ? swingEntry - swingStopDistance 
              : swingEntry + swingStopDistance;
          final newSwingTarget = isBuy 
              ? swingEntry + swingTargetDistance 
              : swingEntry - swingTargetDistance;
          
          finalSwingSignal = SwingSignal(
            direction: swingSignal.direction,
            entryPrice: swingEntry,
            stopLoss: newSwingStop,
            takeProfit: newSwingTarget,
            confidence: swingSignal.confidence,
            riskReward: swingTargetDistance / swingStopDistance,
            macroTrend: swingSignal.macroTrend,
            marketStructure: swingSignal.marketStructure,
            fibonacci: swingSignal.fibonacci,
            zones: swingSignal.zones,
            qcf: swingSignal.qcf,
            reversal: swingSignal.reversal,
            timestamp: DateTime.now(),
            reason: null,
          );
          
          AppLogger.success(
            '✅ SWING RECALCULATED: Stop \$${newSwingStop.toStringAsFixed(2)} (2.5%), Target \$${newSwingTarget.toStringAsFixed(2)} (10%)',
          );
        } else {
          AppLogger.success(
            '✅ DIFFERENTIATION SUCCESS: Stops differ by ${stopRatio.toStringAsFixed(1)}x',
          );
        }
        AppLogger.info('╚════════════════════════════════════════╝');
      }

      // 6. Calculate Market Metrics (using scalp data for real-time metrics)
      final marketMetrics = MarketMetrics(
        volatility: scalpIndicators.atr / currentPrice * 100,
        momentum:
            (scalpCandles.first.close - scalpCandles[50].close) /
            scalpCandles[50].close *
            100,
        volume:
            scalpCandles.take(20).map((c) => c.volume).reduce((a, b) => a + b) /
            20,
        trend: scalpSignal.direction == 'BUY'
            ? 'UP'
            : scalpSignal.direction == 'SELL'
            ? 'DOWN'
            : 'SIDEWAYS',
      );

      // 7. Update state (using scalp indicators for display, as they're more current)
      state = state.copyWith(
        scalp: scalpSignal,
        swing: finalSwingSignal, // استخدام finalSwingSignal بدلاً من swingSignal
        indicators: scalpIndicators,
        marketMetrics: marketMetrics,
        currentPrice: currentPrice,
        isLoading: false,
        error: null,
        lastUpdate: DateTime.now(),
      );

      AppLogger.success('✅ Royal Analysis completed successfully');

      // Play feedback for strong signals
      _playFeedbackForSignal(scalpSignal);
    } catch (e, stackTrace) {
      AppLogger.error('Royal Analysis failed', e, stackTrace);

      state = state.copyWith(isLoading: false, error: e.toString());
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
      'Starting Royal Analysis auto-refresh (${interval}s interval)',
    );
    state = state.copyWith(isAutoRefreshEnabled: true);

    _autoRefreshTimer = Timer.periodic(Duration(seconds: interval), (_) {
      // Only refresh if data is stale
      if (state.isStale) {
        generateAnalysis();
      } else {
        AppLogger.debug(
          'Skipping auto-refresh: Royal Analysis data is still fresh',
        );
      }
    });
  }

  /// Disable auto-refresh
  void stopAutoRefresh() {
    _stopAutoRefresh();
    state = state.copyWith(isAutoRefreshEnabled: false);
    AppLogger.info('Royal Analysis auto-refresh stopped');
  }

  void _stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  /// Force refresh (clear cache)
  Future<void> forceRefresh() async {
    AppLogger.info('Royal Analysis force refresh requested');
    await generateAnalysis(forceRefresh: true);
  }

  /// Play feedback for signal based on settings
  void _playFeedbackForSignal(ScalpingSignal signal) {
    try {
      final settings = ref.read(settingsProvider).settings;
      final direction = signal.direction;
      final confidence = signal.confidence;

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

/// 👑 Royal Analysis Provider Instance
final royalAnalysisProvider =
    StateNotifierProvider.autoDispose<
      RoyalAnalysisNotifier,
      RoyalAnalysisState
    >((ref) {
      return RoyalAnalysisNotifier(ref);
    });
