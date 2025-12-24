// 🔥 ZONE DETECTOR
// Detects: Demand/Supply Zones, FVG, Imbalances, Rejection Wicks

import 'dart:math';
import '../../models/candle.dart';

class ZoneDetector {
  /// Strictness settings (can be updated from outside)
  static double minZoneStrength = 30.0; // أقل صرامة
  static double minConfluence = 30.0; // أقل صرامة
  static double minRsiOversold = 35.0; // أوسع نطاق
  static double maxRsiOverbought = 65.0; // أوسع نطاق
  static double minLiquidityStrength = 40.0; // أقل صرامة
  static int minPivotCount = 1; // أقل صرامة

  /// Detect all trading zones
  static ZoneAnalysis analyze(
    List<Candle> candles,
    double currentPrice,
    double rsi, {
    double? ma20,
    double? ma50,
    double? ma100,
    double? ma200,
    double? atr,
    List<double>? supportLevels,
    List<double>? resistanceLevels,
  }) {
    if (candles.length < 50) {
      throw Exception('Need at least 50 candles for zone analysis');
    }

    // 1. Detect demand zones (support)
    final demandZones = _detectDemandZones(candles, currentPrice);

    // 2. Detect supply zones (resistance)
    final supplyZones = _detectSupplyZones(candles, currentPrice);

    // 3. Detect Fair Value Gaps (FVG)
    final fvg = _detectFVG(candles, currentPrice);

    // 4. Detect imbalances
    final imbalances = _detectImbalances(candles);

    // 5. Detect rejection wicks
    final rejectionWicks = _detectRejectionWicks(candles.take(20).toList());

    // 6. Find nearest active zone
    final nearestZone = _findNearestZone(
      demandZones,
      supplyZones,
      currentPrice,
    );

    // 7. Check if at reaction zone (with enhanced confluence calculation)
    final atReactionZone = _isAtReactionZone(
      currentPrice,
      demandZones,
      supplyZones,
      rsi,
      atr: atr,
      ma20: ma20,
      ma50: ma50,
      ma100: ma100,
      ma200: ma200,
      supportLevels: supportLevels,
      resistanceLevels: resistanceLevels,
    );

    return ZoneAnalysis(
      demandZones: demandZones,
      supplyZones: supplyZones,
      fvg: fvg,
      imbalances: imbalances,
      rejectionWicks: rejectionWicks,
      nearestZone: nearestZone,
      atReactionZone: atReactionZone,
    );
  }

