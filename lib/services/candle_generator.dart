import 'dart:math';
import '../models/candle.dart';

/// خدمة توليد الشموع التاريخية
/// تُستخدم لتوليد بيانات شموع واقعية بناءً على السعر الحالي
/// ✅ مع CACHE لضمان استقرار البيانات
class CandleGenerator {
  static final _random = Random();

  // ✅ Cache للبيانات بناءً على السعر والإطار الزمني
  static final Map<String, List<Candle>> _candleCache = {};
  static final Map<String, double> _basePriceCache = {};
  static final Map<String, DateTime> _cacheTimestamp = {};

  // ✅ مدة صلاحية الـ cache (5 دقائق)
  static const Duration _cacheExpiry = Duration(minutes: 5);

  /// توليد شموع تاريخية (مع cache)
  static List<Candle> generate({
    required double currentPrice,
    required int count,
    String timeframe = '15m',
  }) {
    // ✅ Cache key يتضمن الـ seed لضمان بيانات مختلفة لكل timeframe
    final seed = _getTimeframeSeed(timeframe);
    final cacheKey = '${timeframe}_${count}_$seed';

    // ✅ التحقق من الـ cache
    if (_candleCache.containsKey(cacheKey)) {
      final cachedTime = _cacheTimestamp[cacheKey];
      final cachedBasePrice = _basePriceCache[cacheKey];

      // إذا السعر قريب جداً من السعر المحفوظ (أقل من 0.5%)
      // والبيانات لسه جديدة، استخدم الـ cache
      if (cachedTime != null && cachedBasePrice != null) {
        final age = DateTime.now().difference(cachedTime);
        final priceChange =
            ((currentPrice - cachedBasePrice).abs() / cachedBasePrice) * 100;

        if (age < _cacheExpiry && priceChange < 0.5) {
          // ✅ استخدام بيانات محفوظة + تحديث آخر شمعة فقط
          final cached = List<Candle>.from(_candleCache[cacheKey]!);
          return _updateLastCandle(cached, currentPrice);
        }
      }
    }

    // ✅ توليد بيانات جديدة فقط إذا تغير السعر كثير أو انتهى الـ cache
    final candles = _generateNewCandles(
      currentPrice: currentPrice,
      count: count,
      timeframe: timeframe,
    );

    // حفظ في الـ cache
    _candleCache[cacheKey] = candles;
    _basePriceCache[cacheKey] = currentPrice;
    _cacheTimestamp[cacheKey] = DateTime.now();

    return candles;
  }

  /// تحديث آخر شمعة فقط (بدلاً من توليد كل البيانات من جديد)
  static List<Candle> _updateLastCandle(
      List<Candle> candles, double currentPrice) {
    if (candles.isEmpty) return candles;

    final updated = List<Candle>.from(candles);
    final last = updated.last;

    // تحديث آخر شمعة بالسعر الحالي
    updated[updated.length - 1] = Candle(
      time: DateTime.now(),
      open: last.open,
      high: max(last.high, currentPrice),
      low: min(last.low, currentPrice),
      close: currentPrice,
      volume: last.volume + (100 + _random.nextDouble() * 200),
    );

    return updated;
  }

  /// الحصول على seed مخصص لكل إطار زمني لضمان اختلاف البيانات
  static int _getTimeframeSeed(String timeframe) {
    switch (timeframe) {
      case '1m':
        return 11111;
      case '5m':
        return 12345; // Scalping seed
      case '15m':
        return 23456;
      case '1h':
        return 34567;
      case '4h':
        return 67890; // Swing seed
      case '1d':
        return 78901;
      default:
        return 50000;
    }
  }

  /// الحصول على ملف تعريف التقلب حسب الإطار الزمني
  static double _getVolatilityProfile(String timeframe) {
    switch (timeframe) {
      case '1m':
        return 0.003; // High volatility for 1-minute
      case '5m':
        return 0.006; // Very high volatility for scalping (5m) - INCREASED
      case '15m':
        return 0.002; // Medium volatility
      case '1h':
        return 0.0015; // Lower volatility
      case '4h':
        return 0.001; // Low volatility for swing (4h)
      case '1d':
        return 0.001; // Low volatility for daily
      default:
        return 0.002; // Default medium
    }
  }

