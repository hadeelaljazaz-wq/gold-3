import 'dart:io' show Platform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/trade_record.dart';
import '../../../core/utils/logger.dart';
import '../../../services/telemetry_service.dart';

/// 📊 Trade History State
class TradeHistoryState {
  final List<TradeRecord> trades;
  final bool isLoading;
  final String? error;
  final String filter; // 'all', 'open', 'closed', 'profitable', 'loss'

  TradeHistoryState({
    this.trades = const [],
    this.isLoading = false,
    this.error,
    this.filter = 'all',
  });

  TradeHistoryState copyWith({
    List<TradeRecord>? trades,
    bool? isLoading,
    String? error,
    String? filter,
  }) {
    return TradeHistoryState(
      trades: trades ?? this.trades,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filter: filter ?? this.filter,
    );
  }

  /// Get filtered trades
  List<TradeRecord> get filteredTrades {
    switch (filter) {
      case 'open':
        return trades.where((t) => t.status == 'open').toList();
      case 'closed':
        return trades.where((t) => t.status == 'closed').toList();
      case 'profitable':
        return trades
            .where((t) => t.status == 'closed' && t.isProfitable)
            .toList();
      case 'loss':
        return trades
            .where((t) => t.status == 'closed' && !t.isProfitable)
            .toList();
      default:
        return trades;
    }
  }

  /// Statistics
  int get totalTrades => trades.length;
  int get openTrades => trades.where((t) => t.status == 'open').length;
  int get closedTrades => trades.where((t) => t.status == 'closed').length;
  int get profitableTrades =>
      trades.where((t) => t.status == 'closed' && t.isProfitable).length;
  int get lossTrades =>
      trades.where((t) => t.status == 'closed' && !t.isProfitable).length;

  double get totalProfit {
    return trades
        .where((t) => t.status == 'closed')
        .fold(0.0, (sum, t) => sum + (t.profitLoss ?? 0));
  }

  double get winRate {
    if (closedTrades == 0) return 0;
    return (profitableTrades / closedTrades) * 100;
  }

  double get averageProfit {
    if (closedTrades == 0) return 0;
    return totalProfit / closedTrades;
  }
}

/// 📊 Trade History Notifier
class TradeHistoryNotifier extends StateNotifier<TradeHistoryState> {
  static const String _boxName = 'trade_history';

  TradeHistoryNotifier() : super(TradeHistoryState()) {
    _init();
  }

  Future<void> _init() async {
    try {
      // Skip initialization in test environment (avoids Hive require path in CI)
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        AppLogger.info('Skipping TradeHistory initialization during tests');
        return;
      }

      AppLogger.info('Initializing Trade History Provider...');
      await loadTrades();

      // إضافة بيانات تجريبية إذا كانت القائمة فارغة (فقط إذا لم يحدث خطأ أثناء التحميل)
      if (state.trades.isEmpty && state.error == null) {
        await _addMockTrades();
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize trade history', e, stackTrace);
      state = state.copyWith(error: e.toString());
    }
  }

  /// Load trades from Hive
  Future<void> loadTrades() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final box = await Hive.openBox(_boxName);
      final tradesJson = box.get('trades', defaultValue: <dynamic>[]);