  /// Detect demand zones (strong buying areas)
  static List<DemandZone> _detectDemandZones(
    List<Candle> candles,
    double currentPrice,
  ) {
    final zones = <DemandZone>[];

    // Look for strong bullish moves from a base
    // Check last 100 candles for recent zones
    final checkRange = min(100, candles.length - 10);

    // Calculate average volume for volume analysis
    final avgVolume =
        candles.take(50).map((c) => c.volume).reduce((a, b) => a + b) /
            min(50, candles.length);

    for (int i = 10; i < checkRange; i++) {
      final base = candles[i];

      // Look ahead for strong move (next 3-10 candles)
      if (i >= 3) {
        final lookAhead = min(10, candles.length - i);
        for (int j = 3; j < lookAhead; j++) {
          if (i + j >= candles.length) break;

          final futureCandle = candles[i + j];
          final basePrice = base.low;
          final moveSize = futureCandle.close - basePrice;

          if (moveSize > 0) {
            final movePercent = (moveSize / basePrice * 100).abs();

            // Strong move = > 0.3% (more permissive)
            if (movePercent > 0.3) {
              // This is a demand zone
              final zoneHigh = base.high;
              final zoneLow = base.low;

              // Calculate strength based on multiple factors
              int strength = 40; // Base strength

              // 1. Move size (existing)
              if (movePercent > 0.5) strength += 15;
              if (movePercent > 1.0) strength += 20;
              if (movePercent > 1.5) strength += 15;

              // 2. Reaction speed (faster moves = stronger zones)
              if (j <= 5) strength += 10;
              if (j <= 3) strength += 5; // Very fast reaction

              // 3. Volume analysis - higher volume = stronger zone
              final zoneVolume = base.volume;
              if (zoneVolume > avgVolume * 1.5) strength += 10;
              if (zoneVolume > avgVolume * 2.0) strength += 5;

              // 4. Check if untested (price hasn't returned to zone)
              int testCount = 0;
              bool untested = true;
              for (int k = i + j; k < candles.length && k < i + j + 30; k++) {
                if (candles[k].low <= zoneHigh && candles[k].high >= zoneLow) {
                  untested = false;
                  testCount++;
                }
              }

              // Untested zones are stronger, but tested zones can also be strong if they held
              if (untested) {
                strength += 10;
              } else if (testCount <= 2) {
                // Tested 1-2 times and held = still strong
                strength += 5;
              } else if (testCount > 3) {
                // Tested too many times = weaker
                strength -= 10;
              }

              // 5. Zone size - tighter zones are often stronger
              final zoneSize = zoneHigh - zoneLow;
              final zoneSizePercent = (zoneSize / basePrice * 100);
              if (zoneSizePercent < 0.1) strength += 5; // Very tight zone
              if (zoneSizePercent > 0.5) strength -= 5; // Too wide zone

              // 6. Move continuation - check if move continued strongly
              if (i + j + 3 < candles.length) {
                final continuationMove =
                    candles[i + j + 3].close - futureCandle.close;
                if (continuationMove > moveSize * 0.5) {
                  strength += 5; // Strong continuation
                }
              }

              // Only add if zone is above current price (for demand) or very close
              final zoneMid = (zoneHigh + zoneLow) / 2;
              if (zoneMid <= currentPrice * 1.02) {
                // Within 2% below current price
                zones.add(DemandZone(
                  high: zoneHigh,
                  low: zoneLow,
                  strength: min(max(strength, 0), 100), // Clamp between 0-100
                  distance: (currentPrice - zoneMid).abs(),
                  untested: untested,
                  testCount: testCount,
                  reactionSpeed: j,
                  moveSize: moveSize,
                ));
              }

              break; // Found a move, move to next base
            }
          }
        }
      }
    }

    // Remove duplicates (zones that overlap significantly)
    final uniqueZones = <DemandZone>[];
    for (final zone in zones) {
      bool isDuplicate = false;
      for (final existing in uniqueZones) {
        final overlap =
            (zone.high >= existing.low && zone.low <= existing.high);
        if (overlap) {
          isDuplicate = true;
          break;
        }
      }
      if (!isDuplicate) {
        uniqueZones.add(zone);
      }
    }

    // Sort by distance (nearest first), then by strength
    uniqueZones.sort((a, b) {
      final distCompare = a.distance.compareTo(b.distance);
      if (distCompare != 0) return distCompare;
      return b.strength.compareTo(a.strength);
    });

    // Return top 10 (more zones to choose from)
    return uniqueZones.take(10).toList();
  }

