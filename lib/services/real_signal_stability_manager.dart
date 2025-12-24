import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'technical_analysis_engine.dart';
import '../core/utils/logger.dart';

/// 🔒 Real Signal Stability Manager
/// يضمن ثبات الإشارات ومنع التغيير العشوائي
/// ✅ Scalp: ثابت 15 دقيقة أو حتى يتغير السعر 0.1%
/// ✅ Swing: ثابت 4 ساعات أو حتى يتغير السعر 0.3%
class RealSignalStabilityManager {
  static const String _scalpSignalKey = 'real_cached_scalp_signal';
  static const String _swingSignalKey = 'real_cached_swing_signal';

  // Cache duration
  static const Duration scalpCacheDuration = Duration(minutes: 15);
  static const Duration swingCacheDuration = Duration(hours: 4);

  // Price change threshold to invalidate signal
  static const double scalpPriceThreshold = 0.001; // 0.1%
  static const double swingPriceThreshold = 0.003; // 0.3%

  // ═══════════════════════════════════════════════════════════════════
  // 💾 CACHE MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════

  /// حفظ إشارة Scalp
  static Future<void> cacheScalpSignal(
    TradingSignal signal,
    double currentPrice,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final cache = {
      'signal': _signalToJson(signal),
      'cachedPrice': currentPrice,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await prefs.setString(_scalpSignalKey, json.encode(cache));
    AppLogger.debug('💾 Cached scalp signal: ${signal.directionString}');
  }

  /// حفظ إشارة Swing
  static Future<void> cacheSwingSignal(
    TradingSignal signal,
    double currentPrice,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final cache = {
      'signal': _signalToJson(signal),
      'cachedPrice': currentPrice,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await prefs.setString(_swingSignalKey, json.encode(cache));
    AppLogger.debug('💾 Cached swing signal: ${signal.directionString}');
  }

  /// استرجاع إشارة Scalp
  static Future<CachedSignal?> getCachedScalpSignal() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_scalpSignalKey);

    if (cached == null) return null;

    try {
      final data = json.decode(cached) as Map<String, dynamic>;
      final signal = _signalFromJson(data['signal']);
      final cachedPrice = (data['cachedPrice'] as num).toDouble();
      final timestamp = DateTime.parse(data['timestamp']);

      return CachedSignal(
        signal: signal,
        cachedPrice: cachedPrice,
        timestamp: timestamp,
      );
    } catch (e) {
      AppLogger.error('❌ Error parsing cached scalp signal', e);
      return null;
    }
  }

