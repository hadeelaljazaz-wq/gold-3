/// 🌊 Elliott Wave Models
///
/// موديلات Elliott Wave - الموجات الدافعة والتصحيحية
library;

import 'package:flutter/foundation.dart';

// لم يتم إنشاء الملف بعد - Placeholder

/// Elliott Wave - موجة Elliott
@immutable
class ElliottWave {
  final WaveType type;
  final int waveNumber;
  final double startPrice;
  final double endPrice;
  final DateTime startTime;
  final DateTime endTime;

  ElliottWave({
    required this.type,
    required this.waveNumber,
    required this.startPrice,
    required this.endPrice,
    required this.startTime,
    required this.endTime,
  });

  double get waveSize => (endPrice - startPrice).abs();
  bool get isImpulse => type == WaveType.impulse;
  bool get isCorrective => type == WaveType.corrective;
}

enum WaveType {
  impulse, // موجة دافعة (1,2,3,4,5)
  corrective, // موجة تصحيحية (A,B,C)
}

/// Wave Count - عدّ الموجات
class WaveCount {
  final List<ElliottWave> impulseWaves; // 1-2-3-4-5
  final List<ElliottWave> correctiveWaves; // A-B-C
  final int currentWave;
  final WaveType currentType;
  final bool isComplete;

  WaveCount({
    required this.impulseWaves,
    required this.correctiveWaves,
    required this.currentWave,
    required this.currentType,
    required this.isComplete,
  });

  bool get isInWave3 => currentWave == 3 && currentType == WaveType.impulse;
  bool get isInWave5 => currentWave == 5 && currentType == WaveType.impulse;
}

/// Fibonacci Levels - مستويات فيبوناتشي
class FibonacciLevels {
  final double level0; // 0%
  final double level236; // 23.6%
  final double level382; // 38.2%
  final double level500; // 50%
  final double level618; // 61.8% (الذهبي)
  final double level786; // 78.6%
  final double level1000; // 100%

  FibonacciLevels({
    required this.level0,
    required this.level236,
    required this.level382,
    required this.level500,
    required this.level618,
    required this.level786,
    required this.level1000,
  });

  double? getNearestLevel(double price, double threshold) {
    final levels = [
      level0,
      level236,
      level382,
      level500,
      level618,
      level786,
      level1000,
    ];

    for (final level in levels) {
      if ((price - level).abs() <= threshold) {
        return level;
      }
    }
    return null;
  }
}

/// Wave Rules Validation - التحقق من قواعد الموجات
class WaveRulesValidation {
  final bool wave2DoesNotRetraceBeyondWave1;
  final bool wave3IsNotShortest;
  final bool wave4DoesNotOverlapWave1;
  final bool isValid;

  WaveRulesValidation({
    required this.wave2DoesNotRetraceBeyondWave1,
    required this.wave3IsNotShortest,
    required this.wave4DoesNotOverlapWave1,
  }) : isValid =
           wave2DoesNotRetraceBeyondWave1 &&
           wave3IsNotShortest &&
           wave4DoesNotOverlapWave1;
}

/// Elliott Wave Analysis Result - نتيجة تحليل Elliott
class ElliottAnalysisResult {
  final WaveCount? waveCount;
  final FibonacciLevels? fibonacciLevels;
  final WaveRulesValidation? validation;
  final String currentWaveDescription;
  final String nextExpectedMove;
  final double confidence;
  final String bias;

  ElliottAnalysisResult({
    this.waveCount,
    this.fibonacciLevels,
    this.validation,
    required this.currentWaveDescription,
    required this.nextExpectedMove,
    required this.confidence,
    required this.bias,
  });

  Map<String, dynamic> toJson() => {
    'hasWaveCount': waveCount != null,
    'currentWave': waveCount?.currentWave,
    'currentType': waveCount?.currentType.name,
    'isWaveComplete': waveCount?.isComplete,
    'hasFibonacci': fibonacciLevels != null,
    'goldenRatio': fibonacciLevels?.level618,
    'isValid': validation?.isValid ?? false,
    'currentWaveDescription': currentWaveDescription,
    'nextExpectedMove': nextExpectedMove,
    'confidence': confidence,
    'bias': bias,
  };
}
