/// 🎯 Signal Stability Manager - مدير استقرار الإشارات
///
/// **المشكلة:** التوصيات تتغير كل دقيقة
/// **الحل:** استقرار الإشارات لمدة معينة
///
/// **القواعد:**
/// 1. لا تغيير إلا إذا تغير السعر > 0.5% (للسكالب) أو > 1% (للسوينج)
/// 2. الإشارة تبقى ثابتة لمدة 15 دقيقة minimum (سكالب) أو 4 ساعات (سوينج)
/// 3. لا تغيير إلا إذا وصل الستوب أو الهدف
library;

import '../core/utils/logger.dart';
import '../models/scalping_signal.dart';
import '../models/swing_signal.dart';

class SignalStabilityManager {
  // ══════════════════════════════════════════════════════════════════════════
  // SINGLETON PATTERN
  // ══════════════════════════════════════════════════════════════════════════

  static final SignalStabilityManager _instance =
      SignalStabilityManager._internal();
  factory SignalStabilityManager() => _instance;
  SignalStabilityManager._internal();

  // ══════════════════════════════════════════════════════════════════════════
  // STABLE SIGNALS STORAGE
  // ══════════════════════════════════════════════════════════════════════════

  ScalpingSignal? _stableScalpSignal;
  SwingSignal? _stableSwingSignal;

  DateTime? _scalpSignalTimestamp;
  DateTime? _swingSignalTimestamp;

  double? _scalpEntryPrice;
  double? _swingEntryPrice;

  // ══════════════════════════════════════════════════════════════════════════
  // CONFIGURATION
  // ══════════════════════════════════════════════════════════════════════════

  /// الحد الأدنى لعمر إشارة السكالب قبل التغيير (15 دقيقة)
  static const Duration scalpMinAge = Duration(minutes: 15);

  /// الحد الأدنى لعمر إشارة السوينج قبل التغيير (4 ساعات)
  static const Duration swingMinAge = Duration(hours: 4);

  /// الحد الأدنى لتغير السعر لتحديث السكالب (0.5%)
  static const double scalpMinPriceChange = 0.005;

  /// الحد الأدنى لتغير السعر لتحديث السوينج (1%)
  static const double swingMinPriceChange = 0.01;

  // ══════════════════════════════════════════════════════════════════════════
  // PUBLIC API - SCALPING
  // ══════════════════════════════════════════════════════════════════════════

