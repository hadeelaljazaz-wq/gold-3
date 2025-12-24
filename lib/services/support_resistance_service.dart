/// Support & Resistance Levels Service
/// Calculates dynamic support/resistance using multiple methods

import 'dart:math';
import '../models/candle.dart';

class SupportResistanceLevel {
  final double price;
  final String type; // 'SUPPORT' or 'RESISTANCE'
  final int strength; // 0-100
  final String source; // 'PIVOT', 'STRUCTURE', 'FIBONACCI'
  final int touchCount; // How many times tested

  SupportResistanceLevel({
    required this.price,
    required this.type,
    required this.strength,
    required this.source,
    required this.touchCount,
  });
}

class SupportResistanceAnalysis {
  final List<SupportResistanceLevel> supports;
  final List<SupportResistanceLevel> resistances;
  final SupportResistanceLevel? nearestSupport;
  final SupportResistanceLevel? nearestResistance;

  SupportResistanceAnalysis({
    required this.supports,
    required this.resistances,
    this.nearestSupport,
    this.nearestResistance,
  });
}

class SupportResistanceService {
  /// Calculate all support/resistance levels
  static SupportResistanceAnalysis calculate(
    List<Candle> candles,
    double currentPrice,
  ) {
    final allLevels = <SupportResistanceLevel>[];

    // 1. Market Structure (Swing Highs/Lows) - Most important, closest to price
    final structureLevels = _calculateStructureLevels(candles, currentPrice);
    allLevels.addAll(structureLevels);

    // 2. Recent Pivot Points (from last 20 candles only)
    final pivotLevels = _calculatePivotPoints(candles, currentPrice);
    allLevels.addAll(pivotLevels);

    // 3. Fibonacci Retracements (only if within reasonable range)
    final fibLevels = _calculateFibonacciLevels(candles, currentPrice);
    allLevels.addAll(fibLevels);

    // Filter levels to be within reasonable range (±5% of current price)
    final maxDistance = currentPrice * 0.05; // 5% max distance
    final filteredLevels = allLevels.where((level) {
      final distance = (level.price - currentPrice).abs();
      return distance <= maxDistance;
    }).toList();

    // Separate supports and resistances
    final supports = filteredLevels
        .where((l) => l.type == 'SUPPORT' && l.price < currentPrice)
        .toList()
      ..sort((a, b) {
        // Sort by distance first, then by strength
        final distA = (currentPrice - a.price).abs();
        final distB = (currentPrice - b.price).abs();
        final distCompare = distA.compareTo(distB);
        if (distCompare != 0) return distCompare;
        return b.strength.compareTo(a.strength);
      });

    final resistances = filteredLevels
        .where((l) => l.type == 'RESISTANCE' && l.price > currentPrice)
        .toList()
      ..sort((a, b) {
        // Sort by distance first, then by strength
        final distA = (a.price - currentPrice).abs();
        final distB = (b.price - currentPrice).abs();
        final distCompare = distA.compareTo(distB);
        if (distCompare != 0) return distCompare;
        return b.strength.compareTo(a.strength);
      });

    return SupportResistanceAnalysis(
      supports: supports.take(5).toList(),
      resistances: resistances.take(5).toList(),
      nearestSupport: supports.isNotEmpty ? supports.first : null,
      nearestResistance: resistances.isNotEmpty ? resistances.first : null,
    );
  }

  /// Calculate Pivot Points (only near current price)
  static List<SupportResistanceLevel> _calculatePivotPoints(
      List<Candle> candles, double currentPrice) {
    if (candles.length < 20) return [];

    // Use last 20 candles for pivot calculation
    final recent = candles.take(20).toList();
    final high = recent.map((c) => c.high).reduce(max);
    final low = recent.map((c) => c.low).reduce(min);
    final close = recent.first.close;

    final pivot = (high + low + close) / 3;
    final r1 = (2 * pivot) - low;
    final s1 = (2 * pivot) - high;

    // Only include R1 and S1 if they're within 3% of current price
    final levels = <SupportResistanceLevel>[];
    final maxDistance = currentPrice * 0.03;

    if (r1 > currentPrice && (r1 - currentPrice) <= maxDistance) {
      levels.add(SupportResistanceLevel(
        price: r1,
        type: 'RESISTANCE',
        strength: 75,
        source: 'PIVOT R1',
        touchCount: 0,
      ));
    }

    if (s1 < currentPrice && (currentPrice - s1) <= maxDistance) {
      levels.add(SupportResistanceLevel(
        price: s1,
        type: 'SUPPORT',
        strength: 75,
        source: 'PIVOT S1',
        touchCount: 0,
      ));
    }

    return levels;
  }