  /// Detect supply zones (strong selling areas)
  static List<SupplyZone> _detectSupplyZones(
    List<Candle> candles,
    double currentPrice,
  ) {
    final zones = <SupplyZone>[];

    // Look for strong bearish moves from a top
    // Check last 100 candles for recent zones
    final checkRange = min(100, candles.length - 10);

    // Calculate average volume for volume analysis
    final avgVolume =
        candles.take(50).map((c) => c.volume).reduce((a, b) => a + b) /
            min(50, candles.length);

    for (int i = 10; i < checkRange; i++) {
      final top = candles[i];

      // Look ahead for strong move (next 3-10 candles)
      if (i >= 3) {
        final lookAhead = min(10, candles.length - i);
        for (int j = 3; j < lookAhead; j++) {
          if (i + j >= candles.length) break;

          final futureCandle = candles[i + j];
          final topPrice = top.high;
          final moveSize = topPrice - futureCandle.close;

          if (moveSize > 0) {
            final movePercent = (moveSize / topPrice * 100).abs();

            // Strong move = > 0.3% (more permissive)
            if (movePercent > 0.3) {
              final zoneHigh = top.high;
              final zoneLow = top.low;

              // Calculate strength based on multiple factors
              int strength = 40; // Base strength

              // 1. Move size (existing)
              if (movePercent > 0.5) strength += 15;
              if (movePercent > 1.0) strength += 20;
              if (movePercent > 1.5) strength += 15;

              // 2. Reaction speed (faster moves = stronger zones)
              if (j <= 5) strength += 10;
              if (j <= 3) strength += 5; // Very fast reaction

              // 3. Volume analysis - higher volume = stronger zone
              final zoneVolume = top.volume;
              if (zoneVolume > avgVolume * 1.5) strength += 10;
              if (zoneVolume > avgVolume * 2.0) strength += 5;

              // 4. Check if untested (price hasn't returned to zone)
              int testCount = 0;
              bool untested = true;
              for (int k = i + j; k < candles.length && k < i + j + 30; k++) {
                if (candles[k].high >= zoneLow && candles[k].low <= zoneHigh) {
                  untested = false;
                  testCount++;
                }
              }

              // Untested zones are stronger, but tested zones can also be strong if they held
              if (untested) {
                strength += 10;
              } else if (testCount <= 2) {
                // Tested 1-2 times and held = still strong
                strength += 5;
              } else if (testCount > 3) {
                // Tested too many times = weaker
                strength -= 10;
              }

              // 5. Zone size - tighter zones are often stronger
              final zoneSize = zoneHigh - zoneLow;
              final zoneSizePercent = (zoneSize / topPrice * 100);
              if (zoneSizePercent < 0.1) strength += 5; // Very tight zone
              if (zoneSizePercent > 0.5) strength -= 5; // Too wide zone

              // 6. Move continuation - check if move continued strongly
              if (i + j + 3 < candles.length) {
                final continuationMove =
                    futureCandle.close - candles[i + j + 3].close;
                if (continuationMove > moveSize * 0.5) {
                  strength += 5; // Strong continuation
                }
              }

              // Only add if zone is below current price (for supply) or very close
              final zoneMid = (zoneHigh + zoneLow) / 2;
              if (zoneMid >= currentPrice * 0.98) {
                // Within 2% above current price
                zones.add(SupplyZone(
                  high: zoneHigh,
                  low: zoneLow,
                  strength: min(max(strength, 0), 100), // Clamp between 0-100
                  distance: (currentPrice - zoneMid).abs(),
                  untested: untested,
                  testCount: testCount,
                  reactionSpeed: j,
                  moveSize: moveSize,
                ));
              }

              break; // Found a move, move to next top
            }
          }
        }
      }
    }

    // Remove duplicates (zones that overlap significantly)
    final uniqueZones = <SupplyZone>[];
    for (final zone in zones) {
      bool isDuplicate = false;
      for (final existing in uniqueZones) {
        final overlap =
            (zone.high >= existing.low && zone.low <= existing.high);
        if (overlap) {
          isDuplicate = true;
          break;
        }
      }
      if (!isDuplicate) {
        uniqueZones.add(zone);
      }
    }

    // Sort by distance (nearest first), then by strength
    uniqueZones.sort((a, b) {
      final distCompare = a.distance.compareTo(b.distance);
      if (distCompare != 0) return distCompare;
      return b.strength.compareTo(a.strength);
    });

    // Return top 10 (more zones to choose from)
    return uniqueZones.take(10).toList();
  }

