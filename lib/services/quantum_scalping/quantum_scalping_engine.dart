import '../../models/candle.dart';
import '../../models/trade_decision.dart';
import '../../core/utils/logger.dart';
import 'quantum_state_analyzer.dart';
import 'temporal_flux_detector.dart';
import 'smart_money_tracker.dart';
import 'chaos_volatility_engine.dart';
import 'bayesian_probability_matrix.dart';
import 'quantum_correlator.dart';
import '../central_bayesian_engine.dart';
import '../ml_decision_maker.dart';

/// 🚀 QUANTUM SCALPING ENGINE
/// المحرك الثوري المتعدد الأبعاد
class QuantumScalpingEngine {
  /// تحليل شامل وتوليد إشارة
  static Future<QuantumSignal> analyze({
    required List<Candle> goldCandles,
    List<Candle>? dxyCandles,
    List<Candle>? bondsCandles,
  }) async {
    final startTime = DateTime.now();
    AppLogger.info('🚀 Starting Quantum Scalping Analysis...');

    try {
      // PHASE 1: Quantum State Detection (0.1ms)
      final quantumState = QuantumStateAnalyzer.analyze(goldCandles);

      // PHASE 2: Temporal Flux Analysis (0.2ms)
      final temporalFlux = TemporalFluxDetector.detect(goldCandles);

      // PHASE 3: Smart Money Detection (0.3ms)
      final smartMoneyFlow = SmartMoneyTracker.track(goldCandles);

      // PHASE 4: Chaos Prediction (0.4ms)
      final chaosAnalysis = ChaosVolatilityEngine.analyze(goldCandles);

      // PHASE 5: Quantum Correlation (0.1ms)
      final quantumCorrelation = QuantumCorrelator.analyze(
        goldCandles,
        dxyCandles,
        bondsCandles,
      );

      // PHASE 6: Bayesian Probability Calculation (0.1ms)
      final bayesianProbability = BayesianProbabilityMatrix.calculate(
        quantumState: quantumState,
        temporalFlux: temporalFlux,
        smartMoneyFlow: smartMoneyFlow,
        chaosAnalysis: chaosAnalysis,
      );

      // PHASE 7: Signal Generation (0.1ms)
      final signal = _generateSignal(
        goldCandles: goldCandles,
        quantumState: quantumState,
        temporalFlux: temporalFlux,
        smartMoneyFlow: smartMoneyFlow,
        chaosAnalysis: chaosAnalysis,
        quantumCorrelation: quantumCorrelation,
        bayesianProbability: bayesianProbability,
      );

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      AppLogger.success(
        '✅ Quantum Analysis Complete in ${duration.inMilliseconds}ms',
      );

      return signal;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Quantum Analysis Failed', e, stackTrace);
      rethrow;
    }
  }

  /// توليد الإشارة النهائية
  static QuantumSignal _generateSignal({
    required List<Candle> goldCandles,
    required QuantumState quantumState,
    required TemporalFlux temporalFlux,
    required SmartMoneyFlow smartMoneyFlow,
    required ChaosAnalysis chaosAnalysis,
    required QuantumCorrelation quantumCorrelation,
    required BayesianProbability bayesianProbability,
  }) {
    // 1. تحديد الاتجاه
    final direction = _determineDirection(
      quantumState,
      temporalFlux,
      smartMoneyFlow,
      quantumCorrelation,
    );

    // 2. حساب Quantum Score (0-10)
    final quantumScore = _calculateQuantumScore(
      quantumState,
      temporalFlux,
      smartMoneyFlow,
      chaosAnalysis,
      quantumCorrelation,
      bayesianProbability,
    );

    // 3. حساب نقاط الدخول والخروج
    final currentPrice = goldCandles.last.close;
    final entry = currentPrice;
    final stopLoss = _calculateStopLoss(
      currentPrice,
      direction,
      chaosAnalysis.volatility,
    );
    final takeProfit = _calculateTakeProfit(
      currentPrice,
      direction,
      bayesianProbability.riskRewardRatio,
      stopLoss,
    );

    // 4. تحديد حجم الصفقة
    final positionSize = bayesianProbability.optimalPositionSize;

    // 5. جمع الأسباب
    final reasoning = _generateReasoning(
      quantumState,
      temporalFlux,
      smartMoneyFlow,
      chaosAnalysis,
      quantumCorrelation,
    );

    // 6. جمع التنبيهات
    final alerts = _generateAlerts(
      smartMoneyFlow,
      chaosAnalysis,
      quantumCorrelation,
    );

    // 7. حساب الأبعاد السبعة
    final dimensions = _calculateDimensions(
      quantumState,
      temporalFlux,
      smartMoneyFlow,
      chaosAnalysis,
      quantumCorrelation,
      bayesianProbability,
    );

    return QuantumSignal(
      direction: direction,
      entry: entry,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
      confidence: bayesianProbability.posteriorProbability,
      quantumScore: quantumScore,
      positionSize: positionSize,
      riskRewardRatio: bayesianProbability.riskRewardRatio,
      expectedReturn: bayesianProbability.expectedReturn,
      dimensions: dimensions,
      reasoning: reasoning,
      alerts: alerts,
      tradeQuality: bayesianProbability.tradeQuality,
      timestamp: DateTime.now(),
    );
  }

