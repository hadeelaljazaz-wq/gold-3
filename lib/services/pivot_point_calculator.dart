/// 👑 Pivot Point Calculator
///
/// حاسبة نقاط البيفوت الاحترافية
///
/// **المنهجية:**
/// - حساب Standard Pivot Points
/// - تصفية المستويات القريبة من السعر الحالي
/// - التحقق من صحة المستويات
///
/// **القواعد:**
/// - المقاومة يجب أن تكون > السعر الحالي
/// - الدعم يجب أن يكون < السعر الحالي
/// - الحد الأدنى للفارق: 15 USD
/// - الحد الأقصى للمسافة: 50 USD

class PivotLevel {
  final String name; // 'R1', 'R2', 'R3', 'S1', 'S2', 'S3', 'PIVOT'
  final double price;
  final String type; // 'RESISTANCE', 'SUPPORT', 'PIVOT'
  final double distanceFromPrice;

  PivotLevel({
    required this.name,
    required this.price,
    required this.type,
    required this.distanceFromPrice,
  });

  @override
  String toString() => '$name: \$${price.toStringAsFixed(2)}';
}

class PivotPointsResult {
  final double pivot;
  final List<PivotLevel> resistances;
  final List<PivotLevel> supports;
  final PivotLevel? nearestResistance;
  final PivotLevel? nearestSupport;
  final DateTime calculatedAt;

  PivotPointsResult({
    required this.pivot,
    required this.resistances,
    required this.supports,
    this.nearestResistance,
    this.nearestSupport,
    required this.calculatedAt,
  });
}

class PivotPointCalculator {
  // ============================================================================
  // CONFIGURATION
  // ============================================================================

  static const double MIN_GAP_USD = 15.0; // Minimum gap between levels
  static const double MAX_DISTANCE_USD =
      50.0; // Maximum distance from current price

  // ============================================================================
  // PUBLIC API
  // ============================================================================

  /// Calculate Standard Pivot Points
  ///
  /// **Parameters:**
  /// - [high]: آخر قمة (High)
  /// - [low]: آخر قاع (Low)
  /// - [close]: آخر إغلاق (Close)
  ///
  /// **Returns:**
  /// خريطة تحتوي على جميع مستويات البيفوت
  static Map<String, double> calculatePivots({
    required double high,
    required double low,
    required double close,
  }) {
    // Validate inputs
    if (high <= 0 || low <= 0 || close <= 0) {
      throw ArgumentError('High, Low, and Close must be positive values');
    }

    if (low > high) {
      throw ArgumentError('Low cannot be greater than High');
    }

    if (close < low || close > high) {
      throw ArgumentError('Close must be between Low and High');
    }

    // Calculate pivot point
    final pivot = (high + low + close) / 3;

    // Calculate resistances
    final r1 = (2 * pivot) - low;
    final r2 = pivot + (high - low);
    final r3 = high + 2 * (pivot - low);

    // Calculate supports
    final s1 = (2 * pivot) - high;
    final s2 = pivot - (high - low);
    final s3 = low - 2 * (high - pivot);

    return {
      'pivot': pivot,
      'r1': r1,
      'r2': r2,
      'r3': r3,
      's1': s1,
      's2': s2,
      's3': s3,
    };
  }

