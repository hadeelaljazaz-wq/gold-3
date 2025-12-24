/// NEXUS Quantum Signal Model
class NexusSignalModel {
  final String direction; // BUY, SELL, NO_TRADE
  final double entryPrice;
  final double? stopLoss;
  final double? takeProfit;
  final double confidence; // 0-100
  final double riskReward;
  final double nexusScore; // 0-10 (NEXUS Quantum Score)
  final DateTime timestamp;

  NexusSignalModel({
    required this.direction,
    required this.entryPrice,
    this.stopLoss,
    this.takeProfit,
    required this.confidence,
    required this.riskReward,
    required this.nexusScore,
    required this.timestamp,
  });

  bool get isValid => direction != 'NO_TRADE';
  bool get isBuy => direction == 'BUY';
  bool get isSell => direction == 'SELL';
}