  /// تحديد الاتجاه
  static SignalDirection _determineDirection(
    QuantumState quantumState,
    TemporalFlux temporalFlux,
    SmartMoneyFlow smartMoneyFlow,
    QuantumCorrelation quantumCorrelation,
  ) {
    int buySignals = 0;
    int sellSignals = 0;

    // Quantum State
    if (quantumState.dominantState == MarketState.bullish) {
      buySignals++;
    } else if (quantumState.dominantState == MarketState.bearish) {
      sellSignals++;
    }

    // Temporal Flux
    if (temporalFlux.fluxDirection == FluxDirection.upward) {
      buySignals++;
    } else if (temporalFlux.fluxDirection == FluxDirection.downward) {
      sellSignals++;
    }

    // Smart Money
    if (smartMoneyFlow.smartMoneyDirection == SmartMoneyDirection.buying) {
      buySignals++;
    } else if (smartMoneyFlow.smartMoneyDirection ==
        SmartMoneyDirection.selling) {
      sellSignals++;
    }

    // Quantum Correlation
    if (quantumCorrelation.supportsBullish) {
      buySignals++;
    } else if (quantumCorrelation.supportsBearish) {
      sellSignals++;
    }

    if (buySignals > sellSignals) {
      return SignalDirection.buy;
    } else if (sellSignals > buySignals) {
      return SignalDirection.sell;
    } else {
      return SignalDirection.neutral;
    }
  }

  /// حساب Quantum Score (0-10)
  static double _calculateQuantumScore(
    QuantumState quantumState,
    TemporalFlux temporalFlux,
    SmartMoneyFlow smartMoneyFlow,
    ChaosAnalysis chaosAnalysis,
    QuantumCorrelation quantumCorrelation,
    BayesianProbability bayesianProbability,
  ) {
    double score = 0.0;

    // 1. Quantum State (0-1.5)
    score += quantumState.confidence * 1.5;

    // 2. Temporal Flux (0-1.5)
    score += temporalFlux.fluxStrength * 1.5;

    // 3. Smart Money (0-1.5)
    score += smartMoneyFlow.smartMoneyStrength * 1.5;

    // 4. Chaos (0-1.5) - عكسي (كلما قل الخطر، زاد الـ score)
    score += (1 - chaosAnalysis.riskLevel) * 1.5;

    // 5. Correlation (0-1.5)
    score += quantumCorrelation.correlationStrength * 1.5;

    // 6. Probability (0-2.5)
    score += bayesianProbability.posteriorProbability * 2.5;

    return score;
  }

  /// حساب Stop Loss
  static double _calculateStopLoss(
    double currentPrice,
    SignalDirection direction,
    double volatility,
  ) {
    // Stop Loss = 0.3-0.8% من السعر بناءً على التقلب
    final slPercentage = 0.003 + (volatility * 0.005); // 0.3% - 0.8%
    final slDistance = currentPrice * slPercentage;

    if (direction == SignalDirection.buy) {
      return currentPrice - slDistance;
    } else {
      return currentPrice + slDistance;
    }
  }

  /// حساب Take Profit
  static double _calculateTakeProfit(
    double currentPrice,
    SignalDirection direction,
    double riskRewardRatio,
    double stopLoss,
  ) {
    final slDistance = (currentPrice - stopLoss).abs();
    final tpDistance = slDistance * riskRewardRatio;

    if (direction == SignalDirection.buy) {
      return currentPrice + tpDistance;
    } else {
      return currentPrice - tpDistance;
    }
  }

