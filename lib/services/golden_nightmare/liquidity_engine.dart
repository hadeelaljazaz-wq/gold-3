// 🔥 LIQUIDITY ENGINE - Layer 2
// Detects: Liquidity Highs/Lows, Stop Clusters, Sweep Zones, Breaker Blocks, Order Blocks

import 'dart:math';
import '../../models/candle.dart';

class LiquidityEngine {
  /// Comprehensive liquidity analysis
  static LiquidityMap analyze(List<Candle> candles, double currentPrice) {
    if (candles.length < 100) {
      throw Exception('Need at least 100 candles for liquidity analysis');
    }

    // 1. Liquidity highs/lows (swing points where stops cluster)
    final liquidityLevels = _detectLiquidityLevels(candles);

    // 2. Stop clusters (equal highs/lows = stop accumulation)
    final stopClusters = _detectStopClusters(candles);

    // 3. Sweep zones (areas that got swept)
    final sweepZones = _detectSweepZones(candles);

    // 4. Breaker blocks (failed support/resistance that reversed)
    final breakerBlocks = _detectBreakerBlocks(candles);

    // 5. Order blocks (last bullish/bearish candle before strong move)
    final orderBlocks = _detectOrderBlocks(candles);

    // 6. Fair value gaps (price inefficiencies)
    final fvg = _detectFVG(candles);

    // 7. Volume pockets (low volume nodes = fast move zones)
    final volumePockets = _detectVolumePockets(candles);

    // 8. Rejection wicks (strong rejections)
    final rejectionWicks = _detectRejectionWicks(candles);

    // 9. Find nearest liquidity target
    final nearestTarget = _findNearestLiquidityTarget(
      liquidityLevels,
      stopClusters,
      currentPrice,
    );

    return LiquidityMap(
      liquidityHighs: liquidityLevels.where((l) => l.type == 'HIGH').toList(),
      liquidityLows: liquidityLevels.where((l) => l.type == 'LOW').toList(),
      stopClusters: stopClusters,
      sweepZones: sweepZones,
      breakerBlocks: breakerBlocks,
      orderBlocks: orderBlocks,
      fvg: fvg,
      volumePockets: volumePockets,
      rejectionWicks: rejectionWicks,
      nearestTarget: nearestTarget,
    );
  }

  /// Detect liquidity highs and lows (swing points)
  static List<LiquidityLevel> _detectLiquidityLevels(List<Candle> candles) {
    final levels = <LiquidityLevel>[];
    final window = 5;

    for (int i = window; i < candles.length - window; i++) {
      final current = candles[i];

      // Swing high = liquidity high (stops above)
      bool isSwingHigh = true;
      for (int j = i - window; j <= i + window; j++) {
        if (j != i && candles[j].high >= current.high) {
          isSwingHigh = false;
          break;
        }
      }

      if (isSwingHigh) {
        // Count touches (more touches = more liquidity)
        int touches = 1;
        for (int j = 0; j < candles.length; j++) {
          if (j != i && (candles[j].high - current.high).abs() < 1.0) {
            touches++;
          }
        }

        levels.add(LiquidityLevel(
          type: 'HIGH',
          price: current.high,
          touches: touches,
          strength: min(touches * 20, 100),
          index: i,
        ));
      }

      // Swing low = liquidity low (stops below)
      bool isSwingLow = true;
      for (int j = i - window; j <= i + window; j++) {
        if (j != i && candles[j].low <= current.low) {
          isSwingLow = false;
          break;
        }
      }

      if (isSwingLow) {
        int touches = 1;
        for (int j = 0; j < candles.length; j++) {
          if (j != i && (candles[j].low - current.low).abs() < 1.0) {
            touches++;
          }
        }

        levels.add(LiquidityLevel(
          type: 'LOW',
          price: current.low,
          touches: touches,
          strength: min(touches * 20, 100),
          index: i,
        ));
      }
    }

    // Sort by strength
    levels.sort((a, b) => b.strength.compareTo(a.strength));
    return levels.take(10).toList();
  }

