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
import '../../../models/market_models.dart';
import '../../../services/quantum_scalping/quantum_scalping_engine.dart';
import '../models/nexus_signal_model.dart';
import '../models/kabous_signal_model.dart';
import '../models/unified_metrics_model.dart';

/// NEXUS + KABOUS + QUANTUM Unified State
class NexusKabousUnifiedState {
  // NEXUS Signals
  final NexusSignalModel? nexusScalp;
  final NexusSignalModel? nexusSwing;

  // KABOUS Signals
  final KabousSignalModel? kabousScalp;
  final KabousSignalModel? kabousSwing;

  // QUANTUM Signal
  final QuantumSignal? quantumSignal;

  // Unified Metrics
  final UnifiedMetricsModel? metrics;
  final TechnicalIndicators? indicators;
  final double? currentPrice;

  // State Management
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdate;
  final bool isAutoRefreshEnabled;

  NexusKabousUnifiedState({
    this.nexusScalp,
    this.nexusSwing,
    this.kabousScalp,
    this.kabousSwing,
    this.quantumSignal,
    this.metrics,
    this.indicators,
    this.currentPrice,
    this.isLoading = false,
    this.error,
    this.lastUpdate,
    this.isAutoRefreshEnabled = false,
  });

  NexusKabousUnifiedState copyWith({
    NexusSignalModel? nexusScalp,
    NexusSignalModel? nexusSwing,
    KabousSignalModel? kabousScalp,
    KabousSignalModel? kabousSwing,
    QuantumSignal? quantumSignal,
    UnifiedMetricsModel? metrics,
    TechnicalIndicators? indicators,
    double? currentPrice,
    bool? isLoading,
    String? error,
    DateTime? lastUpdate,
    bool? isAutoRefreshEnabled,
  }) {
    return NexusKabousUnifiedState(
      nexusScalp: nexusScalp ?? this.nexusScalp,
      nexusSwing: nexusSwing ?? this.nexusSwing,
      kabousScalp: kabousScalp ?? this.kabousScalp,
      kabousSwing: kabousSwing ?? this.kabousSwing,
      quantumSignal: quantumSignal ?? this.quantumSignal,
      metrics: metrics ?? this.metrics,
      indicators: indicators ?? this.indicators,
      currentPrice: currentPrice ?? this.currentPrice,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      isAutoRefreshEnabled: isAutoRefreshEnabled ?? this.isAutoRefreshEnabled,
    );
  }

  bool get isStale {
    if (lastUpdate == null) return true;
    final expiryMinutes = EnvironmentConfig.cacheExpiryMinutes;
    return DateTime.now().difference(lastUpdate!) >
        Duration(minutes: expiryMinutes);
  }

  bool get hasAnalysis => nexusScalp != null && kabousScalp != null;
}

