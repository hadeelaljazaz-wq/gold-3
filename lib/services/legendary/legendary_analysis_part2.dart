/// 👑 LEGENDARY ANALYSIS ENGINE - PART 2 👑
///
/// **ICT Methodology + Wyckoff + Elliott Wave + Volume Profile**
///
library;

import 'dart:math';
import '../../models/candle.dart';

// ═══════════════════════════════════════════════════════════════
// 🔧 ENUMS AND BASE TYPES
// ═══════════════════════════════════════════════════════════════

enum TrendDirection { bullish, bearish, ranging }

enum OTEType { bullish, bearish }

enum BreakerType { bullish, bearish }

enum MitigationType { bullish, bearish }

enum KillZoneType { londonOpen, londonClose, newYorkOpen, newYorkClose, asian }

enum MMModelType { accumulation, manipulation, distribution }

enum SwingType { high, low }

// ═══════════════════════════════════════════════════════════════
// 🎓 ICT METHODOLOGY ANALYSIS
// ═══════════════════════════════════════════════════════════════

class ICTAnalysis {
  final OptimalTradeEntry? ote;
  final List<BreakerBlock> breakerBlocks;
  final List<MitigationBlock> mitigationBlocks;
  final KillZoneStatus killZoneStatus;
  final MarketMakerModel? mmModel;
  final TrendDirection bias;

  ICTAnalysis({
    this.ote,
    required this.breakerBlocks,
    required this.mitigationBlocks,
    required this.killZoneStatus,
    this.mmModel,
    required this.bias,
  });
}

// ═══════════════════════════════════════════════════════════════
// 💎 OPTIMAL TRADE ENTRY (OTE) - نقطة الدخول المثالية
// ═══════════════════════════════════════════════════════════════

class OptimalTradeEntry {
  final double fibLevel; // مستوى فيبوناتشي (0.618 - 0.79)
  final double entryPrice; // سعر الدخول
  final OTEType type; // صعودي أم هبوطي
  final double confidence; // نسبة الثقة

  OptimalTradeEntry({
    required this.fibLevel,
    required this.entryPrice,
    required this.type,
    required this.confidence,
  });
}

// Helper class for all legendary analysis functions
class LegendaryHelpers {
  static OptimalTradeEntry? calculateOTE(
      List<Candle> candles, double currentPrice) {
    if (candles.length < 50) return null;

    // البحث عن آخر swing high و swing low
    final swingHigh = candles.map((c) => c.high).reduce(max);
    final swingLow = candles.map((c) => c.low).reduce(min);
    final range = swingHigh - swingLow;

    // حساب مستويات فيبوناتشي
    final fib618 = swingLow + (range * 0.618);
    final fib786 = swingLow + (range * 0.786);

    // Bullish OTE: السعر في منطقة 0.618 - 0.786
    if (currentPrice >= fib618 && currentPrice <= fib786) {
      return OptimalTradeEntry(
        fibLevel: 0.618,
        entryPrice: fib618,
        type: OTEType.bullish,
        confidence: 85.0,
      );
    }

    // Bearish OTE
    final bearishFib618 = swingHigh - (range * 0.618);
    final bearishFib786 = swingHigh - (range * 0.786);

    if (currentPrice <= bearishFib618 && currentPrice >= bearishFib786) {
      return OptimalTradeEntry(
        fibLevel: 0.618,
        entryPrice: bearishFib618,
        type: OTEType.bearish,
        confidence: 85.0,
      );
    }

    return null;
  }
} // End of LegendaryHelpers class

// ═══════════════════════════════════════════════════════════════
// 🔨 BREAKER BLOCKS - كتل الكسر
// ═══════════════════════════════════════════════════════════════

class BreakerBlock {
  final BreakerType type;
  final double high;
  final double low;
  final DateTime timestamp;
  final double strength;

  BreakerBlock({
    required this.type,
    required this.high,
    required this.low,
    required this.timestamp,
    required this.strength,
  });
}

