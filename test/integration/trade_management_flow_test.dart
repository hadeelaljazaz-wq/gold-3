import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_nightmare_pro/features/trade_history/providers/trade_history_provider.dart';
import 'package:golden_nightmare_pro/models/trade_record.dart';
import 'package:golden_nightmare_pro/models/scalping_signal.dart';

void main() {
  group('Trade Management Flow Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should complete full trade lifecycle', () async {
      final notifier = container.read(tradeHistoryProvider.notifier);

      // 1. Create trade from signal
      final signal = ScalpingSignal(
        direction: 'BUY',
        entryPrice: 2050.0,
        stopLoss: 2040.0,
        takeProfit: 2060.0,
        confidence: 75,
        timestamp: DateTime.now(),
      );

      await notifier.addTrade(TradeRecord.fromSignal(
        type: 'SCALP',
        direction: signal.direction,
        entryPrice: signal.entryPrice!,
        stopLoss: signal.stopLoss!,
        takeProfit: [signal.takeProfit!],
        engine: 'scalping_v2',
        strictness: 'moderate',
      ));
      final tradeId = container.read(tradeHistoryProvider).trades.first.id;

      expect(container.read(tradeHistoryProvider).trades.length, equals(1));

      // 2. Close trade
      await notifier.closeTrade(tradeId, 2060.0);

      final closedTrade = container
          .read(tradeHistoryProvider)
          .trades
          .firstWhere((t) => t.id == tradeId);

      expect(closedTrade.status, equals('closed'));
      expect(closedTrade.profitLoss, greaterThan(0));

      // 3. Verify statistics updated
      final state = container.read(tradeHistoryProvider);
      expect(state.totalTrades, equals(1));
      expect(state.profitableTrades, equals(1));
    });

    test('should create and track multiple trades', () async {
      final notifier = container.read(tradeHistoryProvider.notifier);

      // Create multiple trades
      final signal1 = ScalpingSignal(
        direction: 'BUY',
        entryPrice: 2050.0,
        stopLoss: 2040.0,
        takeProfit: 2060.0,
        confidence: 75,
        timestamp: DateTime.now(),
      );

      await notifier.addTrade(TradeRecord.fromSignal(
        type: 'SCALP',
        direction: signal1.direction,
        entryPrice: signal1.entryPrice!,
        stopLoss: signal1.stopLoss!,
        takeProfit: [signal1.takeProfit!],
        engine: 'scalping_v2',
        strictness: 'moderate',
      ));

      expect(container.read(tradeHistoryProvider).trades.length, equals(1));
    });

    test('should filter trades by type', () async {
      final notifier = container.read(tradeHistoryProvider.notifier);

      // Create test trades
      final scalpSignal = ScalpingSignal(
        direction: 'BUY',
        entryPrice: 2050.0,
        stopLoss: 2040.0,
        takeProfit: 2060.0,
        confidence: 75,
        timestamp: DateTime.now(),
      );

      await notifier.addTrade(TradeRecord.fromSignal(
        type: 'SCALP',
        direction: scalpSignal.direction,
        entryPrice: scalpSignal.entryPrice!,
        stopLoss: scalpSignal.stopLoss!,
        takeProfit: [scalpSignal.takeProfit!],
        engine: 'scalping_v2',
        strictness: 'moderate',
      ));

      // Filter by type
      final scalpTrades = container
          .read(tradeHistoryProvider)
          .trades
          .where((t) => t.type == 'SCALP')
          .toList();
      expect(scalpTrades.length, greaterThan(0));

      final swingTrades = container
          .read(tradeHistoryProvider)
          .trades
          .where((t) => t.type == 'SWING')
          .toList();
      expect(swingTrades.length, equals(0));
    });
  });
}