  /// توليد الأسباب
  static String _generateReasoning(
    QuantumState quantumState,
    TemporalFlux temporalFlux,
    SmartMoneyFlow smartMoneyFlow,
    ChaosAnalysis chaosAnalysis,
    QuantumCorrelation quantumCorrelation,
  ) {
    final reasons = <String>[];

    // Quantum State
    if (quantumState.isStrong) {
      reasons.add('Strong ${quantumState.dominantState.name} quantum state');
    }

    // Temporal Flux
    if (temporalFlux.hasBreakoutPotential) {
      reasons.add('High breakout potential detected');
    }

    // Smart Money
    if (smartMoneyFlow.hasWhales) {
      reasons.add(
          'Whale activity: ${smartMoneyFlow.whaleActivity.totalWhales} detected');
    }

    // Chaos
    if (!chaosAnalysis.isChaotic) {
      reasons.add('Market is stable (low chaos)');
    }

    // Correlation
    if (quantumCorrelation.isEntangled) {
      reasons.add('Quantum entanglement detected');
    }

    return reasons.join(' + ');
  }

  /// توليد التنبيهات
  static List<String> _generateAlerts(
    SmartMoneyFlow smartMoneyFlow,
    ChaosAnalysis chaosAnalysis,
    QuantumCorrelation quantumCorrelation,
  ) {
    final alerts = <String>[];

    // Smart Money Alerts
    if (smartMoneyFlow.hasWhales) {
      alerts.add(
          '🐋 ${smartMoneyFlow.whaleActivity.totalWhales} whales detected');
    }

    // Chaos Alerts
    if (chaosAnalysis.isHighRisk) {
      alerts.add(
          '⚠️ High risk level: ${(chaosAnalysis.riskLevel * 100).toStringAsFixed(0)}%');
    }

    // Correlation Alerts
    if (quantumCorrelation.isEntangled) {
      alerts.add('🔗 Quantum entanglement active');
    }

    return alerts;
  }

  /// حساب الأبعاد السبعة
  static Map<String, double> _calculateDimensions(
    QuantumState quantumState,
    TemporalFlux temporalFlux,
    SmartMoneyFlow smartMoneyFlow,
    ChaosAnalysis chaosAnalysis,
    QuantumCorrelation quantumCorrelation,
    BayesianProbability bayesianProbability,
  ) {
    return {
      'temporal': temporalFlux.fluxStrength,
      'momentum': temporalFlux.momentum.abs() / 20, // Normalize
      'volume': smartMoneyFlow.smartMoneyStrength,
      'volatility': chaosAnalysis.volatility,
      'sentiment': quantumState.confidence,
      'probability': bayesianProbability.posteriorProbability,
      'correlation': quantumCorrelation.correlationStrength,
    };
  }

  // ══════════════════════════════════════════════════════════════════
  // 🆕 ENHANCED ANALYSIS WITH CENTRALIZED SYSTEMS
  // ══════════════════════════════════════════════════════════════════