List<BreakerBlock> detectBreakerBlocks(List<Candle> candles) {
  List<BreakerBlock> blocks = [];

  // Breaker Block: Order Block تم كسره وأصبح مستوى دعم/مقاومة
  for (int i = 20; i < candles.length - 10; i++) {
    final candle = candles[i];
    final beforeCandles = candles.sublist(i - 20, i);
    final afterCandles = candles.sublist(i + 1, min(i + 11, candles.length));

    // Bullish Breaker: مقاومة تحولت لدعم
    final wasResistance =
        beforeCandles.where((c) => c.high < candle.low).length > 15;
    final nowSupport = afterCandles
            .where((c) => c.low >= candle.low && c.close > candle.high)
            .length >=
        3;

    if (wasResistance && nowSupport) {
      blocks.add(BreakerBlock(
        type: BreakerType.bullish,
        high: candle.high,
        low: candle.low,
        timestamp: candle.time,
        strength: 90.0,
      ));
    }

    // Bearish Breaker: دعم تحول لمقاومة
    final wasSupport =
        beforeCandles.where((c) => c.low > candle.high).length > 15;
    final nowResistance = afterCandles
            .where((c) => c.high <= candle.high && c.close < candle.low)
            .length >=
        3;

    if (wasSupport && nowResistance) {
      blocks.add(BreakerBlock(
        type: BreakerType.bearish,
        high: candle.high,
        low: candle.low,
        timestamp: candle.time,
        strength: 90.0,
      ));
    }
  }

  return blocks.take(3).toList();
}

// ═══════════════════════════════════════════════════════════════
// 🛡️ MITIGATION BLOCKS - كتل التخفيف
// ═══════════════════════════════════════════════════════════════

class MitigationBlock {
  final MitigationType type;
  final double price;
  final double strength;

  MitigationBlock({
    required this.type,
    required this.price,
    required this.strength,
  });
}

List<MitigationBlock> detectMitigationBlocks(List<Candle> candles) {
  List<MitigationBlock> blocks = [];

  // مناطق التخفيف: مناطق التصحيح المتوقعة
  final recentHigh = candles.map((c) => c.high).reduce(max);
  final recentLow = candles.map((c) => c.low).reduce(min);
  final range = recentHigh - recentLow;

  // Bullish Mitigation: مناطق الشراء المتوقعة
  blocks.add(MitigationBlock(
    type: MitigationType.bullish,
    price: recentLow + (range * 0.382), // فيبوناتشي 38.2%
    strength: 75.0,
  ));

  blocks.add(MitigationBlock(
    type: MitigationType.bullish,
    price: recentLow + (range * 0.5), // فيبوناتشي 50%
    strength: 80.0,
  ));

  // Bearish Mitigation: مناطق البيع المتوقعة
  blocks.add(MitigationBlock(
    type: MitigationType.bearish,
    price: recentHigh - (range * 0.382),
    strength: 75.0,
  ));

  blocks.add(MitigationBlock(
    type: MitigationType.bearish,
    price: recentHigh - (range * 0.5),
    strength: 80.0,
  ));

  return blocks;
}

// ═══════════════════════════════════════════════════════════════
// ⏰ KILL ZONES - مناطق القتل (أوقات التداول المثالية)
// ═══════════════════════════════════════════════════════════════

class KillZoneStatus {
  final bool inKillZone;
  final KillZoneType? type;
  final String description;

  KillZoneStatus({
    required this.inKillZone,
    this.type,
    required this.description,
  });
}

KillZoneStatus getKillZoneStatus() {
  final now = DateTime.now().toUtc();
  final hour = now.hour;
  final minute = now.minute;

  // London Kill Zone: 02:00 - 05:00 UTC (الأهم)
  if ((hour >= 2 && hour < 5) || (hour == 5 && minute == 0)) {
    return KillZoneStatus(
      inKillZone: true,
      type: KillZoneType.londonOpen,
      description: 'London Open Kill Zone - أقوى فترة تداول',
    );
  }

  // London Close: 11:00 - 12:00 UTC
  if (hour >= 11 && hour < 12) {
    return KillZoneStatus(
      inKillZone: true,
      type: KillZoneType.londonClose,
      description: 'London Close Kill Zone',
    );
  }

  // New York Kill Zone: 13:00 - 16:00 UTC
  if (hour >= 13 && hour < 16) {
    return KillZoneStatus(
      inKillZone: true,
      type: KillZoneType.newYorkOpen,
      description: 'New York Open Kill Zone',
    );
  }

  // Asian Session: 00:00 - 02:00 UTC (ضعيفة)
  if (hour >= 0 && hour < 2) {
    return KillZoneStatus(
      inKillZone: false,
      type: KillZoneType.asian,
      description: 'Asian Session - حركة ضعيفة',
    );
  }

  return KillZoneStatus(
    inKillZone: false,
    description: 'خارج مناطق القتل - تجنب التداول',
  );
}

// ═══════════════════════════════════════════════════════════════
// 📊 MARKET MAKER MODEL - نموذج صانع السوق
// ═══════════════════════════════════════════════════════════════

