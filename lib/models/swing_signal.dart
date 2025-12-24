/// 👑 Swing Signal Model
///
/// نموذج إشارة السوينج الكامل

import 'package:flutter/foundation.dart';
import '../services/engines/swing_engine_v2.dart';

@immutable
class SwingSignal {
  final String direction; // BUY, SELL, NO_TRADE
  final double? entryPrice;
  final double? stopLoss;
  final double? takeProfit;
  final int confidence; // 0-100
  final double? riskReward;
  final MacroTrend? macroTrend;
  final MarketStructure? marketStructure;
  final FibonacciLevels? fibonacci;
  final SupplyDemandZones? zones;
  final QuantumConvergence? qcf;
  final ReversalDetection? reversal;
  final DateTime timestamp;
  final String? reason; // سبب عدم التداول

  SwingSignal({
    required this.direction,
    this.entryPrice,
    this.stopLoss,
    this.takeProfit,
    required this.confidence,
    this.riskReward,
    this.macroTrend,
    this.marketStructure,
    this.fibonacci,
    this.zones,
    this.qcf,
    this.reversal,
    required this.timestamp,
    this.reason,
  });

  factory SwingSignal.noTrade({required String reason}) {
    return SwingSignal(
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