  /// Detect stop clusters (equal highs/lows)
  static List<StopCluster> _detectStopClusters(List<Candle> candles) {
    final clusters = <StopCluster>[];
    final tolerance = 1.0; // $1 tolerance

    // Find equal highs
    for (int i = 0; i < candles.length - 10; i++) {
      final current = candles[i];
      int equalCount = 0;

      for (int j = i + 1; j < min(i + 50, candles.length); j++) {
        if ((candles[j].high - current.high).abs() < tolerance) {
          equalCount++;
        }
      }

      if (equalCount >= 2) {
        clusters.add(StopCluster(
          type: 'HIGH',
          price: current.high,
          count: equalCount + 1,
          strength: min((equalCount + 1) * 25, 100),
        ));
      }
    }

    // Find equal lows
    for (int i = 0; i < candles.length - 10; i++) {
      final current = candles[i];
      int equalCount = 0;

      for (int j = i + 1; j < min(i + 50, candles.length); j++) {
        if ((candles[j].low - current.low).abs() < tolerance) {
          equalCount++;
        }
      }

      if (equalCount >= 2) {
        clusters.add(StopCluster(
          type: 'LOW',
          price: current.low,
          count: equalCount + 1,
          strength: min((equalCount + 1) * 25, 100),
        ));
      }
    }

    // Remove duplicates
    final unique = <StopCluster>[];
    for (final cluster in clusters) {
      bool isDuplicate = false;
      for (final existing in unique) {
        if (cluster.type == existing.type &&
            (cluster.price - existing.price).abs() < tolerance) {
          isDuplicate = true;
          break;
        }
      }
      if (!isDuplicate) unique.add(cluster);
    }

    unique.sort((a, b) => b.strength.compareTo(a.strength));
    return unique.take(5).toList();
  }

  /// Detect sweep zones (liquidity that got swept)
  static List<SweepZone> _detectSweepZones(List<Candle> candles) {
    final sweeps = <SweepZone>[];

    // Look for wicks beyond key levels that rejected
    for (int i = 5; i < min(30, candles.length); i++) {
      final candle = candles[i];
      final body = (candle.close - candle.open).abs();
      final upperWick = candle.high - max(candle.open, candle.close);
      final lowerWick = min(candle.open, candle.close) - candle.low;

      // Upper sweep: large upper wick + close below
      if (upperWick > body * 2 && candle.close < candle.open) {
        // Check if it swept a previous high
        bool sweptHigh = false;
        for (int j = i + 1; j < min(i + 20, candles.length); j++) {
          if (candles[j].high < candle.high && candles[j].high > candle.close) {
            sweptHigh = true;
            break;
          }
        }

        if (sweptHigh) {
          sweeps.add(SweepZone(
            type: 'HIGH_SWEEP',
            price: candle.high,
            wickSize: upperWick,
            rejected: true,
            strength: 75,
          ));
        }
      }

      // Lower sweep: large lower wick + close above
      if (lowerWick > body * 2 && candle.close > candle.open) {
        bool sweptLow = false;
        for (int j = i + 1; j < min(i + 20, candles.length); j++) {
          if (candles[j].low > candle.low && candles[j].low < candle.close) {
            sweptLow = true;
            break;
          }
        }

        if (sweptLow) {
          sweeps.add(SweepZone(
            type: 'LOW_SWEEP',
            price: candle.low,
            wickSize: lowerWick,
            rejected: true,
            strength: 75,
          ));
        }
      }
    }

    return sweeps.take(3).toList();
  }

  /// Detect breaker blocks (failed S/R that reversed)
  static List<BreakerBlock> _detectBreakerBlocks(List<Candle> candles) {
    final breakers = <BreakerBlock>[];

    // Look for support that broke and became resistance (bearish breaker)
    // or resistance that broke and became support (bullish breaker)

    for (int i = 20; i < min(100, candles.length); i++) {
      final candle = candles[i];

      // Check if this was a support level
      int supportTouches = 0;
      for (int j = i + 1; j < min(i + 30, candles.length); j++) {
        if ((candles[j].low - candle.low).abs() < 2.0 &&
            candles[j].close > candle.low) {
          supportTouches++;
        }
      }

      if (supportTouches >= 2) {
        // Check if it broke and became resistance
        bool brokeAndReversed = false;
        for (int j = i - 10; j < i; j++) {
          if (j >= 0 && candles[j].close < candle.low) {
            brokeAndReversed = true;
            break;
          }
        }

        if (brokeAndReversed) {
          breakers.add(BreakerBlock(
            type: 'BEARISH_BREAKER',
            price: candle.low,
            strength: 70,
            originalType: 'SUPPORT',
          ));
        }
      }

      // Check if this was a resistance level
      int resistanceTouches = 0;
      for (int j = i + 1; j < min(i + 30, candles.length); j++) {
        if ((candles[j].high - candle.high).abs() < 2.0 &&
            candles[j].close < candle.high) {
          resistanceTouches++;
        }
      }

      if (resistanceTouches >= 2) {
        bool brokeAndReversed = false;
        for (int j = i - 10; j < i; j++) {
          if (j >= 0 && candles[j].close > candle.high) {
            brokeAndReversed = true;
            break;
          }
        }

        if (brokeAndReversed) {
          breakers.add(BreakerBlock(
            type: 'BULLISH_BREAKER',
            price: candle.high,
            strength: 70,
            originalType: 'RESISTANCE',
          ));
        }
      }
    }

    return breakers.take(3).toList();
  }