class MarketMakerModel {
  final MMModelType type;
  final double confidence;
  final String phase;

  MarketMakerModel({
    required this.type,
    required this.confidence,
    required this.phase,
  });
}

MarketMakerModel? detectMarketMakerModel(List<Candle> candles) {
  final recentCandles =
      candles.length > 30 ? candles.sublist(candles.length - 30) : candles;

  // حساب التقلب
  final volatility = calculateVolatility(recentCandles);
  final volumeAvg = recentCandles.map((c) => c.volume).reduce((a, b) => a + b) /
      recentCandles.length;

  // Accumulation: تقلب منخفض + حجم متزايد
  if (volatility < 0.5 && recentCandles.last.volume > volumeAvg * 1.2) {
    return MarketMakerModel(
      type: MMModelType.accumulation,
      confidence: 80.0,
      phase: 'تجميع - المؤسسات تشتري',
    );
  }

  // Manipulation: تقلب عالي + حركة سعرية حادة
  if (volatility > 1.5) {
    return MarketMakerModel(
      type: MMModelType.manipulation,
      confidence: 75.0,
      phase: 'تلاعب - اصطياد الأوامر',
    );
  }

  // Distribution: تقلب متوسط + حجم مرتفع
  if (volatility >= 0.5 &&
      volatility <= 1.5 &&
      recentCandles.last.volume > volumeAvg * 1.5) {
    return MarketMakerModel(
      type: MMModelType.distribution,
      confidence: 85.0,
      phase: 'توزيع - المؤسسات تبيع',
    );
  }

  return null;
}

double calculateVolatility(List<Candle> candles) {
  final returns = <double>[];
  for (int i = 1; i < candles.length; i++) {
    returns
        .add((candles[i].close - candles[i - 1].close) / candles[i - 1].close);
  }
  final mean = returns.reduce((a, b) => a + b) / returns.length;
  final variance =
      returns.map((r) => pow(r - mean, 2)).reduce((a, b) => a + b) /
          returns.length;
  return sqrt(variance);
}

// ═══════════════════════════════════════════════════════════════
// 📚 WYCKOFF ANALYSIS - تحليل وايكوف
// ═══════════════════════════════════════════════════════════════

class WyckoffAnalysis {
  final WyckoffPhase phase;
  final double confidence;
  final String description;
  final TrendDirection bias;

  WyckoffAnalysis({
    required this.phase,
    required this.confidence,
    required this.description,
    required this.bias,
  });
}

enum WyckoffPhase {
  accumulationPhaseA,
  accumulationPhaseB,
  accumulationPhaseC,
  accumulationPhaseD,
  accumulationPhaseE,
  distributionPhaseA,
  distributionPhaseB,
  distributionPhaseC,
  distributionPhaseD,
  distributionPhaseE,
}

WyckoffAnalysis analyzeWyckoffPhase(
    List<Candle> candles4h, List<Candle> candlesDaily) {
  final recentDaily = candlesDaily.length > 20
      ? candlesDaily.sublist(candlesDaily.length - 20)
      : candlesDaily;

  // حساب النطاق والحجم
  final priceRange =
      recentDaily.map((c) => c.high - c.low).reduce((a, b) => a + b) /
          recentDaily.length;
  final volumeAvg = recentDaily.map((c) => c.volume).reduce((a, b) => a + b) /
      recentDaily.length;
  final lastVolume = recentDaily.last.volume;

  // Phase A - Selling Climax (SC) أو Buying Climax (BC)
  if (lastVolume > volumeAvg * 2.0 && priceRange > 10.0) {
    return WyckoffAnalysis(
      phase: WyckoffPhase.accumulationPhaseA,
      confidence: 80.0,
      description: 'مرحلة A - ذروة البيع (Selling Climax)',
      bias: TrendDirection.bullish,
    );
  }

  // Phase B - Building a Cause (التجميع)
  if (priceRange < 5.0 && lastVolume < volumeAvg * 0.8) {
    return WyckoffAnalysis(
      phase: WyckoffPhase.accumulationPhaseB,
      confidence: 75.0,
      description: 'مرحلة B - بناء السبب (التجميع)',
      bias: TrendDirection.ranging,
    );
  }

  // Phase C - Spring (اختبار الدعم)
  final hasSpring = detectSpring(candles4h);
  if (hasSpring) {
    return WyckoffAnalysis(
      phase: WyckoffPhase.accumulationPhaseC,
      confidence: 85.0,
      description: 'مرحلة C - الاختبار (Spring)',
      bias: TrendDirection.bullish,
    );
  }

  // Phase D - Sign of Strength (SOS)
  final hasStrength = detectSignOfStrength(candles4h);
  if (hasStrength) {
    return WyckoffAnalysis(
      phase: WyckoffPhase.accumulationPhaseD,
      confidence: 90.0,
      description: 'مرحلة D - علامة القوة (SOS)',
      bias: TrendDirection.bullish,
    );
  }

  // Default: Phase E - Markup
  return WyckoffAnalysis(
    phase: WyckoffPhase.accumulationPhaseE,
    confidence: 70.0,
    description: 'مرحلة E - الارتفاع (Markup)',
    bias: TrendDirection.bullish,
  );
}

