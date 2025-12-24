/// Recommendation Model
enum Direction {
  buy,
  sell,
  noTrade;

  String get displayName {
    switch (this) {
      case Direction.buy:
        return 'BUY';
      case Direction.sell:
        return 'SELL';
      case Direction.noTrade:
        return 'NO TRADE';
    }
  }
}

enum Confidence {
  veryHigh,
  high,
  medium,
  low;

  String get displayName {
    switch (this) {
      case Confidence.veryHigh:
        return 'Very High';
      case Confidence.high:
        return 'High';
      case Confidence.medium:
        return 'Medium';
      case Confidence.low:
        return 'Low';
    }
  }
}

class Recommendation {
  final Direction direction;
  final double? entry;
  final double? entryMin;
  final double? entryMax;
  final double? stopLoss;
  final double? takeProfit;
  final Confidence confidence;
  final String reasoning;
  final DateTime timestamp;
  final String? liquidityTarget;
  final double? riskRewardRatio;

  Recommendation({
    required this.direction,
    this.entry,
    this.entryMin,
    this.entryMax,
    this.stopLoss,
    this.takeProfit,
    required this.confidence,
    required this.reasoning,
    required this.timestamp,
    this.liquidityTarget,
    this.riskRewardRatio,
  });

  // From Map (from engine)
  factory Recommendation.fromMap(Map<String, dynamic> map) {
    // Helper: Parse price from various formats ($2607.50, $2605-$2610, 2607.5)
    double? parsePrice(dynamic value) {
      if (value == null) return null;
      if (value is double) {
        if (value.isNaN || value.isInfinite || value <= 0) return null;
        return value;
      }
      if (value is int) {
        if (value <= 0) return null;
        return value.toDouble();
      }
      if (value is String) {
        // Remove $, commas, and whitespace
        final cleaned = value
            .replaceAll('\$', '')
            .replaceAll(',', '')
            .replaceAll(' ', '')
            .trim();

        // Handle empty strings
        if (cleaned.isEmpty) return null;

        // Handle "NONE", "N/A", "NULL", etc.
        final upper = cleaned.toUpperCase();
        if (upper == 'NONE' ||
            upper == 'N/A' ||
            upper == 'NULL' ||
            upper == 'NA') {
          return null;
        }

        // Handle ranges like "$2605-$2610" or "2605-2610" → take midpoint
        if (cleaned.contains('-')) {
          final parts = cleaned.split('-');
          if (parts.length == 2) {
            final lowStr = parts[0].trim();
            final highStr = parts[1].trim();
            final low = double.tryParse(lowStr);
            final high = double.tryParse(highStr);
            if (low != null && high != null && low > 0 && high > 0) {
              return (low + high) / 2;
            }
          }
        }

        // Try parsing as double
        final parsed = double.tryParse(cleaned);
        if (parsed != null &&
            parsed > 0 &&
            !parsed.isNaN &&
            !parsed.isInfinite) {
          return parsed;
        }
      }
      return null;
    }

    // Helper: Convert confidence from int to String for parsing
    String confIntToString(dynamic conf) {
      if (conf is int) {
        if (conf >= 81) return 'VERY HIGH';
        if (conf >= 61) return 'HIGH';
        if (conf >= 31) return 'MEDIUM';
        return 'LOW';
      }
      return conf?.toString() ?? 'LOW';
    }

    // Extract reasoning from various possible fields
    String extractReasoning() {
      return map['reasoning']?.toString() ??
          map['structure_reason']?.toString() ??
          map['trend_reason']?.toString() ??
          map['zone_validation']?.toString() ??
          '';
    }

    return Recommendation(
      direction: _parseDirection(map['direction']),
      entry: parsePrice(map['entry'] ?? map['entry_zone']),
      entryMin: parsePrice(map['entryMin']),
      entryMax: parsePrice(map['entryMax']),
      stopLoss: parsePrice(map['stopLoss'] ?? map['stop_loss']),
      takeProfit: parsePrice(map['takeProfit'] ?? map['take_profit']),
      confidence: _parseConfidence(confIntToString(map['confidence'])),
      reasoning: extractReasoning(),
      timestamp: DateTime.now(),
      liquidityTarget: map['liquidityTarget'] ?? map['liquidity_target'],
      riskRewardRatio: map['riskReward']?.toDouble(),
    );
  }

  static Direction _parseDirection(String? dir) {
    switch (dir?.toUpperCase()) {
      case 'BUY':
        return Direction.buy;
      case 'SELL':
        return Direction.sell;
      default:
        return Direction.noTrade;
    }
  }

  static Confidence _parseConfidence(String? conf) {
    switch (conf?.toUpperCase()) {
      case 'VERY HIGH':
        return Confidence.veryHigh;
      case 'HIGH':
        return Confidence.high;
      case 'MEDIUM':
        return Confidence.medium;
      default:
        return Confidence.low;
    }
  }

  // Helpers
  String get directionText {
    switch (direction) {
      case Direction.buy:
        return 'BUY';
      case Direction.sell:
        return 'SELL';
      case Direction.noTrade:
        return 'NO TRADE';
    }
  }

  String get confidenceText {
    switch (confidence) {
      case Confidence.veryHigh:
        return 'Very High';
      case Confidence.high:
        return 'High';
      case Confidence.medium:
        return 'Medium';
      case Confidence.low:
        return 'Low';
    }
  }

  double? get potentialProfit {
    if (entry == null || takeProfit == null) return null;
    return direction == Direction.buy
        ? takeProfit! - entry!
        : entry! - takeProfit!;
  }

  double? get potentialLoss {
    if (entry == null || stopLoss == null) return null;
    return direction == Direction.buy ? entry! - stopLoss! : stopLoss! - entry!;
  }

  String get rrText {
    if (riskRewardRatio == null) return 'N/A';
    return '1:${riskRewardRatio!.toStringAsFixed(1)}';
  }

  /// Get direction emoji
  String get directionEmoji {
    switch (direction) {
      case Direction.buy:
        return '🟢';
      case Direction.sell:
        return '🔴';
      case Direction.noTrade:
        return '⚪';
    }
  }

  /// Get confidence as numeric value (0-100)
  double get confidenceValue {
    switch (confidence) {
      case Confidence.veryHigh:
        return 95.0;
      case Confidence.high:
        return 80.0;
      case Confidence.medium:
        return 60.0;
      case Confidence.low:
        return 40.0;
    }
  }

  /// Getter for entryPrice (alias for entry)
  double? get entryPrice => entry;
}