  /// Detect order blocks (last opposite candle before strong move)
  static List<OrderBlock> _detectOrderBlocks(List<Candle> candles) {
    final blocks = <OrderBlock>[];

    // Look for strong moves and find the last opposite candle before it
    for (int i = 5; i < min(50, candles.length); i++) {
      final move = candles.sublist(max(0, i - 5), i);

      // Calculate move size
      final moveSize = move.first.close - move.last.close;
      final movePercent = (moveSize / move.last.close * 100).abs();

      // Strong bullish move
      if (moveSize > 0 && movePercent > 0.5) {
        // Find last bearish candle before move
        for (int j = i; j < min(i + 10, candles.length); j++) {
          if (candles[j].close < candles[j].open) {
            blocks.add(OrderBlock(
              type: 'BULLISH_OB',
              high: candles[j].high,
              low: candles[j].low,
              strength: min((movePercent * 10).round(), 100),
            ));
            break;
          }
        }
      }

      // Strong bearish move
      if (moveSize < 0 && movePercent > 0.5) {
        // Find last bullish candle before move
        for (int j = i; j < min(i + 10, candles.length); j++) {
          if (candles[j].close > candles[j].open) {
            blocks.add(OrderBlock(
              type: 'BEARISH_OB',
              high: candles[j].high,
              low: candles[j].low,
              strength: min((movePercent * 10).round(), 100),
            ));
            break;
          }
        }
      }
    }

    blocks.sort((a, b) => b.strength.compareTo(a.strength));
    return blocks.take(5).toList();
  }

  /// Detect Fair Value Gaps
  static List<FVG> _detectFVG(List<Candle> candles) {
    final gaps = <FVG>[];

    for (int i = 2; i < min(30, candles.length); i++) {
      final c1 = candles[i];
      final c3 = candles[i - 2];

      // Bullish FVG
      if (c3.low > c1.high) {
        gaps.add(FVG(
          type: 'BULLISH_FVG',
          upper: c3.low,
          lower: c1.high,
          gap: c3.low - c1.high,
        ));
      }

      // Bearish FVG
      if (c3.high < c1.low) {
        gaps.add(FVG(
          type: 'BEARISH_FVG',
          upper: c1.low,
          lower: c3.high,
          gap: c1.low - c3.high,
        ));
      }
    }

    return gaps.take(5).toList();
  }

  /// Detect volume pockets (low volume zones)
  static List<VolumePocket> _detectVolumePockets(List<Candle> candles) {
    final pockets = <VolumePocket>[];
    final avgVolume =
        candles.take(50).map((c) => c.volume).reduce((a, b) => a + b) / 50;

    for (int i = 0; i < min(50, candles.length); i++) {
      if (candles[i].volume < avgVolume * 0.5) {
        pockets.add(VolumePocket(
          high: candles[i].high,
          low: candles[i].low,
          volume: candles[i].volume,
          strength: 60,
        ));
      }
    }

    return pockets.take(3).toList();
  }

