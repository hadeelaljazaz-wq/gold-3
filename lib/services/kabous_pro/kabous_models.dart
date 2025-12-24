/// KABOUS PRO - Models
/// ============================
/// Models ported from Python KABOUS PRO system

import '../../core/utils/type_converter.dart';

/// Backtest Trade Model
class BacktestTrade {
  final DateTime entryTime;
  final DateTime? exitTime;
  final String signal; // BUY, SELL
  final double entryPrice;
  final double? exitPrice;
  final double stopLoss;
  final double takeProfit;
  final double lots;
  final String status; // OPEN, CLOSED, STOPPED
  final double pnl;
  final double pnlPercentage;

  BacktestTrade({
    required this.entryTime,
    this.exitTime,
    required this.signal,
    required this.entryPrice,
    this.exitPrice,
    required this.stopLoss,
    required this.takeProfit,
    required this.lots,
    required this.status,
    required this.pnl,
    required this.pnlPercentage,
  });

  factory BacktestTrade.fromJson(Map<String, dynamic> json) {
    return BacktestTrade(
      entryTime: DateTime.parse(json['entry_time']),
      exitTime: json['exit_time'] != null ? DateTime.parse(json['exit_time']) : null,
      signal: json['signal'],
      entryPrice: TypeConverter.safeToDouble(json['entry_price']) ?? 0.0,
      exitPrice: TypeConverter.safeToDouble(json['exit_price']),
      stopLoss: TypeConverter.safeToDouble(json['stop_loss']) ?? 0.0,
      takeProfit: TypeConverter.safeToDouble(json['take_profit']) ?? 0.0,
      lots: TypeConverter.safeToDouble(json['lots']) ?? 0.01,
      status: json['status'],
      pnl: TypeConverter.safeToDouble(json['pnl']) ?? 0.0,
      pnlPercentage: TypeConverter.safeToDouble(json['pnl_percentage']) ?? 0.0,
    );
  }
}

/// Backtest Result Model
class BacktestResult {
  final int totalTrades;
  final int winningTrades;
  final int losingTrades;
  final double winRate;
  final double totalPnl;
  final double totalPnlPercentage;
  final double maxDrawdown;
  final double sharpeRatio;
  final double profitFactor;
  final double avgWin;
  final double avgLoss;
  final int maxConsecutiveWins;
  final int maxConsecutiveLosses;
  final List<BacktestTrade> trades;
  final List<double> equityCurve;

  BacktestResult({
    required this.totalTrades,
    required this.winningTrades,
    required this.losingTrades,
    required this.winRate,
    required this.totalPnl,
    required this.totalPnlPercentage,
    required this.maxDrawdown,
    required this.sharpeRatio,
    required this.profitFactor,
    required this.avgWin,
    required this.avgLoss,
    required this.maxConsecutiveWins,
    required this.maxConsecutiveLosses,
    required this.trades,
    required this.equityCurve,
  });

  factory BacktestResult.fromJson(Map<String, dynamic> json) {
    return BacktestResult(
      totalTrades: json['total_trades'],
      winningTrades: json['winning_trades'],
      losingTrades: json['losing_trades'],
      winRate: TypeConverter.safeToDouble(json['win_rate']) ?? 0.0,
      totalPnl: TypeConverter.safeToDouble(json['total_pnl']) ?? 0.0,
      totalPnlPercentage: TypeConverter.safeToDouble(json['total_pnl_percentage']) ?? 0.0,
      maxDrawdown: TypeConverter.safeToDouble(json['max_drawdown']) ?? 0.0,
      sharpeRatio: TypeConverter.safeToDouble(json['sharpe_ratio']) ?? 0.0,
      profitFactor: TypeConverter.safeToDouble(json['profit_factor']) ?? 1.0,
      avgWin: TypeConverter.safeToDouble(json['avg_win']) ?? 0.0,
      avgLoss: TypeConverter.safeToDouble(json['avg_loss']) ?? 0.0,
      maxConsecutiveWins: json['max_consecutive_wins'],
      maxConsecutiveLosses: json['max_consecutive_losses'],
      trades: (json['trades'] as List).map((t) => BacktestTrade.fromJson(t)).toList(),
      equityCurve: TypeConverter.safeToListOfDoubles(json['equity_curve'] as List? ?? []),
    );
  }
}