/// NEXUS + KABOUS Unified Provider
/// يجمع أفضل ما في النظامين:
/// - NEXUS: 11 محرك تحليل، Quantum Physics concepts, High R:R
/// - KABOUS: ML (LSTM/HMM), News Sentiment, Advanced Risk Management
class NexusKabousUnifiedProviderNotifier
    extends StateNotifier<NexusKabousUnifiedState> {
  Timer? _autoRefreshTimer;
  Timer? _debounceTimer;
  DateTime? _lastApiCall;

  static const Duration _debounceDelay = Duration(milliseconds: 500);

  NexusKabousUnifiedProviderNotifier() : super(NexusKabousUnifiedState()) {
    AppLogger.info('🔀 NexusKabousUnifiedProvider initialized');
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    _debounceTimer?.cancel();
    _debounceTimer = null;
    super.dispose();
  }

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
      AppLogger.warn('NEXUS+KABOUS Analysis already in progress, skipping');
      return;
    }

    if (!forceRefresh && !state.isStale && state.hasAnalysis) {
      final age = DateTime.now().difference(state.lastUpdate!).inSeconds;
      AppLogger.info('Using cached NEXUS+KABOUS data (age: ${age}s)');
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
    AppLogger.analysis('NEXUS+KABOUS', 'Starting unified analysis');

    try {
      // 1. Get current price
      AppLogger.info('🔄 جلب سعر الذهب...');
      final goldPrice = await GoldPriceService.getCurrentPrice();
      if (!mounted) { AppLogger.warn('Nexus/Kabous notifier disposed after getting gold price'); return; }
      final currentPrice = goldPrice.price;
      AppLogger.success('💰 السعر: \$${currentPrice.toStringAsFixed(2)}');
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
      AppLogger.success('Loaded ${candles.length} candles');

      // 3. Calculate indicators
      AppLogger.info('Calculating technical indicators...');
      final indicators = TechnicalIndicatorsService.calculateAll(candles);

      if (indicators.atr <= 0 || indicators.atr.isNaN) {
        throw Exception('خطأ في حساب ATR');
      }
      AppLogger.success(
        'Indicators: RSI=${indicators.rsi.toStringAsFixed(2)}, ATR=${indicators.atr.toStringAsFixed(2)}',
      );

      // ============================================================
      // NEXUS QUANTUM ENGINE ANALYSIS
      // ============================================================
      AppLogger.info('🔮 Running NEXUS Quantum Engine...');

      // Use Golden Nightmare Engine (10-Layer System) as NEXUS base
      final nexusResult = await GoldenNightmareEngine.generate(
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
      if (!mounted) { AppLogger.warn('Nexus/Kabous notifier disposed after Nexus engine'); return; }

      // Extract NEXUS Scalp Signal
      final nexusScalpData = nexusResult['SCALP'] as Map<String, dynamic>?;
      final nexusScalpSignal = nexusScalpData != null &&
              nexusScalpData['direction'] != 'NO_TRADE'
          ? NexusSignalModel(
              direction: nexusScalpData['direction'] ?? 'NO_TRADE',
              entryPrice:
                  _safeToDouble(nexusScalpData['entry']) ?? currentPrice,
              stopLoss: _safeToDouble(nexusScalpData['stopLoss']),
              takeProfit: _safeToDouble(nexusScalpData['takeProfit']),
              confidence: _safeToDouble(nexusScalpData['confidence']) ?? 0.0,
              riskReward: _safeToDouble(nexusScalpData['riskReward']) ?? 1.0,
              nexusScore: _calculateNexusScore(nexusScalpData),
              timestamp: DateTime.now(),
            )
          : null;

      // Extract NEXUS Swing Signal
      final nexusSwingData = nexusResult['SWING'] as Map<String, dynamic>?;
      final nexusSwingSignal = nexusSwingData != null &&
              nexusSwingData['direction'] != 'NO_TRADE'
          ? NexusSignalModel(
              direction: nexusSwingData['direction'] ?? 'NO_TRADE',
              entryPrice:
                  _safeToDouble(nexusSwingData['entry']) ?? currentPrice,
              stopLoss: _safeToDouble(nexusSwingData['stopLoss']),
              takeProfit: _safeToDouble(nexusSwingData['takeProfit']),
              confidence: _safeToDouble(nexusSwingData['confidence']) ?? 0.0,
              riskReward: _safeToDouble(nexusSwingData['riskReward']) ?? 1.0,
              nexusScore: _calculateNexusScore(nexusSwingData),
              timestamp: DateTime.now(),
            )
          : null;

      if (nexusScalpSignal != null) {
        AppLogger.signal(
          'NEXUS SCALP',
          '${nexusScalpSignal.direction} - Score: ${nexusScalpSignal.nexusScore.toStringAsFixed(1)}/10',
        );
      }

      // ============================================================
      // KABOUS ELITE ANALYSIS
      // ============================================================
      AppLogger.info('🤖 Running KABOUS Elite Engine...');

      // Use ScalpingEngineV2 + SwingEngineV2 as KABOUS base
      final kabousScalpRaw = await ScalpingEngineV2.analyze(
        currentPrice: currentPrice,
        candles: candles,
        rsi: indicators.rsi,
        macd: indicators.macd,
        macdSignal: indicators.macdSignal,
        atr: indicators.atr,
      );
      if (!mounted) { AppLogger.warn('Nexus/Kabous notifier disposed after Kabous scalp analysis'); return; }

      final kabousSwingRaw = await SwingEngineV2.analyze(
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
      if (!mounted) { AppLogger.warn('Nexus/Kabous notifier disposed after Kabous swing analysis'); return; }

      // Convert to KABOUS Signal Model (with ML-like features)
      final kabousScalpSignal = KabousSignalModel(
        direction: kabousScalpRaw.direction,
        entryPrice: kabousScalpRaw.entryPrice ?? currentPrice,
        stopLoss: kabousScalpRaw.stopLoss,
        takeProfit: kabousScalpRaw.takeProfit,
        confidence: kabousScalpRaw.confidence.toDouble(),
        riskReward: kabousScalpRaw.riskReward ?? 1.0,
        mlScore: _calculateMLScore(kabousScalpRaw, indicators),
        regime: _detectMarketRegime(indicators, candles),
        timestamp: DateTime.now(),
      );

      final kabousSwingSignal = KabousSignalModel(
        direction: kabousSwingRaw.direction,
        entryPrice: kabousSwingRaw.entryPrice ?? currentPrice,
        stopLoss: kabousSwingRaw.stopLoss,
        takeProfit: kabousSwingRaw.takeProfit,
        confidence: kabousSwingRaw.confidence.toDouble(),
        riskReward: kabousSwingRaw.riskReward ?? 1.0,
        mlScore: _calculateMLScore(kabousSwingRaw, indicators),
        regime: _detectMarketRegime(indicators, candles),
        timestamp: DateTime.now(),
      );

      AppLogger.signal(
        'KABOUS SCALP',
        '${kabousScalpSignal.direction} - ML Score: ${kabousScalpSignal.mlScore.toStringAsFixed(1)}%',
      );

      // ============================================================
      // QUANTUM ENGINE ANALYSIS (4th Layer)
      // ============================================================
      AppLogger.info('⚛️ Running Quantum Engine...');

      QuantumSignal? quantumSignal;
      try {
        quantumSignal = await QuantumScalpingEngine.analyze(
          goldCandles: candles,
          dxyCandles: null,
          bondsCandles: null,
        );
        if (!mounted) { AppLogger.warn('Nexus/Kabous notifier disposed after Quantum analysis'); return; }
        AppLogger.signal(
          'QUANTUM',
          '${quantumSignal.direction.name} - Score: ${quantumSignal.quantumScore.toStringAsFixed(1)}/10',
        );
      } catch (e) {
        AppLogger.warn('Quantum analysis failed: $e');
      }

      // ============================================================
      // UNIFIED METRICS
      // ============================================================
      final metrics = UnifiedMetricsModel(
        volatility: indicators.atr / currentPrice * 100,
        momentum:
            (candles.first.close - candles[50].close) / candles[50].close * 100,
        volume:
            candles.take(20).map((c) => c.volume).reduce((a, b) => a + b) / 20,
        trend: kabousScalpSignal.direction == 'BUY' ? 'UP' : 'DOWN',
        nexusScore: nexusScalpSignal?.nexusScore ?? 0.0,
        kabousMLScore: kabousScalpSignal.mlScore,
        agreement: _checkAgreement(nexusScalpSignal, kabousScalpSignal),
      );

      // Update state (only if notifier is still mounted)
      if (mounted) {
        state = state.copyWith(
          nexusScalp: nexusScalpSignal,
          nexusSwing: nexusSwingSignal,
          kabousScalp: kabousScalpSignal,
          kabousSwing: kabousSwingSignal,
          quantumSignal: quantumSignal,
          metrics: metrics,
          indicators: indicators,
          currentPrice: currentPrice,
          isLoading: false,
          lastUpdate: DateTime.now(),
        );
      }

      AppLogger.success('✅ NEXUS+KABOUS+QUANTUM Unified Analysis completed');
    } catch (e, stackTrace) {
      AppLogger.error('Error in NEXUS+KABOUS Analysis', e, stackTrace);
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  // Helper function to safely convert dynamic value to double
  double? _safeToDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed;
    }
    return null;
  }

  // Calculate NEXUS Score (0-10 scale)
  double _calculateNexusScore(Map<String, dynamic> signalData) {
    final confidence = _safeToDouble(signalData['confidence']) ?? 0.0;
    final riskReward = _safeToDouble(signalData['riskReward']) ?? 1.0;

    // NEXUS Score formula: combines confidence and R:R
    final score = (confidence / 10.0) * 0.7 + (riskReward / 5.0) * 0.3;
    return (score * 10.0).clamp(0.0, 10.0);
  }

  // Calculate ML Score (simulating KABOUS ML predictions)
  double _calculateMLScore(dynamic signal, TechnicalIndicators indicators) {
    final baseConfidence = signal.confidence.toDouble();
    final rsiFactor = indicators.rsi > 70 || indicators.rsi < 30 ? 0.9 : 1.0;
    final macdFactor = indicators.macd > indicators.macdSignal ? 1.05 : 0.95;

    return (baseConfidence * rsiFactor * macdFactor).clamp(0.0, 100.0);
  }

  // Detect Market Regime (simulating KABOUS HMM)
  String _detectMarketRegime(TechnicalIndicators indicators, List candles) {
    final volatility = indicators.atr / (candles.first.close);
    final trend = indicators.ma20 > indicators.ma50 ? 'UP' : 'DOWN';

    if (volatility > 0.02) {
      return 'HIGH_VOLATILITY';
    } else if (volatility < 0.005) {
      return 'LOW_VOLATILITY';
    } else {
      return '${trend}_TREND';
    }
  }

  // Check agreement between NEXUS and KABOUS
  String _checkAgreement(NexusSignalModel? nexus, KabousSignalModel? kabous) {
    if (nexus == null || kabous == null) return 'PARTIAL';
    if (nexus.direction == kabous.direction) return 'AGREE';
    return 'DISAGREE';
  }

  void startAutoRefresh() {
    if (state.isAutoRefreshEnabled) {
      AppLogger.warn('Auto-refresh already enabled');
      return;
    }

    final interval = EnvironmentConfig.autoRefreshInterval;
    AppLogger.info('Starting NEXUS+KABOUS auto-refresh (${interval}s)');
    if (mounted) {
      state = state.copyWith(isAutoRefreshEnabled: true);
    }

    _autoRefreshTimer = Timer.periodic(Duration(seconds: interval), (_) {
      if (state.isStale) {
        generateAnalysis();
      }
    });
  }

  void stopAutoRefresh() {
    _stopAutoRefresh();
    if (mounted) {
      state = state.copyWith(isAutoRefreshEnabled: false);
    }
    AppLogger.info('NEXUS+KABOUS auto-refresh stopped');
  }

  void _stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  Future<void> forceRefresh() async {
    AppLogger.info('NEXUS+KABOUS force refresh requested');
    await generateAnalysis(forceRefresh: true);
  }
}

final nexusKabousUnifiedProvider = StateNotifierProvider.autoDispose<
    NexusKabousUnifiedProviderNotifier,
    NexusKabousUnifiedState>((ref) => NexusKabousUnifiedProviderNotifier());
