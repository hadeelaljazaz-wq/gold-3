import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/real_market_data_service.dart';
import '../../../services/technical_analysis_engine.dart';
import '../../../services/real_signal_stability_manager.dart';
import '../../../services/csv_data_service.dart';
import '../../../services/real_levels_detector.dart';
import '../../../models/support_resistance_level.dart';
import '../../../core/utils/logger.dart';

/// 🎯 Real Unified Analysis State
/// الحالة الجديدة بتحليل حقيقي وإشارات ثابتة
class RealUnifiedAnalysisState {
  final double currentPrice;
  final double priceChange;
  final double changePercent;
  final TradingSignal scalpSignal;
  final TradingSignal swingSignal;
  final RealSupportResistance? realLevels;
  final bool isLoading;
  final String? error;
  final DateTime lastUpdate;

  RealUnifiedAnalysisState({
    required this.currentPrice,
    required this.priceChange,
    required this.changePercent,
    required this.scalpSignal,
    required this.swingSignal,
    this.realLevels,
    required this.isLoading,
    this.error,
    required this.lastUpdate,
  });

  factory RealUnifiedAnalysisState.initial() {
    final now = DateTime.now();
    return RealUnifiedAnalysisState(
      currentPrice: 2645.80,
      priceChange: 0,
      changePercent: 0,
      scalpSignal: TradingSignal.neutral(2645.80),
      swingSignal: TradingSignal.neutral(2645.80),
      isLoading: true,
      lastUpdate: now,
    );
  }