  /// استرجاع إشارة Swing
  static Future<CachedSignal?> getCachedSwingSignal() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_swingSignalKey);

    if (cached == null) return null;

    try {
      final data = json.decode(cached) as Map<String, dynamic>;
      final signal = _signalFromJson(data['signal']);
      final cachedPrice = (data['cachedPrice'] as num).toDouble();
      final timestamp = DateTime.parse(data['timestamp']);

      return CachedSignal(
        signal: signal,
        cachedPrice: cachedPrice,
        timestamp: timestamp,
      );
    } catch (e) {
      AppLogger.error('❌ Error parsing cached swing signal', e);
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // ✅ VALIDATION
  // ═══════════════════════════════════════════════════════════════════

  /// التحقق من صلاحية إشارة Scalp
  static bool isScalpSignalValid(
    CachedSignal? cached,
    double currentPrice,
  ) {
    if (cached == null) {
      AppLogger.debug('📊 No cached scalp signal - will generate new');
      return false;
    }

    // Check age
    final age = DateTime.now().difference(cached.timestamp);
    if (age > scalpCacheDuration) {
      AppLogger.debug('⏰ Scalp signal expired (age: ${age.inMinutes}min) - will generate new');
      return false;
    }

    // Check price change
    final priceChange =
        ((currentPrice - cached.cachedPrice) / cached.cachedPrice).abs();
    if (priceChange > scalpPriceThreshold) {
      AppLogger.debug('📈 Price changed ${(priceChange * 100).toStringAsFixed(2)}% - will generate new scalp signal');
      return false;
    }

    AppLogger.debug('✅ Using cached scalp signal (age: ${age.inMinutes}min)');
    return true;
  }

  /// التحقق من صلاحية إشارة Swing
  static bool isSwingSignalValid(
    CachedSignal? cached,
    double currentPrice,
  ) {
    if (cached == null) {
      AppLogger.debug('📊 No cached swing signal - will generate new');
      return false;
    }

    // Check age
    final age = DateTime.now().difference(cached.timestamp);
    if (age > swingCacheDuration) {
      AppLogger.debug('⏰ Swing signal expired (age: ${age.inHours}h) - will generate new');
      return false;
    }

    // Check price change (swing has higher threshold: 0.3%)
    final priceChange =
        ((currentPrice - cached.cachedPrice) / cached.cachedPrice).abs();
    if (priceChange > swingPriceThreshold) {
      AppLogger.debug('📈 Price changed ${(priceChange * 100).toStringAsFixed(2)}% - will generate new swing signal');
      return false;
    }

    AppLogger.debug('✅ Using cached swing signal (age: ${age.inHours}h ${age.inMinutes % 60}min)');
    return true;
  }

  /// حذف الكاش
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scalpSignalKey);
    await prefs.remove(_swingSignalKey);
    AppLogger.debug('🗑️ Signal cache cleared');
  }

  // ═══════════════════════════════════════════════════════════════════
  // 🔄 JSON CONVERSION
  // ═══════════════════════════════════════════════════════════════════

  static Map<String, dynamic> _signalToJson(TradingSignal signal) {
    return {
      'direction': signal.direction.toString(),
      'confidence': signal.confidence,
      'entryPrice': signal.entryPrice,
      'stopLoss': signal.stopLoss,
      'target1': signal.target1,
      'target2': signal.target2,
      'timestamp': signal.timestamp.toIso8601String(),
      'indicators': {
        'ema20': signal.indicators.ema20,
        'ema50': signal.indicators.ema50,
        'rsi': signal.indicators.rsi,
        'atr': signal.indicators.atr,
        'support': signal.indicators.support,
        'resistance': signal.indicators.resistance,
      },
    };
  }

  static TradingSignal _signalFromJson(Map<String, dynamic> json) {
    final directionString = json['direction'] as String;
    final direction = SignalDirection.values.firstWhere(
      (e) => e.toString() == directionString,
      orElse: () => SignalDirection.neutral,
    );

    final indicators = json['indicators'] as Map<String, dynamic>;

    return TradingSignal(
      direction: direction,
      confidence: json['confidence'] as int,
      entryPrice: (json['entryPrice'] as num).toDouble(),
      stopLoss: (json['stopLoss'] as num).toDouble(),
      target1: (json['target1'] as num).toDouble(),
      target2: (json['target2'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      indicators: IndicatorValues(
        ema20: (indicators['ema20'] as num).toDouble(),
        ema50: (indicators['ema50'] as num).toDouble(),
        rsi: (indicators['rsi'] as num).toDouble(),
        macd: MACDResult(macdLine: 0, signalLine: 0, histogram: 0),
        bollingerBands: BollingerBandsResult(
          upper: 0,
          middle: 0,
          lower: 0,
        ),
        atr: (indicators['atr'] as num?)?.toDouble() ?? 1.0,
        support: (indicators['support'] as num).toDouble(),
        resistance: (indicators['resistance'] as num).toDouble(),
      ),
    );
  }
}

/// 📦 Cached Signal Model
class CachedSignal {
  final TradingSignal signal;
  final double cachedPrice;
  final DateTime timestamp;

  CachedSignal({
    required this.signal,
    required this.cachedPrice,
    required this.timestamp,
  });

  Duration get age => DateTime.now().difference(timestamp);

  String get ageString {
    final minutes = age.inMinutes;
    if (minutes < 1) return 'منذ لحظات';
    if (minutes < 60) return 'منذ $minutes دقيقة';
    final hours = age.inHours;
    return 'منذ $hours ساعة';
  }
}
