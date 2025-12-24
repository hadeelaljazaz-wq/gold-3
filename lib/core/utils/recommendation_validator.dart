import '../../models/recommendation.dart';
import 'logger.dart';

/// Validation Result
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    required this.errors,
    this.warnings = const [],
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;

  @override
  String toString() {
    final parts = <String>[];
    if (isValid) {
      parts.add('✅ Valid');
    } else {
      parts.add('❌ Invalid');
    }
    if (hasErrors) {
      parts.add('Errors: ${errors.join(", ")}');
    }
    if (hasWarnings) {
      parts.add('Warnings: ${warnings.join(", ")}');
    }
    return parts.join(' | ');
  }
}

/// Professional Recommendation Validator
class RecommendationValidator {
  /// Validate recommendation against current price
  static ValidationResult validate(
    Recommendation rec,
    double currentPrice,
  ) {
    final errors = <String>[];
    final warnings = <String>[];

    AppLogger.debug(
        'Validating ${rec.direction.displayName} recommendation against \$${currentPrice.toStringAsFixed(2)}');

    // Skip validation for NO_TRADE
    if (rec.direction == Direction.noTrade) {
      return ValidationResult(
        isValid: true,
        errors: [],
        warnings: ['No trade recommendation'],
      );
    }

    // Check 1: Entry should be near current price (±5%)
    if (rec.entry != null) {
      final diff = ((rec.entry! - currentPrice).abs() / currentPrice) * 100;

      if (diff > 10) {
        errors.add(
            'Entry very far from current price: ${diff.toStringAsFixed(1)}% (max 10%)');
      } else if (diff > 5) {
        warnings
            .add('Entry far from current price: ${diff.toStringAsFixed(1)}%');
      }

      AppLogger.debug('Entry distance: ${diff.toStringAsFixed(2)}%');
    } else {
      errors.add('Missing entry price');
    }

    // Check 2: Must have stop loss
    if (rec.stopLoss == null) {
      errors.add('Missing stop loss');
    }

    // Check 3: Must have take profit
    if (rec.takeProfit == null) {
      errors.add('Missing take profit');
    }

    // Check 4: For BUY - SL < Entry < TP
    if (rec.direction == Direction.buy) {
      if (rec.stopLoss != null && rec.entry != null) {
        if (rec.stopLoss! >= rec.entry!) {
          errors.add(
              'BUY: Stop Loss (\$${rec.stopLoss!.toStringAsFixed(2)}) must be below Entry (\$${rec.entry!.toStringAsFixed(2)})');
        }
      }

      if (rec.takeProfit != null && rec.entry != null) {
        if (rec.takeProfit! <= rec.entry!) {
          errors.add(
              'BUY: Take Profit (\$${rec.takeProfit!.toStringAsFixed(2)}) must be above Entry (\$${rec.entry!.toStringAsFixed(2)})');
        }
      }
    }

    // Check 5: For SELL - TP < Entry < SL
    if (rec.direction == Direction.sell) {
      if (rec.stopLoss != null && rec.entry != null) {
        if (rec.stopLoss! <= rec.entry!) {
          errors.add(
              'SELL: Stop Loss (\$${rec.stopLoss!.toStringAsFixed(2)}) must be above Entry (\$${rec.entry!.toStringAsFixed(2)})');
        }
      }

      if (rec.takeProfit != null && rec.entry != null) {
        if (rec.takeProfit! >= rec.entry!) {
          errors.add(
              'SELL: Take Profit (\$${rec.takeProfit!.toStringAsFixed(2)}) must be below Entry (\$${rec.entry!.toStringAsFixed(2)})');
        }
      }
    }

    // Check 6: Risk/Reward should be >= 1:1
    if (rec.riskRewardRatio != null) {
      if (rec.riskRewardRatio! < 0.8) {
        errors.add('Poor Risk/Reward: ${rec.rrText} (min 1:1)');
      } else if (rec.riskRewardRatio! < 1.0) {
        warnings.add('Low Risk/Reward: ${rec.rrText}');
      }

      AppLogger.debug('Risk/Reward: ${rec.rrText}');
    }

    // Check 7: SL distance should be reasonable (0.2% - 5%)
    if (rec.entry != null && rec.stopLoss != null) {
      final slDist = ((rec.entry! - rec.stopLoss!).abs() / rec.entry!) * 100;

      if (slDist < 0.1) {
        errors.add('SL too tight: ${slDist.toStringAsFixed(2)}% (min 0.2%)');
      } else if (slDist > 5) {
        errors.add('SL too wide: ${slDist.toStringAsFixed(2)}% (max 5%)');
      } else if (slDist < 0.2) {
        warnings.add('SL very tight: ${slDist.toStringAsFixed(2)}%');
      } else if (slDist > 3) {
        warnings.add('SL wide: ${slDist.toStringAsFixed(2)}%');
      }

      AppLogger.debug('SL distance: ${slDist.toStringAsFixed(2)}%');
    }

    // Check 8: TP distance should be reasonable (0.3% - 10%)
    if (rec.entry != null && rec.takeProfit != null) {
      final tpDist = ((rec.entry! - rec.takeProfit!).abs() / rec.entry!) * 100;

      if (tpDist < 0.2) {
        errors.add('TP too close: ${tpDist.toStringAsFixed(2)}% (min 0.3%)');
      } else if (tpDist > 10) {
        warnings.add('TP very far: ${tpDist.toStringAsFixed(2)}%');
      }

      AppLogger.debug('TP distance: ${tpDist.toStringAsFixed(2)}%');
    }

    // Check 9: Confidence check
    if (rec.confidence == Confidence.low) {
      warnings.add('Low confidence recommendation');
    }

    // Summary
    final isValid = errors.isEmpty;

    if (isValid) {
      AppLogger.success('✓ Recommendation validation passed');
    } else {
      AppLogger.error(
          '✗ Recommendation validation failed: ${errors.join(", ")}',
          null,
          StackTrace.current);
    }

    if (warnings.isNotEmpty) {
      AppLogger.warn('⚠ Validation warnings: ${warnings.join(", ")}');
    }

    return ValidationResult(
      isValid: isValid,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Validate multiple recommendations
  static Map<String, ValidationResult> validateBatch(
    Map<String, Recommendation> recommendations,
    double currentPrice,
  ) {
    final results = <String, ValidationResult>{};

    for (final entry in recommendations.entries) {
      final type = entry.key; // 'SCALP' or 'SWING'
      final rec = entry.value;

      AppLogger.debug('Validating $type recommendation...');
      results[type] = validate(rec, currentPrice);
    }

    return results;
  }

  /// Quick check if recommendation is safe to display
  static bool isSafeToDisplay(Recommendation rec, double currentPrice) {
    final result = validate(rec, currentPrice);
    return result.isValid || result.errors.length <= 1;
  }
}
