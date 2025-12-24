import 'dart:math';
import '../../models/candle.dart';
import '../../core/utils/logger.dart';

/// 💰 Smart Money Quantum Tracker
/// يتتبع "آثار الأموال الذكية" - المؤسسات والحيتان
class SmartMoneyTracker {
  /// تتبع الأموال الذكية
  static SmartMoneyFlow track(List<Candle> candles) {
    if (candles.length < 50) {
      throw Exception('Need at least 50 candles for smart money analysis');
    }

    AppLogger.info('💰 Tracking smart money...');

    // 1. حساب Volume Delta (الفرق بين الشراء والبيع)
    final volumeDelta = _calculateVolumeDelta(candles);

    // 2. كشف Order Flow Imbalance (عدم توازن الأوامر)
    final orderFlowImbalance = _calculateOrderFlowImbalance(candles);

    // 3. كشف نشاط الحيتان (Whale Detection)
    final whaleActivity = _detectWhaleActivity(candles);

    // 4. حساب Accumulation/Distribution
    final accumulationDistribution =
        _calculateAccumulationDistribution(candles);

    // 5. تحديد اتجاه الأموال الذكية
    final smartMoneyDirection = _determineSmartMoneyDirection(
      volumeDelta,
      orderFlowImbalance,
      accumulationDistribution,
    );

    // 6. حساب قوة الأموال الذكية
    final smartMoneyStrength = _calculateSmartMoneyStrength(
      volumeDelta,
      orderFlowImbalance,
      whaleActivity,
      accumulationDistribution,
    );

    // 7. حساب الثقة
    final confidence = _calculateConfidence(
      volumeDelta,
      orderFlowImbalance,
      whaleActivity,
    );

    final flow = SmartMoneyFlow(
      volumeDelta: volumeDelta,
      orderFlowImbalance: orderFlowImbalance,
      whaleActivity: whaleActivity,
      accumulationDistribution: accumulationDistribution,
      smartMoneyDirection: smartMoneyDirection,
      smartMoneyStrength: smartMoneyStrength,
      confidence: confidence,
      timestamp: DateTime.now(),
    );

    AppLogger.success(
      '✅ Smart Money: ${smartMoneyDirection.name} (strength: ${(smartMoneyStrength * 100).toStringAsFixed(1)}%)',
    );

    return flow;
  }

  /// حساب Volume Delta
  /// Delta = Buy Volume - Sell Volume
  static double _calculateVolumeDelta(List<Candle> candles) {
    final recent = candles.sublist(candles.length - 20);

    double buyVolume = 0;
    double sellVolume = 0;

    for (var candle in recent) {
      if (candle.close > candle.open) {
        // شمعة خضراء = شراء
        buyVolume += candle.volume;
      } else {
        // شمعة حمراء = بيع
        sellVolume += candle.volume;
      }
    }

    final delta = buyVolume - sellVolume;

    // Normalize to millions
    return delta / 1000000;
  }

  /// حساب Order Flow Imbalance
  /// Imbalance = Buy Orders / Sell Orders
  static double _calculateOrderFlowImbalance(List<Candle> candles) {
    final recent = candles.sublist(candles.length - 20);

    double buyOrders = 0;
    double sellOrders = 0;

    for (var candle in recent) {
      final bodySize = (candle.close - candle.open).abs();
      final upperWick = candle.high - max(candle.open, candle.close);
      final lowerWick = min(candle.open, candle.close) - candle.low;

      if (candle.close > candle.open) {
        // شمعة خضراء
        buyOrders += bodySize + upperWick;
        sellOrders += lowerWick;
      } else {
        // شمعة حمراء
        sellOrders += bodySize + lowerWick;
        buyOrders += upperWick;
      }
    }

    if (sellOrders == 0) return 10.0; // تجنب القسمة على صفر

    return buyOrders / sellOrders;
  }

  /// كشف نشاط الحيتان
  /// Whale = شمعة بحجم أكبر من 3× المتوسط
  static WhaleActivity _detectWhaleActivity(List<Candle> candles) {
    final recent = candles.sublist(candles.length - 50);

    // حساب متوسط الحجم
    final avgVolume =
        recent.map((c) => c.volume).reduce((a, b) => a + b) / recent.length;
    final whaleThreshold = avgVolume * 3;

    // كشف الحيتان
    final whales = recent.where((c) => c.volume > whaleThreshold).toList();

    int bullishWhales = 0;
    int bearishWhales = 0;

    for (var whale in whales) {
      if (whale.close > whale.open) {
        bullishWhales++;
      } else {
        bearishWhales++;
      }
    }

    return WhaleActivity(
      totalWhales: whales.length,
      bullishWhales: bullishWhales,
      bearishWhales: bearishWhales,
      lastWhaleCandle: whales.isNotEmpty ? whales.last : null,
    );
  }

  /// حساب Accumulation/Distribution
  /// A/D = Σ[(Close - Low) - (High - Close)] / (High - Low) × Volume
  static double _calculateAccumulationDistribution(List<Candle> candles) {
    final recent = candles.sublist(candles.length - 20);

    double ad = 0;

    for (var candle in recent) {
      final range = candle.high - candle.low;
      if (range == 0) continue;

      final moneyFlowMultiplier =
          ((candle.close - candle.low) - (candle.high - candle.close)) / range;
      final moneyFlowVolume = moneyFlowMultiplier * candle.volume;

      ad += moneyFlowVolume;
    }

    // Normalize to millions
    return ad / 1000000;
  }

