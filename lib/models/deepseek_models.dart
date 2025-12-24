/// DeepSeek Service Models
library;

import 'recommendation.dart';

/// Signal types for trading
enum SignalType { buy, sell, wait }

/// Trading signal with detailed information
class TradingSignal {
  final SignalType type;
  final int strength; // 0-100
  final String reason;
  final double? entryPrice;
  final double? stopLoss;
  final double? takeProfit;

  TradingSignal({
    required this.type,
    required this.strength,
    required this.reason,
    this.entryPrice,
    this.stopLoss,
    this.takeProfit,
  });

  /// Convert from Recommendation to TradingSignal
  factory TradingSignal.fromRecommendation(Recommendation rec) {
    // Convert Direction to SignalType
    SignalType signalType;
    switch (rec.direction) {
      case Direction.buy:
        signalType = SignalType.buy;
        break;
      case Direction.sell:
        signalType = SignalType.sell;
        break;
      case Direction.noTrade:
        signalType = SignalType.wait;
        break;
    }

    // Convert Confidence to strength (0-100)
    int strength;
    switch (rec.confidence) {
      case Confidence.veryHigh:
        strength = 95;
        break;
      case Confidence.high:
        strength = 80;
        break;
      case Confidence.medium:
        strength = 60;
        break;
      case Confidence.low:
        strength = 40;
        break;
    }

    return TradingSignal(
      type: signalType,
      strength: strength,
      reason: rec.reasoning.isNotEmpty ? rec.reasoning : 'Technical analysis',
      entryPrice: rec.entry,
      stopLoss: rec.stopLoss,
      takeProfit: rec.takeProfit,
    );
  }

  /// Convert to Recommendation
  Recommendation toRecommendation() {
    // Convert SignalType to Direction
    Direction direction;
    switch (type) {
      case SignalType.buy:
        direction = Direction.buy;
        break;
      case SignalType.sell:
        direction = Direction.sell;
        break;
      case SignalType.wait:
        direction = Direction.noTrade;
        break;
    }

    // Convert strength to Confidence
    Confidence confidence;
    if (strength >= 85) {
      confidence = Confidence.veryHigh;
    } else if (strength >= 70) {
      confidence = Confidence.high;
    } else if (strength >= 50) {
      confidence = Confidence.medium;
    } else {
      confidence = Confidence.low;
    }

    return Recommendation(
      direction: direction,
      entry: entryPrice,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
      confidence: confidence,
      reasoning: reason,
      timestamp: DateTime.now(),
    );
  }
}

/// Smart analysis result from DeepSeek
class SmartAnalysis {
  final SignalType recommendation;
  final int confidence; // 0-100
  final String reasoning;
  final List<double> keyLevels;
  final String riskManagement;
  final DateTime generatedAt;

  SmartAnalysis({
    required this.recommendation,
    required this.confidence,
    required this.reasoning,
    required this.keyLevels,
    required this.riskManagement,
    required this.generatedAt,
  });

  /// Get recommendation as text
  String get recommendationText {
    switch (recommendation) {
      case SignalType.buy:
        return 'شراء';
      case SignalType.sell:
        return 'بيع';
      case SignalType.wait:
        return 'انتظار';
    }
  }

  /// Get confidence level as text
  String get confidenceText {
    if (confidence >= 85) {
      return 'قوي جداً';
    } else if (confidence >= 70) {
      return 'قوي';
    } else if (confidence >= 50) {
      return 'متوسط';
    } else {
      return 'ضعيف';
    }
  }

  /// Check if high quality analysis
  bool get isHighQuality => confidence >= 70 && keyLevels.length >= 3;
}
















