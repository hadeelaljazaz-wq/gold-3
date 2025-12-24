/// Market-related Models

import 'package:flutter/foundation.dart';

// Gold Price
@immutable
class GoldPrice {
  final double price;
  final double change;
  final double changePercent;
  final double high24h;
  final double low24h;
  final double open24h;
  final DateTime timestamp;

  GoldPrice({
    required this.price,
    required this.change,
    required this.changePercent,
    required this.high24h,
    required this.low24h,
    required this.open24h,
    required this.timestamp,
  });

  bool get isBullish => change > 0;
  bool get isBearish => change < 0;
}

// Market Status
enum MarketSession { london, newYork, asian, closed }

@immutable
class MarketStatus {
  final bool isOpen;
  final MarketSession session;
  final DateTime? nextOpen;
  final DateTime? nextClose;

  MarketStatus({
    required this.isOpen,
    required this.session,
    this.nextOpen,
    this.nextClose,
  });

  String get sessionName {
    switch (session) {
      case MarketSession.london:
        return 'London Session';
      case MarketSession.newYork:
        return 'New York Session';
      case MarketSession.asian:
        return 'Asian Session';
      case MarketSession.closed:
        return 'Market Closed';
    }
  }
}

// Technical Indicators
class TechnicalIndicators {
  final double rsi;
  final double macd;
  final double macdSignal;
  final double macdHistogram;
  final double ma20;
  final double ma50;
  final double ma100;
  final double ma200;
  final double atr;
  final double bollingerUpper;
  final double bollingerMiddle;
  final double bollingerLower;

  TechnicalIndicators({
    required this.rsi,
    required this.macd,
    required this.macdSignal,
    required this.macdHistogram,
    required this.ma20,
    required this.ma50,
    required this.ma100,
    required this.ma200,
    required this.atr,
    required this.bollingerUpper,
    required this.bollingerMiddle,
    required this.bollingerLower,
  });

  // RSI Levels
  bool get rsiOverbought => rsi > 70;
  bool get rsiOversold => rsi < 30;
  bool get rsiNeutral => rsi >= 30 && rsi <= 70;

  String get rsiLevel {
    if (rsi > 70) return 'Overbought';
    if (rsi < 30) return 'Oversold';
    return 'Neutral';
  }

  // MACD Trend
  bool get macdBullish => macd > macdSignal;
  bool get macdBearish => macd < macdSignal;

  String get macdTrend => macdBullish ? 'Bullish' : 'Bearish';

  // Volume Trend (optional - يمكن إضافته لاحقاً)
  String? get volumeTrend => null;
}

// Performance Stats
class PerformanceStats {
  final int totalTrades;
  final int winningTrades;
  final int losingTrades;
  final double totalProfit;
  final double totalLoss;
  final double netProfit;
  final double winRate;
  final double avgWin;
  final double avgLoss;
  final double profitFactor;

  PerformanceStats({
    required this.totalTrades,
    required this.winningTrades,
    required this.losingTrades,
    required this.totalProfit,
    required this.totalLoss,
    required this.netProfit,
    required this.winRate,
    required this.avgWin,
    required this.avgLoss,
    required this.profitFactor,
  });

  factory PerformanceStats.empty() {
    return PerformanceStats(
      totalTrades: 0,
      winningTrades: 0,
      losingTrades: 0,
      totalProfit: 0,
      totalLoss: 0,
      netProfit: 0,
      winRate: 0,
      avgWin: 0,
      avgLoss: 0,
      profitFactor: 0,
    );
  }
}

// Alert Model
enum AlertType { price, indicator, time }

enum AlertStatus { active, triggered, expired }

class Alert {
  final String id;
  final AlertType type;
  final String condition;
  final double? targetPrice;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final AlertStatus status;
  final String? message;
  final bool notified;

  Alert({
    required this.id,
    required this.type,
    required this.condition,
    this.targetPrice,
    required this.createdAt,
    this.expiresAt,
    required this.status,
    this.message,
    required this.notified,
  });
}
