import 'logger.dart';

/// 📊 Performance Monitor - مراقبة أداء التحليل مع حدود زمنية
class PerformanceMonitor {
  final Map<String, Stopwatch> _timers = {};
  final Map<String, int> _budgets = {};
  final List<PerformanceViolation> _violations = [];

  /// بدء قياس مرحلة
  void startStage(String stageName, {int budgetMs = 1000}) {
    _timers[stageName] = Stopwatch()..start();
    _budgets[stageName] = budgetMs;
  }

  /// إنهاء قياس مرحلة والتحقق من الحد الزمني
  void endStage(String stageName) {
    final timer = _timers[stageName];
    if (timer == null) {
      AppLogger.warn('⚠️ Performance timer not found: $stageName');
      return;
    }

    timer.stop();
    final elapsedMs = timer.elapsedMilliseconds;
    final budgetMs = _budgets[stageName] ?? 1000;

    if (elapsedMs > budgetMs) {
      final violation = PerformanceViolation(
        stage: stageName,
        elapsedMs: elapsedMs,
        budgetMs: budgetMs,
        timestamp: DateTime.now(),
      );
      _violations.add(violation);

      AppLogger.warn(
        '⏱️ Performance Budget Exceeded: $stageName took ${elapsedMs}ms (budget: ${budgetMs}ms)',
      );
    } else {
      AppLogger.info(
        '✅ Performance OK: $stageName took ${elapsedMs}ms (budget: ${budgetMs}ms)',
      );
    }
  }

  /// الحصول على نتائج الأداء
  PerformanceReport getReport() {
    final stageTimings = <String, int>{};
    for (final entry in _timers.entries) {
      stageTimings[entry.key] = entry.value.elapsedMilliseconds;
    }

    final totalMs = stageTimings.values.fold(0, (sum, ms) => sum + ms);

    return PerformanceReport(
      stageTimings: stageTimings,
      totalMs: totalMs,
      violations: List.from(_violations),
    );
  }

  /// إعادة تعيين المراقب
  void reset() {
    _timers.clear();
    _budgets.clear();
    _violations.clear();
  }
}

/// تقرير أداء المرحلة
class PerformanceReport {
  final Map<String, int> stageTimings;
  final int totalMs;
  final List<PerformanceViolation> violations;

  PerformanceReport({
    required this.stageTimings,
    required this.totalMs,
    required this.violations,
  });

  /// هل تجاوز أي مرحلة الحد المسموح؟
  bool get hasViolations => violations.isNotEmpty;

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('📊 Performance Report:');
    buffer.writeln('  Total: ${totalMs}ms');
    for (final entry in stageTimings.entries) {
      buffer.writeln('  - ${entry.key}: ${entry.value}ms');
    }
    if (violations.isNotEmpty) {
      buffer.writeln('  ⚠️ Violations: ${violations.length}');
      for (final v in violations) {
        buffer.writeln('    - ${v.stage}: ${v.elapsedMs}ms > ${v.budgetMs}ms');
      }
    }
    return buffer.toString();
  }
}

/// انتهاك حد الأداء
class PerformanceViolation {
  final String stage;
  final int elapsedMs;
  final int budgetMs;
  final DateTime timestamp;

  PerformanceViolation({
    required this.stage,
    required this.elapsedMs,
    required this.budgetMs,
    required this.timestamp,
  });

  int get overageMs => elapsedMs - budgetMs;
}