      final trades = (tradesJson as List)
          .map((json) => TradeRecord.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      // Sort by entry time (newest first)
      trades.sort((a, b) => b.entryTime.compareTo(a.entryTime));

      state = state.copyWith(trades: trades, isLoading: false);
      AppLogger.success('Trades loaded: ${trades.length}');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load trades', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'فشل تحميل سجل الصفقات',
      );
    }
  }

  /// Save trades to Hive
  Future<void> _saveTrades() async {
    try {
      final box = await Hive.openBox(_boxName);
      final tradesJson = state.trades.map((t) => t.toJson()).toList();
      await box.put('trades', tradesJson);
      AppLogger.success('Trades saved: ${state.trades.length}');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save trades', e, stackTrace);
    }
  }

  /// Add new trade
  Future<void> addTrade(TradeRecord trade) async {
    try {
      AppLogger.info('Adding new trade: ${trade.id}');
      final updatedTrades = [trade, ...state.trades];
      state = state.copyWith(trades: updatedTrades);
      await _saveTrades();
      AppLogger.success('Trade added: ${trade.id}');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to add trade', e, stackTrace);
      state = state.copyWith(error: 'فشل إضافة الصفقة');
    }
  }

  /// Close trade
  Future<void> closeTrade(String tradeId, double exitPrice,
      {String? notes}) async {
    try {
      AppLogger.info('Closing trade: $tradeId at $exitPrice');

      TradeRecord? closedTrade;

      final updatedTrades = state.trades.map((t) {
        if (t.id == tradeId) {
          final closed = t.close(exitPrice: exitPrice, notes: notes);
          closedTrade = closed;
          return closed;
        }
        return t;
      }).toList();

      state = state.copyWith(trades: updatedTrades);
      await _saveTrades();

      // Record telemetry for closed trade
      if (closedTrade != null) {
        TelemetryService.instance.recordSignalOutcome(closedTrade!.engine, closedTrade!.profitLoss ?? 0.0);
      }

      AppLogger.success('Trade closed: $tradeId');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to close trade', e, stackTrace);
      state = state.copyWith(error: 'فشل إغلاق الصفقة');
    }
  }

  /// Cancel trade
  Future<void> cancelTrade(String tradeId, {String? notes}) async {
    try {
      AppLogger.info('Cancelling trade: $tradeId');

      final updatedTrades = state.trades.map((t) {
        if (t.id == tradeId) {
          return t.cancel(notes: notes);
        }
        return t;
      }).toList();

      state = state.copyWith(trades: updatedTrades);
      await _saveTrades();
      AppLogger.success('Trade cancelled: $tradeId');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to cancel trade', e, stackTrace);
      state = state.copyWith(error: 'فشل إلغاء الصفقة');
    }
  }

  /// Delete trade
  Future<void> deleteTrade(String tradeId) async {
    try {
      AppLogger.info('Deleting trade: $tradeId');

      final updatedTrades = state.trades.where((t) => t.id != tradeId).toList();
      state = state.copyWith(trades: updatedTrades);
      await _saveTrades();
      AppLogger.success('Trade deleted: $tradeId');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete trade', e, stackTrace);
      state = state.copyWith(error: 'فشل حذف الصفقة');
    }
  }

  /// Change filter
  void changeFilter(String filter) {
    state = state.copyWith(filter: filter);
    AppLogger.info('Filter changed to: $filter');
  }

  /// Clear all trades
  Future<void> clearAllTrades() async {
    try {
      AppLogger.info('Clearing all trades');
      state = state.copyWith(trades: []);
      await _saveTrades();
      AppLogger.success('All trades cleared');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to clear trades', e, stackTrace);
      state = state.copyWith(error: 'فشل مسح الصفقات');
    }
  }

  /// Add mock trades for demo
  Future<void> _addMockTrades() async {
    // ignore: unused_local_variable
    final now = DateTime.now();

    final mockTrades = [
      // Closed profitable scalp
      TradeRecord.fromSignal(
        type: 'scalp',
        direction: 'BUY',
        entryPrice: 2650.50,
        stopLoss: 2648.00,
        takeProfit: [2652.00, 2653.50, 2655.00],
        engine: 'scalping_v2',
        strictness: 'balanced',
      ).close(exitPrice: 2653.50, notes: 'TP2 hit'),

      // Closed loss swing
      TradeRecord.fromSignal(
        type: 'swing',
        direction: 'SELL',
        entryPrice: 2655.00,
        stopLoss: 2658.00,
        takeProfit: [2650.00, 2645.00, 2640.00],
        engine: 'swing_v2',
        strictness: 'strict',
      ).close(exitPrice: 2658.00, notes: 'SL hit'),

      // Open scalp
      TradeRecord.fromSignal(
        type: 'scalp',
        direction: 'BUY',
        entryPrice: 2652.00,
        stopLoss: 2649.50,
        takeProfit: [2654.00, 2655.50, 2657.00],
        engine: 'golden_nightmare',
        strictness: 'relaxed',
      ),

      // Closed profitable swing
      TradeRecord.fromSignal(
        type: 'swing',
        direction: 'BUY',
        entryPrice: 2640.00,
        stopLoss: 2635.00,
        takeProfit: [2650.00, 2660.00, 2670.00],
        engine: 'swing_v2',
        strictness: 'balanced',
      ).close(exitPrice: 2660.00, notes: 'TP2 hit - excellent trade'),
    ];

    for (final trade in mockTrades) {
      await addTrade(trade);
    }

    AppLogger.success('Mock trades added: ${mockTrades.length}');
  }

  /// Export to CSV
  String exportToCSV() {
    final header =
        'ID,Type,Direction,Entry Price,Stop Loss,Take Profit,Entry Time,Exit Time,Exit Price,Status,P/L,P/L %,Engine,Strictness,Notes\n';

    final rows = state.trades.map((t) {
      return '${t.id},${t.type},${t.direction},${t.entryPrice},${t.stopLoss},"${t.takeProfit.join('|')}",${t.entryTime.toIso8601String()},${t.exitTime?.toIso8601String() ?? ''},${t.exitPrice ?? ''},${t.status},${t.profitLoss ?? ''},${t.profitLossPercent ?? ''},${t.engine},${t.strictness},"${t.notes ?? ''}"';
    }).join('\n');

    return header + rows;
  }
}

/// 📊 Trade History Provider Instance
final tradeHistoryProvider =
    StateNotifierProvider.autoDispose<TradeHistoryNotifier, TradeHistoryState>((ref) {
  return TradeHistoryNotifier();
});
