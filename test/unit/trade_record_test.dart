import 'package:flutter_test/flutter_test.dart';
import 'package:golden_nightmare_pro/models/trade_record.dart';

void main() {
  group('TradeRecord Tests', () {
    test('should create trade from signal', () {
      // Arrange & Act
      final trade = TradeRecord.fromSignal(
        type: 'scalp',
        direction: 'BUY',
        entryPrice: 2650.00,
        stopLoss: 2648.00,
        takeProfit: [2652.00, 2653.50, 2655.00],
        engine: 'scalping_v2',
        strictness: 'balanced',
      );

      // Assert
      expect(trade.type, 'scalp');
      expect(trade.direction, 'BUY');
      expect(trade.entryPrice, 2650.00);
      expect(trade.stopLoss, 2648.00);
      expect(trade.takeProfit.length, 3);
      expect(trade.status, 'open');
      expect(trade.isOpen, true);
    });

    test('should close trade with profit', () {
      // Arrange
      final trade = TradeRecord.fromSignal(
        type: 'scalp',
        direction: 'BUY',
        entryPrice: 2650.00,
        stopLoss: 2648.00,
        takeProfit: [2652.00, 2653.50, 2655.00],
        engine: 'scalping_v2',
        strictness: 'balanced',
      );

      // Act
      final closedTrade = trade.close(exitPrice: 2653.50);

      // Assert
      expect(closedTrade.status, 'closed');
      expect(closedTrade.exitPrice, 2653.50);
      expect(closedTrade.profitLoss, 3.50);
      expect(closedTrade.isProfitable, true);
      expect(closedTrade.isOpen, false);
    });

    test('should close trade with loss', () {
      // Arrange
      final trade = TradeRecord.fromSignal(
        type: 'scalp',
        direction: 'BUY',
        entryPrice: 2650.00,
        stopLoss: 2648.00,
        takeProfit: [2652.00, 2653.50, 2655.00],
        engine: 'scalping_v2',
        strictness: 'balanced',
      );

      // Act
      final closedTrade = trade.close(exitPrice: 2648.00);

      // Assert
      expect(closedTrade.status, 'closed');
      expect(closedTrade.exitPrice, 2648.00);
      expect(closedTrade.profitLoss, -2.00);
      expect(closedTrade.isProfitable, false);
    });

    test('should calculate profit/loss correctly for SELL trade', () {
      // Arrange
      final trade = TradeRecord.fromSignal(
        type: 'swing',
        direction: 'SELL',
        entryPrice: 2650.00,
        stopLoss: 2653.00,
        takeProfit: [2645.00, 2640.00, 2635.00],
        engine: 'swing_v2',
        strictness: 'strict',
      );

      // Act
      final closedTrade = trade.close(exitPrice: 2645.00);

      // Assert
      expect(closedTrade.profitLoss, 5.00); // SELL: entry - exit
      expect(closedTrade.isProfitable, true);
    });

    test('should cancel trade', () {
      // Arrange
      final trade = TradeRecord.fromSignal(
        type: 'scalp',
        direction: 'BUY',
        entryPrice: 2650.00,
        stopLoss: 2648.00,
        takeProfit: [2652.00, 2653.50, 2655.00],
        engine: 'scalping_v2',
        strictness: 'balanced',
      );

      // Act
      final cancelledTrade = trade.cancel(notes: 'Market conditions changed');

      // Assert
      expect(cancelledTrade.status, 'cancelled');
      expect(cancelledTrade.profitLoss, 0);
      expect(cancelledTrade.notes, 'Market conditions changed');
    });

    test('should calculate duration correctly', () {
      // Arrange
      final trade = TradeRecord.fromSignal(
        type: 'scalp',
        direction: 'BUY',
        entryPrice: 2650.00,
        stopLoss: 2648.00,
        takeProfit: [2652.00, 2653.50, 2655.00],
        engine: 'scalping_v2',
        strictness: 'balanced',
      );

      // Act
      final duration = trade.durationHours;

      // Assert
      expect(duration, greaterThanOrEqualTo(0));
      expect(duration, lessThan(1)); // Should be less than 1 hour for new trade
    });

    test('should serialize to/from JSON', () {
      // Arrange
      final trade = TradeRecord.fromSignal(
        type: 'scalp',
        direction: 'BUY',
        entryPrice: 2650.00,
        stopLoss: 2648.00,
        takeProfit: [2652.00, 2653.50, 2655.00],
        engine: 'scalping_v2',
        strictness: 'balanced',
      );

      // Act
      final json = trade.toJson();
      final deserializedTrade = TradeRecord.fromJson(json);

      // Assert
      expect(deserializedTrade.type, trade.type);
      expect(deserializedTrade.direction, trade.direction);
      expect(deserializedTrade.entryPrice, trade.entryPrice);
      expect(deserializedTrade.stopLoss, trade.stopLoss);
      expect(deserializedTrade.takeProfit, trade.takeProfit);
      expect(deserializedTrade.engine, trade.engine);
      expect(deserializedTrade.strictness, trade.strictness);
    });
  });
}
