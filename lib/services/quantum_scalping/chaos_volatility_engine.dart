import 'dart:math';
import '../../models/candle.dart';
import '../../core/utils/logger.dart';

/// 🌪️ Chaos Volatility Engine
/// يستخدم نظرية الفوضى لتوقع التقلبات
class ChaosVolatilityEngine {
  /// تحليل التقلبات باستخدام نظرية الفوضى
  static ChaosAnalysis analyze(List<Candle> candles) {
    if (candles.length < 100) {
      throw Exception('Need at least 100 candles for chaos analysis');
    }

    AppLogger.info('🌪️ Analyzing chaos and volatility...');

    // 1. حساب Lyapunov Exponent (معامل التشتت)
    final lyapunovExponent = _calculateLyapunovExponent(candles);

    // 2. حساب Fractal Dimension (البعد الكسيري)
    final fractalDimension = _calculateFractalDimension(candles);

    // 3. حساب Entropy (العشوائية)
    final entropy = _calculateEntropy(candles);

    // 4. حساب Volatility (التقلب)
    final volatility = _calculateVolatility(candles);

    // 5. حساب Hurst Exponent (الاتجاهية)
    final hurstExponent = _calculateHurstExponent(candles);

    // 6. توقع نقطة الانفجار (Chaos Point)
    final chaosPointProbability = _predictChaosPoint(
      lyapunovExponent,
      fractalDimension,
      entropy,
      volatility,
    );

    // 7. تحديد حالة السوق
    final marketCondition = _determineMarketCondition(
      lyapunovExponent,
      entropy,
      hurstExponent,
    );

    // 8. حساب مستوى الخطر
    final riskLevel = _calculateRiskLevel(
      volatility,
      entropy,
      chaosPointProbability,
    );

    final analysis = ChaosAnalysis(
      lyapunovExponent: lyapunovExponent,
      fractalDimension: fractalDimension,
      entropy: entropy,
      volatility: volatility,
      hurstExponent: hurstExponent,
      chaosPointProbability: chaosPointProbability,
      marketCondition: marketCondition,
      riskLevel: riskLevel,
      timestamp: DateTime.now(),
    );

    AppLogger.success(
      '✅ Chaos Analysis: ${marketCondition.name} (risk: ${(riskLevel * 100).toStringAsFixed(1)}%)',
    );

    return analysis;
  }

  /// حساب Lyapunov Exponent
  /// يقيس مدى حساسية النظام للتغيرات الصغيرة
  /// λ > 0: فوضى (chaotic)
  /// λ = 0: حد الفوضى
  /// λ < 0: مستقر (stable)
  static double _calculateLyapunovExponent(List<Candle> candles) {
    final prices = candles.map((c) => c.close).toList();
    final n = prices.length;

    double sumDivergence = 0;
    int count = 0;

    // حساب التباعد بين نقاط قريبة
    for (int i = 0; i < n - 10; i++) {
      final initialDistance = (prices[i + 1] - prices[i]).abs();
      if (initialDistance < 0.01) continue; // تجنب القسمة على صفر

      final finalDistance = (prices[min(i + 10, n - 1)] - prices[i]).abs();

      if (finalDistance > 0) {
        sumDivergence += log(finalDistance / initialDistance);
        count++;
      }
    }

    if (count == 0) return 0.0;

    final lyapunov = sumDivergence / (count * 10);

    // Normalize to -1 to 1
    return max(-1.0, min(1.0, lyapunov));
  }

  /// حساب Fractal Dimension
  /// يقيس مدى تعقيد السلسلة الزمنية
  /// D ≈ 1: خطي (linear)
  /// D ≈ 1.5: عشوائي (random walk)
  /// D ≈ 2: معقد جداً (highly complex)
  static double _calculateFractalDimension(List<Candle> candles) {
    final prices = candles.map((c) => c.close).toList();
    final n = prices.length;

    // حساب Box-Counting Dimension
    final scales = [2, 4, 8, 16, 32];
    final List<double> logScales = [];
    final List<double> logCounts = [];

    for (var scale in scales) {
      if (scale > n / 2) continue;

      int boxes = 0;
      for (int i = 0; i < n - scale; i += scale) {
        final segment = prices.sublist(i, min(i + scale, n));
        final minPrice = segment.reduce(min);
        final maxPrice = segment.reduce(max);
        final range = maxPrice - minPrice;

        if (range > 0) {
          boxes += ((range / (maxPrice * 0.001))).ceil();
        }
      }

      if (boxes > 0) {
        logScales.add(log(scale.toDouble()));
        logCounts.add(log(boxes.toDouble()));
      }
    }

    if (logScales.length < 2) return 1.5;

    // حساب الميل (slope) باستخدام linear regression
    final dimension = _linearRegressionSlope(logScales, logCounts).abs();

    return max(1.0, min(2.0, dimension));
  }