bool detectSpring(List<Candle> candles) {
  if (candles.length < 10) return false;

  final recent = candles.sublist(candles.length - 10);
  final lows = recent.map((c) => c.low).toList();
  final minLow = lows.reduce(min);

  // Spring: كسر زائف للدعم ثم ارتداد
  final hasBreak = recent.where((c) => c.low < minLow * 0.998).length >= 2;
  final hasRecovery = recent.last.close > minLow * 1.002;

  return hasBreak && hasRecovery;
}

bool detectSignOfStrength(List<Candle> candles) {
  if (candles.length < 5) return false;

  final recent = candles.sublist(candles.length - 5);
  final bullishCandles = recent.where((c) => c.close > c.open).length;

  return bullishCandles >= 4; // معظم الشموع صاعدة
}

// ═══════════════════════════════════════════════════════════════
// 🌊 ELLIOTT WAVE ANALYSIS - تحليل موجات إليوت
// ═══════════════════════════════════════════════════════════════

class ElliottWaveAnalysis {
  final ElliottWaveType currentWave;
  final int waveCount;
  final double confidence;
  final TrendDirection bias;
  final List<double> fibonacciLevels;

  ElliottWaveAnalysis({
    required this.currentWave,
    required this.waveCount,
    required this.confidence,
    required this.bias,
    required this.fibonacciLevels,
  });
}

enum ElliottWaveType {
  impulseWave1,
  impulseWave2,
  impulseWave3,
  impulseWave4,
  impulseWave5,
  correctiveWaveA,
  correctiveWaveB,
  correctiveWaveC,
}

ElliottWaveAnalysis detectElliottWave(List<Candle> candles) {
  // التبسيط: كشف الموجات بناءً على القمم والقيعان
  final swingPoints = identifySwingPoints(candles);

  if (swingPoints.length < 5) {
    return ElliottWaveAnalysis(
      currentWave: ElliottWaveType.impulseWave1,
      waveCount: 1,
      confidence: 60.0,
      bias: TrendDirection.ranging,
      fibonacciLevels: [],
    );
  }

  // Impulse Pattern: 5 waves (1-2-3-4-5)
  final isImpulse = isImpulsePattern(swingPoints);

  if (isImpulse) {
    // نحن في موجة 5 (الأخيرة) - توقع تصحيح
    return ElliottWaveAnalysis(
      currentWave: ElliottWaveType.impulseWave5,
      waveCount: 5,
      confidence: 80.0,
      bias: TrendDirection.bearish, // توقع تصحيح
      fibonacciLevels: _calculateFibonacciRetracements(swingPoints),
    );
  }

  // Corrective Pattern: ABC
  return ElliottWaveAnalysis(
    currentWave: ElliottWaveType.correctiveWaveB,
    waveCount: 2,
    confidence: 75.0,
    bias: TrendDirection.ranging,
    fibonacciLevels: _calculateFibonacciRetracements(swingPoints),
  );
}

List<SwingPoint> identifySwingPoints(List<Candle> candles) {
  List<SwingPoint> points = [];

  for (int i = 5; i < candles.length - 5; i++) {
    final current = candles[i];
    final before = candles.sublist(i - 5, i);
    final after = candles.sublist(i + 1, i + 6);

    // Swing High
    if (before.every((c) => c.high < current.high) &&
        after.every((c) => c.high < current.high)) {
      points
          .add(SwingPoint(type: SwingType.high, price: current.high, index: i));
    }

    // Swing Low
    if (before.every((c) => c.low > current.low) &&
        after.every((c) => c.low > current.low)) {
      points.add(SwingPoint(type: SwingType.low, price: current.low, index: i));
    }
  }

  return points;
}