  /// تحليل محسّن مع استخدام Central Bayesian + ML Decision
  /// 
  /// يستخدم النظام الأصلي لكن يضيف ML Decision للحصول على EXECUTE/WAIT/ABORT
  static Future<Map<String, dynamic>> analyzeEnhanced({
    required List<Candle> goldCandles,
    List<Candle>? dxyCandles,
    List<Candle>? bondsCandles,
    double accountBalance = 10000.0,
  }) async {
    // التحليل الأصلي
    final originalSignal = await analyze(
      goldCandles: goldCandles,
      dxyCandles: dxyCandles,
      bondsCandles: bondsCandles,
    );

    // استخدام Central Bayesian بدلاً من الـ local one
    final signalDirection = originalSignal.direction == SignalDirection.buy 
        ? 'BUY' 
        : originalSignal.direction == SignalDirection.sell 
        ? 'SELL' 
        : null;

    // حساب العوامل من Quantum Signal
    final trendStrength = originalSignal.dimensions['momentum']! * 2 - 1; // -1 to 1
    final momentum = originalSignal.dimensions['momentum']! * 2 - 1;
    final volatility = originalSignal.dimensions['volatility']!;
    final volumeProfile = originalSignal.dimensions['volume']!;

    // استخدام Central Bayesian
    final centralBayesian = CentralBayesianEngine.analyze(
      signalStrength: originalSignal.confidence,
      trendStrength: trendStrength,
      momentum: momentum,
      volatility: volatility,
      volumeProfile: volumeProfile,
      timeframeAlignment: originalSignal.dimensions['correlation']!,
      structureQuality: originalSignal.dimensions['temporal']!,
      chaosRiskLevel: originalSignal.dimensions['volatility']! * 1.2, // adjusted
      signalDirection: signalDirection,
    );

    // حساب Position Size من Bayesian
    final calculatedPositionSize = centralBayesian.posteriorProbability * 
        (1 - originalSignal.dimensions['volatility']! * 1.2) * 0.10;

    // Decision Factors
    final factors = DecisionFactors(
      trendStrength: trendStrength,
      volatility: volatility,
      momentum: momentum,
      chaosLevel: originalSignal.dimensions['volatility']! * 1.2,
      signalStrength: originalSignal.confidence,
      timeframeAlignment: originalSignal.dimensions['correlation']!,
      volumeProfile: volumeProfile,
      structureQuality: originalSignal.dimensions['temporal']!,
    );

    // ML Decision
    final mlDecision = MLDecisionMaker.makeDecision(
      bayesianAnalysis: centralBayesian,
      chaosRiskLevel: originalSignal.dimensions['volatility']! * 1.2,
      signalStrength: originalSignal.confidence,
      signalConfidence: originalSignal.confidence,
      volatility: volatility,
      factors: factors,
      accountBalance: accountBalance,
      signalDirection: signalDirection,
    );

    // Build enhanced result
    return {
      'original_signal': originalSignal.toJson(),
      'bayesian': centralBayesian.toJson(),
      'decision': mlDecision.toJson(),
      'action': mlDecision.action.name,
      'action_icon': mlDecision.action.icon,
      'action_description': mlDecision.action.description,
      'position_size_percent': calculatedPositionSize.clamp(0.005, 0.10),
      'position_size_dollars': calculatedPositionSize * accountBalance,
      'position_size_lots': (calculatedPositionSize * accountBalance) / 1000.0,
      'chaos_risk_level': originalSignal.dimensions['volatility']! * 1.2,
      'quality_score': mlDecision.qualityScore,
    };
  }
}

/// 🚀 Quantum Signal Model
class QuantumSignal {
  final SignalDirection direction;
  final double entry;
  final double stopLoss;
  final double takeProfit;
  final double confidence; // 0-1
  final double quantumScore; // 0-10
  final double positionSize; // 0-0.25
  final double riskRewardRatio; // 1-5
  final double expectedReturn; // pips
  final Map<String, double> dimensions; // 7 dimensions
  final String reasoning;
  final List<String> alerts;
  final TradeQuality tradeQuality;
  final DateTime timestamp;

  QuantumSignal({
    required this.direction,
    required this.entry,
    required this.stopLoss,
    required this.takeProfit,
    required this.confidence,
    required this.quantumScore,
    required this.positionSize,
    required this.riskRewardRatio,
    required this.expectedReturn,
    required this.dimensions,
    required this.reasoning,
    required this.alerts,
    required this.tradeQuality,
    required this.timestamp,
  });

  /// هل الإشارة قوية؟
  bool get isStrong => quantumScore >= 8.0;

  /// هل الإشارة جيدة؟
  bool get isGood => quantumScore >= 6.5;

  /// هل يجب التداول؟
  bool get shouldTrade =>
      direction != SignalDirection.neutral &&
      quantumScore >= 6.0 &&
      tradeQuality != TradeQuality.poor;

  @override
  String toString() {
    return 'QuantumSignal('
        'direction: ${direction.name}, '
        'entry: ${entry.toStringAsFixed(2)}, '
        'SL: ${stopLoss.toStringAsFixed(2)}, '
        'TP: ${takeProfit.toStringAsFixed(2)}, '
        'confidence: ${(confidence * 100).toStringAsFixed(1)}%, '
        'score: ${quantumScore.toStringAsFixed(1)}/10, '
        'R/R: 1:${riskRewardRatio.toStringAsFixed(2)}, '
        'quality: ${tradeQuality.name}'
        ')';
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'direction': direction.name,
      'entry': entry,
      'stopLoss': stopLoss,
      'takeProfit': takeProfit,
      'confidence': confidence,
      'quantumScore': quantumScore,
      'positionSize': positionSize,
      'riskRewardRatio': riskRewardRatio,
      'expectedReturn': expectedReturn,
      'dimensions': dimensions,
      'reasoning': reasoning,
      'alerts': alerts,
      'tradeQuality': tradeQuality.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// اتجاه الإشارة
enum SignalDirection {
  buy,
  sell,
  neutral,
}