  /// الحصول على إشارة سكالب مستقرة
  ///
  /// **Parameters:**
  /// - [newSignal]: الإشارة الجديدة من المحرك
  /// - [currentPrice]: السعر الحالي
  ///
  /// **Returns:**
  /// - الإشارة المستقرة (قد تكون القديمة أو الجديدة)
  ScalpingSignal getStableScalpSignal({
    required ScalpingSignal newSignal,
    required double currentPrice,
  }) {
    // إذا لا توجد إشارة سابقة → أرجع الجديدة
    if (_stableScalpSignal == null) {
      AppLogger.info('📌 إشارة سكالب جديدة: ${newSignal.direction}');
      _updateScalpSignal(newSignal, currentPrice);
      return newSignal;
    }

    // فحص عمر الإشارة الحالية
    final age = DateTime.now().difference(_scalpSignalTimestamp!);

    // إذا الإشارة جديدة (< 15 دقيقة) → لا تغيير
    if (age < scalpMinAge) {
      final remainingMinutes = (scalpMinAge.inMinutes - age.inMinutes);
      AppLogger.info(
          '⏰ إشارة السكالب ثابتة (متبقي: ${remainingMinutes} دقيقة)');
      return _stableScalpSignal!;
    }

    // فحص تغير السعر
    if (_scalpEntryPrice != null) {
      final priceChange =
          ((currentPrice - _scalpEntryPrice!) / _scalpEntryPrice!).abs();

      // إذا التغير قليل (< 0.5%) → لا تغيير
      if (priceChange < scalpMinPriceChange) {
        AppLogger.info(
            '📊 السعر مستقر (${(priceChange * 100).toStringAsFixed(2)}%) - لا تغيير');
        return _stableScalpSignal!;
      }
    }

    // فحص وصول الستوب أو الهدف
    if (_shouldUpdateScalp(newSignal, currentPrice)) {
      AppLogger.success(
          '🔄 تحديث إشارة السكالب: ${_stableScalpSignal!.direction} → ${newSignal.direction}');
      _updateScalpSignal(newSignal, currentPrice);
      return newSignal;
    }

    // افتراضياً → أرجع الإشارة الثابتة
    AppLogger.info('✅ الحفاظ على إشارة السكالب الحالية');
    return _stableScalpSignal!;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PUBLIC API - SWING
  // ══════════════════════════════════════════════════════════════════════════

  /// الحصول على إشارة سوينج مستقرة
  SwingSignal getStableSwingSignal({
    required SwingSignal newSignal,
    required double currentPrice,
  }) {
    // إذا لا توجد إشارة سابقة → أرجع الجديدة
    if (_stableSwingSignal == null) {
      AppLogger.info('📌 إشارة سوينج جديدة: ${newSignal.direction}');
      _updateSwingSignal(newSignal, currentPrice);
      return newSignal;
    }

    // فحص عمر الإشارة الحالية
    final age = DateTime.now().difference(_swingSignalTimestamp!);

    // إذا الإشارة جديدة (< 4 ساعات) → لا تغيير
    if (age < swingMinAge) {
      final remainingHours = (swingMinAge.inHours - age.inHours);
      AppLogger.info('⏰ إشارة السوينج ثابتة (متبقي: ${remainingHours} ساعة)');
      return _stableSwingSignal!;
    }

    // فحص تغير السعر
    if (_swingEntryPrice != null) {
      final priceChange =
          ((currentPrice - _swingEntryPrice!) / _swingEntryPrice!).abs();

      // إذا التغير قليل (< 1%) → لا تغيير
      if (priceChange < swingMinPriceChange) {
        AppLogger.info(
            '📊 السعر مستقر (${(priceChange * 100).toStringAsFixed(2)}%) - لا تغيير');
        return _stableSwingSignal!;
      }
    }

    // فحص وصول الستوب أو الهدف
    if (_shouldUpdateSwing(newSignal, currentPrice)) {
      AppLogger.success(
          '🔄 تحديث إشارة السوينج: ${_stableSwingSignal!.direction} → ${newSignal.direction}');
      _updateSwingSignal(newSignal, currentPrice);
      return newSignal;
    }

    // افتراضياً → أرجع الإشارة الثابتة
    AppLogger.info('✅ الحفاظ على إشارة السوينج الحالية');
    return _stableSwingSignal!;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PRIVATE METHODS
  // ══════════════════════════════════════════════════════════════════════════

  /// تحديث إشارة السكالب المخزنة
  void _updateScalpSignal(ScalpingSignal signal, double currentPrice) {
    _stableScalpSignal = signal;
    _scalpSignalTimestamp = DateTime.now();
    _scalpEntryPrice = signal.entryPrice ?? currentPrice;
  }

  /// تحديث إشارة السوينج المخزنة
  void _updateSwingSignal(SwingSignal signal, double currentPrice) {
    _stableSwingSignal = signal;
    _swingSignalTimestamp = DateTime.now();
    _swingEntryPrice = signal.entryPrice ?? currentPrice;
  }

  /// فحص ضرورة تحديث إشارة السكالب
  bool _shouldUpdateScalp(ScalpingSignal newSignal, double currentPrice) {
    final oldSignal = _stableScalpSignal!;

    // 1. إذا الاتجاه تغير بشكل جذري (BUY → SELL أو العكس)
    if (oldSignal.direction == 'BUY' && newSignal.direction == 'SELL') {
      return true;
    }
    if (oldSignal.direction == 'SELL' && newSignal.direction == 'BUY') {
      return true;
    }

    // 2. إذا وصل السعر للستوب
    if (oldSignal.stopLoss != null) {
      if (oldSignal.direction == 'BUY' && currentPrice <= oldSignal.stopLoss!) {
        AppLogger.warn('🛑 وصل الستوب لوس (سكالب BUY)');
        return true;
      }
      if (oldSignal.direction == 'SELL' &&
          currentPrice >= oldSignal.stopLoss!) {
        AppLogger.warn('🛑 وصل الستوب لوس (سكالب SELL)');
        return true;
      }
    }

    // 3. إذا وصل السعر للهدف
    if (oldSignal.takeProfit != null) {
      if (oldSignal.direction == 'BUY' &&
          currentPrice >= oldSignal.takeProfit!) {
        AppLogger.success('🎯 وصل الهدف (سكالب BUY)');
        return true;
      }
      if (oldSignal.direction == 'SELL' &&
          currentPrice <= oldSignal.takeProfit!) {
        AppLogger.success('🎯 وصل الهدف (سكالب SELL)');
        return true;
      }
    }

    // 4. إذا الثقة انخفضت بشكل كبير (> 20%)
    final confidenceDrop = (oldSignal.confidence - newSignal.confidence).abs();
    if (confidenceDrop > 20) {
      AppLogger.warn('⚠️ انخفاض كبير في الثقة (${confidenceDrop}%)');
      return true;
    }

    return false;
  }

  /// فحص ضرورة تحديث إشارة السوينج
  bool _shouldUpdateSwing(SwingSignal newSignal, double currentPrice) {
    final oldSignal = _stableSwingSignal!;

    // 1. إذا الاتجاه تغير بشكل جذري
    if (oldSignal.direction == 'BUY' && newSignal.direction == 'SELL') {
      return true;
    }
    if (oldSignal.direction == 'SELL' && newSignal.direction == 'BUY') {
      return true;
    }

    // 2. إذا وصل السعر للستوب
    if (oldSignal.stopLoss != null) {
      if (oldSignal.direction == 'BUY' && currentPrice <= oldSignal.stopLoss!) {
        AppLogger.warn('🛑 وصل الستوب لوس (سوينج BUY)');
        return true;
      }
      if (oldSignal.direction == 'SELL' &&
          currentPrice >= oldSignal.stopLoss!) {
        AppLogger.warn('🛑 وصل الستوب لوس (سوينج SELL)');
        return true;
      }
    }

    // 3. إذا وصل السعر للهدف
    if (oldSignal.takeProfit != null) {
      if (oldSignal.direction == 'BUY' &&
          currentPrice >= oldSignal.takeProfit!) {
        AppLogger.success('🎯 وصل الهدف (سوينج BUY)');
        return true;
      }
      if (oldSignal.direction == 'SELL' &&
          currentPrice <= oldSignal.takeProfit!) {
        AppLogger.success('🎯 وصل الهدف (سوينج SELL)');
        return true;
      }
    }

    // 4. إذا الثقة انخفضت بشكل كبير (> 15%)
    final confidenceDrop = (oldSignal.confidence - newSignal.confidence).abs();
    if (confidenceDrop > 15) {
      AppLogger.warn('⚠️ انخفاض كبير في الثقة (${confidenceDrop}%)');
      return true;
    }

    return false;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // RESET & CLEAR
  // ══════════════════════════════════════════════════════════════════════════

  /// إجبار تحديث الإشارات (للتحديث اليدوي)
  void forceUpdate() {
    AppLogger.warn('🔄 إجبار تحديث جميع الإشارات');
    _stableScalpSignal = null;
    _stableSwingSignal = null;
    _scalpSignalTimestamp = null;
    _swingSignalTimestamp = null;
    _scalpEntryPrice = null;
    _swingEntryPrice = null;
  }

  /// مسح إشارة السكالب فقط
  void clearScalpSignal() {
    AppLogger.info('🗑️ مسح إشارة السكالب');
    _stableScalpSignal = null;
    _scalpSignalTimestamp = null;
    _scalpEntryPrice = null;
  }

  /// مسح إشارة السوينج فقط
  void clearSwingSignal() {
    AppLogger.info('🗑️ مسح إشارة السوينج');
    _stableSwingSignal = null;
    _swingSignalTimestamp = null;
    _swingEntryPrice = null;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // GETTERS
  // ══════════════════════════════════════════════════════════════════════════

  /// الحصول على الإشارة الحالية (بدون تحديث)
  ScalpingSignal? get currentScalpSignal => _stableScalpSignal;
  SwingSignal? get currentSwingSignal => _stableSwingSignal;

  /// الحصول على عمر الإشارات
  Duration? get scalpSignalAge => _scalpSignalTimestamp != null
      ? DateTime.now().difference(_scalpSignalTimestamp!)
      : null;

  Duration? get swingSignalAge => _swingSignalTimestamp != null
      ? DateTime.now().difference(_swingSignalTimestamp!)
      : null;
}
