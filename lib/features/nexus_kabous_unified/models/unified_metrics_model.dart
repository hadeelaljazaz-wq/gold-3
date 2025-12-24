/// Unified Metrics Model (NEXUS + KABOUS)
class UnifiedMetricsModel {
  final double volatility; // %
  final double momentum; // %
  final double volume;
  final String trend; // UP, DOWN, SIDEWAYS
  final double nexusScore; // 0-10
  final double kabousMLScore; // 0-100
  final String agreement; // AGREE, DISAGREE, PARTIAL

  UnifiedMetricsModel({
    required this.volatility,
    required this.momentum,
    required this.volume,
    required this.trend,
    required this.nexusScore,
    required this.kabousMLScore,
    required this.agreement,
  });
}