  /// Detect Fair Value Gap (FVG)
  /// FVG = gap between candle bodies = imbalance
  static FVGSignal? _detectFVG(List<Candle> candles, double currentPrice) {
    // Check last 20 candles for FVG
    for (int i = 2; i < min(20, candles.length); i++) {
      final candle1 = candles[i];
      final candle3 = candles[i - 2];

      // Bullish FVG: candle3.low > candle1.high (gap up)
      if (candle3.low > candle1.high) {
        final gap = candle3.low - candle1.high;
        if (gap > 0.01) {
          // minimum 1 cent gap
          return FVGSignal(
            type: 'BULLISH_FVG',
            upper: candle3.low,
            lower: candle1.high,
            gap: gap,
            unfilled: currentPrice < candle3.low,
          );
        }
      }

      // Bearish FVG: candle3.high < candle1.low (gap down)
      if (candle3.high < candle1.low) {
        final gap = candle1.low - candle3.high;
        if (gap > 0.01) {
          return FVGSignal(
            type: 'BEARISH_FVG',
            upper: candle1.low,
            lower: candle3.high,
            gap: gap,
            unfilled: currentPrice > candle1.low,
          );
        }
      }
    }

    return null;
  }

  /// Detect imbalances (volume pockets)
  static List<Imbalance> _detectImbalances(List<Candle> candles) {
    final imbalances = <Imbalance>[];

    // Simple: large body candles = imbalance
    for (int i = 0; i < min(30, candles.length); i++) {
      final candle = candles[i];
      final body = (candle.close - candle.open).abs();
      final range = candle.high - candle.low;

      // Body > 80% of range = strong imbalance
      if (body > range * 0.8) {
        imbalances.add(Imbalance(
          high: max(candle.open, candle.close),
          low: min(candle.open, candle.close),
          type: candle.close > candle.open ? 'BULLISH' : 'BEARISH',
        ));
      }
    }

    return imbalances.take(5).toList();
  }

  /// Detect rejection wicks (strong reversals)
  static List<RejectionWick> _detectRejectionWicks(List<Candle> candles) {
    final wicks = <RejectionWick>[];

    for (final candle in candles) {
      final body = (candle.close - candle.open).abs();
      final upperWick = candle.high - max(candle.open, candle.close);
      final lowerWick = min(candle.open, candle.close) - candle.low;

      // Strong rejection: wick > 2x body
      if (upperWick > body * 2) {
        wicks.add(RejectionWick(
          type: 'REJECTION_HIGH',
          level: candle.high,
          strength: (upperWick / body * 50).round(),
        ));
      }

      if (lowerWick > body * 2) {
        wicks.add(RejectionWick(
          type: 'REJECTION_LOW',
          level: candle.low,
          strength: (lowerWick / body * 50).round(),
        ));
      }
    }

    return wicks.take(3).toList();
  }

  /// Find nearest zone to current price
  static Zone? _findNearestZone(
    List<DemandZone> demandZones,
    List<SupplyZone> supplyZones,
    double currentPrice,
  ) {
    Zone? nearest;
    double minDistance = 9999999;

    for (final zone in demandZones) {
      final mid = (zone.high + zone.low) / 2;
      final dist = (currentPrice - mid).abs();
      if (dist < minDistance) {
        minDistance = dist;
        nearest = Zone(
          type: 'DEMAND',
          high: zone.high,
          low: zone.low,
          strength: zone.strength,
        );
      }
    }

    for (final zone in supplyZones) {
      final mid = (zone.high + zone.low) / 2;
      final dist = (currentPrice - mid).abs();
      if (dist < minDistance) {
        minDistance = dist;
        nearest = Zone(
          type: 'SUPPLY',
          high: zone.high,
          low: zone.low,
          strength: zone.strength,
        );
      }
    }

    return nearest;
  }

