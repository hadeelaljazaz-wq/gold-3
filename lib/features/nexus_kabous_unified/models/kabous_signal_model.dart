/// KABOUS Elite Signal Model
class KabousSignalModel {
  final String direction; // BUY, SELL, NO_TRADE
  final double entryPrice;
  final double? stopLoss;
  final double? takeProfit;
  final double confidence; // 0-100
  final double riskReward;
  final double mlScore; // 0-100 (ML Prediction Score)
  final String regime; // Market Regime (HMM detected)
  final DateTime timestamp;

  KabousSignalModel({
    required this.direction,
    required this.entryPrice,
    this.stopLoss,
    this.takeProfit,
    required this.confidence,
    required this.riskReward,
    required this.mlScore,
    required this.regime,
    required this.timestamp,
  });

  bool get isValid => direction != 'NO_TRADE';
  bool get isBuy => direction == 'BUY';
  bool get isSell => direction == 'SELL';
}
