import 'dart:math';
import '../../models/candle.dart';
import '../../core/utils/logger.dart';

/// 🌌 Quantum State Analyzer
/// يحلل السوق كحالة كمومية - السعر موجود في عدة احتمالات في نفس الوقت
class QuantumStateAnalyzer {
  /// تحليل الحالة الكمومية للسوق
  static QuantumState analyze(List<Candle> candles) {
    if (candles.length < 50) {
      throw Exception('Need at least 50 candles for quantum analysis');
    }

    AppLogger.info('🌌 Analyzing quantum state...');

    // 1. حساب احتمال الصعود
    final bullishProbability = _calculateBullishProbability(candles);

    // 2. حساب احتمال الهبوط
    final bearishProbability = _calculateBearishProbability(candles);

    // 3. حساب احتمال الحياد
    final neutralProbability = 1.0 - bullishProbability - bearishProbability;

    // 4. تحديد الحالة المهيمنة
    final dominantState = _determineDominantState(
      bullishProbability,
      bearishProbability,
      neutralProbability,
    );

    // 5. حساب قوة الحالة
    final stateStrength = _calculateStateStrength(
      bullishProbability,
      bearishProbability,
      neutralProbability,
    );

    // 6. حساب entropy (العشوائية)
    final entropy = _calculateEntropy(
      bullishProbability,
      bearishProbability,
      neutralProbability,
    );

    final state = QuantumState(
      bullishProbability: bullishProbability,
      bearishProbability: bearishProbability,
      neutralProbability: neutralProbability,
      dominantState: dominantState,
      stateStrength: stateStrength,
      entropy: entropy,
      confidence: stateStrength,
    );

    AppLogger.success(
      '✅ Quantum State: ${dominantState.name} '
      '(${(stateStrength * 100).toStringAsFixed(1)}%)',
    );

    return state;
  }

  /// حساب احتمال الصعود
  static double _calculateBullishProbability(List<Candle> candles) {
    double score = 0.0;
    int bullishCandles = 0;
    double priceChange = 0.0;

    // 1. عدد الشموع الصاعدة
    for (final candle in candles.take(20)) {
      if (candle.close > candle.open) {
        bullishCandles++;
      }
    }
    score += (bullishCandles / 20) * 0.3;

    // 2. التغير في السعر
    priceChange =
        (candles.last.close - candles.first.close) / candles.first.close;
    if (priceChange > 0) {
      score += min(priceChange * 10, 0.3);
    }

    // 3. momentum
    final recentChange =
        (candles.last.close - candles[candles.length - 10].close) /
            candles[candles.length - 10].close;
    if (recentChange > 0) {
      score += min(recentChange * 10, 0.2);
    }

    // 4. Higher highs & Higher lows
    int higherHighs = 0;
    int higherLows = 0;
    for (int i = 10; i < candles.length; i += 10) {
      final prevHigh = candles[i - 10].high;
      final currHigh = candles[i].high;
      final prevLow = candles[i - 10].low;
      final currLow = candles[i].low;

      if (currHigh > prevHigh) higherHighs++;
      if (currLow > prevLow) higherLows++;
    }
    score += ((higherHighs + higherLows) / (candles.length / 5)) * 0.2;

    return min(score, 0.95);
  }

  /// حساب احتمال الهبوط
  static double _calculateBearishProbability(List<Candle> candles) {
    double score = 0.0;
    int bearishCandles = 0;
    double priceChange = 0.0;

    // 1. عدد الشموع الهابطة
    for (final candle in candles.take(20)) {
      if (candle.close < candle.open) {
        bearishCandles++;
      }
    }
    score += (bearishCandles / 20) * 0.3;

    // 2. التغير في السعر
    priceChange =
        (candles.first.close - candles.last.close) / candles.first.close;
    if (priceChange > 0) {
      score += min(priceChange * 10, 0.3);
    }

    // 3. momentum
    final recentChange =
        (candles[candles.length - 10].close - candles.last.close) /
            candles[candles.length - 10].close;
    if (recentChange > 0) {
      score += min(recentChange * 10, 0.2);
    }

    // 4. Lower highs & Lower lows
    int lowerHighs = 0;
    int lowerLows = 0;
    for (int i = 10; i < candles.length; i += 10) {
      final prevHigh = candles[i - 10].high;
      final currHigh = candles[i].high;
      final prevLow = candles[i - 10].low;
      final currLow = candles[i].low;

      if (currHigh < prevHigh) lowerHighs++;
      if (currLow < prevLow) lowerLows++;
    }
    score += ((lowerHighs + lowerLows) / (candles.length / 5)) * 0.2;

    return min(score, 0.95);
  }

  /// تحديد الحالة المهيمنة
  static MarketState _determineDominantState(
    double bullish,
    double bearish,
    double neutral,
  ) {
    if (bullish > bearish && bullish > neutral) {
      return MarketState.bullish;
    } else if (bearish > bullish && bearish > neutral) {
      return MarketState.bearish;
    } else {
      return MarketState.ranging;
    }
  }

  /// حساب قوة الحالة
  static double _calculateStateStrength(
    double bullish,
    double bearish,
    double neutral,
  ) {
    final maxProb = max(max(bullish, bearish), neutral);
    final minProb = min(min(bullish, bearish), neutral);
    return maxProb - minProb; // الفرق بين أعلى وأدنى احتمال
  }

  /// حساب Entropy (العشوائية)
  /// Entropy = -Σ(p × log(p))
  static double _calculateEntropy(
    double bullish,
    double bearish,
    double neutral,
  ) {
    double entropy = 0.0;

    if (bullish > 0) entropy -= bullish * log(bullish);
    if (bearish > 0) entropy -= bearish * log(bearish);
    if (neutral > 0) entropy -= neutral * log(neutral);

    return entropy / log(3); // Normalize to 0-1
  }
}

/// 🌌 Quantum State Model
class QuantumState {
  final double bullishProbability;
  final double bearishProbability;
  final double neutralProbability;
  final MarketState dominantState;
  final double stateStrength; // 0-1
  final double entropy; // 0-1 (عشوائية)
  final double confidence; // 0-1

  QuantumState({
    required this.bullishProbability,
    required this.bearishProbability,
    required this.neutralProbability,
    required this.dominantState,
    required this.stateStrength,
    required this.entropy,
    required this.confidence,
  });

  /// هل الحالة قوية؟
  bool get isStrong => stateStrength >= 0.6;

  /// هل السوق عشوائي؟
  bool get isRandom => entropy >= 0.8;

  @override
  String toString() {
    return 'QuantumState('
        'dominant: ${dominantState.name}, '
        'strength: ${(stateStrength * 100).toStringAsFixed(1)}%, '
        'entropy: ${(entropy * 100).toStringAsFixed(1)}%'
        ')';
  }
}

/// حالات السوق
enum MarketState {
  bullish,
  bearish,
  ranging,
}