  /// Check if at reaction zone - Enhanced with ATR-based distance and improved confluence
  static ReactionZone? _isAtReactionZone(
    double currentPrice,
    List<DemandZone> demandZones,
    List<SupplyZone> supplyZones,
    double rsi, {
    double? atr,
    double? ma20,
    double? ma50,
    double? ma100,
    double? ma200,
    List<double>? supportLevels,
    List<double>? resistanceLevels,
  }) {
    // Use ATR for dynamic distance calculation, fallback to $10 if ATR not provided
    final effectiveAtr = atr ?? 10.0;
    final atrBasedDistance = effectiveAtr * 1.5; // 1.5x ATR for zone extension

    // Check demand zones - ATR-based distance
    for (final zone in demandZones.take(15)) {
      final zoneMid = (zone.high + zone.low) / 2;
      final distanceToZone = (currentPrice - zoneMid).abs();

      // Use ATR-based extension or 1% of price, whichever is larger
      final zoneExtension = max(atrBasedDistance, zone.high * 0.01);

      // Check if price is near zone
      if (currentPrice >= zone.low - zoneExtension &&
          currentPrice <= zone.high + zoneExtension) {
        // Calculate enhanced confluence
        final confluence = _calculateEnhancedConfluence(
          zoneStrength: zone.strength,
          rsi: rsi,
          isDemand: true,
          zoneMid: zoneMid,
          ma20: ma20,
          ma50: ma50,
          ma100: ma100,
          ma200: ma200,
          supportLevels: supportLevels,
          resistanceLevels: resistanceLevels,
          testCount: zone.testCount,
        );

        // Enhanced validation with ATR-based distance - أكثر مرونة
        final isWithinZone =
            currentPrice >= zone.low && currentPrice <= zone.high;
        final isVeryClose = distanceToZone < effectiveAtr * 1.0; // أوسع نطاق
        final hasDecentStrength = zone.strength >= minZoneStrength * 0.5;
        final rsiOversold = rsi <= minRsiOversold + 10; // أوسع
        final highConfluence = confluence >= minConfluence * 0.7;
        final isNearATR = distanceToZone < atrBasedDistance * 2.5;

        final isValid = isWithinZone ||
            isVeryClose ||
            (hasDecentStrength && isNearATR) ||
            rsiOversold ||
            highConfluence ||
            (zone.strength >= minZoneStrength * 0.6);

        if (isValid) {
          return ReactionZone(
            type: 'DEMAND',
            zone: Zone(
              type: 'DEMAND',
              high: zone.high,
              low: zone.low,
              strength: zone.strength,
            ),
            confluence: confluence,
            valid: true,
          );
        }
      }
    }

    // Check supply zones - ATR-based distance
    for (final zone in supplyZones.take(15)) {
      final zoneMid = (zone.high + zone.low) / 2;
      final distanceToZone = (currentPrice - zoneMid).abs();

      final zoneExtension = max(atrBasedDistance, zone.low * 0.01);

      if (currentPrice >= zone.low - zoneExtension &&
          currentPrice <= zone.high + zoneExtension) {
        final confluence = _calculateEnhancedConfluence(
          zoneStrength: zone.strength,
          rsi: rsi,
          isDemand: false,
          zoneMid: zoneMid,
          ma20: ma20,
          ma50: ma50,
          ma100: ma100,
          ma200: ma200,
          supportLevels: supportLevels,
          resistanceLevels: resistanceLevels,
          testCount: zone.testCount,
        );

        final isWithinZone =
            currentPrice >= zone.low && currentPrice <= zone.high;
        final isVeryClose = distanceToZone < effectiveAtr * 1.0; // أوسع
        final hasDecentStrength = zone.strength >= minZoneStrength * 0.5;
        final rsiOverbought = rsi >= maxRsiOverbought - 10; // أوسع
        final highConfluence = confluence >= minConfluence * 0.7;
        final isNearATR = distanceToZone < atrBasedDistance * 2.5;

        final isValid = isWithinZone ||
            isVeryClose ||
            (hasDecentStrength && isNearATR) ||
            rsiOverbought ||
            highConfluence ||
            (zone.strength >= minZoneStrength * 0.6);

        if (isValid) {
          return ReactionZone(
            type: 'SUPPLY',
            zone: Zone(
              type: 'SUPPLY',
              high: zone.high,
              low: zone.low,
              strength: zone.strength,
            ),
            confluence: confluence,
            valid: true,
          );
        }
      }
    }

    // If no zone found, try to find nearest zone and use it if very close (ATR-based)
    if (demandZones.isNotEmpty || supplyZones.isNotEmpty) {
      Zone? nearestZone;
      double minDistance = double.infinity;

      for (final zone in demandZones.take(5)) {
        final zoneMid = (zone.high + zone.low) / 2;
        final distance = (currentPrice - zoneMid).abs();
        if (distance < minDistance) {
          minDistance = distance;
          nearestZone = Zone(
            type: 'DEMAND',
            high: zone.high,
            low: zone.low,
            strength: zone.strength,
          );
        }
      }

      for (final zone in supplyZones.take(5)) {
        final zoneMid = (zone.high + zone.low) / 2;
        final distance = (currentPrice - zoneMid).abs();
        if (distance < minDistance) {
          minDistance = distance;
          nearestZone = Zone(
            type: 'SUPPLY',
            high: zone.high,
            low: zone.low,
            strength: zone.strength,
          );
        }
      }

      // Use ATR-based distance instead of fixed $20
      if (nearestZone != null && minDistance < atrBasedDistance * 2.0) {
        final confluence = _calculateEnhancedConfluence(
          zoneStrength: nearestZone.strength,
          rsi: rsi,
          isDemand: nearestZone.type == 'DEMAND',
          zoneMid: (nearestZone.high + nearestZone.low) / 2,
          ma20: ma20,
          ma50: ma50,
          ma100: ma100,
          ma200: ma200,
          supportLevels: supportLevels,
          resistanceLevels: resistanceLevels,
        );

        return ReactionZone(
          type: nearestZone.type,
          zone: nearestZone,
          confluence: confluence,
          valid: true,
        );
      }
    }

    return null;
  }