  /// توليد بيانات جديدة (مع تقلب متكيف حسب الإطار الزمني)
  static List<Candle> _generateNewCandles({
    required double currentPrice,
    required int count,
    required String timeframe,
  }) {
    final candles = <Candle>[];
    final now = DateTime.now();
    final timeframeDuration = _getTimeframeDuration(timeframe);

    // ✅ استخدام Random مخصص بـ seed مختلف لكل إطار زمني
    // نضيف السعر الحالي للـ seed عشان البيانات تتغير، بس تظل مختلفة بين الأطر
    final baseSeed = _getTimeframeSeed(timeframe);
    final priceSeed = (currentPrice * 1000).toInt(); // تحويل السعر لرقم صحيح
    final seed = baseSeed + (priceSeed % 10000); // دمج الـ seeds
    final random = Random(seed);

    // ✅ استخدام ملف تقلب مخصص لكل إطار زمني
    final baseVolatility = _getVolatilityProfile(timeframe);

    // بدء التوليد من السعر الحالي والعودة للخلف
    double price = currentPrice;
    int previousDirection = 1; // 1 = up, -1 = down

    for (int i = count - 1; i >= 0; i--) {
      final candleTime = now.subtract(timeframeDuration * i);

      // ✅ توليد تغير عشوائي واقعي (متكيف حسب الإطار الزمني)
      // 5m: 0.0018 - 0.0102 (very high, choppy)
      // 4h: 0.0003 - 0.002 (low, smooth)
      final volatility =
          (baseVolatility * 0.3) + (random.nextDouble() * baseVolatility * 1.7);

      // ✅ تطبيق Trend Persistence حسب الإطار الزمني
      int direction;
      if (timeframe == '5m' || timeframe == '1m') {
        // Scalping: 50% chance to continue same direction (choppy)
        direction =
            random.nextDouble() < 0.5 ? previousDirection : -previousDirection;
      } else if (timeframe == '4h' || timeframe == '1d') {
        // Swing: 70% chance to continue same direction (trending)
        direction =
            random.nextDouble() < 0.7 ? previousDirection : -previousDirection;
      } else {
        // Default: 60% chance
        direction =
            random.nextDouble() < 0.6 ? previousDirection : -previousDirection;
      }

      final change = (price * volatility) * direction;

      final open = price;
      final close = price + change;

      // توليد High/Low واقعية (متكيفة حسب الإطار الزمني)
      // 5m: More aggressive wicks
      final wickMultiplier = timeframe == '5m' || timeframe == '1m' ? 1.5 : 1.0;
      final highOffset =
          price * (0.0002 + (random.nextDouble() * 0.002)) * wickMultiplier;
      final lowOffset =
          price * (0.0002 + (random.nextDouble() * 0.002)) * wickMultiplier;

      final high = max(open, close) + highOffset;
      final low = min(open, close) - lowOffset;

      // توليد حجم تداول واقعي (أعلى للأطر الزمنية الأكبر)
      final volumeMultiplier =
          timeframe == '4h' || timeframe == '1d' ? 2.0 : 1.0;
      final volume =
          (1000.0 + (random.nextDouble() * 9000.0)) * volumeMultiplier;

      candles.insert(
        0,
        Candle(
          time: candleTime,
          open: open,
          high: high,
          low: low,
          close: close,
          volume: volume,
        ),
      );

      // تحديث السعر والاتجاه للشمعة التالية
      price = close;
      previousDirection = direction;
    }

    return candles;
  }

  /// مسح الـ cache (يستخدم عند تغيير الإطار الزمني)
  static void clearCache() {
    _candleCache.clear();
    _basePriceCache.clear();
    _cacheTimestamp.clear();
  }

  /// الحصول على مدة الإطار الزمني
  static Duration _getTimeframeDuration(String timeframe) {
    switch (timeframe) {
      case '1m':
        return const Duration(minutes: 1);
      case '5m':
        return const Duration(minutes: 5);
      case '15m':
        return const Duration(minutes: 15);
      case '1h':
        return const Duration(hours: 1);
      case '4h':
        return const Duration(hours: 4);
      case '1d':
        return const Duration(days: 1);
      default:
        return const Duration(minutes: 15);
    }
  }
}
