/// TradeAction - إجراء التداول
enum TradeAction {
  strongBuy,
  buy,
  hold,
  sell,
  strongSell,
}

/// TradingRecommendation - توصية تداول مع Risk/Reward
class TradingRecommendation {
  final TradeAction action;
  final double confidence;
  final double entryPrice;
  final double targetPrice;
  final double stopLoss;
  final String timeframe;
  final String reason;
  final double riskRewardRatio;

  TradingRecommendation({
    required this.action,
    required this.confidence,
    required this.entryPrice,
    required this.targetPrice,
    required this.stopLoss,
    required this.timeframe,
    required this.reason,
    required this.riskRewardRatio,
  });

  /// نص الإجراء
  String get actionText {
    switch (action) {
      case TradeAction.strongBuy:
        return 'شراء قوي 🚀';
      case TradeAction.buy:
        return 'شراء 📈';
      case TradeAction.hold:
        return 'انتظار ⏸️';
      case TradeAction.sell:
        return 'بيع 📉';
      case TradeAction.strongSell:
        return 'بيع قوي ⚠️';
    }
  }

  /// حساب الربح المحتمل
  double get potentialProfit => (targetPrice - entryPrice).abs();

  /// حساب الخسارة المحتملة
  double get potentialLoss => (entryPrice - stopLoss).abs();
}

/// EntryType - نوع نقطة الدخول
enum EntryType { buy, sell }

/// EntryPoint - نقطة دخول محتملة
class EntryPoint {
  final DateTime timestamp;
  final double price;
  final EntryType type;
  final String reason;
  final double confidence;

  EntryPoint({
    required this.timestamp,
    required this.price,
    required this.type,
    required this.reason,
    required this.confidence,
  });
}

/// ExitType - نوع نقطة الخروج
enum ExitType { takeProfit, stopLoss, trailing }

/// ExitPoint - نقطة خروج محتملة
class ExitPoint {
  final DateTime timestamp;
  final double price;
  final ExitType type;
  final String reason;
  final double confidence;

  ExitPoint({
    required this.timestamp,
    required this.price,
    required this.type,
    required this.reason,
    required this.confidence,
  });
}