  /// Calculate Structure Levels (Swing Highs/Lows) - Focus on recent, close levels
  static List<SupportResistanceLevel> _calculateStructureLevels(
      List<Candle> candles, double currentPrice) {
    if (candles.length < 30) return [];

    final levels = <SupportResistanceLevel>[];
    final lookback = 5;
    final maxDistance = currentPrice * 0.04; // 4% max distance

    // Focus on last 50 candles for closer levels
    final checkRange = min(50, candles.length - lookback);

    // Find swing highs and lows
    for (int i = lookback; i < checkRange; i++) {
      // Check for swing high
      bool isSwingHigh = true;
      for (int j = i - lookback; j <= i + lookback; j++) {
        if (j != i && candles[j].high >= candles[i].high) {
          isSwingHigh = false;
          break;
        }
      }

      if (isSwingHigh) {
        final price = candles[i].high;
        final distance = (price - currentPrice).abs();

        // Only include if within range and above current price
        if (price > currentPrice && distance <= maxDistance) {
          // Count touches (more recent = higher weight)
          int touches = 1;
          double touchScore = 1.0;
          for (int k = 0; k < min(i + 20, candles.length); k++) {
            if (k != i && (candles[k].high - price).abs() < 1.5) {
              touches++;
              // Recent touches are more valuable
              final age = (i - k).abs();
              touchScore += 1.0 / (1.0 + age * 0.1);
            }
          }

          final strength =
              min(60 + (touches * 8) + (touchScore * 5).round(), 100);

          levels.add(SupportResistanceLevel(
            price: price,
            type: 'RESISTANCE',
            strength: strength,
            source: 'STRUCTURE',
            touchCount: touches,
          ));
        }
      }

      // Check for swing low
      bool isSwingLow = true;
      for (int j = i - lookback; j <= i + lookback; j++) {
        if (j != i && candles[j].low <= candles[i].low) {
          isSwingLow = false;
          break;
        }
      }

      if (isSwingLow) {
        final price = candles[i].low;
        final distance = (currentPrice - price).abs();

        // Only include if within range and below current price
        if (price < currentPrice && distance <= maxDistance) {
          int touches = 1;
          double touchScore = 1.0;
          for (int k = 0; k < min(i + 20, candles.length); k++) {
            if (k != i && (candles[k].low - price).abs() < 1.5) {
              touches++;
              final age = (i - k).abs();
              touchScore += 1.0 / (1.0 + age * 0.1);
            }
          }

          final strength =
              min(60 + (touches * 8) + (touchScore * 5).round(), 100);

          levels.add(SupportResistanceLevel(
            price: price,
            type: 'SUPPORT',
            strength: strength,
            source: 'STRUCTURE',
            touchCount: touches,
          ));
        }
      }
    }

    return levels;
  }

  /// Calculate Fibonacci Retracement Levels (only near current price)
  static List<SupportResistanceLevel> _calculateFibonacciLevels(
      List<Candle> candles, double currentPrice) {
    if (candles.length < 30) return [];

    // Find recent swing high and low (last 30 candles)
    final recent30 = candles.take(30).toList();
    final swingHigh = recent30.map((c) => c.high).reduce(max);
    final swingLow = recent30.map((c) => c.low).reduce(min);
    final diff = swingHigh - swingLow;

    if (diff < currentPrice * 0.01) return []; // Too small range

    // Fibonacci levels
    final fib382 = swingHigh - (diff * 0.382);
    final fib50 = swingHigh - (diff * 0.5);
    final fib618 = swingHigh - (diff * 0.618);

    final levels = <SupportResistanceLevel>[];
    final maxDistance = currentPrice * 0.03; // 3% max distance

    // Only include levels within range
    if (fib382 > currentPrice && (fib382 - currentPrice) <= maxDistance) {
      levels.add(SupportResistanceLevel(
        price: fib382,
        type: 'RESISTANCE',
        strength: 70,
        source: 'FIB 38.2%',
        touchCount: 0,
      ));
    } else if (fib382 < currentPrice &&
        (currentPrice - fib382) <= maxDistance) {
      levels.add(SupportResistanceLevel(
        price: fib382,
        type: 'SUPPORT',
        strength: 70,
        source: 'FIB 38.2%',
        touchCount: 0,
      ));
    }

    if (fib50 > currentPrice && (fib50 - currentPrice) <= maxDistance) {
      levels.add(SupportResistanceLevel(
        price: fib50,
        type: 'RESISTANCE',
        strength: 80,
        source: 'FIB 50%',
        touchCount: 0,
      ));
    } else if (fib50 < currentPrice && (currentPrice - fib50) <= maxDistance) {
      levels.add(SupportResistanceLevel(
        price: fib50,
        type: 'SUPPORT',
        strength: 80,
        source: 'FIB 50%',
        touchCount: 0,
      ));
    }

    if (fib618 > currentPrice && (fib618 - currentPrice) <= maxDistance) {
      levels.add(SupportResistanceLevel(
        price: fib618,
        type: 'RESISTANCE',
        strength: 85,
        source: 'FIB 61.8%',
        touchCount: 0,
      ));
    } else if (fib618 < currentPrice &&
        (currentPrice - fib618) <= maxDistance) {
      levels.add(SupportResistanceLevel(
        price: fib618,
        type: 'SUPPORT',
        strength: 85,
        source: 'FIB 61.8%',
        touchCount: 0,
      ));
    }

    return levels;
  }
}
