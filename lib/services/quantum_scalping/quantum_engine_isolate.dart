import 'package:flutter/foundation.dart';
import '../../models/candle.dart';
import 'quantum_scalping_engine.dart';

/// 🚀 Quantum Engine Isolate Wrapper
/// تشغيل المحرك في Isolate منفصل لتجنب حجب UI
class QuantumEngineIsolate {
  /// تشغيل التحليل في Isolate منفصل باستخدام compute
  static Future<QuantumSignal> analyzeInIsolate({
    required List<Candle> goldCandles,
    List<Candle>? dxyCandles,
    List<Candle>? bondsCandles,
  }) async {
    // استخدام compute لتشغيل في Isolate منفصل
    final params = _AnalysisParams(
      goldCandles: goldCandles,
      dxyCandles: dxyCandles,
      bondsCandles: bondsCandles,
    );

    return await compute(_runAnalysisInIsolate, params);
  }

  /// دالة ثابتة للتشغيل في Isolate (يجب أن تكون top-level أو static)
  static Future<QuantumSignal> _runAnalysisInIsolate(_AnalysisParams params) async {
    return await QuantumScalpingEngine.analyze(
      goldCandles: params.goldCandles,
      dxyCandles: params.dxyCandles,
      bondsCandles: params.bondsCandles,
    );
  }
}

/// معاملات التحليل (قابلة للإرسال عبر Isolate)
class _AnalysisParams {
  final List<Candle> goldCandles;
  final List<Candle>? dxyCandles;
  final List<Candle>? bondsCandles;

  _AnalysisParams({
    required this.goldCandles,
    this.dxyCandles,
    this.bondsCandles,
  });
}
