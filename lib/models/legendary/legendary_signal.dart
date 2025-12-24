/// 👑 Legendary Signal Model
///
/// موديل الإشارة الأسطورية الموحد
library;

enum SignalDirection { buy, sell, wait }

class LegendarySignal {
  final SignalDirection direction;
  final double entryPrice;
  final double stopLoss;
  final double takeProfit1;
  final double takeProfit2;
  final double confidence;
  final String reasoning;
  final List<String> confirmations;
  final double confluenceScore;
  final DateTime timestamp;

  LegendarySignal({
    required this.direction,
    required this.entryPrice,
    required this.stopLoss,
    required this.takeProfit1,
    required this.takeProfit2,
    required this.confidence,
    required this.reasoning,
    required this.confirmations,
    required this.confluenceScore,
    required this.timestamp,
  });

  // Risk Management Calculations
  double get riskReward1 =>
      (takeProfit1 - entryPrice).abs() / (entryPrice - stopLoss).abs();
  double get riskReward2 =>
      (takeProfit2 - entryPrice).abs() / (entryPrice - stopLoss).abs();
  double get riskAmount => (entryPrice - stopLoss).abs();
  double get potentialProfit1 => (takeProfit1 - entryPrice).abs();
  double get potentialProfit2 => (takeProfit2 - entryPrice).abs();

  bool get isBuy => direction == SignalDirection.buy;
  bool get isSell => direction == SignalDirection.sell;
  bool get isWait => direction == SignalDirection.wait;

  String get directionText {
    switch (direction) {
      case SignalDirection.buy:
        return 'شراء';
      case SignalDirection.sell:
        return 'بيع';
      case SignalDirection.wait:
        return 'انتظار';
    }
  }

  Map<String, dynamic> toJson() => {
    'direction': direction.name,
    'entryPrice': entryPrice,
    'stopLoss': stopLoss,
    'takeProfit1': takeProfit1,
    'takeProfit2': takeProfit2,
    'confidence': confidence,
    'reasoning': reasoning,
    'confirmations': confirmations,
    'confluenceScore': confluenceScore,
    'timestamp': timestamp.toIso8601String(),
    'riskReward1': riskReward1,
    'riskReward2': riskReward2,
  };

  factory LegendarySignal.fromJson(Map<String, dynamic> json) {
    return LegendarySignal(
      direction: SignalDirection.values.byName(json['direction']),
      entryPrice: json['entryPrice'],
      stopLoss: json['stopLoss'],
      takeProfit1: json['takeProfit1'],
      takeProfit2: json['takeProfit2'],
      confidence: json['confidence'],
      reasoning: json['reasoning'],
      confirmations: List<String>.from(json['confirmations']),
      confluenceScore: json['confluenceScore'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  factory LegendarySignal.noTrade({required String reason}) {
    return LegendarySignal(
      direction: SignalDirection.wait,
      entryPrice: 0,
      stopLoss: 0,
      takeProfit1: 0,
      takeProfit2: 0,
      confidence: 0,
      reasoning: reason,
      confirmations: [],
      confluenceScore: 0,
      timestamp: DateTime.now(),
    );
  }

  LegendarySignal copyWith({
    SignalDirection? direction,
    double? entryPrice,
    double? stopLoss,
    double? takeProfit1,
    double? takeProfit2,
    double? confidence,
    String? reasoning,
    List<String>? confirmations,
    double? confluenceScore,
    DateTime? timestamp,
  }) {
    return LegendarySignal(
      direction: direction ?? this.direction,
      entryPrice: entryPrice ?? this.entryPrice,
      stopLoss: stopLoss ?? this.stopLoss,
      takeProfit1: takeProfit1 ?? this.takeProfit1,
      takeProfit2: takeProfit2 ?? this.takeProfit2,
      confidence: confidence ?? this.confidence,
      reasoning: reasoning ?? this.reasoning,
      confirmations: confirmations ?? this.confirmations,
      confluenceScore: confluenceScore ?? this.confluenceScore,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// نتيجة التحليل الأسطوري الكاملة
class LegendaryAnalysisResult {
  final LegendarySignal scalpSignal;
  final LegendarySignal swingSignal;
  final List<double> supportLevels;
  final List<double> resistanceLevels;
  final double confluenceScore;
  final String marketStructure;
  final Map<String, dynamic> strategies;
  final DateTime timestamp;

  LegendaryAnalysisResult({
    required this.scalpSignal,
    required this.swingSignal,
    required this.supportLevels,
    required this.resistanceLevels,
    required this.confluenceScore,
    required this.marketStructure,
    required this.strategies,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'scalpSignal': scalpSignal.toJson(),
    'swingSignal': swingSignal.toJson(),
    'supportLevels': supportLevels,
    'resistanceLevels': resistanceLevels,
    'confluenceScore': confluenceScore,
    'marketStructure': marketStructure,
    'strategies': strategies,
    'timestamp': timestamp.toIso8601String(),
  };
}