  /// تحديد اتجاه الأموال الذكية
  static SmartMoneyDirection _determineSmartMoneyDirection(
    double volumeDelta,
    double orderFlowImbalance,
    double accumulationDistribution,
  ) {
    int buySignals = 0;
    int sellSignals = 0;

    // Volume Delta
    if (volumeDelta > 5) {
      buySignals++;
    } else if (volumeDelta < -5) {
      sellSignals++;
    }

    // Order Flow Imbalance
    if (orderFlowImbalance > 1.5) {
      buySignals++;
    } else if (orderFlowImbalance < 0.67) {
      sellSignals++;
    }

    // Accumulation/Distribution (10x more sensitive)
    if (accumulationDistribution > 1.0) {
      buySignals++;
    } else if (accumulationDistribution < -1.0) {
      sellSignals++;
    }

    if (buySignals > sellSignals) {
      return SmartMoneyDirection.buying;
    } else if (sellSignals > buySignals) {
      return SmartMoneyDirection.selling;
    } else {
      return SmartMoneyDirection.neutral;
    }
  }

  /// حساب قوة الأموال الذكية
  static double _calculateSmartMoneyStrength(
    double volumeDelta,
    double orderFlowImbalance,
    WhaleActivity whaleActivity,
    double accumulationDistribution,
  ) {
    double score = 0.0;

    // Volume Delta strength (10x more sensitive)
    score += min(volumeDelta.abs() / 5.0, 0.25);

    // Order Flow Imbalance strength (more sensitive)
    final imbalanceScore = (orderFlowImbalance - 1).abs();
    score += min(imbalanceScore / 0.5, 0.25);

    // Whale Activity strength
    if (whaleActivity.totalWhales > 0) {
      score += min(whaleActivity.totalWhales / 5.0, 0.25); // 2x more sensitive
    }

    // Accumulation/Distribution strength (10x more sensitive)
    score += min(accumulationDistribution.abs() / 10.0, 0.25);

    return min(score, 1.0);
  }

  /// حساب الثقة
  static double _calculateConfidence(
    double volumeDelta,
    double orderFlowImbalance,
    WhaleActivity whaleActivity,
  ) {
    double score = 0.0;

    // Volume Delta confidence (10x more sensitive)
    if (volumeDelta.abs() > 2.0) score += 0.33;

    // Order Flow Imbalance confidence (more sensitive)
    if (orderFlowImbalance > 1.5 || orderFlowImbalance < 0.67) score += 0.33;

    // Whale Activity confidence
    if (whaleActivity.totalWhales >= 3) score += 0.34;

    return score;
  }
}

/// 💰 Smart Money Flow Model
class SmartMoneyFlow {
  final double volumeDelta; // بالملايين
  final double orderFlowImbalance; // نسبة
  final WhaleActivity whaleActivity;
  final double accumulationDistribution; // بالملايين
  final SmartMoneyDirection smartMoneyDirection;
  final double smartMoneyStrength; // 0-1
  final double confidence; // 0-1
  final DateTime timestamp;

  SmartMoneyFlow({
    required this.volumeDelta,
    required this.orderFlowImbalance,
    required this.whaleActivity,
    required this.accumulationDistribution,
    required this.smartMoneyDirection,
    required this.smartMoneyStrength,
    required this.confidence,
    required this.timestamp,
  });

  /// هل الأموال الذكية نشطة؟
  bool get isActive => smartMoneyStrength > 0.6;

  /// هل يوجد حيتان؟
  bool get hasWhales => whaleActivity.totalWhales > 0;

  /// هل الإشارة قوية؟
  bool get isStrongSignal => confidence > 0.7 && smartMoneyStrength > 0.7;

  @override
  String toString() {
    return 'SmartMoneyFlow('
        'delta: \$${volumeDelta.toStringAsFixed(1)}M, '
        'imbalance: ${orderFlowImbalance.toStringAsFixed(2)}, '
        'whales: ${whaleActivity.totalWhales}, '
        'A/D: \$${accumulationDistribution.toStringAsFixed(1)}M, '
        'direction: ${smartMoneyDirection.name}, '
        'strength: ${(smartMoneyStrength * 100).toStringAsFixed(1)}%, '
        'confidence: ${(confidence * 100).toStringAsFixed(1)}%'
        ')';
  }
}

/// نشاط الحيتان
class WhaleActivity {
  final int totalWhales;
  final int bullishWhales;
  final int bearishWhales;
  final Candle? lastWhaleCandle;

  WhaleActivity({
    required this.totalWhales,
    required this.bullishWhales,
    required this.bearishWhales,
    this.lastWhaleCandle,
  });

  /// هل الحيتان صاعدة؟
  bool get areBullish => bullishWhales > bearishWhales;

  /// هل الحيتان هابطة؟
  bool get areBearish => bearishWhales > bullishWhales;
}

/// اتجاه الأموال الذكية
enum SmartMoneyDirection {
  buying,
  selling,
  neutral,
}
