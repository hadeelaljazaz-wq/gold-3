/// TradeSignal - إشارة تداول
enum TradeSignal { buy, sell, none }

/// ExecutedTrade - صفقة منفذة في الـ Backtest
class ExecutedTrade {
  final double entryPrice;
  final double exitPrice;
  final double quantity;
  final DateTime entryTime;
  final DateTime exitTime;
  final double profitLoss;
  final double profitLossPercent;
  final String reason;

  ExecutedTrade({
    required this.entryPrice,
    required this.exitPrice,
    required this.quantity,
    required this.entryTime,
    required this.exitTime,
    required this.profitLoss,
    required this.profitLossPercent,
    required this.reason,
  });

  bool get isWinning => profitLoss > 0;
  bool get isLosing => profitLoss < 0;
}

/// OpenTrade - صفقة مفتوحة
class OpenTrade {
  final double entryPrice;
  final DateTime entryTime;
  final double quantity;
  final TradeSignal signal;
  final double stopLoss;
  final double takeProfit;

  OpenTrade({
    required this.entryPrice,
    required this.entryTime,
    required this.quantity,
    required this.signal,
    required this.stopLoss,
    required this.takeProfit,
  });
}

/// EquityPoint - نقطة في منحنى رأس المال
class EquityPoint {
  final DateTime timestamp;
  final double equity;
  final double balance;

  EquityPoint({
    required this.timestamp,
    required this.equity,
    required this.balance,
  });
}

/// BacktestResult - نتيجة Backtesting
class BacktestResult {
  final int totalTrades;
  final int winningTrades;
  final int losingTrades;
  final double winRate;
  final double totalProfit;
  final double profitFactor;
  final double sharpeRatio;
  final double maxDrawdown;
  final double roi;
  final List<EquityPoint> equityHistory;
  final List<ExecutedTrade>? trades;

  BacktestResult({
    required this.totalTrades,
    required this.winningTrades,
    required this.losingTrades,
    required this.winRate,
    required this.totalProfit,
    required this.profitFactor,
    required this.sharpeRatio,
    required this.maxDrawdown,
    required this.roi,
    required this.equityHistory,
    this.trades,
  });

  factory BacktestResult.empty() {
    return BacktestResult(
      totalTrades: 0,
      winningTrades: 0,
      losingTrades: 0,
      winRate: 0.0,
      totalProfit: 0.0,
      profitFactor: 0.0,
      sharpeRatio: 0.0,
      maxDrawdown: 0.0,
      roi: 0.0,
      equityHistory: [],
      trades: [],
    );
  }
}

/// BacktestMetrics - مقاييس الـ Backtest
class BacktestMetrics {
  final int totalTrades;
  final double winRate;
  final double profitFactor;
  final double totalReturn;
  final double maxDrawdown;
  final double sharpeRatio;
  final double avgWin;
  final double avgLoss;

  BacktestMetrics({
    required this.totalTrades,
    required this.winRate,
    required this.profitFactor,
    required this.totalReturn,
    required this.maxDrawdown,
    required this.sharpeRatio,
    required this.avgWin,
    required this.avgLoss,
  });
}

/// BacktestReport - تقرير Backtesting شامل
class BacktestReport {
  final DateTime startDate;
  final DateTime endDate;
  final double initialCapital;
  final double finalCapital;
  final int totalTrades;
  final int winningTrades;
  final int losingTrades;
  final List<ExecutedTrade> trades;
  final BacktestMetrics metrics;
  final DateTime timestamp;

  BacktestReport({
    required this.startDate,
    required this.endDate,
    required this.initialCapital,
    required this.finalCapital,
    required this.totalTrades,
    required this.winningTrades,
    required this.losingTrades,
    required this.trades,
    required this.metrics,
    required this.timestamp,
  });

  double get totalReturnPercent => ((finalCapital - initialCapital) / initialCapital) * 100;
}

