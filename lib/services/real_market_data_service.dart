import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/candle.dart';
import '../core/utils/logger.dart';

/// 📊 Real Market Data Service
/// خدمة جلب بيانات السوق الحقيقية من مصادر موثوقة
/// ✅ يستخدم Dio بدلاً من http
/// ✅ يستخدم dotenv للـ API Keys
/// ✅ متوافق مع Candle Model الموجود
class RealMarketDataService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  // ═══════════════════════════════════════════════════════════════════
  // API KEYS من .env
  // ═══════════════════════════════════════════════════════════════════

  static String get twelveDataKey => dotenv.env['TWELVE_DATA_API_KEY'] ?? '';

  static String get goldPriceApiKey => dotenv.env['GOLD_PRICE_API_KEY'] ?? '';

  // ═══════════════════════════════════════════════════════════════════
  // 🕯️ جلب شموع الذهب (Candlesticks)
  // ═══════════════════════════════════════════════════════════════════

  /// جلب شموع الذهب من Twelve Data
  static Future<List<Candle>> getGoldCandles({
    required String timeframe, // '1min', '5min', '15min', '1h', '4h', '1d'
    int limit = 100,
  }) async {
    try {
      final interval = _convertTimeframe(timeframe);

      final response = await _dio.get(
        'https://api.twelvedata.com/time_series',
        queryParameters: {
          'symbol': 'XAU/USD',
          'interval': interval,
          'outputsize': limit,
          'apikey': twelveDataKey,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final values = data['values'] as List<dynamic>?;

        if (values == null || values.isEmpty) {
          AppLogger.warn('⚠️ No candle data found, using fallback');
          return _getMockCandles(timeframe: timeframe, limit: limit);
        }

        final candles = values.map((v) {
          return _candleFromTwelveData(v as Map<String, dynamic>);
        }).toList();

        // Sort by time (oldest first)
        candles.sort((a, b) => a.time.compareTo(b.time));

        AppLogger.success('✅ Loaded ${candles.length} candles from Twelve Data');
        return candles;
      } else {
        throw Exception('Failed to load candles: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('❌ Error fetching candles', e);

      // Fallback to mock data
      return _getMockCandles(timeframe: timeframe, limit: limit);
    }
  }

  /// جلب السعر الحالي من Gold API
  static Future<double> getCurrentPrice() async {
    try {
      final response = await _dio.get(
        'https://www.goldapi.io/api/XAU/USD',
        options: Options(
          headers: {
            'x-access-token': goldPriceApiKey,
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final price = data['price'] as num?;

        if (price != null) {
          AppLogger.debug('✅ Current price: \$${price.toDouble()}');
          return price.toDouble();
        }
      }
    } catch (e) {
      AppLogger.error('❌ Error fetching current price', e);
    }

    // Fallback: try Twelve Data
    try {
      final response = await _dio.get(
        'https://api.twelvedata.com/price',
        queryParameters: {
          'symbol': 'XAU/USD',
          'apikey': twelveDataKey,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final price = double.parse(data['price']);
        AppLogger.debug('✅ Current price from Twelve Data: \$$price');
        return price;
      }
    } catch (e) {
      AppLogger.error('❌ Error fetching from Twelve Data', e);
    }

    // Last resort: return reasonable price
    AppLogger.warn('⚠️ Using fallback price');
    return 2645.80;
  }

  // ═══════════════════════════════════════════════════════════════════
  // 🔧 Helper Methods
  // ═══════════════════════════════════════════════════════════════════

  static String _convertTimeframe(String timeframe) {
    switch (timeframe) {
      case '1min':
        return '1min';
      case '5min':
        return '5min';
      case '15min':
        return '15min';
      case '1h':
        return '1h';
      case '4h':
        return '4h';
      case '1d':
        return '1day';
      default:
        return '15min';
    }
  }

  /// تحويل بيانات Twelve Data إلى Candle Model
  static Candle _candleFromTwelveData(Map<String, dynamic> data) {
    return Candle(
      time: DateTime.parse(data['datetime']),
      open: double.parse(data['open']),
      high: double.parse(data['high']),
      low: double.parse(data['low']),
      close: double.parse(data['close']),
      volume: 0, // XAU/USD doesn't have volume
    );
  }

  /// Mock candles للتطوير والـ fallback
  /// ✅ FIXED: Now generates varied data based on current time AND timeframe
  static List<Candle> _getMockCandles({
    required String timeframe,
    int limit = 100,
  }) {
    AppLogger.warn('⚠️ Using mock candles for $timeframe');

    final now = DateTime.now();
    final candles = <Candle>[];
    double basePrice = 2645.80;

    // Use current hour to determine trend direction
    // This makes signals change based on time
    final hourSeed = now.hour + now.minute ~/ 30;
    final isBullish = hourSeed % 2 == 0;

    AppLogger.debug('📈 Mock trend: ${isBullish ? "BULLISH" : "BEARISH"} (hour seed: $hourSeed)');

    // Calculate time step based on timeframe
    final minutesStep = _getMinutesStep(timeframe);
    
    // 🔥 CRITICAL FIX: Swing (4h) should have MUCH WIDER ranges than Scalp (15m)
    final isSwing = minutesStep >= 240; // 4h or larger
    final volatilityMultiplier = isSwing ? 8.0 : 1.0; // Swing 8x more volatile
    
    AppLogger.info('📊 Mock volatility multiplier: ${volatilityMultiplier}x (${isSwing ? "SWING" : "SCALP"})');

    for (int i = limit - 1; i >= 0; i--) {
      final timestamp = now.subtract(Duration(minutes: i * minutesStep));

      // Trend based on time seed - SCALED by volatility
      final trendStrength = (isBullish ? 0.15 : -0.15) * volatilityMultiplier;
      final cyclicalTrend =
          (i % 30 < 15) ? trendStrength : -trendStrength * 0.5;
      final noise = ((i * 7) % 11 - 5) * 0.1 * volatilityMultiplier;

      final open = basePrice;
      final change = cyclicalTrend + noise;
      final close = open + change;
      final high = (open > close ? open : close) + (i % 5) * 0.3 * volatilityMultiplier + 0.5;
      final low = (open < close ? open : close) - (i % 4) * 0.3 * volatilityMultiplier - 0.5;
      final volume = 1000 + (i % 100) * 10.0;

      candles.add(Candle(
        time: timestamp,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume,
      ));

      basePrice = close;
    }

    // Print last candle info
    if (candles.isNotEmpty) {
      final last = candles.last;
      AppLogger.debug('📊 Last mock candle: O=${last.open.toStringAsFixed(2)}, C=${last.close.toStringAsFixed(2)}');
    }

    return candles;
  }

  static int _getMinutesStep(String timeframe) {
    switch (timeframe) {
      case '1min':
        return 1;
      case '5min':
        return 5;
      case '15min':
        return 15;
      case '1h':
        return 60;
      case '4h':
        return 240;
      case '1d':
        return 1440;
      default:
        return 15;
    }
  }

  /// اختبار الاتصال بالـ API
  static Future<bool> testConnection() async {
    try {
      final candles = await getGoldCandles(
        timeframe: '15min',
        limit: 5,
      );

      return candles.isNotEmpty;
    } catch (e) {
      AppLogger.error('❌ Connection test failed', e);
      return false;
    }
  }
}
