import '../models/candle.dart';
import '../models/support_resistance_level.dart';
import '../core/utils/logger.dart';

/// 🔍 Real Levels Detector
/// يستخرج مستويات الدعم والمقاومة الحقيقية من البيانات التاريخية
class RealLevelsDetector {
  /// استخراج مستويات حقيقية من بيانات CSV
  static Future<RealSupportResistance> extractLevels({
    required List<Candle> candles,
    required double currentPrice,
    required String timeframe,
  }) async {
    AppLogger.info('🔍 استخراج مستويات حقيقية من ${candles.length} شمعة...');

    if (candles.length < 30) {
      AppLogger.warn('⚠️ بيانات غير كافية لاستخراج مستويات موثوقة');
      return RealSupportResistance(
        supports: [],
        resistances: [],
        extractedAt: DateTime.now(),
        totalPivotsAnalyzed: 0,
      );
    }

    // 1. إيجاد Pivot Points (القمم والقيعان)
    final pivots = _findPivotPoints(candles, timeframe);
    AppLogger.info('📊 تم إيجاد ${pivots.length} pivot point');

    // 2. تجميع المستويات المتقاربة (Clustering)
    final clusteredLevels = _clusterPivots(pivots);
    AppLogger.info('🎯 تم تجميع ${clusteredLevels.length} مستوى');

    // 3. حساب قوة كل مستوى (عدد الاختبارات)
    final levelsWithStrength = _calculateLevelStrength(clusteredLevels, candles);

    // 4. فصل الدعوم والمقاومات حسب السعر الحالي
    final supports = levelsWithStrength
        .where((l) => l.price < currentPrice)
        .toList()
      ..sort((a, b) => b.price.compareTo(a.price)); // الأقرب أولاً

    final resistances = levelsWithStrength
        .where((l) => l.price > currentPrice)
        .toList()
      ..sort((a, b) => a.price.compareTo(b.price)); // الأقرب أولاً

    AppLogger.success(
      '✅ استخرجنا ${supports.length} دعم و ${resistances.length} مقاومة حقيقية',
    );

    return RealSupportResistance(
      supports: supports.take(5).toList(),
      resistances: resistances.take(5).toList(),
      extractedAt: DateTime.now(),
      totalPivotsAnalyzed: pivots.length,
    );
  }

  /// إيجاد Pivot Points (القمم والقيعان الحقيقية)
  static List<_PivotPoint> _findPivotPoints(
    List<Candle> candles,
    String timeframe,
  ) {
    // تحديد lookback حسب الـ timeframe
    final lookback = timeframe == '15m' ? 5 : 10;
    final pivots = <_PivotPoint>[];

    for (int i = lookback; i < candles.length - lookback; i++) {
      // فحص Swing High (مقاومة)
      bool isSwingHigh = true;
      for (int j = i - lookback; j <= i + lookback; j++) {
        if (j != i && candles[j].high >= candles[i].high) {
          isSwingHigh = false;
          break;
        }
      }

      if (isSwingHigh) {
        pivots.add(_PivotPoint(
          price: candles[i].high,
          type: 'RESISTANCE',
          time: candles[i].time,
          volume: candles[i].volume,
        ));
      }

      // فحص Swing Low (دعم)
      bool isSwingLow = true;
      for (int j = i - lookback; j <= i + lookback; j++) {
        if (j != i && candles[j].low <= candles[i].low) {
          isSwingLow = false;
          break;
        }
      }

      if (isSwingLow) {
        pivots.add(_PivotPoint(
          price: candles[i].low,
          type: 'SUPPORT',
          time: candles[i].time,
          volume: candles[i].volume,
        ));
      }
    }

    return pivots;
  }

  /// تجميع المستويات المتقاربة (Clustering)
  static List<_ClusteredLevel> _clusterPivots(List<_PivotPoint> pivots) {
    final tolerance = 10.0; // $10 tolerance للذهب
    final clusters = <_ClusteredLevel>[];

    for (final pivot in pivots) {
      bool addedToCluster = false;

      // البحث عن cluster موجود قريب
      for (final cluster in clusters) {
        if ((pivot.price - cluster.averagePrice).abs() <= tolerance &&
            pivot.type == cluster.type) {
          cluster.pivots.add(pivot);
          cluster.averagePrice = cluster.pivots
                  .map((p) => p.price)
                  .reduce((a, b) => a + b) /
              cluster.pivots.length;
          addedToCluster = true;
          break;
        }
      }

      // إنشاء cluster جديد
      if (!addedToCluster) {
        clusters.add(_ClusteredLevel(
          averagePrice: pivot.price,
          type: pivot.type,
          pivots: [pivot],
        ));
      }
    }

    // فلترة: فقط الـ clusters اللي فيها 2+ pivots
    return clusters.where((c) => c.pivots.length >= 2).toList();
  }

  /// حساب قوة المستوى (عدد مرات الاختبار والارتداد)
  static List<SupportResistanceLevel> _calculateLevelStrength(
    List<_ClusteredLevel> clusters,
    List<Candle> candles,
  ) {
    final levels = <SupportResistanceLevel>[];

    for (final cluster in clusters) {
      final level = cluster.averagePrice;
      final type = cluster.type;

      // حساب عدد الاختبارات (touches)
      int touches = 0;
      DateTime? lastTestTime;
      final tolerance = 8.0; // $8 tolerance

      for (int i = 1; i < candles.length; i++) {
        final candle = candles[i];

        // هل لامس المستوى؟
        final touchedLevel = type == 'RESISTANCE'
            ? (candle.high - level).abs() <= tolerance
            : (candle.low - level).abs() <= tolerance;

        if (touchedLevel) {
          // هل ارتد؟ (الشمعة التالية عكست)
          if (i < candles.length - 1) {
            final nextCandle = candles[i + 1];
            final rejected = type == 'RESISTANCE'
                ? nextCandle.close < candle.close // ارتد للأسفل
                : nextCandle.close > candle.close; // ارتد للأعلى

            if (rejected) {
              touches++;
              lastTestTime = candle.time;
            }
          }
        }
      }

      // فقط المستويات القوية (2+ touches)
      if (touches >= 2) {
        final isStrong = touches >= 3;
        
        levels.add(SupportResistanceLevel(
          price: double.parse(level.toStringAsFixed(2)),
          type: type,
          strength: touches,
          lastTest: lastTestTime ?? cluster.pivots.last.time,
          isStrong: isStrong,
          note: _generateLevelNote(touches, isStrong),
        ));
      }
    }

    return levels;
  }

  /// توليد ملاحظة للمستوى
  static String _generateLevelNote(int touches, bool isStrong) {
    if (touches >= 6) return 'قوي جداً - مستوى رئيسي';
    if (touches >= 4) return 'قوي - تم اختباره عدة مرات';
    if (touches >= 3) return 'متوسط القوة';
    return 'ضعيف نسبياً';
  }
}

/// نقطة Pivot داخلية
class _PivotPoint {
  final double price;
  final String type;
  final DateTime time;
  final double volume;

  _PivotPoint({
    required this.price,
    required this.type,
    required this.time,
    required this.volume,
  });
}

/// مستوى مجمّع
class _ClusteredLevel {
  double averagePrice;
  final String type;
  final List<_PivotPoint> pivots;

  _ClusteredLevel({
    required this.averagePrice,
    required this.type,
    required this.pivots,
  });
}

