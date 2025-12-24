class MarketMetricsModel {
  final double volatility; // %
  final double momentum; // %
  final double volume;
  final String trend; // UP, DOWN, SIDEWAYS

  MarketMetricsModel({
    required this.volatility,
    required this.momentum,
    required this.volume,
    required this.trend,
  });
}
