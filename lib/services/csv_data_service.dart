import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/candle.dart';
import '../core/utils/logger.dart';

/// خدمة قراءة بيانات السوق الحقيقية من ملفات CSV
/// دعم جميع الفريمات: 5m, 15m, 60m, 240m, Daily
class CsvDataService {
  // Cache للبيانات
  static Map<String, List<Candle>> _cache = {};
  static DateTime? _lastLoad;

  /// قراءة بيانات 5 دقائق (Scalping السريع)
  static Future<List<Candle>> load5MinData() async {
    return _loadCsvData('assets/XAUUSDm5.csv', 'm5');
  }

  /// قراءة بيانات السكالب (15m timeframe) - ملف قديم للتوافقية
  static Future<List<Candle>> loadScalpData() async {
    // أولاً جرب الملف الجديد، ثم القديم
    try {
      return await load5MinData();
    } catch (e) {
      try {
        return await _loadCsvData('assets/XAUUSDm15.csv', 'm15');
      } catch (e2) {
        AppLogger.error('Failed to load scalp data: $e2');
        return [];
      }
    }
  }

  /// قراءة بيانات الساعة (60m - Intraday)
  static Future<List<Candle>> load60MinData() async {
    return _loadCsvData('assets/XAUUSDm60.csv', 'm60');
  }

  /// قراءة بيانات 4 ساعات (Swing Trading)
  static Future<List<Candle>> loadSwingData() async {
    return _loadCsvData('assets/XAUUSDm240.csv', 'm240');
  }

  /// قراءة بيانات يومية (Position Trading)
  static Future<List<Candle>> loadDailyData() async {
    return _loadCsvData('assets/XAUUSDm1440.csv', 'd1');
  }

  /// تحميل جميع البيانات مرة واحدة
  static Future<Map<String, List<Candle>>> loadAllTimeframes() async {
    final results = <String, List<Candle>>{};
    
    try {
      results['m5'] = await load5MinData();
      AppLogger.success('Loaded M5: ${results['m5']!.length} candles');
    } catch (e) {
      AppLogger.warn('M5 data not available: $e');
    }
    
    try {
      results['m60'] = await load60MinData();
      AppLogger.success('Loaded H1: ${results['m60']!.length} candles');
    } catch (e) {
      AppLogger.warn('H1 data not available: $e');
    }
    
    try {
      results['m240'] = await loadSwingData();
      AppLogger.success('Loaded H4: ${results['m240']!.length} candles');
    } catch (e) {
      AppLogger.warn('H4 data not available: $e');
    }
    
    try {
      results['d1'] = await loadDailyData();
      AppLogger.success('Loaded D1: ${results['d1']!.length} candles');
    } catch (e) {
      AppLogger.warn('D1 data not available: $e');
    }
    
    return results;
  }

  /// قراءة وتحليل ملف CSV مع Cache
  static Future<List<Candle>> _loadCsvData(String assetPath, String cacheKey) async {
    // Check cache
    if (_cache.containsKey(cacheKey) && _lastLoad != null) {
      final cacheAge = DateTime.now().difference(_lastLoad!);
      if (cacheAge.inMinutes < 30) {
        return _cache[cacheKey]!;
      }
    }

    try {
      AppLogger.info('Loading CSV: $assetPath');
      
      // قراءة الملف
      final csvString = await rootBundle.loadString(assetPath);

      // تقسيم الأسطر
      final lines = const LineSplitter().convert(csvString);

      // تحويل كل سطر لشمعة
      final candles = <Candle>[];
      int errorCount = 0;

      for (final line in lines) {
        if (line.trim().isEmpty) continue;

        final parts = line.split(',');
        if (parts.length < 6) continue;

        try {
          // صيغة CSV: Date,Time,Open,High,Low,Close,Volume
          final date = parts[0].trim();
          final time = parts[1].trim();
          final open = double.parse(parts[2].trim());
          final high = double.parse(parts[3].trim());
          final low = double.parse(parts[4].trim());
          final close = double.parse(parts[5].trim());
          final volume =
              parts.length > 6 ? double.parse(parts[6].trim()) : 1000.0;

          // التحقق من صحة الأسعار
          if (open <= 0 || high <= 0 || low <= 0 || close <= 0) {
            errorCount++;
            continue;
          }

          // التحقق من منطقية OHLC
          if (high < low || high < open || high < close || low > open || low > close) {
            // تصحيح البيانات إذا كانت غير منطقية
            final correctedHigh = [open, high, low, close].reduce((a, b) => a > b ? a : b);
            final correctedLow = [open, high, low, close].reduce((a, b) => a < b ? a : b);
            
            candles.add(_parseCandle(date, time, open, correctedHigh, correctedLow, close, volume));
          } else {
            candles.add(_parseCandle(date, time, open, high, low, close, volume));
          }
        } catch (e) {
          errorCount++;
          continue;
        }
      }

      if (errorCount > 0) {
        AppLogger.warn('Skipped $errorCount invalid rows in $assetPath');
      }

      // ترتيب الشموع من الأقدم للأحدث
      candles.sort((a, b) => a.time.compareTo(b.time));

      // Cache the result
      _cache[cacheKey] = candles;
      _lastLoad = DateTime.now();

      AppLogger.success('Loaded ${candles.length} candles from $assetPath');
      
      if (candles.isNotEmpty) {
        AppLogger.info('Date range: ${candles.first.time} to ${candles.last.time}');
        AppLogger.info('Price range: \$${candles.map((c) => c.low).reduce((a, b) => a < b ? a : b).toStringAsFixed(2)} - \$${candles.map((c) => c.high).reduce((a, b) => a > b ? a : b).toStringAsFixed(2)}');
      }

      return candles;
    } catch (e) {
      AppLogger.error('Failed to load CSV $assetPath: $e');
      throw Exception('فشل تحميل بيانات CSV: $e');
    }
  }

  /// تحويل البيانات إلى Candle
  static Candle _parseCandle(
    String date, String time,
    double open, double high, double low, double close, double volume,
  ) {
    // صيغة التاريخ: 2025.11.14 (YYYY.MM.DD)
    final dateTimeParts = date.split('.');
    final timeParts = time.split(':');

    if (dateTimeParts.length >= 3 && timeParts.length >= 2) {
      final year = int.parse(dateTimeParts[0]);
      final month = int.parse(dateTimeParts[1]);
      final day = int.parse(dateTimeParts[2]);
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      return Candle(
        time: DateTime(year, month, day, hour, minute),
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume,
      );
    }

    throw Exception('Invalid date/time format');
  }

  /// الحصول على آخر N شمعة من البيانات
  static List<Candle> getLastCandles(List<Candle> candles, int count) {
    if (candles.isEmpty) return [];
    if (candles.length <= count) return List.from(candles);

    return candles.sublist(candles.length - count);
  }

  /// تحديث آخر شمعة بالسعر الحالي (محاكاة real-time)
  static List<Candle> updateWithCurrentPrice(
    List<Candle> candles,
    double currentPrice,
  ) {
    if (candles.isEmpty) return candles;

    final updated = List<Candle>.from(candles);
    final last = updated.last;

    // تحديث آخر شمعة
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

  /// الحصول على أحدث سعر من البيانات
  static double getLatestPrice(List<Candle> candles) {
    if (candles.isEmpty) return 0;
    return candles.last.close;
  }

  /// مسح الـ Cache
  static void clearCache() {
    _cache.clear();
    _lastLoad = null;
    AppLogger.info('CSV cache cleared');
  }
}
