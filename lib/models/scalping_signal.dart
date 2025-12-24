/// 👑 Scalping Signal Model
///
/// نموذج إشارة السكالبينج الكامل

import 'package:flutter/foundation.dart';
import '../services/engines/scalping_engine_v2.dart';

@immutable
class ScalpingSignal {
  final String direction; // BUY, SELL, NO_TRADE
  final double? entryPrice;
  final double? stopLoss;
  final double? takeProfit;
  final int confidence; // 0-100
  final double? riskReward;
  final MicroTrend? microTrend;
  final MomentumAnalysis? momentum;
  final MicroVolatility? volatility;
  final RsiSignalZone? rsiZone;
  final DateTime timestamp;
  final String? reason; // سبب عدم التداول

  ScalpingSignal({
    required this.direction,
    this.entryPrice,
    this.stopLoss,
    this.takeProfit,
    required this.confidence,
    this.riskReward,
    this.microTrend,
    this.momentum,
    this.volatility,
    this.rsiZone,
    required this.timestamp,
    this.reason,
  });

  factory ScalpingSignal.noTrade({required String reason}) {
    return ScalpingSignal(
      direction: 'NO_TRADE',
      confidence: 0,
      timestamp: DateTime.now(),
      reason: reason,
    );
  }

  bool get isValid => direction != 'NO_TRADE';
  bool get isBuy => direction == 'BUY';
  bool get isSell => direction == 'SELL';

  Map<String, dynamic> toJson() {
    return {
      'direction': direction,
      'entryPrice': entryPrice,
      'stopLoss': stopLoss,
      'takeProfit': takeProfit,
      'confidence': confidence,
      'riskReward': riskReward,
      'timestamp': timestamp.toIso8601String(),
      'reason': reason,
    };
  }
}
