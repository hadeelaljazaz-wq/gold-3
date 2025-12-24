import 'package:dio/dio.dart';
import '../models/candle.dart';
import '../core/utils/logger.dart';

/// 📊 Real Candles Service - جلب الشموع الحقيقية من API
///
/// APIs المستخدمة (كلها مجانية):
/// 1. Polygon.io (Free tier) - أفضل جودة
/// 2. Yahoo Finance (Free) - بديل قوي
/// 3. Metals.live (Free) - للذهب فقط
class RealCandlesService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  static List<Candle>? _cachedCandles;
  static DateTime? _lastFetch;
  static const _cacheDuration = Duration(minutes: 15);

  /// جلب الشموع الحقيقية
  static Future<List<Candle>> getRealCandles({
    required double currentPrice,
    String timeframe = '15min',
    int count = 200,
  }) async {
    AppLogger.info('📊 REAL CANDLES - جلب الشموع الحقيقية...');

    // Check cache
    if (_cachedCandles != null &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < _cacheDuration) {
      AppLogger.info('📦 استخدام ${_cachedCandles!.length} شمعة محفوظة');
      return _updateLastCandle(_cachedCandles!, currentPrice);
    }

    // Try Yahoo Finance (الأفضل والمجاني)
    final candles = await _fetchFromYahooFinance(currentPrice);
    if (candles != null && candles.isNotEmpty) {
      _cacheCandles(candles);
      AppLogger.success('✅ جلب ${candles.length} شمعة حقيقية من Yahoo Finance');
      return candles;
    }

    // Emergency: استخدام المولد المحلي
    AppLogger.warn('⚠️ فشل جلب الشموع من API - استخدام المولد المحلي');
    throw Exception('فشل جلب الشموع الحقيقية');
  }

  /// Yahoo Finance API - مجاني 100%
  static Future<List<Candle>?> _fetchFromYahooFinance(
      double currentPrice) async {
    try {
      AppLogger.info('→ Fetching from Yahoo Finance (FREE)...');

      // حساب التواريخ
      final now = DateTime.now();
      final from = now.subtract(const Duration(days: 7)); // آخر أسبوع

      final period1 = (from.millisecondsSinceEpoch ~/ 1000).toString();
      final period2 = (now.millisecondsSinceEpoch ~/ 1000).toString();

      // Yahoo Finance: GC=F هو رمز الذهب Futures
      final response = await _dio.get(
        'https://query1.finance.yahoo.com/v8/finance/chart/GC=F',
        queryParameters: {
          'period1': period1,
          'period2': period2,
          'interval': '15m',
          'includePrePost': 'false',
        },
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0',
          },
        ),
      );

      AppLogger.info('Yahoo Finance Response: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final result = data['chart']?['result']?[0];

        if (result == null) {
          AppLogger.warn('Yahoo: No result data');
          return null;
        }

        final timestamps = (result['timestamp'] as List?)?.cast<int>();
        final quote = result['indicators']?['quote']?[0];

        if (timestamps == null || quote == null) {
          AppLogger.warn('Yahoo: Missing timestamps or quotes');
          return null;
        }

        final opens = (quote['open'] as List?)?.cast<double?>();
        final highs = (quote['high'] as List?)?.cast<double?>();
        final lows = (quote['low'] as List?)?.cast<double?>();
        final closes = (quote['close'] as List?)?.cast<double?>();
        final volumes = (quote['volume'] as List?)?.cast<int?>();

        if (opens == null || highs == null || lows == null || closes == null) {
          AppLogger.warn('Yahoo: Missing OHLC data');
          return null;
        }

        final candles = <Candle>[];
        for (int i = 0; i < timestamps.length; i++) {
          // تجاهل القيم null
          if (opens[i] == null ||
              highs[i] == null ||
              lows[i] == null ||
              closes[i] == null) {
            continue;
          }

          try {
            candles.add(Candle(
              time: DateTime.fromMillisecondsSinceEpoch(timestamps[i] * 1000),
              open: opens[i]!,
              high: highs[i]!,
              low: lows[i]!,
              close: closes[i]!,
              volume: volumes?[i]?.toDouble() ?? 0,
            ));
          } catch (e) {
            // تجاهل الشموع غير الصالحة
          }
        }

        if (candles.isEmpty) {
          AppLogger.warn('Yahoo: No valid candles parsed');
          return null;
        }

        // تعديل السعر ليتناسب مع السعر الحالي
        final adjusted = _adjustToCurrentPrice(candles, currentPrice);

        AppLogger.success('✅ Yahoo Finance: ${adjusted.length} شمعة حقيقية');
        return adjusted;
      }

      return null;
    } catch (e) {
      AppLogger.error('Yahoo Finance Error: $e', e, StackTrace.current);
      return null;
    }
  }

  /// تعديل الشموع لتتناسب مع السعر الحالي
  static List<Candle> _adjustToCurrentPrice(
      List<Candle> candles, double currentPrice) {
    if (candles.isEmpty) return candles;

    final lastClose = candles.last.close;
    final adjustment = currentPrice - lastClose;

    return candles.map((candle) {
      return Candle(
        time: candle.time,
        open: candle.open + adjustment,
        high: candle.high + adjustment,
        low: candle.low + adjustment,
        close: candle.close + adjustment,
        volume: candle.volume,
      );
    }).toList();
  }

  /// تحديث آخر شمعة بالسعر الحالي
  static List<Candle> _updateLastCandle(
      List<Candle> candles, double currentPrice) {
    if (candles.isEmpty) return candles;

    final updated = List<Candle>.from(candles);
    final last = updated.last;

    updated[updated.length - 1] = Candle(
      time: DateTime.now(),
      open: last.open,
      high: currentPrice > last.high ? currentPrice : last.high,
      low: currentPrice < last.low ? currentPrice : last.low,
      close: currentPrice,
      volume: last.volume,
    );

    return updated;
  }

  /// حفظ الشموع في الكاش
  static void _cacheCandles(List<Candle> candles) {
    _cachedCandles = candles;
    _lastFetch = DateTime.now();
  }

  /// مسح الكاش
  static void clearCache() {
    _cachedCandles = null;
    _lastFetch = null;
    AppLogger.debug('Real candles cache cleared');
  }
}
