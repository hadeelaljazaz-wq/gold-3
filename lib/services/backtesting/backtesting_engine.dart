import 'dart:math';
import '../../models/advanced/candle_data.dart';
import '../../models/advanced/backtesting_models.dart';

/// BacktestingEngine - محرك محاكاة التداول
class BacktestingEngine {
  static final BacktestingEngine _instance = BacktestingEngine._internal();

  BacktestingEngine._internal();

  factory BacktestingEngine() => _instance;

  /// تشغيل backtest على بيانات تاريخية
  Future<BacktestResult> runBacktest({
    required List<CandleData> historicalData,
    required TradingStrategy strategy,
    required double initialBalance,
    required double riskPerTrade,
  }) async {
    try {
      final trades = <ExecutedTrade>[];
      var currentBalance = initialBalance;
      var equity = initialBalance;
      var maxDrawdown = 0.0;
      OpenTrade? openTrade;

      final equityHistory = <EquityPoint>[
        EquityPoint(
          timestamp: historicalData.first.timestamp,
          equity: equity,
          balance: currentBalance,
        ),
      ];

      for (int i = 0; i < historicalData.length - 1; i++) {
        final candle = historicalData[i];
        final nextCandle = historicalData[i + 1];

        // احصل على إشارات الاستراتيجية
        final signal = strategy.generateSignal(historicalData, i);

        // معالجة الإشارات
        if (signal != TradeSignal.none && openTrade == null) {
          // فتح صفقة جديدة
          final riskAmount = currentBalance * riskPerTrade;

          openTrade = OpenTrade(
            entryPrice: nextCandle.open,
            entryTime: nextCandle.timestamp,
            quantity: riskAmount / nextCandle.open,
            signal: signal,
            stopLoss: signal == TradeSignal.buy
                ? nextCandle.open * 0.98
                : nextCandle.open * 1.02,
            takeProfit: signal == TradeSignal.buy
                ? nextCandle.open * 1.03
                : nextCandle.open * 0.97,
          );
        }

        // إدارة الصفقة المفتوحة
        if (openTrade != null) {
          final currentPrice = candle.high;

          // فحص Stop Loss
          if (openTrade.signal == TradeSignal.buy &&
              currentPrice <= openTrade.stopLoss) {
            final profitLoss =
                (openTrade.stopLoss - openTrade.entryPrice) * openTrade.quantity;
            final trade = ExecutedTrade(
              entryPrice: openTrade.entryPrice,
              exitPrice: openTrade.stopLoss,
              quantity: openTrade.quantity,
              entryTime: openTrade.entryTime,
              exitTime: candle.timestamp,
              profitLoss: profitLoss,
              profitLossPercent: (profitLoss / (openTrade.entryPrice * openTrade.quantity)) * 100,
              reason: 'Stop Loss',
            );

            trades.add(trade);
            currentBalance += trade.profitLoss;
            openTrade = null;
          }

          // فحص Take Profit
          if (openTrade != null &&
              openTrade.signal == TradeSignal.buy &&
              currentPrice >= openTrade.takeProfit) {
            final profitLoss =
                (openTrade.takeProfit - openTrade.entryPrice) * openTrade.quantity;
            final trade = ExecutedTrade(
              entryPrice: openTrade.entryPrice,
              exitPrice: openTrade.takeProfit,
              quantity: openTrade.quantity,
              entryTime: openTrade.entryTime,
              exitTime: candle.timestamp,
              profitLoss: profitLoss,
              profitLossPercent: (profitLoss / (openTrade.entryPrice * openTrade.quantity)) * 100,
              reason: 'Take Profit',
            );

            trades.add(trade);
            currentBalance += trade.profitLoss;
            openTrade = null;
          }
        }

        // تحديث Equity
        equity = currentBalance;
        if (openTrade != null) {
          final unrealizedPL =
              (candle.close - openTrade.entryPrice) * openTrade.quantity;
          equity = currentBalance + unrealizedPL;
        }

        // تتبع الحد الأقصى للتراجع
        final peak = equityHistory
            .map((e) => e.equity)
            .reduce((a, b) => a > b ? a : b);
        final drawdown = ((equity - peak) / peak) * 100;
        if (drawdown < maxDrawdown) {
          maxDrawdown = drawdown;
        }

        equityHistory.add(EquityPoint(
          timestamp: candle.timestamp,
          equity: equity,
          balance: currentBalance,
        ));
      }

      // حساب المقاييس
      final result = _calculateBacktestMetrics(
        trades: trades,
        equityHistory: equityHistory,
        initialBalance: initialBalance,
        maxDrawdown: maxDrawdown,
      );

      return result;
    } catch (e) {
      print('❌ Backtesting error: $e');
      rethrow;
    }
  }