  /// Get Nearest Levels to Current Price with Validation
  ///
  /// **Parameters:**
  /// - [currentPrice]: السعر الحالي
  /// - [pivots]: خريطة مستويات البيفوت من calculatePivots
  ///
  /// **Returns:**
  /// نتيجة كاملة مع المستويات المفلترة والمعتمدة
  static PivotPointsResult getNearestLevels({
    required double currentPrice,
    required Map<String, double> pivots,
  }) {
    if (currentPrice <= 0) {
      throw ArgumentError('Current price must be positive');
    }

    final resistanceLevels = <PivotLevel>[];
    final supportLevels = <PivotLevel>[];

    // Process Resistances (above price)
    final r1 = pivots['r1']!;
    final r2 = pivots['r2']!;
    final r3 = pivots['r3']!;

    // Validate and add R1
    if (_isValidResistance(r1, currentPrice)) {
      resistanceLevels.add(PivotLevel(
        name: 'R1',
        price: r1,
        type: 'RESISTANCE',
        distanceFromPrice: r1 - currentPrice,
      ));
    }

    // Validate and add R2 (must have minimum gap from R1)
    if (_isValidResistance(r2, currentPrice)) {
      if (resistanceLevels.isEmpty ||
          (r2 - resistanceLevels.last.price) >= MIN_GAP_USD) {
        resistanceLevels.add(PivotLevel(
          name: 'R2',
          price: r2,
          type: 'RESISTANCE',
          distanceFromPrice: r2 - currentPrice,
        ));
      }
    }

    // Validate and add R3 (must have minimum gap from R2)
    if (_isValidResistance(r3, currentPrice)) {
      if (resistanceLevels.isEmpty ||
          (r3 - resistanceLevels.last.price) >= MIN_GAP_USD) {
        resistanceLevels.add(PivotLevel(
          name: 'R3',
          price: r3,
          type: 'RESISTANCE',
          distanceFromPrice: r3 - currentPrice,
        ));
      }
    }

    // Process Supports (below price)
    final s1 = pivots['s1']!;
    final s2 = pivots['s2']!;
    final s3 = pivots['s3']!;

    // Validate and add S1
    if (_isValidSupport(s1, currentPrice)) {
      supportLevels.add(PivotLevel(
        name: 'S1',
        price: s1,
        type: 'SUPPORT',
        distanceFromPrice: currentPrice - s1,
      ));
    }

    // Validate and add S2 (must have minimum gap from S1)
    if (_isValidSupport(s2, currentPrice)) {
      if (supportLevels.isEmpty ||
          (supportLevels.last.price - s2) >= MIN_GAP_USD) {
        supportLevels.add(PivotLevel(
          name: 'S2',
          price: s2,
          type: 'SUPPORT',
          distanceFromPrice: currentPrice - s2,
        ));
      }
    }

    // Validate and add S3 (must have minimum gap from S2)
    if (_isValidSupport(s3, currentPrice)) {
      if (supportLevels.isEmpty ||
          (supportLevels.last.price - s3) >= MIN_GAP_USD) {
        supportLevels.add(PivotLevel(
          name: 'S3',
          price: s3,
          type: 'SUPPORT',
          distanceFromPrice: currentPrice - s3,
        ));
      }
    }

    // Sort by distance (nearest first)
    resistanceLevels
        .sort((a, b) => a.distanceFromPrice.compareTo(b.distanceFromPrice));
    supportLevels
        .sort((a, b) => a.distanceFromPrice.compareTo(b.distanceFromPrice));

    // Limit to 3 levels each
    final finalResistances = resistanceLevels.take(3).toList();
    final finalSupports = supportLevels.take(3).toList();

    return PivotPointsResult(
      pivot: pivots['pivot']!,
      resistances: finalResistances,
      supports: finalSupports,
      nearestResistance:
          finalResistances.isNotEmpty ? finalResistances.first : null,
      nearestSupport: finalSupports.isNotEmpty ? finalSupports.first : null,
      calculatedAt: DateTime.now(),
    );
  }

  /// Quick Calculate - All-in-one method
  ///
  /// حساب سريع مع التصفية في خطوة واحدة
  static PivotPointsResult calculate({
    required double high,
    required double low,
    required double close,
    required double currentPrice,
  }) {
    final pivots = calculatePivots(high: high, low: low, close: close);
    return getNearestLevels(currentPrice: currentPrice, pivots: pivots);
  }

  // ============================================================================
  // VALIDATION HELPERS
  // ============================================================================

  /// Check if resistance level is valid
  static bool _isValidResistance(double resistance, double currentPrice) {
    // Must be above current price
    if (resistance <= currentPrice) return false;

    // Must be positive
    if (resistance <= 0) return false;

    // Must be within maximum distance
    final distance = resistance - currentPrice;
    if (distance > MAX_DISTANCE_USD) return false;

    return true;
  }

  /// Check if support level is valid
  static bool _isValidSupport(double support, double currentPrice) {
    // Must be below current price
    if (support >= currentPrice) return false;

    // Must be positive
    if (support <= 0) return false;

    // Must be within maximum distance
    final distance = currentPrice - support;
    if (distance > MAX_DISTANCE_USD) return false;

    return true;
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Find closest level (support or resistance) to current price
  static PivotLevel? findClosestLevel(PivotPointsResult result) {
    final allLevels = [...result.resistances, ...result.supports];
    if (allLevels.isEmpty) return null;

    allLevels
        .sort((a, b) => a.distanceFromPrice.compareTo(b.distanceFromPrice));
    return allLevels.first;
  }

  /// Check if price is near a pivot level
  static bool isPriceNearLevel({
    required double price,
    required PivotLevel level,
    double threshold = 5.0, // USD
  }) {
    return (price - level.price).abs() <= threshold;
  }

  /// Get all valid levels (both resistance and support)
  static List<PivotLevel> getAllValidLevels(PivotPointsResult result) {
    return [...result.resistances, ...result.supports]
      ..sort((a, b) => b.price.compareTo(a.price)); // Sort by price descending
  }

  /// Format levels for display
  static String formatLevelsForDisplay(PivotPointsResult result) {
    final buffer = StringBuffer();
    buffer.writeln('Pivot Point: \$${result.pivot.toStringAsFixed(2)}');
    buffer.writeln('\nResistances:');
    for (final r in result.resistances) {
      buffer.writeln(
          '  ${r.name}: \$${r.price.toStringAsFixed(2)} (+${r.distanceFromPrice.toStringAsFixed(2)})');
    }
    buffer.writeln('\nSupports:');
    for (final s in result.supports) {
      buffer.writeln(
          '  ${s.name}: \$${s.price.toStringAsFixed(2)} (-${s.distanceFromPrice.toStringAsFixed(2)})');
    }
    return buffer.toString();
  }
}
