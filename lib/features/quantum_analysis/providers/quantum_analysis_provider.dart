import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/quantum_scalping/quantum_scalping_engine.dart';
import '../../../services/quantum_scalping/quantum_engine_isolate.dart';
import '../../../models/candle.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/execution_guard.dart';
import '../../../core/utils/performance_monitor.dart';
import '../../../core/services/market_data_service.dart';
import '../../settings/providers/settings_provider.dart';

/// Quantum Analysis State
class QuantumAnalysisState {
  final QuantumSignal? signal;
  final dynamic quantumState;
  final dynamic temporalFlux;
  final dynamic smartMoneyFlow;
  final dynamic chaosAnalysis;
  final dynamic quantumCorrelation;
  final dynamic bayesianProbability;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdate;

  QuantumAnalysisState({
    this.signal,
    this.quantumState,
    this.temporalFlux,
    this.smartMoneyFlow,
    this.chaosAnalysis,
    this.quantumCorrelation,
    this.bayesianProbability,
    this.isLoading = false,
    this.error,
    this.lastUpdate,
  });

  QuantumAnalysisState copyWith({
    QuantumSignal? signal,
    dynamic quantumState,
    dynamic temporalFlux,
    dynamic smartMoneyFlow,
    dynamic chaosAnalysis,
    dynamic quantumCorrelation,
    dynamic bayesianProbability,
    bool? isLoading,
    String? error,
    DateTime? lastUpdate,
  }) {
    return QuantumAnalysisState(
      signal: signal ?? this.signal,
      quantumState: quantumState ?? this.quantumState,
      temporalFlux: temporalFlux ?? this.temporalFlux,
      smartMoneyFlow: smartMoneyFlow ?? this.smartMoneyFlow,
      chaosAnalysis: chaosAnalysis ?? this.chaosAnalysis,
      quantumCorrelation: quantumCorrelation ?? this.quantumCorrelation,
      bayesianProbability: bayesianProbability ?? this.bayesianProbability,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  /// Check if analysis data is stale (older than 60 seconds)
  bool get isStale {
    if (lastUpdate == null) return true;
    return DateTime.now().difference(lastUpdate!) > const Duration(seconds: 60);
  }
}

/// Quantum Analysis Notifier
class QuantumAnalysisNotifier extends StateNotifier<QuantumAnalysisState> {
  final Ref ref;
  DateTime? _lastApiCall;
  static const _minApiInterval = Duration(seconds: 10);
  static const Duration _analysisTimeout = Duration(seconds: 8);
  
  // 🔒 حماية من التشغيل المتزامن
  static final _executionGuard = ExecutionGuard();
  static const _lockKey = 'quantum_analysis';

  QuantumAnalysisNotifier(this.ref) : super(QuantumAnalysisState());

  /// Generate quantum analysis
  Future<void> generateAnalysis({bool forceRefresh = false}) async {
    await _executeAnalysis(forceRefresh: forceRefresh);
  }

  /// Internal method to execute quantum analysis
  Future<void> _executeAnalysis({bool forceRefresh = false}) async {
    // Check cache first (no lock needed for cache hits)
    if (!forceRefresh && !state.isStale && state.signal != null) {
      AppLogger.info(
          'Using cached quantum analysis (age: ${DateTime.now().difference(state.lastUpdate!).inSeconds}s)');
      return;
    }

    // 🔒 Execution guard - prevent concurrent runs
    if (!_executionGuard.tryAcquire(_lockKey)) {
      AppLogger.warn('❌ Quantum analysis already running, blocked concurrent execution');
      return;
    }

    // Prevent multiple simultaneous calls (double check)
    if (state.isLoading) {
      _executionGuard.release(_lockKey);
      AppLogger.warn('Quantum analysis already in progress, skipping');
      return;
    }

    // Rate limiting (bypass if forceRefresh requested)
    if (!forceRefresh &&
        _lastApiCall != null &&
        DateTime.now().difference(_lastApiCall!) < _minApiInterval) {
      final remainingSeconds = _minApiInterval.inSeconds -
          DateTime.now().difference(_lastApiCall!).inSeconds;
      AppLogger.warn(
          'Rate limit: Please wait ${remainingSeconds}s before next call');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    AppLogger.analysis(
        'QuantumScalping', 'Starting quantum analysis generation');

    // 📊 مراقبة الأداء
    final perfMonitor = PerformanceMonitor();
    perfMonitor.startStage('total_analysis', budgetMs: 8000);

    try {
      await _runWithTimeout(() => _runAnalysisFlow(perfMonitor), _analysisTimeout);
      if (!mounted) {
        AppLogger.warn('Quantum notifier disposed after analysis; aborting');
        return;
      }
    } on TimeoutException catch (e, stackTrace) {
      AppLogger.error('Quantum analysis timed out', e, stackTrace);
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          error: 'انتهت مهلة التحليل الكمومي، حاول مرة أخرى.',
        );
      }
      return;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to generate quantum analysis', e, stackTrace);
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
        );
      }
      return;
    } finally {
      // 📊 إنهاء مراقبة الأداء وطباعة التقرير
      perfMonitor.endStage('total_analysis');
      final report = perfMonitor.getReport();
      AppLogger.info(report.toString());

      // 🔓 تحرير القفل دائماً
      _executionGuard.release(_lockKey);

      if (mounted && state.isLoading) {
        // Safety guard to avoid sticky loader
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> _runAnalysisFlow(PerformanceMonitor perfMonitor) async {
    // 1. Get market data with OHLCV from MarketDataService
    perfMonitor.startStage('market_data_fetch', budgetMs: 3000);
    AppLogger.info('🔄 جلب بيانات السوق (OHLCV) من APIs...');

    final marketData = await MarketDataService.getCandles(
      symbol: 'XAU/USD',
      interval: '5min',
      outputSize: 500,
    ).timeout(const Duration(seconds: 5), onTimeout: () async {
      AppLogger.warn('Market data API timed out, using fallback');
      return MarketDataService.getCandles(
        symbol: 'XAU/USD',
        interval: '5min',
        outputSize: 500,
      );
    });

    if (marketData.candles.isEmpty) {
      throw Exception('لا توجد بيانات السوق متاحة');
    }
    perfMonitor.endStage('market_data_fetch');

    // 2. Convert CandleData to Candle model
    perfMonitor.startStage('data_conversion', budgetMs: 100);
    final candles = marketData.candles.map((candleData) {
      return Candle(
        time: candleData.timestamp,
        open: candleData.open,
        high: candleData.high,
        low: candleData.low,
        close: candleData.close,
        volume: candleData.volume ?? 0,
      );
    }).toList();

    final currentPrice = candles.last.close;
    AppLogger.success('💰 السعر الحالي: \$${currentPrice.toStringAsFixed(2)}');
    AppLogger.success(
        '✅ تم تحميل ${candles.length} شمعة من ${marketData.symbol}');
    _lastApiCall = DateTime.now();
    perfMonitor.endStage('data_conversion');

    // 3. Run Quantum Scalping Engine في Isolate منفصل
    perfMonitor.startStage('quantum_engine', budgetMs: 3000);
    AppLogger.info('Running Quantum Scalping Engine (7 layers) in Isolate...');
    final signal = await QuantumEngineIsolate.analyzeInIsolate(
      goldCandles: candles,
      dxyCandles: null, // Can be added later
      bondsCandles: null, // Can be added later
    );
    perfMonitor.endStage('quantum_engine');

    AppLogger.success(
      '✅ Quantum Signal: ${signal.direction.name} - Score: ${signal.quantumScore.toStringAsFixed(1)}/10',
    );

    if (mounted) {
      state = state.copyWith(
        signal: signal,
        isLoading: false,
        error: null,
        lastUpdate: DateTime.now(),
      );

      AppLogger.success('Quantum analysis generation completed successfully');

      // Play feedback for strong signals (only if still mounted)
      _playFeedbackForSignal(signal);
    } else {
      AppLogger.warn('Quantum notifier disposed before finishing analysis; skipping state update');
    }
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
          'Quantum analysis timed out after ${timeout.inSeconds}s',
        ),
      ),
    ]);
  }

  /// Force refresh (clear cache and regenerate)
  Future<void> forceRefresh() async {
    AppLogger.info('Force refresh quantum analysis requested');
    await generateAnalysis(forceRefresh: true);
  }

  /// Play feedback for signal based on settings
  void _playFeedbackForSignal(QuantumSignal signal) {
    try {
      final settings = ref.read(settingsProvider).settings;
      final direction = signal.direction.name;
      final score = signal.quantumScore * 10; // Convert to percentage

      // Play sound if enabled
      if (settings.soundEffectsEnabled && score >= 70) {
        if (score >= 85) {
          SystemSound.play(SystemSoundType.alert);
          AppLogger.info('🔊 Played STRONG signal alert');
        } else {
          SystemSound.play(SystemSoundType.click);
          AppLogger.info('🔊 Played signal click');
        }
      }

      // Vibrate if enabled
      if (settings.vibrationEnabled && score >= 80) {
        HapticFeedback.heavyImpact();
        AppLogger.info('📳 Vibrated for ${direction.toUpperCase()} signal');

        // Double vibration for very strong signals
        if (score >= 90) {
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

/// Quantum Analysis Provider
final quantumAnalysisProvider =
    StateNotifierProvider.autoDispose<QuantumAnalysisNotifier, QuantumAnalysisState>((ref) {
  return QuantumAnalysisNotifier(ref);
});