  /// حساب المقاييس
  BacktestResult _calculateBacktestMetrics({
    required List<ExecutedTrade> trades,
    required List<EquityPoint> equityHistory,
    required double initialBalance,
    required double maxDrawdown,
  }) {
    if (trades.isEmpty) {
      return BacktestResult.empty();
    }

    final winningTrades = trades.where((t) => t.profitLoss > 0).toList();
    final losingTrades = trades.where((t) => t.profitLoss < 0).toList();

    final totalProfit = trades.fold<double>(0, (sum, t) => sum + t.profitLoss);
    final grossProfit =
        winningTrades.fold<double>(0, (sum, t) => sum + t.profitLoss);
    final grossLoss =
        losingTrades.fold<double>(0, (sum, t) => sum + t.profitLoss.abs());

    final profitFactor = grossLoss > 0 ? grossProfit / grossLoss : 0.0;

    // حساب Sharpe Ratio
    final returns = <double>[];
    for (int i = 1; i < equityHistory.length; i++) {
      final dailyReturn =
          (equityHistory[i].equity - equityHistory[i - 1].equity) /
              equityHistory[i - 1].equity;
      returns.add(dailyReturn);
    }

    double sharpeRatio = 0.0;
    if (returns.isNotEmpty) {
      final mean = returns.reduce((a, b) => a + b) / returns.length;
      final variance = returns
              .map((r) => pow(r - mean, 2))
              .reduce((a, b) => a + b) /
          returns.length;
      final stdDev = sqrt(variance);

      if (stdDev > 0) {
        sharpeRatio = (mean * sqrt(252)) / stdDev;
      }
    }

    final finalEquity = equityHistory.last.equity;
    final roi = ((finalEquity - initialBalance) / initialBalance) * 100;

    return BacktestResult(
      totalTrades: trades.length,
      winningTrades: winningTrades.length,
      losingTrades: losingTrades.length,
      winRate: (winningTrades.length / trades.length) * 100,
      totalProfit: totalProfit,
      profitFactor: profitFactor,
      sharpeRatio: sharpeRatio,
      maxDrawdown: maxDrawdown,
      roi: roi,
      equityHistory: equityHistory,
      trades: trades,
    );
  }
}

/// TradingStrategy - استراتيجية تداول
abstract class TradingStrategy {
  TradeSignal generateSignal(List<CandleData> data, int currentIndex);
}

/// Simple LSTM Strategy
class LSTMStrategy extends TradingStrategy {
  @override
  TradeSignal generateSignal(List<CandleData> data, int currentIndex) {
    if (currentIndex < 20) return TradeSignal.none;

    // استراتيجية بسيطة: شراء عند RSI < 30، بيع عند RSI > 70
    final rsi = _calculateSimpleRSI(data, currentIndex);

    if (rsi < 30) return TradeSignal.buy;
    if (rsi > 70) return TradeSignal.sell;

    return TradeSignal.none;
  }

  double _calculateSimpleRSI(List<CandleData> data, int index) {
    if (index < 14) return 50.0;
    
    double gains = 0;
    double losses = 0;
    
    for (int i = index - 14; i < index; i++) {
      final change = data[i + 1].close - data[i].close;
      if (change > 0) {
        gains += change;
      } else {
        losses += change.abs();
      }
    }
    
    final avgGain = gains / 14;
    final avgLoss = losses / 14;
    
    if (avgLoss == 0) return 100.0;
    
    final rs = avgGain / avgLoss;
    return 100 - (100 / (1 + rs));
  }
}

