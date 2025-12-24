import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/candle_data.dart';
import '../utils/logger.dart';
import '../utils/type_converter.dart';

/// 📊 Market Data Service
/// خدمة الحصول على بيانات OHLCV من مصادر متعددة
class MarketDataService {
  static final Dio _dio = Dio();

  // Cache للبيانات
  static final Map<String, _CacheEntry> _cache = {};
  static const Duration _cacheDuration = Duration(minutes: 1);

  /// الحصول على بيانات الشموع من مصادر متعددة
  static Future<MarketDataResponse> getCandles({
    required String symbol,
    String interval = '5min',
    int outputSize = 100,
  }) async {
    // التحقق من Cache
    final cacheKey = '$symbol-$interval-$outputSize';
    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey]!;
      if (DateTime.now().difference(cached.timestamp) < _cacheDuration) {
        AppLogger.info('📦 استخدام بيانات من Cache: $cacheKey');
        return cached.data;
      }
    }

    try {
      // محاولة GoldAPI أولاً (للذهب)
      String? goldApiKey;
      try {
        goldApiKey = dotenv.env['GOLD_PRICE_API_KEY'];
      } catch (_) {
        goldApiKey = null; // dotenv not initialized in tests
      }
      if (goldApiKey != null &&
          goldApiKey.isNotEmpty &&
          symbol.contains('XAU')) {
        AppLogger.info('🔄 جلب بيانات من GoldAPI...');
        final response = await _fetchFromGoldAPI(
          symbol: symbol,
          interval: interval,
          outputSize: outputSize,
          apiKey: goldApiKey,
        );

        // حفظ في Cache
        _cache[cacheKey] = _CacheEntry(
          data: response,
          timestamp: DateTime.now(),
        );

        return response;
      }

      // محاولة Twelve Data كاحتياطي
      String? twelveDataKey;
      try {
        twelveDataKey = dotenv.env['TWELVE_DATA_API_KEY'];
      } catch (_) {
        twelveDataKey = null; // dotenv not initialized in tests
      }
      if (twelveDataKey != null && twelveDataKey.isNotEmpty) {
        AppLogger.info('🔄 جلب بيانات من Twelve Data...');
        final response = await _fetchFromTwelveData(
          symbol: symbol,
          interval: interval,
          outputSize: outputSize,
          apiKey: twelveDataKey,
        );

        // حفظ في Cache
        _cache[cacheKey] = _CacheEntry(
          data: response,
          timestamp: DateTime.now(),
        );

        return response;
      }

      // إذا لم يتوفر API key، استخدم بيانات واقعية مولدة
      AppLogger.warn('⚠️ لا يوجد API key، استخدام بيانات واقعية مولدة...');
      return _generateRealisticData(symbol, interval, outputSize);
    } catch (e) {
      AppLogger.error('خطأ في جلب البيانات', e, StackTrace.current);
      // في حالة الخطأ، استخدم بيانات واقعية مولدة
      return _generateRealisticData(symbol, interval, outputSize);
    }
  }

  /// جلب البيانات من GoldAPI
  static Future<MarketDataResponse> _fetchFromGoldAPI({
    required String symbol,
    required String interval,
    required int outputSize,
    required String apiKey,
  }) async {
    final url = 'https://www.goldapi.io/api/XAU/USD';

    final response = await _dio.get(
      url,
      options: Options(
        headers: {
          'x-access-token': apiKey,
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('فشل جلب البيانات من GoldAPI: ${response.statusCode}');
    }

    final data = response.data;

    // GoldAPI يعطي بيانات اليوم فقط، نحتاج لتوليد شموع تاريخية
    final currentPrice = TypeConverter.safeToDouble(data['price']) ?? 2000.0;
    final openPrice = TypeConverter.safeToDouble(data['open_price']) ?? currentPrice;
    final highPrice = TypeConverter.safeToDouble(data['high_price']) ?? currentPrice;
    final lowPrice = TypeConverter.safeToDouble(data['low_price']) ?? currentPrice;
    final change = TypeConverter.safeToDouble(data['ch']) ?? 0.0;

    // توليد شموع تاريخية بناءً على البيانات الحالية
    final candles = _generateHistoricalFromCurrent(
      currentPrice: currentPrice,
      openPrice: openPrice,
      highPrice: highPrice,
      lowPrice: lowPrice,
      change: change,
      interval: interval,
      outputSize: outputSize,
    );

    AppLogger.success(
        '✅ تم جلب بيانات من GoldAPI وتوليد ${candles.length} شمعة');

    return MarketDataResponse(
      symbol: symbol,
      interval: interval,
      candles: candles,
      fetchedAt: DateTime.now(),
    );
  }

  /// جلب البيانات من Twelve Data API
  static Future<MarketDataResponse> _fetchFromTwelveData({
    required String symbol,
    required String interval,
    required int outputSize,
    required String apiKey,
  }) async {
    final url = 'https://api.twelvedata.com/time_series';

    final response = await _dio.get(
      url,
      queryParameters: {
        'symbol': symbol,
        'interval': interval,
        'outputsize': outputSize,
        'apikey': apiKey,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('فشل جلب البيانات: ${response.statusCode}');
    }

    final data = response.data;

    // التحقق من وجود خطأ في الاستجابة
    if (data['status'] == 'error') {
      throw Exception('خطأ من API: ${data['message']}');
    }

    // تحويل البيانات إلى CandleData
    final values = data['values'] as List;
    final candles = values.map((v) {
      return CandleData(
        timestamp: DateTime.parse(v['datetime']),
        open: double.parse(v['open']),
        high: double.parse(v['high']),
        low: double.parse(v['low']),
        close: double.parse(v['close']),
        volume: null, // Twelve Data لا يعطي Volume للذهب في الخطة المجانية
      );
    }).toList();

    AppLogger.success('✅ تم جلب ${candles.length} شمعة من Twelve Data');

    return MarketDataResponse(
      symbol: symbol,
      interval: interval,
      candles: candles,
      fetchedAt: DateTime.now(),
    );
  }

  /// توليد شموع تاريخية من البيانات الحالية (GoldAPI)
  static List<CandleData> _generateHistoricalFromCurrent({
    required double currentPrice,
    required double openPrice,
    required double highPrice,
    required double lowPrice,
    required double change,
    required String interval,
    required int outputSize,
  }) {
    final candles = <CandleData>[];
    final now = DateTime.now();
    final intervalMinutes = _parseInterval(interval);
    final random = Random();

    // الشمعة الحالية (الأحدث)
    final currentVolume = 1500000.0 + random.nextDouble() * 1000000.0;
    candles.add(CandleData(
      timestamp: now,
      open: openPrice,
      high: highPrice,
      low: lowPrice,
      close: currentPrice,
      volume: currentVolume,
    ));

    // حساب التقلب الأساسي
    final baseVolatility = (highPrice - lowPrice) / currentPrice;
    double prevClose = openPrice;

    // توليد بيانات واقعية مع trends و patterns
    int trendLength = 20 + random.nextInt(30); // 20-50 candles per trend
    int trendType = random.nextInt(3); // 0=bullish, 1=bearish, 2=sideways
    int candlesInTrend = 0;

    for (int i = 1; i < outputSize; i++) {
      final timestamp = now.subtract(Duration(minutes: intervalMinutes * i));

      // تغيير الاتجاه كل فترة
      if (candlesInTrend >= trendLength) {
        trendType = random.nextInt(3);
        trendLength = 20 + random.nextInt(30);
        candlesInTrend = 0;
      }
      candlesInTrend++;

      // تقلب متغير حسب قوة الاتجاه
      final volatilityMultiplier = 0.5 + random.nextDouble() * 1.5;
      final currentVolatility = baseVolatility * volatilityMultiplier;

      // حركة السعر حسب الاتجاه
      double priceChange;
      if (trendType == 0) {
        // Bullish trend
        priceChange = currentPrice *
            currentVolatility *
            (0.3 + random.nextDouble() * 0.7);
      } else if (trendType == 1) {
        // Bearish trend
        priceChange = -currentPrice *
            currentVolatility *
            (0.3 + random.nextDouble() * 0.7);
      } else {
        // Sideways
        priceChange = currentPrice *
            currentVolatility *
            (random.nextDouble() - 0.5) *
            0.5;
      }

      final open = prevClose;
      final close = open + priceChange;

      // High و Low واقعيين مع wicks
      final wickSize =
          currentPrice * currentVolatility * (0.2 + random.nextDouble() * 0.3);
      final high = max(open, close) + wickSize * random.nextDouble();
      final low = min(open, close) - wickSize * random.nextDouble();

      // Volume واقعي مع spikes
      final baseVolume = 800000.0 + random.nextDouble() * 1500000.0;
      final volumeSpike =
          random.nextDouble() < 0.15 ? (1.5 + random.nextDouble() * 2.0) : 1.0;
      final trendVolumeMultiplier =
          trendType == 2 ? 0.7 : 1.0; // Lower volume in sideways
      final volume = baseVolume * volumeSpike * trendVolumeMultiplier;

      candles.add(CandleData(
        timestamp: timestamp,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume,
      ));

      prevClose = close;
    }

    // عكس الترتيب ليكون الأحدث أولاً
    return candles.reversed.toList();
  }

  /// توليد بيانات واقعية (Fallback)
  static MarketDataResponse _generateRealisticData(
    String symbol,
    String interval,
    int outputSize,
  ) {
    AppLogger.info('🎲 توليد بيانات واقعية لـ $symbol...');

    final random = Random();

    // سعر أساسي واقعي للذهب
    double basePrice = 2650.0;

    // إذا كان الرمز يحتوي على XAU، استخدم سعر الذهب الحالي
    if (symbol.contains('XAU')) {
      basePrice =
          2650.0 + (DateTime.now().millisecondsSinceEpoch % 100).toDouble();
    }

    final candles = <CandleData>[];
    final now = DateTime.now();

    // حساب الفترة الزمنية بين الشموع
    final intervalMinutes = _parseInterval(interval);

    double currentPrice = basePrice;

    // توليد بيانات واقعية مع trends
    int trendLength = 25 + random.nextInt(35); // 25-60 candles per trend
    int trendType = random.nextInt(3); // 0=bullish, 1=bearish, 2=sideways
    int candlesInTrend = 0;

    for (int i = outputSize - 1; i >= 0; i--) {
      final timestamp = now.subtract(Duration(minutes: intervalMinutes * i));

      // تغيير الاتجاه كل فترة
      if (candlesInTrend >= trendLength) {
        trendType = random.nextInt(3);
        trendLength = 25 + random.nextInt(35);
        candlesInTrend = 0;
      }
      candlesInTrend++;

      // تقلب متغير (0.001 - 0.005)
      final baseVolatility = 0.001 + random.nextDouble() * 0.004;

      // حركة السعر حسب الاتجاه
      double priceChange;
      if (trendType == 0) {
        // Bullish trend
        priceChange =
            currentPrice * baseVolatility * (0.5 + random.nextDouble() * 1.0);
      } else if (trendType == 1) {
        // Bearish trend
        priceChange =
            -currentPrice * baseVolatility * (0.5 + random.nextDouble() * 1.0);
      } else {
        // Sideways
        priceChange =
            currentPrice * baseVolatility * (random.nextDouble() - 0.5);
      }

      final open = currentPrice;
      final close = open + priceChange;

      // High و Low واقعيين مع wicks
      final wickSize =
          currentPrice * baseVolatility * (0.3 + random.nextDouble() * 0.4);
      final high = max(open, close) + wickSize * random.nextDouble();
      final low = min(open, close) - wickSize * random.nextDouble();

      // Volume واقعي مع تنوع وspikes
      final baseVolume = 700000.0 + random.nextDouble() * 1800000.0;
      final volumeSpike =
          random.nextDouble() < 0.12 ? (1.8 + random.nextDouble() * 2.5) : 1.0;
      final trendVolumeMultiplier = trendType == 2 ? 0.75 : 1.0;
      final volume = baseVolume * volumeSpike * trendVolumeMultiplier;

      candles.add(CandleData(
        timestamp: timestamp,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume,
      ));

      currentPrice = close;
    }

    // عكس الترتيب ليكون الأحدث أولاً
    final reversedCandles = candles.reversed.toList();

    AppLogger.success('✅ تم توليد ${reversedCandles.length} شمعة واقعية');

    return MarketDataResponse(
      symbol: symbol,
      interval: interval,
      candles: reversedCandles,
      fetchedAt: DateTime.now(),
    );
  }

  /// تحويل interval إلى دقائق
  static int _parseInterval(String interval) {
    if (interval.endsWith('min')) {
      return int.parse(interval.replaceAll('min', ''));
    } else if (interval.endsWith('h')) {
      return int.parse(interval.replaceAll('h', '')) * 60;
    } else if (interval.endsWith('d')) {
      return int.parse(interval.replaceAll('d', '')) * 1440;
    }
    return 5; // افتراضي 5 دقائق
  }

  /// مسح Cache
  static void clearCache() {
    _cache.clear();
    AppLogger.info('🗑️ تم مسح Cache');
  }
}

/// إدخال Cache
class _CacheEntry {
  final MarketDataResponse data;
  final DateTime timestamp;

  _CacheEntry({
    required this.data,
    required this.timestamp,
  });
}
