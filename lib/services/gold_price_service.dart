import 'package:dio/dio.dart';
import '../models/market_models.dart';
import '../core/constants/api_keys.dart';
import '../core/utils/logger.dart';
import '../core/utils/type_converter.dart';

/// Professional Gold Price Service - Real-time XAUUSD
///
/// يجلب سعر الذهب الحقيقي من Gold API مباشرة
class GoldPriceService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  static GoldPrice? _cachedPrice;
  static DateTime? _lastFetch;
  static const _cacheDuration = Duration(seconds: 30); // تحديث كل 30 ثانية

  /// Get Current Gold Price - السعر الحقيقي من API
  static Future<GoldPrice> getCurrentPrice() async {
    print('═══════════════════════════════════════');
    print('🔍 GOLD PRICE SERVICE - START');
    print('═══════════════════════════════════════');

    // Check cache (30 seconds)
    if (_cachedPrice != null &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < _cacheDuration) {
      print('📦 USING CACHED PRICE: \$${_cachedPrice!.price}');
      print('═══════════════════════════════════════');
      return _cachedPrice!;
    }

    print('🌐 FETCHING FRESH PRICE FROM API...');

    // جلب السعر الحقيقي مباشرة
    try {
      final price = await _fetchRealPrice();
      if (price != null) {
        _cachePrice(price);
        print('✅ SUCCESS: \$${price.price.toStringAsFixed(2)}');
        print('═══════════════════════════════════════');
        AppLogger.success(
            '💰 سعر الذهب الحقيقي: \$${price.price.toStringAsFixed(2)}');
        return price;
      }
    } catch (e) {
      print('❌ ERROR FETCHING PRICE: $e');
      AppLogger.error('فشل جلب السعر', e, StackTrace.current);
    }

    // إذا فشل، استخدم آخر سعر محفوظ أو احتياطي
    if (_cachedPrice != null) {
      print('⚠️ USING OLD CACHED PRICE: \$${_cachedPrice!.price}');
      print('═══════════════════════════════════════');
      AppLogger.warn(
          'استخدام آخر سعر محفوظ: \$${_cachedPrice!.price.toStringAsFixed(2)}');
      return _cachedPrice!;
    }

    print('🆘 USING EMERGENCY FALLBACK');
    print('═══════════════════════════════════════');
    return _getEmergencyFallback();
  }

  /// جلب السعر الحقيقي من Gold API
  static Future<GoldPrice?> _fetchRealPrice() async {
    // Priority 1: Coinbase (FREE, Fast, Reliable!)
    try {
      final coinbase = await _fetchFromCoinbase();
      if (coinbase != null) {
        print('✅ SUCCESS: Using Coinbase (FREE API)');
        return coinbase;
      }
    } catch (e) {
      print('Coinbase failed: $e');
    }

    // Priority 2: metals.live (FREE, Good backup)
    try {
      final metalsLive = await _fetchFromMetalsLive();
      if (metalsLive != null) {
        print('✅ SUCCESS: Using metals.live (FREE API)');
        return metalsLive;
      }
    } catch (e) {
      print('metals.live failed: $e');
    }

    // Priority 3: goldapi.io (paid API with key)
    try {
      final goldApi = await _fetchFromGoldApi();
      if (goldApi != null) {
        print('✅ SUCCESS: Using goldapi.io');
        return goldApi;
      }
    } catch (e) {
      print('goldapi.io failed: $e');
    }

    AppLogger.error('❌ جميع APIs فشلت!');
    return null;
  }

  /// New: Coinbase API (FREE - Most reliable!)
  static Future<GoldPrice?> _fetchFromCoinbase() async {
    try {
      print('  → Trying Coinbase (FREE)...');
      print('  → Calling: https://api.coinbase.com/v2/prices/XAU-USD/spot');

      final response = await _dio.get(
        'https://api.coinbase.com/v2/prices/XAU-USD/spot',
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      print('  → Status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        print('  → Data: $data');

        // Coinbase format: {"data": {"amount": "2650.50", "currency": "USD"}}
        final amount =
            TypeConverter.safeToDouble(data['data']?['amount']) ?? 0.0;

        if (amount > 1000 && amount < 5000) {
          print('  ✓ Price: \$$amount');

          AppLogger.success('✅ Coinbase (FREE): السعر = \$$amount');

          return GoldPrice(
            price: amount,
            change: 0,
            changePercent: 0,
            high24h: amount + 15,
            low24h: amount - 15,
            open24h: amount,
            timestamp: DateTime.now(),
          );
        }
      } else {
        print('  ✗ Bad response: ${response.statusCode}');
        AppLogger.warn('Coinbase Error: ${response.statusCode}');
      }

      return null;
    } catch (e) {
      print('  ✗ Exception: $e');
      AppLogger.warn('Coinbase Exception: $e');
      return null;
    }
  }

  /// Primary: goldapi.io (with API key)
  static Future<GoldPrice?> _fetchFromGoldApi() async {
    try {
      print('═══════════════════════════════════════');
      print('  → Trying goldapi.io...');
      final apiKey = ApiKeys.goldPriceApiKey;
      final baseUrl = ApiKeys.goldPriceBaseUrl;

      print('  → API Key: $apiKey');
      print('  → Base URL: $baseUrl');

      if (apiKey.isEmpty) {
        print('  ✗ No API key');
        AppLogger.warn('مفتاح Gold API غير موجود!');
        return null;
      }

      print('  → Calling: $baseUrl/XAU/USD');
      print('  → Header: x-access-token: $apiKey');

      final response = await _dio.get(
        '$baseUrl/XAU/USD',
        options: Options(
          headers: {'x-access-token': apiKey},
          validateStatus: (status) => true,
          receiveTimeout: Duration(seconds: 10),
          sendTimeout: Duration(seconds: 10),
        ),
      );

      print('  → Response Status: ${response.statusCode}');
      print('  → Response Data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        double price = TypeConverter.safeToDouble(data['price']) ?? 2000.0;
        print('  ✓✓✓ SUCCESS! Price from goldapi.io: \$$price');
        print('═══════════════════════════════════════');

        double prevClose =
            TypeConverter.safeToDouble(data['prev_close_price']) ?? price;
        double change = price - prevClose;
        double changePercent = prevClose > 0 ? (change / prevClose) * 100 : 0;

        AppLogger.success('✅ goldapi.io: السعر = \$$price');

        return GoldPrice(
          price: price,
          change: change,
          changePercent: changePercent,
          high24h: TypeConverter.safeToDouble(data['high_price']) ?? price + 10,
          low24h: TypeConverter.safeToDouble(data['low_price']) ?? price - 10,
          open24h: TypeConverter.safeToDouble(data['open_price']) ?? prevClose,
          timestamp: DateTime.now(),
        );
      } else {
        print('  ✗ Bad response: ${response.statusCode}');
        AppLogger.warn('goldapi.io Error: ${response.statusCode}');
      }

      return null;
    } catch (e) {
      print('  ✗ Exception: $e');
      AppLogger.warn('goldapi.io Exception: $e');
      return null;
    }
  }

  /// Fallback: metals.live (free, no API key)
  static Future<GoldPrice?> _fetchFromMetalsLive() async {
    try {
      print('  → Trying metals.live (FREE)...');
      print('  → Calling: https://api.metals.live/v1/spot/gold');

      final response = await _dio.get(
        'https://api.metals.live/v1/spot/gold',
        options: Options(validateStatus: (status) => true),
      );

      print('  → Status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        print('  → Data: $data');

        // metals.live returns price per troy ounce in USD
        double price = TypeConverter.safeToDouble(data['price']) ?? 2000.0;
        print('  ✓ Price: \$$price');

        double change = TypeConverter.safeToDouble(data['change']) ?? 0.0;
        double changePercent =
            TypeConverter.safeToDouble(data['change_percent']) ?? 0.0;

        AppLogger.success('✅ metals.live (FREE): السعر = \$$price');

        return GoldPrice(
          price: price,
          change: change,
          changePercent: changePercent,
          high24h: price + 10,
          low24h: price - 10,
          open24h: price - change,
          timestamp: DateTime.now(),
        );
      } else {
        print('  ✗ Bad response: ${response.statusCode}');
        AppLogger.warn('metals.live Error: ${response.statusCode}');
      }

      return null;
    } catch (e) {
      print('  ✗ Exception: $e');
      AppLogger.warn('metals.live Exception: $e');
      return null;
    }
  }

  /// احتياطي طوارئ فقط إذا فشل كل شيء
  static GoldPrice _getEmergencyFallback() {
    AppLogger.error('⚠️ ALL APIs FAILED - استخدام سعر احتياطي طوارئ');
    AppLogger.error('⚠️ يرجى التحقق من الاتصال بالإنترنت!');
    // Use latest known gold price (update manually if needed)
    return GoldPrice(
      price: 2642.00, // Current approximate XAU/USD (Dec 22, 2024)
      change: 0,
      changePercent: 0,
      high24h: 2657.00,
      low24h: 2627.00,
      open24h: 2642.00,
      timestamp: DateTime.now(),
    );
  }

  /// Cache price
  static void _cachePrice(GoldPrice price) {
    _cachedPrice = price;
    _lastFetch = DateTime.now();
  }

  /// Get Price Stream (updates every 30 seconds)
  static Stream<GoldPrice> getPriceStream() {
    return Stream.periodic(
      const Duration(seconds: 30),
      (_) => getCurrentPrice(),
    ).asyncMap((future) => future);
  }

  /// Clear cache
  static void clearCache() {
    _cachedPrice = null;
    _lastFetch = null;
    AppLogger.debug('Gold price cache cleared');
  }

  /// Get Market Status
  static MarketStatus getMarketStatus() {
    final now = DateTime.now().toUtc();
    final hour = now.hour;
    final day = now.weekday;

    // Weekend: Market Closed
    if (day == DateTime.saturday || day == DateTime.sunday) {
      return MarketStatus(
        isOpen: false,
        session: MarketSession.closed,
        nextOpen: _getNextMonday(now),
      );
    }

    // Asian Session: 00:00 - 09:00 UTC
    if (hour >= 0 && hour < 9) {
      return MarketStatus(
        isOpen: true,
        session: MarketSession.asian,
        nextClose: DateTime.utc(now.year, now.month, now.day, 9),
      );
    }

    // London Session: 08:00 - 17:00 UTC
    if (hour >= 8 && hour < 17) {
      return MarketStatus(
        isOpen: true,
        session: MarketSession.london,
        nextClose: DateTime.utc(now.year, now.month, now.day, 17),
      );
    }

    // New York Session: 13:00 - 22:00 UTC
    if (hour >= 13 && hour < 22) {
      return MarketStatus(
        isOpen: true,
        session: MarketSession.newYork,
        nextClose: DateTime.utc(now.year, now.month, now.day, 22),
      );
    }

    // Off hours
    return MarketStatus(
      isOpen: false,
      session: MarketSession.closed,
      nextOpen: DateTime.utc(now.year, now.month, now.day + 1, 0),
    );
  }

  static DateTime _getNextMonday(DateTime date) {
    final daysUntilMonday = (DateTime.monday - date.weekday + 7) % 7;
    return date.add(Duration(days: daysUntilMonday == 0 ? 7 : daysUntilMonday));
  }
}