  /// Calculate enhanced confluence with additional factors
  static int _calculateEnhancedConfluence({
    required int zoneStrength,
    required double rsi,
    required bool isDemand,
    required double zoneMid,
    double? ma20,
    double? ma50,
    double? ma100,
    double? ma200,
    List<double>? supportLevels,
    List<double>? resistanceLevels,
    int testCount = 0,
  }) {
    int score = zoneStrength;

    // 1. RSI factor (existing logic)
    if (isDemand) {
      if (rsi <= minRsiOversold) {
        score += 30;
      } else if (rsi < minRsiOversold + 10) {
        score += 15;
      } else if (rsi < 50) {
        score += 5;
      }
    } else {
      if (rsi >= maxRsiOverbought) {
        score += 30;
      } else if (rsi > maxRsiOverbought - 10) {
        score += 15;
      } else if (rsi > 50) {
        score += 5;
      }
    }

    // 2. Moving Averages confluence
    if (ma20 != null) {
      final distToMA20 = (zoneMid - ma20).abs() / ma20 * 100;
      if (distToMA20 < 0.2) score += 10; // Very close to MA20
      if (distToMA20 < 0.5) score += 5; // Close to MA20
    }

    if (ma50 != null) {
      final distToMA50 = (zoneMid - ma50).abs() / ma50 * 100;
      if (distToMA50 < 0.2) score += 10; // Very close to MA50
      if (distToMA50 < 0.5) score += 5; // Close to MA50
    }

    if (ma100 != null) {
      final distToMA100 = (zoneMid - ma100).abs() / ma100 * 100;
      if (distToMA100 < 0.2) score += 8; // Very close to MA100
      if (distToMA100 < 0.5) score += 4; // Close to MA100
    }

    if (ma200 != null) {
      final distToMA200 = (zoneMid - ma200).abs() / ma200 * 100;
      if (distToMA200 < 0.2) score += 8; // Very close to MA200
      if (distToMA200 < 0.5) score += 4; // Close to MA200
    }

    // 3. Support/Resistance levels confluence
    if (isDemand && supportLevels != null) {
      for (final support in supportLevels) {
        final dist = (zoneMid - support).abs() / support * 100;
        if (dist < 0.15) {
          score += 12; // Zone aligns with support level
          break;
        }
      }
    }

    if (!isDemand && resistanceLevels != null) {
      for (final resistance in resistanceLevels) {
        final dist = (zoneMid - resistance).abs() / resistance * 100;
        if (dist < 0.15) {
          score += 12; // Zone aligns with resistance level
          break;
        }
      }
    }

    // 4. Test count factor (fewer tests = stronger, but 1-2 tests can be good)
    if (testCount == 0) {
      score += 10; // Untested = strongest
    } else if (testCount == 1 || testCount == 2) {
      score += 5; // Tested 1-2 times and held = still strong
    } else if (testCount > 3) {
      score -= 10; // Tested too many times = weaker
    }

    return min(max(score, 0), 100); // Clamp between 0-100
  }
}

