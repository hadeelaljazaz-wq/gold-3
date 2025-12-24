/// Service-specific Settings

/// Gold Price Service Settings
class GoldPriceSettings {
  const GoldPriceSettings._();

  // Cache Settings
  static const Duration cacheDuration = Duration(seconds: 30);
  static const Duration cacheValidityThreshold = Duration(minutes: 1);

  // API Settings
  static const int maxRetries = 3;
  static const Duration timeout = Duration(seconds: 10);

  // Fallback Settings
  static const double fallbackPriceDeviation = 0.02; // 2% deviation allowed
  static const List<String> apiPriority = [
    'twelve_data',
    'gold_api',
    'metals_api',
  ];

  // Price Validation
  static const double minValidPrice = 1000.0;
  static const double maxValidPrice = 5000.0;
  static const double maxPriceChange = 0.05; // 5% max change
}

/// Historical Data Service Settings
class HistoricalDataSettings {
  const HistoricalDataSettings._();

  // Cache Settings
  static const Duration cacheDuration = Duration(minutes: 5);
  static const double cacheInvalidationThreshold = 0.01; // 1% price change

  // Data Generation Settings
  static const int defaultCandleCount = 500;
  static const int minCandleCount = 100;
  static const int maxCandleCount = 1000;

  // Timeframe Settings
  static const Map<String, Duration> timeframeDurations = {
    '1m': Duration(minutes: 1),
    '5m': Duration(minutes: 5),
    '15m': Duration(minutes: 15),
    '1h': Duration(hours: 1),
    '4h': Duration(hours: 4),
    '1d': Duration(days: 1),
  };

  // Volatility Settings (for synthetic data)
  static const double baseVolatility = 0.002; // 0.2%
  static const double trendStrength = 0.3;
  static const double noiseLevel = 0.5;
  static const double maxTrendDrift = 20.0;

  // Volume Settings
  static const double minVolume = 1000.0;
  static const double maxVolume = 10000.0;

  // Validation
  static const double minCandleRange = 0.0001; // Minimum high-low range
  static const double maxCandleRange = 0.05; // Maximum 5% range
}
