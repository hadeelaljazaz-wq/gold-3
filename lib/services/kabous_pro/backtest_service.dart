/// KABOUS PRO - Backtest Service
/// ============================
/// Simplified backtesting - ported from backtest.py

import 'kabous_models.dart';
import '../../models/candle.dart';
import '../../core/utils/logger.dart';
import '../golden_nightmare/golden_nightmare_engine.dart';
import '../technical_indicators_service.dart';

class BacktestService {
  /// Run backtest on historical data
  static Future<BacktestResult> runBacktest({
    required List<Candle> candles,
    required double initialBalance,
    double riskPerTrade = 0.02,
    double commission = 0.0001,
  }) async {
    try {
      AppLogger.info('🧪 Running backtest on ${candles.length} candles...');

      double balance = initialBalance;
      final List<BacktestTrade> trades = [];
      final List<double> equityCurve = [initialBalance];
      final List<BacktestTrade> openTrades = [];

      // Iterate through candles
      for (int i = 50; i < candles.length; i++) {
        final currentCandle = candles[i];
        final historicalCandles = candles.sublist(0, i + 1);

        // Check open trades first
        _checkOpenTrades(openTrades, currentCandle, balance, trades, equityCurve, commission);

        // Get strategy signal
        final signalData = await _getStrategySignal(historicalCandles, currentCandle.close);

        if (signalData['signal'] == 'BUY' || signalData['signal'] == 'SELL') {
          // Open new trade
          _openTrade(
            openTrades: openTrades,
            candle: currentCandle,
            signal: signalData['signal'],
            entry: signalData['entry'],
            stopLoss: signalData['stop_loss'],
            takeProfit: signalData['take_profits'][0],
            confidence: signalData['confidence'],
            balance: balance,
            riskPerTrade: riskPerTrade,
            commission: commission,
          );
        }

        // Update equity curve
        balance = _calculateEquity(balance, openTrades);
        equityCurve.add(balance);
      }

      // Close remaining open trades
      if (openTrades.isNotEmpty) {
        final lastCandle = candles.last;
        for (final trade in List.from(openTrades)) {
          _closeTrade(
            trade,
            lastCandle.close,
            lastCandle.time,
            'FORCED_CLOSE',
            balance,
            trades,
            commission,
          );
        }
      }

      // Calculate results
      final result = _calculateResults(
        trades: trades,
        equityCurve: equityCurve,
        initialBalance: initialBalance,
      );

      AppLogger.success(
        '✅ Backtest completed: ${result.totalTrades} trades, Win Rate: ${result.winRate}%',
      );

      return result;
    } catch (e, stackTrace) {
      AppLogger.error('Backtest failed', e, stackTrace);
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> _getStrategySignal(
    List<Candle> candles,
    double currentPrice,
  ) async {
    final indicators = TechnicalIndicatorsService.calculateAll(candles);

    final result = await GoldenNightmareEngine.generate(
      currentPrice: currentPrice,
      candles: candles,
      rsi: indicators.rsi,
      macd: indicators.macd,
      macdSignal: indicators.macdSignal,
      ma20: indicators.ma20,
      ma50: indicators.ma50,
      ma100: indicators.ma100,
      ma200: indicators.ma200,
      atr: indicators.atr,
    );

    final scalpData = result['SCALP'];
    return {
      'signal': scalpData?['direction'] ?? 'NO_TRADE',
      'entry': scalpData?['entry'] ?? currentPrice,
      'stop_loss': scalpData?['stopLoss'] ?? currentPrice,
      'take_profits': [scalpData?['takeProfit'] ?? currentPrice],
      'confidence': scalpData?['confidence'] ?? 0.0,
    };
  }

  static void _openTrade({
    required List<BacktestTrade> openTrades,
    required Candle candle,
    required String signal,
    required double entry,
    required double stopLoss,
    required double takeProfit,
    required double confidence,
    required double balance,
    required double riskPerTrade,
    required double commission,
  }) {
    final riskAmount = balance * riskPerTrade;
    final riskPoints = (entry - stopLoss).abs();

    if (riskPoints == 0) return;

    final confidenceMultiplier = confidence / 100;
    final adjustedRisk = riskAmount * confidenceMultiplier;
    double lots = adjustedRisk / (riskPoints * 100);
    lots = lots.clamp(0.01, 1.0);

    final trade = BacktestTrade(
      entryTime: candle.time,
      signal: signal,
      entryPrice: entry,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
      lots: lots,
      status: 'OPEN',
      pnl: 0.0,
      pnlPercentage: 0.0,
    );

    openTrades.add(trade);

    // Deduct commission
    final commissionCost = entry * lots * commission * 100;
    balance -= commissionCost;
  }

  static void _checkOpenTrades(
    List<BacktestTrade> openTrades,
    Candle candle,
    double balance,
    List<BacktestTrade> trades,
    List<double> equityCurve,
    double commission,
  ) {
    for (final trade in List.from(openTrades)) {
      // Check Stop Loss
      if (trade.signal == 'BUY') {
        if (candle.low <= trade.stopLoss) {
          _closeTrade(trade, trade.stopLoss, candle.time, 'STOPPED', balance, trades, commission);
          openTrades.remove(trade);
          continue;
        }
        // Check Take Profit
        if (candle.high >= trade.takeProfit) {
          _closeTrade(trade, trade.takeProfit, candle.time, 'CLOSED', balance, trades, commission);
          openTrades.remove(trade);
          continue;
        }
      } else {
        // SELL
        if (candle.high >= trade.stopLoss) {
          _closeTrade(trade, trade.stopLoss, candle.time, 'STOPPED', balance, trades, commission);
          openTrades.remove(trade);
          continue;
        }
        if (candle.low <= trade.takeProfit) {
          _closeTrade(trade, trade.takeProfit, candle.time, 'CLOSED', balance, trades, commission);
          openTrades.remove(trade);
          continue;
        }
      }
    }
  }

  static void _closeTrade(
    BacktestTrade trade,
    double exitPrice,
    DateTime exitTime,
    String status,
    double balance,
    List<BacktestTrade> trades,
    double commission,
  ) {
    final pnlPoints = trade.signal == 'BUY'
        ? exitPrice - trade.entryPrice
        : trade.entryPrice - exitPrice;

    final pnl = pnlPoints * trade.lots * 100;
    final commissionCost = exitPrice * trade.lots * commission * 100;
    final finalPnl = pnl - commissionCost;

    final closedTrade = BacktestTrade(
      entryTime: trade.entryTime,
      exitTime: exitTime,
      signal: trade.signal,
      entryPrice: trade.entryPrice,
      exitPrice: exitPrice,
      stopLoss: trade.stopLoss,
      takeProfit: trade.takeProfit,
      lots: trade.lots,
      status: status,
      pnl: finalPnl,
      pnlPercentage: (pnlPoints / trade.entryPrice) * 100,
    );

    trades.add(closedTrade);
    balance += finalPnl;
  }

  static double _calculateEquity(double balance, List<BacktestTrade> openTrades) {
    return balance; // Simplified - not counting floating P&L
  }

  static BacktestResult _calculateResults({
    required List<BacktestTrade> trades,
    required List<double> equityCurve,
    required double initialBalance,
  }) {
    if (trades.isEmpty) {
      return BacktestResult(
        totalTrades: 0,
        winningTrades: 0,
        losingTrades: 0,
        winRate: 0.0,
        totalPnl: 0.0,
        totalPnlPercentage: 0.0,
        maxDrawdown: 0.0,
        sharpeRatio: 0.0,
        profitFactor: 0.0,
        avgWin: 0.0,
        avgLoss: 0.0,
        maxConsecutiveWins: 0,
        maxConsecutiveLosses: 0,
        trades: [],
        equityCurve: equityCurve,
      );
    }

    final winningTrades = trades.where((t) => t.pnl > 0).toList();
    final losingTrades = trades.where((t) => t.pnl < 0).toList();

    final winCount = winningTrades.length;
    final lossCount = losingTrades.length;
    final winRate = (winCount / trades.length * 100);

    final totalPnl = trades.fold<double>(0.0, (sum, t) => sum + t.pnl);
    final totalPnlPercentage = ((totalPnl / initialBalance) * 100);

    final avgWin = winCount > 0
        ? winningTrades.fold<double>(0.0, (sum, t) => sum + t.pnl) / winCount
        : 0.0;
    final avgLoss = lossCount > 0
        ? losingTrades.fold<double>(0.0, (sum, t) => sum + t.pnl.abs()) / lossCount
        : 0.0;

    final grossProfit = winningTrades.fold<double>(0.0, (sum, t) => sum + t.pnl);
    final grossLoss = losingTrades.fold<double>(0.0, (sum, t) => sum + t.pnl.abs());
    final profitFactor = grossLoss > 0 ? grossProfit / grossLoss : 0.0;

    final maxDrawdown = _calculateMaxDrawdown(equityCurve);
    final sharpeRatio = _calculateSharpeRatio(trades);

    final (maxWins, maxLosses) = _calculateConsecutive(trades);

    return BacktestResult(
      totalTrades: trades.length,
      winningTrades: winCount,
      losingTrades: lossCount,
      winRate: winRate,
      totalPnl: totalPnl,
      totalPnlPercentage: totalPnlPercentage,
      maxDrawdown: maxDrawdown,
      sharpeRatio: sharpeRatio,
      profitFactor: profitFactor,
      avgWin: avgWin,
      avgLoss: avgLoss,
      maxConsecutiveWins: maxWins,
      maxConsecutiveLosses: maxLosses,
      trades: trades,
      equityCurve: equityCurve,
    );
  }

  static double _calculateMaxDrawdown(List<double> equityCurve) {
    double peak = equityCurve.first;
    double maxDD = 0.0;

    for (final equity in equityCurve) {
      if (equity > peak) peak = equity;
      final dd = peak > 0 ? ((peak - equity) / peak) * 100 : 0.0;
      if (dd > maxDD) maxDD = dd;
    }

    return maxDD;
  }

  static double _calculateSharpeRatio(List<BacktestTrade> trades) {
    if (trades.length < 2) return 0.0;

    final returns = trades.map((t) => t.pnlPercentage).toList();
    final avgReturn = (returns.reduce((a, b) => a + b) / returns.length).toDouble();

    final varianceSum = returns.map((r) => (r - avgReturn) * (r - avgReturn)).reduce((a, b) => a + b);
    final variance = (varianceSum / returns.length).toDouble();
    final stdReturn = variance > 0 ? variance : 0.0;

    if (stdReturn == 0) return 0.0;

    // Simplified Sharpe
    return avgReturn / stdReturn;
  }

  static (int, int) _calculateConsecutive(List<BacktestTrade> trades) {
    int currentWins = 0;
    int currentLosses = 0;
    int maxWins = 0;
    int maxLosses = 0;

    for (final trade in trades) {
      if (trade.pnl > 0) {
        currentWins++;
        currentLosses = 0;
        if (currentWins > maxWins) maxWins = currentWins;
      } else {
        currentLosses++;
        currentWins = 0;
        if (currentLosses > maxLosses) maxLosses = currentLosses;
      }
    }

    return (maxWins, maxLosses);
  }
}