/// Timeframe Analysis Model
class TimeframeAnalysis {
  final String timeframe;
  final String signal;
  final double confidence;
  final String trend;
  final double strength;

  TimeframeAnalysis({
    required this.timeframe,
    required this.signal,
    required this.confidence,
    required this.trend,
    required this.strength,
  });

  factory TimeframeAnalysis.fromJson(Map<String, dynamic> json) {
    return TimeframeAnalysis(
      timeframe: json['timeframe'],
      signal: json['signal'],
      confidence: TypeConverter.safeToDouble(json['confidence']) ?? 0.0,
      trend: json['trend'],
      strength: TypeConverter.safeToDouble(json['strength']) ?? 0.0,
    );
  }
}

/// Multi-Timeframe Analysis Result
class MultiTimeframeResult {
  final String overallSignal;
  final double overallConfidence;
  final Map<String, TimeframeAnalysis> timeframes;
  final double alignmentScore;
  final String recommendation;

  MultiTimeframeResult({
    required this.overallSignal,
    required this.overallConfidence,
    required this.timeframes,
    required this.alignmentScore,
    required this.recommendation,
  });

  factory MultiTimeframeResult.fromJson(Map<String, dynamic> json) {
    final timeframesMap = <String, TimeframeAnalysis>{};
    (json['timeframes'] as Map<String, dynamic>).forEach((key, value) {
      timeframesMap[key] = TimeframeAnalysis.fromJson(value);
    });

    return MultiTimeframeResult(
      overallSignal: json['overall_signal'],
      overallConfidence: TypeConverter.safeToDouble(json['overall_confidence']) ?? 0.0,
      timeframes: timeframesMap,
      alignmentScore: TypeConverter.safeToDouble(json['alignment_score']) ?? 0.0,
      recommendation: json['recommendation'],
    );
  }
}

/// KABOUS Analysis Result (Full)
class KabousAnalysisResult {
  final String signal;
  final double confidence;
  final double confluenceScore;
  final double entry;
  final double stopLoss;
  final List<double> takeProfits;
  final double riskReward;
  final Map<String, dynamic> positionSize;
  final Map<String, dynamic> indicators;
  final List<String> confirmations;
  final List<String> warnings;
  final String? claudeAnalysis;
  final DateTime timestamp;

  KabousAnalysisResult({
    required this.signal,
    required this.confidence,
    required this.confluenceScore,
    required this.entry,
    required this.stopLoss,
    required this.takeProfits,
    required this.riskReward,
    required this.positionSize,
    required this.indicators,
    required this.confirmations,
    required this.warnings,
    this.claudeAnalysis,
    required this.timestamp,
  });

  factory KabousAnalysisResult.fromJson(Map<String, dynamic> json) {
    return KabousAnalysisResult(
      signal: json['signal'],
      confidence: (json['confidence'] as num).toDouble(),
      confluenceScore: (json['confluence_score'] as num).toDouble(),
      entry: (json['entry'] as num).toDouble(),
      stopLoss: (json['stop_loss'] as num).toDouble(),
      takeProfits: (json['take_profits'] as List).map((e) => (e as num).toDouble()).toList(),
      riskReward: (json['risk_reward'] as num).toDouble(),
      positionSize: json['position_size'] as Map<String, dynamic>,
      indicators: json['indicators'] as Map<String, dynamic>,
      confirmations: List<String>.from(json['confirmations']),
      warnings: List<String>.from(json['warnings']),
      claudeAnalysis: json['claude_analysis'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