  /// Detect rejection wicks
  static List<RejectionWick> _detectRejectionWicks(List<Candle> candles) {
    final wicks = <RejectionWick>[];

    for (final candle in candles.take(20)) {
      final body = (candle.close - candle.open).abs();
      final upperWick = candle.high - max(candle.open, candle.close);
      final lowerWick = min(candle.open, candle.close) - candle.low;

      if (upperWick > body * 2) {
        wicks.add(RejectionWick(
          type: 'UPPER',
          price: candle.high,
          strength: min((upperWick / body * 30).round(), 100),
        ));
      }

      if (lowerWick > body * 2) {
        wicks.add(RejectionWick(
          type: 'LOWER',
          price: candle.low,
          strength: min((lowerWick / body * 30).round(), 100),
        ));
      }
    }

    return wicks.take(3).toList();
  }

  /// Find nearest liquidity target
  static LiquidityTarget? _findNearestLiquidityTarget(
    List<LiquidityLevel> levels,
    List<StopCluster> clusters,
    double currentPrice,
  ) {
    double? nearestAbove;
    double? nearestBelow;
    double minDistAbove = 9999999;
    double minDistBelow = 9999999;

    // Check liquidity levels
    for (final level in levels) {
      final dist = (level.price - currentPrice).abs();
      if (level.price > currentPrice && dist < minDistAbove) {
        minDistAbove = dist;
        nearestAbove = level.price;
      }
      if (level.price < currentPrice && dist < minDistBelow) {
        minDistBelow = dist;
        nearestBelow = level.price;
      }
    }

    // Check stop clusters
    for (final cluster in clusters) {
      final dist = (cluster.price - currentPrice).abs();
      if (cluster.price > currentPrice && dist < minDistAbove) {
        minDistAbove = dist;
        nearestAbove = cluster.price;
      }
      if (cluster.price < currentPrice && dist < minDistBelow) {
        minDistBelow = dist;
        nearestBelow = cluster.price;
      }
    }

    return LiquidityTarget(
      above: nearestAbove,
      below: nearestBelow,
    );
  }
}

// ============================================
// DATA MODELS
// ============================================

class LiquidityLevel {
  final String type;
  final double price;
  final int touches;
  final int strength;
  final int index;

  LiquidityLevel({
    required this.type,
    required this.price,
    required this.touches,
    required this.strength,
    required this.index,
  });
}

class StopCluster {
  final String type;
  final double price;
  final int count;
  final int strength;

  StopCluster({
    required this.type,
    required this.price,
    required this.count,
    required this.strength,
  });
}

class SweepZone {
  final String type;
  final double price;
  final double wickSize;
  final bool rejected;
  final int strength;

  SweepZone({
    required this.type,
    required this.price,
    required this.wickSize,
    required this.rejected,
    required this.strength,
  });
}

class BreakerBlock {
  final String type;
  final double price;
  final int strength;
  final String originalType;

  BreakerBlock({
    required this.type,
    required this.price,
    required this.strength,
    required this.originalType,
  });
}

class OrderBlock {
  final String type;
  final double high;
  final double low;
  final int strength;

  OrderBlock({
    required this.type,
    required this.high,
    required this.low,
    required this.strength,
  });
}

class FVG {
  final String type;
  final double upper;
  final double lower;
  final double gap;

  FVG({
    required this.type,
    required this.upper,
    required this.lower,
    required this.gap,
  });
}

class VolumePocket {
  final double high;
  final double low;
  final double volume;
  final int strength;

  VolumePocket({
    required this.high,
    required this.low,
    required this.volume,
    required this.strength,
  });
}

class RejectionWick {
  final String type;
  final double price;
  final int strength;

  RejectionWick({
    required this.type,
    required this.price,
    required this.strength,
  });
}

class LiquidityTarget {
  final double? above;
  final double? below;

  LiquidityTarget({
    this.above,
    this.below,
  });
}

class LiquidityMap {
  final List<LiquidityLevel> liquidityHighs;
  final List<LiquidityLevel> liquidityLows;
  final List<StopCluster> stopClusters;
  final List<SweepZone> sweepZones;
  final List<BreakerBlock> breakerBlocks;
  final List<OrderBlock> orderBlocks;
  final List<FVG> fvg;
  final List<VolumePocket> volumePockets;
  final List<RejectionWick> rejectionWicks;
  final LiquidityTarget? nearestTarget;

  LiquidityMap({
    required this.liquidityHighs,
    required this.liquidityLows,
    required this.stopClusters,
    required this.sweepZones,
    required this.breakerBlocks,
    required this.orderBlocks,
    required this.fvg,
    required this.volumePockets,
    required this.rejectionWicks,
    this.nearestTarget,
  });
}
