import '../../models/candle.dart';
import '../utils/logger.dart';

/// Utilities to validate and (optionally) fix historical candles
class DataValidation {
  /// Validate and fix a list of candles.
  /// - Ensures chronological order
  /// - Fixes High/Low consistency
  /// - Fills small gaps by linear interpolation or flat-fill
  /// - Drops obviously invalid candles (NaN / zero prices)
  static List<Candle> validateAndFixCandles(
    List<Candle> candles,
    Duration expectedInterval, {
    bool interpolateSmallGaps = true,
    int maxMissingForInterpolation = 2,
  }) {
    if (candles.isEmpty) return [];

    // Sort ascending by time
    final sorted = List<Candle>.from(candles)..sort((a, b) => a.time.compareTo(b.time));

    final fixed = <Candle>[];

    int inserts = 0;
    int fixes = 0;
    int drops = 0;

    for (int i = 0; i < sorted.length; i++) {
      final c = sorted[i];

      // Drop invalid candles
      if (c.open.isNaN || c.high.isNaN || c.low.isNaN || c.close.isNaN) {
        drops++;
        continue;
      }
      if (c.open <= 0 || c.high <= 0 || c.low <= 0 || c.close <= 0) {
        drops++;
        continue;
      }

      // Fix high/low consistency
      double high = c.high;
      double low = c.low;
      if (high < c.open || high < c.close) {
        high = [c.open, c.close, high].reduce((a, b) => a > b ? a : b);
        fixes++;
      }
      if (low > c.open || low > c.close) {
        low = [c.open, c.close, low].reduce((a, b) => a < b ? a : b);
        fixes++;
      }
      if (high < low) {
        // Swap if necessary
        final tmp = high;
        high = low;
        low = tmp;
        fixes++;
      }

      final corrected = Candle(
        time: c.time,
        open: c.open,
        high: high,
        low: low,
        close: c.close,
        volume: c.volume,
      );

      if (fixed.isEmpty) {
        fixed.add(corrected);
        continue;
      }

      final prev = fixed.last;
      final delta = corrected.time.difference(prev.time);

      // If gap is larger than expected interval, fill
      if (delta > expectedInterval * 1.5) {
        final gapCount = (delta.inSeconds / expectedInterval.inSeconds).round() - 1;
        if (interpolateSmallGaps && gapCount <= maxMissingForInterpolation) {
          // Linear interpolation / flat fill using prev close
          for (int k = 1; k <= gapCount; k++) {
            final ts = prev.time.add(expectedInterval * k);
            final open = prev.close;
            final close = prev.close;
            final high = [prev.close, open, close].reduce((a, b) => a > b ? a : b);
            final low = [prev.close, open, close].reduce((a, b) => a < b ? a : b);
            final vol = (prev.volume + corrected.volume) / 2.0;

            fixed.add(Candle(time: ts, open: open, high: high, low: low, close: close, volume: vol));
            inserts++;
          }
        } else {
          // If gap is large, we still continue by adding the corrected candle but note the gap
          AppLogger.warn('DataValidation: large gap of ${delta.inMinutes} minutes between ${prev.time} and ${corrected.time}');
        }
      }

      fixed.add(corrected);
    }

    AppLogger.info('DataValidation: cleaned ${candles.length} -> ${fixed.length} candles (inserts=$inserts, fixes=$fixes, drops=$drops)');
    return fixed;
  }
}
