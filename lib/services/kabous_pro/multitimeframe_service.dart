/// KABOUS PRO - Multi-Timeframe Service
/// ============================
/// Ported from multitimeframe.py

import 'kabous_models.dart';
import '../golden_nightmare/golden_nightmare_engine.dart';
import '../candle_generator.dart';
import '../technical_indicators_service.dart';
import '../../core/utils/logger.dart';

class MultiTimeframeService {
  static final List<String> timeframes = ['1m', '5m', '15m', '1h', '4h'];

  /// Analyze all timeframes
  static Future<MultiTimeframeResult> analyzeAllTimeframes({
    required double currentPrice,
  }) async {
    try {
      AppLogger.info('Starting Multi-Timeframe Analysis...');

      final results = <String, TimeframeAnalysis>{};

      // Analyze each timeframe
      for (final tf in timeframes) {
        try {
          // توليد شموع لهذا الإطار الزمني
          final candles = CandleGenerator.generate(
            currentPrice: currentPrice,
            timeframe: tf,
            count: 200,
          );

          if (candles.isEmpty || candles.length < 50) {
            continue;
          }

          // Calculate indicators
          final indicators = TechnicalIndicatorsService.calculateAll(candles);

          // Analyze using Golden Nightmare Engine
          final analysis = await GoldenNightmareEngine.generate(
            currentPrice: currentPrice,
            candles: candles,
            rsi: indicators.rsi,
            macd: indicators.macd,
            macdSignal: indicators.macdSignal,
            ma20: indicators.ma20,
            ma50: indicators.ma50,
            ma100: indicators.ma100,
            ma200: indicators.ma200,
            atr: indicators.atr,
          );

          final scalpData = analysis['SCALP'];
          if (scalpData != null) {
            results[tf] = TimeframeAnalysis(
              timeframe: tf,
              signal: scalpData['direction'] ?? 'NO_TRADE',
              confidence: _safeDouble(scalpData['confidence']),
              trend: _determineTrend(indicators),
              strength: _safeDouble(scalpData['confidence']) / 10.0,
            );
          }
        } catch (e) {
          AppLogger.warn('Error analyzing timeframe $tf: $e');
          continue;
        }
      }

      // Calculate overall signal
      final overall = _calculateOverallSignal(results);

      return MultiTimeframeResult(
        overallSignal: overall['signal'],
        overallConfidence: overall['confidence'],
        timeframes: results,
        alignmentScore: overall['alignment'],
        recommendation: overall['recommendation'],
      );
    } catch (e, stackTrace) {
      AppLogger.error('Multi-Timeframe Analysis failed', e, stackTrace);
      rethrow;
    }
  }

  static double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static String _determineTrend(dynamic indicators) {
    final ema9 = indicators.ma20; // Use ma20 as proxy
    final ema21 = indicators.ma50;
    final ema50 = indicators.ma100;

    if (ema9 > ema21 && ema21 > ema50) {
      return 'STRONG_UPTREND';
    } else if (ema9 > ema21) {
      return 'UPTREND';
    } else if (ema9 < ema21 && ema21 < ema50) {
      return 'STRONG_DOWNTREND';
    } else if (ema9 < ema21) {
      return 'DOWNTREND';
    } else {
      return 'SIDEWAYS';
    }
  }

  static Map<String, dynamic> _calculateOverallSignal(
    Map<String, TimeframeAnalysis> timeframeResults,
  ) {
    if (timeframeResults.isEmpty) {
      return {
        'signal': 'HOLD',
        'confidence': 0.0,
        'alignment': 0.0,
        'recommendation': 'لا توجد بيانات كافية',
      };
    }

    // Count signals
    int buyCount = 0;
    int sellCount = 0;
    int holdCount = 0;

    // Weights by timeframe importance
    final weights = {
      '1m': 0.5,
      '5m': 1.0,
      '15m': 1.5,
      '1h': 2.0,
      '4h': 2.5,
    };

    double weightedBuy = 0;
    double weightedSell = 0;
    double totalWeight = 0;

    for (final entry in timeframeResults.entries) {
      final tf = entry.key;
      final analysis = entry.value;
      final weight = weights[tf] ?? 1.0;
      totalWeight += weight;

      if (analysis.signal == 'BUY') {
        buyCount++;
        weightedBuy += weight;
      } else if (analysis.signal == 'SELL') {
        sellCount++;
        weightedSell += weight;
      } else {
        holdCount++;
      }
    }

    // Calculate alignment score (0-10)
    final totalCount = timeframeResults.length;
    final maxCount = [buyCount, sellCount, holdCount].reduce((a, b) => a > b ? a : b);
    final alignmentScore = (maxCount / totalCount) * 10;

    // Determine overall signal
    String overallSignal;
    double overallConfidence;
    String recommendation;

    if (weightedBuy > weightedSell && buyCount >= 3) {
      overallSignal = 'BUY';
      overallConfidence = ((weightedBuy / totalWeight) * 100).clamp(0, 95);
      recommendation = _generateRecommendation('BUY', buyCount, totalCount, alignmentScore);
    } else if (weightedSell > weightedBuy && sellCount >= 3) {
      overallSignal = 'SELL';
      overallConfidence = ((weightedSell / totalWeight) * 100).clamp(0, 95);
      recommendation = _generateRecommendation('SELL', sellCount, totalCount, alignmentScore);
    } else {
      overallSignal = 'HOLD';
      overallConfidence = 50.0;
      recommendation = 'الأطر الزمنية غير متوافقة - انتظر فرصة أفضل';
    }

    return {
      'signal': overallSignal,
      'confidence': overallConfidence,
      'alignment': alignmentScore,
      'recommendation': recommendation,
    };
  }

  static String _generateRecommendation(
    String signal,
    int signalCount,
    int totalCount,
    double alignment,
  ) {
    String strength;
    if (alignment >= 8) {
      strength = "قوية جداً";
    } else if (alignment >= 6) {
      strength = "قوية";
    } else if (alignment >= 4) {
      strength = "متوسطة";
    } else {
      strength = "ضعيفة";
    }

    final action = signal == 'BUY' ? "شراء" : "بيع";

    return "فرصة $action $strength - $signalCount/$totalCount أطر زمنية تؤكد";
  }
}

