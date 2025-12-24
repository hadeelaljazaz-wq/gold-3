/// 👑 Signal Validator
///
/// مدقق الإشارات الاحترافي
///
/// **الهدف:**
/// - التحقق من صحة جميع الإشارات قبل عرضها
/// - منع عرض إشارات خاطئة أو غير منطقية
/// - التأكد من نسب المخاطرة/المكافأة
///
/// **القواعد:**
/// للشراء (BUY):
///   - stop < entry < target
///   - جميع القيم موجبة
///   - RR >= 1.5 (سكالبينج) أو 2.0 (سوينج)
///
/// للبيع (SELL):
///   - target < entry < stop
///   - target موجب
///   - RR >= 1.5 (سكالبينج) أو 2.0 (سوينج)

class SignalValidationResult {
  final bool isValid;
  final String? errorMessage;
  final List<String> warnings;
  final double? calculatedRR;

  SignalValidationResult({
    required this.isValid,
    this.errorMessage,
    this.warnings = const [],
    this.calculatedRR,
  });

  factory SignalValidationResult.valid({double? rr, List<String>? warnings}) {
    return SignalValidationResult(
      isValid: true,
      calculatedRR: rr,
      warnings: warnings ?? [],
    );
  }

  factory SignalValidationResult.invalid(String error,
      {List<String>? warnings}) {
    return SignalValidationResult(
      isValid: false,
      errorMessage: error,
      warnings: warnings ?? [],
    );
  }
}

class SignalValidator {
  // ============================================================================
  // CONFIGURATION
  // ============================================================================

  static const double MIN_RR_SCALP = 1.5; // Minimum Risk/Reward for scalping
  static const double MIN_RR_SWING = 2.0; // Minimum Risk/Reward for swing

  // ============================================================================
  // PUBLIC API
  // ============================================================================

  /// Validate Scalping Signal
  ///
  /// **Parameters:**
  /// - [direction]: 'BUY' أو 'SELL'
  /// - [entry]: سعر الدخول
  /// - [stop]: ستوب لوس
  /// - [target]: هدف الربح
  ///
  /// **Returns:**
  /// نتيجة التحقق مع رسالة الخطأ إن وجدت
  static SignalValidationResult validateScalpSignal({
    required String direction,
    required double entry,
    required double stop,
    required double target,
  }) {
    return _validateSignal(
      direction: direction,
      entry: entry,
      stop: stop,
      target: target,
      minRR: MIN_RR_SCALP,
      signalType: 'SCALP',
    );
  }

  /// Validate Swing Signal
  ///
  /// **Parameters:**
  /// - [direction]: 'BUY' أو 'SELL'
  /// - [entry]: سعر الدخول
  /// - [stop]: ستوب لوس
  /// - [target]: هدف الربح
  ///
  /// **Returns:**
  /// نتيجة التحقق مع رسالة الخطأ إن وجدت
  static SignalValidationResult validateSwingSignal({
    required String direction,
    required double entry,
    required double stop,
    required double target,
  }) {
    return _validateSignal(
      direction: direction,
      entry: entry,
      stop: stop,
      target: target,
      minRR: MIN_RR_SWING,
      signalType: 'SWING',
    );
  }

  // ============================================================================
  // INTERNAL VALIDATION LOGIC
  // ============================================================================

  static SignalValidationResult _validateSignal({
    required String direction,
    required double entry,
    required double stop,
    required double target,
    required double minRR,
    required String signalType,
  }) {
    final warnings = <String>[];

    // ========================================================================
    // STEP 1: Basic Input Validation
    // ========================================================================

    // Check for NaN or Infinity
    if (entry.isNaN || entry.isInfinite) {
      return SignalValidationResult.invalid(
          'Entry price is invalid (NaN or Infinite)');
    }
    if (stop.isNaN || stop.isInfinite) {
      return SignalValidationResult.invalid(
          'Stop loss is invalid (NaN or Infinite)');
    }
    if (target.isNaN || target.isInfinite) {
      return SignalValidationResult.invalid(
          'Target price is invalid (NaN or Infinite)');
    }

    // ========================================================================
    // STEP 2: Direction-Specific Validation
    // ========================================================================

    if (direction.toUpperCase() == 'BUY') {
      return _validateBuySignal(
        entry: entry,
        stop: stop,
        target: target,
        minRR: minRR,
        signalType: signalType,
        warnings: warnings,
      );
    } else if (direction.toUpperCase() == 'SELL') {
      return _validateSellSignal(
        entry: entry,
        stop: stop,
        target: target,
        minRR: minRR,
        signalType: signalType,
        warnings: warnings,
      );
    } else {
      return SignalValidationResult.invalid('Invalid direction: $direction');
    }
  }