  RealUnifiedAnalysisState copyWith({
    double? currentPrice,
    double? priceChange,
    double? changePercent,
    TradingSignal? scalpSignal,
    TradingSignal? swingSignal,
    RealSupportResistance? realLevels,
    bool? isLoading,
    String? error,
    DateTime? lastUpdate,
  }) {
    return RealUnifiedAnalysisState(
      currentPrice: currentPrice ?? this.currentPrice,
      priceChange: priceChange ?? this.priceChange,
      changePercent: changePercent ?? this.changePercent,
      scalpSignal: scalpSignal ?? this.scalpSignal,
      swingSignal: swingSignal ?? this.swingSignal,
      realLevels: realLevels ?? this.realLevels,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}

/// 🎯 Real Unified Analysis Notifier
/// المحرك الجديد بتحليل تقني حقيقي
class RealUnifiedAnalysisNotifier
    extends StateNotifier<RealUnifiedAnalysisState> {
  RealUnifiedAnalysisNotifier() : super(RealUnifiedAnalysisState.initial()) {
    AppLogger.info('🚀 RealUnifiedAnalysisNotifier initialized');
    _initialize();
  }

  // Previous price for change calculation
  double? _previousPrice;

  // ═══════════════════════════════════════════════════════════════════
  // 🚀 INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _initialize() async {
    // مسح الـ cache القديم عند بدء التشغيل لتجنب الإشارات المعكوسة
    await RealSignalStabilityManager.clearCache();
    AppLogger.info('🗑️ Old signal cache cleared on startup');
    await refresh();
  }

  // ═══════════════════════════════════════════════════════════════════
  // 🔄 REFRESH
  // ═══════════════════════════════════════════════════════════════════

  Future<void> refresh() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      AppLogger.info('🔄 Starting real analysis...');

      // ✅ مسح الكاش قبل كل تحديث للتأكد من إشارات جديدة
      await RealSignalStabilityManager.clearCache();
      AppLogger.debug('🗑️ Cache cleared for fresh signals');

      // 1. Get current price
      final currentPrice = await RealMarketDataService.getCurrentPrice();
      AppLogger.info('💰 Current price: \$${currentPrice.toStringAsFixed(2)}');

      // 2. Calculate price change
      final priceChange =
          _previousPrice != null ? currentPrice - _previousPrice! : 0.0;
      final changePercent =
          _previousPrice != null ? (priceChange / _previousPrice!) * 100 : 0.0;

      _previousPrice = currentPrice;

      // 3. Generate fresh Scalp signal (no cache)
      AppLogger.debug('🔍 Generating FRESH Scalp signal...');
      final scalpSignal = await TechnicalAnalysisEngine.generateScalpSignal();
      AppLogger.signal('SCALP', '${scalpSignal.directionString} (${scalpSignal.confidence}%)');

      // 4. Generate fresh Swing signal (no cache)
      AppLogger.debug('🔍 Generating FRESH Swing signal...');
      final swingSignal = await TechnicalAnalysisEngine.generateSwingSignal();
      AppLogger.signal('SWING', '${swingSignal.directionString} (${swingSignal.confidence}%)');

      // 🆕 5. استخراج المستويات الحقيقية من CSV
      RealSupportResistance? realLevels;
      try {
        AppLogger.info('📂 Loading CSV data for real levels...');
        final csvCandles = await CsvDataService.loadSwingData();
        if (csvCandles.isNotEmpty) {
          realLevels = await RealLevelsDetector.extractLevels(
            candles: csvCandles,
            currentPrice: currentPrice,
            timeframe: '4h',
          );
          AppLogger.success('✅ Extracted ${realLevels.supports.length} supports & ${realLevels.resistances.length} resistances');
        }
      } catch (e) {
        AppLogger.warn('⚠️ Failed to extract real levels: $e');
      }

      // 6. Update state
      state = state.copyWith(
        currentPrice: currentPrice,
        priceChange: priceChange,
        changePercent: changePercent,
        scalpSignal: scalpSignal,
        swingSignal: swingSignal,
        realLevels: realLevels,
        isLoading: false,
        lastUpdate: DateTime.now(),
      );

      AppLogger.success('✅ Real analysis complete!');
    } catch (e) {
      AppLogger.error('❌ Error refreshing analysis', e);
      state = state.copyWith(
        isLoading: false,
        error: 'فشل تحديث التحليل: $e',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // 🔧 UTILITIES
  // ═══════════════════════════════════════════════════════════════════

  /// Force refresh Scalp signal (bypass cache)
  Future<void> forceRefreshScalp() async {
    try {
      state = state.copyWith(isLoading: true);
      AppLogger.info('🔄 Force refreshing scalp signal...');

      final currentPrice = await RealMarketDataService.getCurrentPrice();
      final signal = await TechnicalAnalysisEngine.generateScalpSignal();

      await RealSignalStabilityManager.cacheScalpSignal(signal, currentPrice);

      state = state.copyWith(
        currentPrice: currentPrice,
        scalpSignal: signal,
        isLoading: false,
        lastUpdate: DateTime.now(),
      );

      AppLogger.success('✅ Scalp signal force refreshed: ${signal.directionString}');
    } catch (e) {
      AppLogger.error('❌ Error force refreshing scalp', e);
      state = state.copyWith(isLoading: false);
    }
  }

  /// Force refresh Swing signal (bypass cache)
  Future<void> forceRefreshSwing() async {
    try {
      state = state.copyWith(isLoading: true);
      AppLogger.info('🔄 Force refreshing swing signal...');

      final currentPrice = await RealMarketDataService.getCurrentPrice();
      final signal = await TechnicalAnalysisEngine.generateSwingSignal();

      await RealSignalStabilityManager.cacheSwingSignal(signal, currentPrice);

      state = state.copyWith(
        currentPrice: currentPrice,
        swingSignal: signal,
        isLoading: false,
        lastUpdate: DateTime.now(),
      );

      AppLogger.success('✅ Swing signal force refreshed: ${signal.directionString}');
    } catch (e) {
      AppLogger.error('❌ Error force refreshing swing', e);
      state = state.copyWith(isLoading: false);
    }
  }

  /// Clear all cached signals
  Future<void> clearCache() async {
    await RealSignalStabilityManager.clearCache();
    await refresh();
  }
}

/// 🎯 Provider
final realUnifiedAnalysisProvider = StateNotifierProvider.autoDispose<
    RealUnifiedAnalysisNotifier, RealUnifiedAnalysisState>(
  (ref) => RealUnifiedAnalysisNotifier(),
);