// ============================================
// DATA MODELS
// ============================================

class DemandZone {
  final double high;
  final double low;
  final int strength;
  final double distance;
  final bool untested;
  final int testCount; // Number of times zone was tested
  final int reactionSpeed; // How fast the reaction was (candles)
  final double moveSize; // Size of the move after zone

  DemandZone({
    required this.high,
    required this.low,
    required this.strength,
    required this.distance,
    required this.untested,
    this.testCount = 0,
    this.reactionSpeed = 0,
    this.moveSize = 0.0,
  });
}

class SupplyZone {
  final double high;
  final double low;
  final int strength;
  final double distance;
  final bool untested;
  final int testCount; // Number of times zone was tested
  final int reactionSpeed; // How fast the reaction was (candles)
  final double moveSize; // Size of the move after zone

  SupplyZone({
    required this.high,
    required this.low,
    required this.strength,
    required this.distance,
    required this.untested,
    this.testCount = 0,
    this.reactionSpeed = 0,
    this.moveSize = 0.0,
  });
}

class FVGSignal {
  final String type;
  final double upper;
  final double lower;
  final double gap;
  final bool unfilled;

  FVGSignal({
    required this.type,
    required this.upper,
    required this.lower,
    required this.gap,
    required this.unfilled,
  });
}

class Imbalance {
  final double high;
  final double low;
  final String type;

  Imbalance({
    required this.high,
    required this.low,
    required this.type,
  });
}

class RejectionWick {
  final String type;
  final double level;
  final int strength;

  RejectionWick({
    required this.type,
    required this.level,
    required this.strength,
  });
}

class Zone {
  final String type;
  final double high;
  final double low;
  final int strength;

  Zone({
    required this.type,
    required this.high,
    required this.low,
    required this.strength,
  });
}

class ReactionZone {
  final String type;
  final Zone zone;
  final int confluence;
  final bool valid;

  ReactionZone({
    required this.type,
    required this.zone,
    required this.confluence,
    required this.valid,
  });
}

class ZoneAnalysis {
  final List<DemandZone> demandZones;
  final List<SupplyZone> supplyZones;
  final FVGSignal? fvg;
  final List<Imbalance> imbalances;
  final List<RejectionWick> rejectionWicks;
  final Zone? nearestZone;
  final ReactionZone? atReactionZone;

  ZoneAnalysis({
    required this.demandZones,
    required this.supplyZones,
    this.fvg,
    required this.imbalances,
    required this.rejectionWicks,
    this.nearestZone,
    this.atReactionZone,
  });
}