  /// Validate BUY Signal
  static SignalValidationResult _validateBuySignal({
    required double entry,
    required double stop,
    required double target,
    required double minRR,
    required String signalType,
    required List<String> warnings,
  }) {
    // Rule 1: All values must be positive
    if (entry <= 0) {
      return SignalValidationResult.invalid(
          'Entry price must be positive (got $entry)');
    }
    if (stop <= 0) {
      return SignalValidationResult.invalid(
          'Stop loss must be positive (got $stop)');
    }
    if (target <= 0) {
      return SignalValidationResult.invalid(
          'Target price must be positive (got $target)');
    }

    // Rule 2: Stop < Entry < Target
    if (stop >= entry) {
      return SignalValidationResult.invalid(
        'For BUY: Stop loss (\$$stop) must be < Entry (\$$entry)',
      );
    }
    if (target <= entry) {
      return SignalValidationResult.invalid(
        'For BUY: Target (\$$target) must be > Entry (\$$entry)',
      );
    }

    // Rule 3: Calculate Risk/Reward
    final risk = entry - stop;
    final reward = target - entry;

    if (risk <= 0) {
      return SignalValidationResult.invalid(
          'Risk must be positive (Entry - Stop)');
    }

    final rr = reward / risk;

    // Rule 4: Check minimum RR
    if (rr < minRR) {
      return SignalValidationResult.invalid(
        'Risk/Reward ratio too low: ${rr.toStringAsFixed(2)} (minimum: ${minRR.toStringAsFixed(1)} for $signalType)',
      );
    }

    // Warnings
    if (risk < 5.0) {
      warnings.add('Very tight stop loss: \$${risk.toStringAsFixed(2)}');
    }
    if (risk > 50.0) {
      warnings.add('Very wide stop loss: \$${risk.toStringAsFixed(2)}');
    }
    if (rr > 10.0) {
      warnings.add(
          'Unusually high R:R ratio: ${rr.toStringAsFixed(2)} - verify target');
    }

    return SignalValidationResult.valid(rr: rr, warnings: warnings);
  }

  /// Validate SELL Signal
  static SignalValidationResult _validateSellSignal({
    required double entry,
    required double stop,
    required double target,
    required double minRR,
    required String signalType,
    required List<String> warnings,
  }) {
    // Rule 1: Entry and Stop must be positive (Target can be lower but positive for gold)
    if (entry <= 0) {
      return SignalValidationResult.invalid(
          'Entry price must be positive (got $entry)');
    }
    if (stop <= 0) {
      return SignalValidationResult.invalid(
          'Stop loss must be positive (got $stop)');
    }
    if (target <= 0) {
      return SignalValidationResult.invalid(
          'Target price must be positive (got $target)');
    }

    // Rule 2: Target < Entry < Stop
    if (stop <= entry) {
      return SignalValidationResult.invalid(
        'For SELL: Stop loss (\$$stop) must be > Entry (\$$entry)',
      );
    }
    if (target >= entry) {
      return SignalValidationResult.invalid(
        'For SELL: Target (\$$target) must be < Entry (\$$entry)',
      );
    }

    // Rule 3: Calculate Risk/Reward
    final risk = stop - entry;
    final reward = entry - target;

    if (risk <= 0) {
      return SignalValidationResult.invalid(
          'Risk must be positive (Stop - Entry)');
    }
    if (reward <= 0) {
      return SignalValidationResult.invalid(
          'Reward must be positive (Entry - Target)');
    }

    final rr = reward / risk;

    // Rule 4: Check minimum RR
    if (rr < minRR) {
      return SignalValidationResult.invalid(
        'Risk/Reward ratio too low: ${rr.toStringAsFixed(2)} (minimum: ${minRR.toStringAsFixed(1)} for $signalType)',
      );
    }

    // Warnings
    if (risk < 5.0) {
      warnings.add('Very tight stop loss: \$${risk.toStringAsFixed(2)}');
    }
    if (risk > 50.0) {
      warnings.add('Very wide stop loss: \$${risk.toStringAsFixed(2)}');
    }
    if (rr > 10.0) {
      warnings.add(
          'Unusually high R:R ratio: ${rr.toStringAsFixed(2)} - verify target');
    }

    return SignalValidationResult.valid(rr: rr, warnings: warnings);
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Quick validation check (returns boolean only)
  static bool isValidScalpSignal({
    required String direction,
    required double entry,
    required double stop,
    required double target,
  }) {
    final result = validateScalpSignal(
      direction: direction,
      entry: entry,
      stop: stop,
      target: target,
    );
    return result.isValid;
  }

  /// Quick validation check for swing
  static bool isValidSwingSignal({
    required String direction,
    required double entry,
    required double stop,
    required double target,
  }) {
    final result = validateSwingSignal(
      direction: direction,
      entry: entry,
      stop: stop,
      target: target,
    );
    return result.isValid;
  }

  /// Calculate Risk/Reward Ratio
  static double calculateRR({
    required String direction,
    required double entry,
    required double stop,
    required double target,
  }) {
    if (direction.toUpperCase() == 'BUY') {
      final risk = entry - stop;
      final reward = target - entry;
      if (risk <= 0) return 0;
      return reward / risk;
    } else {
      final risk = stop - entry;
      final reward = entry - target;
      if (risk <= 0) return 0;
      return reward / risk;
    }
  }

  /// Get human-readable error message
  static String getErrorMessage(SignalValidationResult result) {
    if (result.isValid) return 'Signal is valid';
    return result.errorMessage ?? 'Unknown validation error';
  }

  /// Check if signal has warnings
  static bool hasWarnings(SignalValidationResult result) {
    return result.warnings.isNotEmpty;
  }
}