  /// حساب Entropy (العشوائية)
  /// يقيس مدى عشوائية البيانات
  static double _calculateEntropy(List<Candle> candles) {
    final returns = <double>[];
    for (int i = 1; i < candles.length; i++) {
      final returnValue =
          (candles[i].close - candles[i - 1].close) / candles[i - 1].close;
      returns.add(returnValue);
    }

    // تقسيم العوائد إلى bins
    const bins = 10;
    final minReturn = returns.reduce(min);
    final maxReturn = returns.reduce(max);
    final binSize = (maxReturn - minReturn) / bins;

    final binCounts = List<int>.filled(bins, 0);
    for (var returnValue in returns) {
      final binIndex =
          min(((returnValue - minReturn) / binSize).floor(), bins - 1);
      binCounts[binIndex]++;
    }

    // حساب Shannon Entropy
    double entropy = 0.0;
    for (var count in binCounts) {
      if (count > 0) {
        final probability = count / returns.length;
        entropy -= probability * log(probability) / log(2);
      }
    }

    // Normalize to 0-1
    final maxEntropy = log(bins.toDouble()) / log(2);
    return entropy / maxEntropy;
  }

  /// حساب Volatility (التقلب)
  static double _calculateVolatility(List<Candle> candles) {
    final returns = <double>[];
    for (int i = 1; i < candles.length; i++) {
      final returnValue =
          (candles[i].close - candles[i - 1].close) / candles[i - 1].close;
      returns.add(returnValue);
    }

    // حساب الانحراف المعياري
    final mean = returns.reduce((a, b) => a + b) / returns.length;
    final variance =
        returns.map((r) => pow(r - mean, 2)).reduce((a, b) => a + b) /
            returns.length;
    final stdDev = sqrt(variance);

    // Annualized volatility (assuming 1-minute candles, 1440 minutes/day, 252 trading days/year)
    final annualizedVolatility = stdDev * sqrt(1440 * 252);

    // Normalize to 0-1 (typical volatility range: 0-100%)
    return min(annualizedVolatility, 1.0);
  }

  /// حساب Hurst Exponent (الاتجاهية)
  /// H < 0.5: mean-reverting (يعود للمتوسط)
  /// H = 0.5: random walk (عشوائي)
  /// H > 0.5: trending (اتجاهي)
  static double _calculateHurstExponent(List<Candle> candles) {
    final prices = candles.map((c) => c.close).toList();
    final n = prices.length;

    // حساب R/S statistic
    final lags = [10, 20, 50];
    final List<double> logLags = [];
    final List<double> logRS = [];

    for (var lag in lags) {
      if (lag > n / 2) continue;

      final segments = n ~/ lag;
      double sumRS = 0;

      for (int i = 0; i < segments; i++) {
        final segment = prices.sublist(i * lag, (i + 1) * lag);
        final mean = segment.reduce((a, b) => a + b) / lag;

        // حساب cumulative deviation
        double cumulativeDeviation = 0;
        final deviations = <double>[];
        for (var price in segment) {
          cumulativeDeviation += price - mean;
          deviations.add(cumulativeDeviation);
        }

        final range = deviations.isNotEmpty
            ? (deviations.reduce(max) - deviations.reduce(min))
            : 0.0;
        final stdDev = sqrt(
            segment.map((p) => pow(p - mean, 2)).reduce((a, b) => a + b) / lag);

        if (stdDev > 0) {
          sumRS += range / stdDev;
        }
      }

      if (segments > 0) {
        logLags.add(log(lag.toDouble()));
        logRS.add(log(sumRS / segments));
      }
    }

    if (logLags.length < 2) return 0.5;

    // Hurst = slope of log(R/S) vs log(lag)
    final hurst = _linearRegressionSlope(logLags, logRS);

    return max(0.0, min(1.0, hurst));
  }

