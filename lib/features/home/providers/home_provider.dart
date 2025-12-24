import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: unused_import
import 'package:hive_flutter/hive_flutter.dart';
import '../../../services/gold_price_service.dart';
import '../../../models/market_models.dart';
import '../../../features/trade_history/providers/trade_history_provider.dart';

/// Gold Price Provider (Stream)
final goldPriceProvider = StreamProvider<GoldPrice>((ref) {
  return GoldPriceService.getPriceStream();
});

/// Market Status Provider
final marketStatusProvider = Provider<MarketStatus>((ref) {
  return GoldPriceService.getMarketStatus();
});

/// Performance Stats Provider
final performanceStatsProvider = Provider<PerformanceStats>((ref) {
  // Load from trade history provider
  final tradeHistoryState = ref.watch(tradeHistoryProvider);
  final trades = tradeHistoryState.trades;

  if (trades.isEmpty) {
    return PerformanceStats.empty();
  }

  final closedTrades = trades.where((t) => t.status == 'CLOSED').toList();
  final profitableTrades = closedTrades
      .where((t) => t.profitLoss != null && t.profitLoss! > 0)
      .toList();
  final losingTrades = closedTrades
      .where((t) => t.profitLoss != null && t.profitLoss! <= 0)
      .toList();

  final totalProfit = profitableTrades.fold<double>(
    0.0,
    (sum, trade) => sum + (trade.profitLoss ?? 0.0),
  );

  final totalLoss = losingTrades.fold<double>(
    0.0,
    (sum, trade) => sum + (trade.profitLoss?.abs() ?? 0.0),
  );

  final netProfit = totalProfit - totalLoss;
  final winRate = closedTrades.isEmpty
      ? 0.0
      : (profitableTrades.length / closedTrades.length * 100);

  final avgWin =
      profitableTrades.isEmpty ? 0.0 : totalProfit / profitableTrades.length;

  final avgLoss = losingTrades.isEmpty ? 0.0 : totalLoss / losingTrades.length;

  final profitFactor = totalLoss == 0
      ? (totalProfit > 0 ? double.infinity : 0.0)
      : totalProfit / totalLoss;

  return PerformanceStats(
    totalTrades: trades.length,
    winningTrades: profitableTrades.length,
    losingTrades: losingTrades.length,
    totalProfit: totalProfit,
    totalLoss: totalLoss,
    netProfit: netProfit,
    winRate: winRate,
    avgWin: avgWin,
    avgLoss: avgLoss,
    profitFactor: profitFactor,
  );
});

/// Refresh Notifier
final refreshNotifierProvider = StateProvider<int>((ref) => 0);