bool isImpulsePattern(List<SwingPoint> points) {
  if (points.length < 5) return false;

  // Impulse: Low-High-Low-High-Low أو High-Low-High-Low-High
  final last5 = points.sublist(points.length - 5);

  // Bullish Impulse
  if (last5[0].type == SwingType.low &&
      last5[1].type == SwingType.high &&
      last5[2].type == SwingType.low &&
      last5[3].type == SwingType.high &&
      last5[4].type == SwingType.low) {
    return true;
  }

  // Bearish Impulse
  if (last5[0].type == SwingType.high &&
      last5[1].type == SwingType.low &&
      last5[2].type == SwingType.high &&
      last5[3].type == SwingType.low &&
      last5[4].type == SwingType.high) {
    return true;
  }

  return false;
}

List<double> _calculateFibonacciRetracements(List<SwingPoint> points) {
  if (points.length < 2) return [];

  final highPoints = points.where((p) => p.type == SwingType.high).toList();
  final lowPoints = points.where((p) => p.type == SwingType.low).toList();

  if (highPoints.isEmpty || lowPoints.isEmpty) return [];

  final high = highPoints.map((p) => p.price).reduce(max);
  final low = lowPoints.map((p) => p.price).reduce(min);
  final range = high - low;

  return [
    low + (range * 0.236),
    low + (range * 0.382),
    low + (range * 0.5),
    low + (range * 0.618),
    low + (range * 0.786),
  ];
}

class SwingPoint {
  final SwingType type;
  final double price;
  final int index;

  SwingPoint({required this.type, required this.price, required this.index});
}

// ═══════════════════════════════════════════════════════════════
// 📊 VOLUME PROFILE ANALYSIS - تحليل الحجم
// ═══════════════════════════════════════════════════════════════

class VolumeProfileAnalysis {
  final double pointOfControl; // POC - أعلى حجم
  final double valueAreaHigh; // VAH
  final double valueAreaLow; // VAL
  final List<VolumeNode> volumeNodes;
  final TrendDirection bias;

  VolumeProfileAnalysis({
    required this.pointOfControl,
    required this.valueAreaHigh,
    required this.valueAreaLow,
    required this.volumeNodes,
    required this.bias,
  });
}

class VolumeNode {
  final double price;
  final double volume;
  final NodeType type;

  VolumeNode({
    required this.price,
    required this.volume,
    required this.type,
  });
}

enum NodeType { highVolume, lowVolume }

VolumeProfileAnalysis buildVolumeProfile(
    List<Candle> candles, double currentPrice) {
  // بناء توزيع الحجم على مستويات السعر
  Map<double, double> volumeByPrice = {};

  for (final candle in candles) {
    final priceLevel = (candle.close / 10).round() * 10.0; // تجميع كل 10$
    volumeByPrice[priceLevel] =
        (volumeByPrice[priceLevel] ?? 0) + candle.volume;
  }

  // POC: المستوى بأعلى حجم
  final poc =
      volumeByPrice.entries.reduce((a, b) => a.value > b.value ? a : b).key;

  // حساب Value Area (70% من الحجم)
  final totalVolume = volumeByPrice.values.reduce((a, b) => a + b);
  final targetVolume = totalVolume * 0.7;

  List<MapEntry<double, double>> sortedByVolume = volumeByPrice.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  double accumulatedVolume = 0;
  List<double> valueAreaPrices = [];

  for (final entry in sortedByVolume) {
    if (accumulatedVolume >= targetVolume) break;
    valueAreaPrices.add(entry.key);
    accumulatedVolume += entry.value;
  }

  final vah = valueAreaPrices.reduce(max);
  final val = valueAreaPrices.reduce(min);

  // Volume Nodes
  List<VolumeNode> nodes = [];
  final avgVolume =
      volumeByPrice.values.reduce((a, b) => a + b) / volumeByPrice.length;

  for (final entry in volumeByPrice.entries) {
    if (entry.value > avgVolume * 1.5) {
      nodes.add(VolumeNode(
        price: entry.key,
        volume: entry.value,
        type: NodeType.highVolume,
      ));
    } else if (entry.value < avgVolume * 0.5) {
      nodes.add(VolumeNode(
        price: entry.key,
        volume: entry.value,
        type: NodeType.lowVolume,
      ));
    }
  }

  // Bias based on current price vs POC
  final bias =
      currentPrice > poc ? TrendDirection.bullish : TrendDirection.bearish;

  return VolumeProfileAnalysis(
    pointOfControl: poc,
    valueAreaHigh: vah,
    valueAreaLow: val,
    volumeNodes: nodes,
    bias: bias,
  );
}