  /// توقع نقطة الفوضى (Chaos Point)
  static double _predictChaosPoint(
    double lyapunovExponent,
    double fractalDimension,
    double entropy,
    double volatility,
  ) {
    double score = 0.0;

    // Lyapunov > 0 = فوضى
    if (lyapunovExponent > 0) score += 0.3;

    // Fractal Dimension عالي = تعقيد
    if (fractalDimension > 1.7) score += 0.2;

    // Entropy عالي = عشوائية
    if (entropy > 0.7) score += 0.3;

    // Volatility عالي = تقلب
    if (volatility > 0.6) score += 0.2;

    return min(score, 1.0);
  }

  /// تحديد حالة السوق
  static MarketCondition _determineMarketCondition(
    double lyapunovExponent,
    double entropy,
    double hurstExponent,
  ) {
    if (lyapunovExponent > 0.2 && entropy > 0.7) {
      return MarketCondition.chaotic;
    } else if (hurstExponent > 0.6) {
      return MarketCondition.trending;
    } else if (hurstExponent < 0.4) {
      return MarketCondition.meanReverting;
    } else {
      return MarketCondition.stable;
    }
  }

  /// حساب مستوى الخطر
  static double _calculateRiskLevel(
    double volatility,
    double entropy,
    double chaosPointProbability,
  ) {
    return (volatility * 0.4 + entropy * 0.3 + chaosPointProbability * 0.3);
  }

  /// Linear Regression Slope
  static double _linearRegressionSlope(List<double> x, List<double> y) {
    final n = x.length;
    if (n != y.length || n < 2) return 0.0;

    final meanX = x.reduce((a, b) => a + b) / n;
    final meanY = y.reduce((a, b) => a + b) / n;

    double numerator = 0;
    double denominator = 0;

    for (int i = 0; i < n; i++) {
      numerator += (x[i] - meanX) * (y[i] - meanY);
      denominator += pow(x[i] - meanX, 2);
    }

    if (denominator == 0) return 0.0;

    return numerator / denominator;
  }
}

/// 🌪️ Chaos Analysis Model
class ChaosAnalysis {
  final double lyapunovExponent; // -1 to 1
  final double fractalDimension; // 1 to 2
  final double entropy; // 0 to 1
  final double volatility; // 0 to 1
  final double hurstExponent; // 0 to 1
  final double chaosPointProbability; // 0 to 1
  final MarketCondition marketCondition;
  final double riskLevel; // 0 to 1
  final DateTime timestamp;

  ChaosAnalysis({
    required this.lyapunovExponent,
    required this.fractalDimension,
    required this.entropy,
    required this.volatility,
    required this.hurstExponent,
    required this.chaosPointProbability,
    required this.marketCondition,
    required this.riskLevel,
    required this.timestamp,
  });

  /// هل السوق فوضوي؟
  bool get isChaotic => marketCondition == MarketCondition.chaotic;

  /// هل السوق مستقر؟
  bool get isStable => marketCondition == MarketCondition.stable;

  /// هل السوق اتجاهي؟
  bool get isTrending => marketCondition == MarketCondition.trending;

  /// هل الخطر عالي؟
  bool get isHighRisk => riskLevel > 0.7;

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'lyapunov_exponent': lyapunovExponent,
      'fractal_dimension': fractalDimension,
      'entropy': entropy,
      'volatility': volatility,
      'hurst_exponent': hurstExponent,
      'chaos_point_probability': chaosPointProbability,
      'market_condition': marketCondition.name,
      'risk_level': riskLevel,
      'is_chaotic': isChaotic,
      'is_stable': isStable,
      'is_trending': isTrending,
      'is_high_risk': isHighRisk,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ChaosAnalysis('
        'lyapunov: ${lyapunovExponent.toStringAsFixed(3)}, '
        'fractal: ${fractalDimension.toStringAsFixed(3)}, '
        'entropy: ${(entropy * 100).toStringAsFixed(1)}%, '
        'volatility: ${(volatility * 100).toStringAsFixed(1)}%, '
        'hurst: ${hurstExponent.toStringAsFixed(3)}, '
        'chaos: ${(chaosPointProbability * 100).toStringAsFixed(1)}%, '
        'condition: ${marketCondition.name}, '
        'risk: ${(riskLevel * 100).toStringAsFixed(1)}%'
        ')';
  }
}

/// حالة السوق
enum MarketCondition {
  stable,
  trending,
  meanReverting,
  chaotic,
}
