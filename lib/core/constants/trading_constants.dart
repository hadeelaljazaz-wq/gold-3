/// 👑 Trading Constants
///
/// ثوابت التداول الشاملة

class TradingConstants {
  const TradingConstants._();

  // ============================================================================
  // TIMEFRAMES
  // ============================================================================

  static const String timeframeM1 = 'M1';
  static const String timeframeM5 = 'M5';
  static const String timeframeM15 = 'M15';
  static const String timeframeH1 = 'H1';
  static const String timeframeH4 = 'H4';
  static const String timeframeD1 = 'D1';

  // ============================================================================
  // RISK MANAGEMENT
  // ============================================================================

  /// نسبة المخاطرة الافتراضية
  static const double defaultRiskPercentage = 1.0; // 1% من رأس المال

  /// أدنى R:R مقبول للسكالبينج
  static const double minScalpRiskReward = 1.5;

  /// أدنى R:R مقبول للسوينج
  static const double minSwingRiskReward = 3.0;

  // ============================================================================
  // CONFIDENCE THRESHOLDS
  // ============================================================================

  /// الحد الأدنى للثقة في السكالبينج
  static const int minScalpConfidence = 50;

  /// الحد الأدنى للثقة في السوينج
  static const int minSwingConfidence = 60;

  // ============================================================================
  // FIBONACCI LEVELS
  // ============================================================================

  static const List<double> fibonacciLevels = [
    0.0,
    0.236,
    0.382,
    0.5,
    0.618,
    0.786,
    1.0,
  ];

  // ============================================================================
  // TECHNICAL INDICATORS
  // ============================================================================

  /// RSI Periods
  static const int rsiPeriod = 14;

  /// RSI Overbought
  static const double rsiOverbought = 70.0;

  /// RSI Oversold
  static const double rsiOversold = 30.0;

  /// MACD Fast
  static const int macdFast = 12;

  /// MACD Slow
  static const int macdSlow = 26;

  /// MACD Signal
  static const int macdSignal = 9;

  /// ATR Period
  static const int atrPeriod = 14;

  // ============================================================================
  // MOVING AVERAGES
  // ============================================================================

  static const int ma20 = 20;
  static const int ma50 = 50;
  static const int ma100 = 100;
  static const int ma200 = 200;
}
