/// 🔥 KABOUS QUANTUM - ML Confidence Predictor V2.0
/// Enhanced version with 70-85% confidence
/// Author: Gold Nightmare Pro Team

import 'dart:math' as math;
import '../models/market_models.dart';

/// Market Features for ML Analysis
class MarketFeatures {
  // Price Action
  final double trendStrength; // -1 to 1
  final double volatility; // 0 to 1
  final double momentum; // -1 to 1

  // Volume Analysis
  final double volumeProfile; // 0 to 1
  final double buyPressure; // 0 to 1

  // Technical Confluence
  final double rsiScore; // 0 to 1
  final double macdScore; // 0 to 1
  final double supportResistance; // 0 to 1

  // Market Structure
  final double marketRegime; // 0=ranging, 1=trending
  final double liquidity; // 0 to 1

  // Multi-Timeframe
  final double higherTFAlignment; // 0 to 1
  final double lowerTFAlignment; // 0 to 1

  // Risk Assessment
  final double riskLevel; // 0 to 1

  MarketFeatures({
    required this.trendStrength,
    required this.volatility,
    required this.momentum,
    required this.volumeProfile,
    required this.buyPressure,
    required this.rsiScore,
    required this.macdScore,
    required this.supportResistance,
    required this.marketRegime,
    required this.liquidity,
    required this.higherTFAlignment,
    required this.lowerTFAlignment,
    required this.riskLevel,
  });

  /// Calculate overall market quality score
  double get qualityScore {
    double sum = 0.0;
    sum += trendStrength.abs() * 0.15; // 15% weight
    sum += (1 - volatility) * 0.10; // 10% weight (prefer low vol)
    sum += momentum.abs() * 0.12; // 12% weight
    sum += volumeProfile * 0.08; // 8% weight
    sum += buyPressure * 0.08; // 8% weight
    sum += rsiScore * 0.08; // 8% weight
    sum += macdScore * 0.08; // 8% weight
    sum += supportResistance * 0.10; // 10% weight
    sum += marketRegime * 0.08; // 8% weight
    sum += liquidity * 0.05; // 5% weight
    sum += higherTFAlignment * 0.04; // 4% weight
    sum += lowerTFAlignment * 0.03; // 3% weight
    sum += (1 - riskLevel) * 0.01; // 1% weight
    return sum.clamp(0.0, 1.0);
  }
}

/// Dynamic Engine Weights
class MLEngineWeights {
  final double goldenNightmare;
  final double quantum;
  final double royal;
  final double nexus;

  MLEngineWeights({
    required this.goldenNightmare,
    required this.quantum,
    required this.royal,
    required this.nexus,
  });

  /// Normalize weights to sum = 1.0
  MLEngineWeights normalize() {
    final sum = goldenNightmare + quantum + royal + nexus;
    if (sum == 0) return this;

    return MLEngineWeights(
      goldenNightmare: goldenNightmare / sum,
      quantum: quantum / sum,
      royal: royal / sum,
      nexus: nexus / sum,
    );
  }
}

/// ML Confidence Predictor - Enhanced V2.0
class MLConfidencePredictor {
  /// Extract features from market data
  static MarketFeatures extractFeatures({
    required double currentPrice,
    required TechnicalIndicators indicators,
    required DateTime currentTime,
  }) {
    // Convert TechnicalIndicators to Map for compatibility
    final indicatorsMap = {
      'rsi': indicators.rsi,
      'macd': indicators.macd,
      'macd_signal': indicators.macdSignal,
      'support': currentPrice - (indicators.atr * 2),
      'resistance': currentPrice + (indicators.atr * 2),
      'momentum': indicators.macdHistogram / currentPrice,
    };

    // Generate synthetic candles based on indicators
    final candles = _generateSyntheticCandles(currentPrice, indicators);
    // Price Action Analysis
    final trendStrength = _calculateTrendStrength(candles);
    final volatility = _calculateVolatility(candles);
    final momentum = _calculateMomentum(candles);

    // Volume Analysis
    final volumeProfile = _calculateVolumeProfile(candles);
    final buyPressure = _calculateBuyPressure(candles);

    // Technical Indicators
    final rsiScore = _evaluateRSI(indicatorsMap['rsi'] ?? 50.0);
    final macdScore = _evaluateMACD(
      indicatorsMap['macd'] ?? 0.0,
      indicatorsMap['macd_signal'] ?? 0.0,
    );
    final srScore = _evaluateSupportResistance(
      currentPrice,
      indicatorsMap['support'] ?? currentPrice - 50,
      indicatorsMap['resistance'] ?? currentPrice + 50,
    );

    // Market Structure
    final marketRegime = _detectMarketRegime(candles);
    final liquidity = _calculateLiquidity(candles);

    // Multi-Timeframe
    final higherTF = _calculateHigherTFAlignment(indicatorsMap);
    final lowerTF = _calculateLowerTFAlignment(indicatorsMap);

    // Risk Assessment
    final riskLevel = _calculateRiskLevel(volatility, liquidity, marketRegime);

    return MarketFeatures(
      trendStrength: trendStrength,
      volatility: volatility,
      momentum: momentum,
      volumeProfile: volumeProfile,
      buyPressure: buyPressure,
      rsiScore: rsiScore,
      macdScore: macdScore,
      supportResistance: srScore,
      marketRegime: marketRegime,
      liquidity: liquidity,
      higherTFAlignment: higherTF,
      lowerTFAlignment: lowerTF,
      riskLevel: riskLevel,
    );
  }

  /// Predict optimal engine weights based on market conditions
  static MLEngineWeights predictWeights(MarketFeatures features) {
    double gn = 0.40; // Default Golden Nightmare
    double qt = 0.25; // Default Quantum
    double ry = 0.20; // Default Royal
    double nx = 0.15; // Default NEXUS

    // ═══════════════════════════════════════════════════
    // 📊 ENHANCED RULES - 15 Smart Conditions
    // ═══════════════════════════════════════════════════

    // 🎯 Rule 1: Strong Trending Market
    if (features.trendStrength.abs() > 0.7 && features.marketRegime > 0.7) {
      gn = 0.50; // Increase Golden Nightmare (trend follower)
      qt = 0.20;
      ry = 0.20;
      nx = 0.10;
    }

    // 🎯 Rule 2: High Volatility + Strong Momentum
    else if (features.volatility > 0.6 && features.momentum.abs() > 0.6) {
      qt = 0.40; // Increase Quantum (volatility trader)
      gn = 0.30;
      ry = 0.20;
      nx = 0.10;
    }

    // 🎯 Rule 3: Low Volatility + Ranging Market
    else if (features.volatility < 0.3 && features.marketRegime < 0.4) {
      ry = 0.45; // Increase Royal (range trader)
      gn = 0.25;
      qt = 0.20;
      nx = 0.10;
    }

    // 🎯 Rule 4: Multi-Timeframe Alignment (Strong Confluence)
    else if (features.higherTFAlignment > 0.8 &&
        features.lowerTFAlignment > 0.7) {
      gn = 0.55; // Very high confidence in trend
      qt = 0.20;
      ry = 0.15;
      nx = 0.10;
    }

    // 🎯 Rule 5: Near Support/Resistance + High Volume
    else if (features.supportResistance > 0.8 && features.volumeProfile > 0.7) {
      nx = 0.35; // NEXUS excels at key levels
      gn = 0.35;
      qt = 0.20;
      ry = 0.10;
    }

    // 🎯 Rule 6: Strong Buy Pressure + Momentum
    else if (features.buyPressure > 0.7 && features.momentum > 0.6) {
      gn = 0.45; // Trend continuation
      qt = 0.30;
      ry = 0.15;
      nx = 0.10;
    }

    // 🎯 Rule 7: RSI Oversold + MACD Bullish Divergence
    else if (features.rsiScore > 0.8 && features.macdScore > 0.7) {
      ry = 0.40; // Reversal play
      qt = 0.30;
      gn = 0.20;
      nx = 0.10;
    }

    // 🎯 Rule 8: High Liquidity + Low Risk
    else if (features.liquidity > 0.8 && features.riskLevel < 0.3) {
      gn = 0.45; // Safe trending
      ry = 0.25;
      qt = 0.20;
      nx = 0.10;
    }

    // 🎯 Rule 9: Low Liquidity + High Risk
    else if (features.liquidity < 0.3 && features.riskLevel > 0.7) {
      nx = 0.40; // Conservative approach
      ry = 0.30;
      qt = 0.20;
      gn = 0.10;
    }

    // 🎯 Rule 10: Momentum Reversal Signal
    else if (features.momentum.abs() > 0.7 &&
        features.trendStrength.abs() < 0.3) {
      qt = 0.45; // Quantum catches reversals
      ry = 0.25;
      gn = 0.20;
      nx = 0.10;
    }

    // 🎯 Rule 11: Perfect Storm (All Conditions Aligned)
    else if (features.qualityScore > 0.85) {
      gn = 0.50; // Maximum confidence
      qt = 0.25;
      ry = 0.15;
      nx = 0.10;
    }

    // 🎯 Rule 12: Weak Market Conditions
    else if (features.qualityScore < 0.35) {
      nx = 0.40; // Most conservative
      ry = 0.30;
      qt = 0.20;
      gn = 0.10;
    }

    // 🎯 Rule 13: Volume Surge + Price Breakout
    else if (features.volumeProfile > 0.8 && features.momentum.abs() > 0.7) {
      gn = 0.50; // Strong breakout
      qt = 0.30;
      ry = 0.10;
      nx = 0.10;
    }

    // 🎯 Rule 14: Consolidation Before Breakout
    else if (features.volatility < 0.25 && features.liquidity > 0.7) {
      ry = 0.40; // Wait for breakout
      nx = 0.30;
      qt = 0.20;
      gn = 0.10;
    }

    // 🎯 Rule 15: Mixed Signals (Uncertainty)
    else if (_hasMixedSignals(features)) {
      gn = 0.30; // Balanced approach
      qt = 0.25;
      ry = 0.25;
      nx = 0.20;
    }

    return MLEngineWeights(
      goldenNightmare: gn,
      quantum: qt,
      royal: ry,
      nexus: nx,
    ).normalize();
  }

  /// Evaluate signal quality and adjust confidence
  static double evaluateSignalQuality({
    required MarketFeatures features,
    required String direction,
    required double baseConfidence,
  }) {
    double confidence = baseConfidence;

    // ═══════════════════════════════════════════════════
    // 🎯 CONFIDENCE BOOSTERS
    // ═══════════════════════════════════════════════════

    // Booster 1: High Quality Market
    if (features.qualityScore > 0.7) {
      confidence *= 1.25; // +25%
    }

    // Booster 2: Multi-Timeframe Confirmation
    if (features.higherTFAlignment > 0.7 && features.lowerTFAlignment > 0.6) {
      confidence *= 1.20; // +20%
    }

    // Booster 3: Strong Directional Bias
    final directionScore =
        direction == 'BUY' ? features.momentum : -features.momentum;
    if (directionScore > 0.6) {
      confidence *= 1.15; // +15%
    }

    // Booster 4: Near Key Level
    if (features.supportResistance > 0.75) {
      confidence *= 1.12; // +12%
    }

    // Booster 5: High Volume Confirmation
    if (features.volumeProfile > 0.7) {
      confidence *= 1.10; // +10%
    }

    // Booster 6: Low Risk Environment
    if (features.riskLevel < 0.3) {
      confidence *= 1.08; // +8%
    }

    // Booster 7: Strong Buy/Sell Pressure
    if (direction == 'BUY' && features.buyPressure > 0.7) {
      confidence *= 1.10; // +10%
    } else if (direction == 'SELL' && features.buyPressure < 0.3) {
      confidence *= 1.10; // +10%
    }

    // Booster 8: RSI Extreme
    if (features.rsiScore > 0.8) {
      confidence *= 1.08; // +8%
    }

    // ═══════════════════════════════════════════════════
    // 🎯 CONFIDENCE PENALTIES
    // ═══════════════════════════════════════════════════

    // Penalty 1: High Volatility
    if (features.volatility > 0.7) {
      confidence *= 0.90; // -10%
    }

    // Penalty 2: Low Liquidity
    if (features.liquidity < 0.4) {
      confidence *= 0.92; // -8%
    }

    // Penalty 3: Mixed Signals
    if (_hasMixedSignals(features)) {
      confidence *= 0.85; // -15%
    }

    // Penalty 4: High Risk
    if (features.riskLevel > 0.7) {
      confidence *= 0.88; // -12%
    }

    // Penalty 5: Weak Trend
    if (features.trendStrength.abs() < 0.3) {
      confidence *= 0.93; // -7%
    }

    // ═══════════════════════════════════════════════════
    // 🎯 FINAL ADJUSTMENTS
    // ═══════════════════════════════════════════════════

    // Ensure minimum confidence
    if (confidence < 50.0) {
      confidence = 50.0 + (features.qualityScore * 15); // Minimum 50-65%
    }

    // Cap maximum confidence
    confidence = confidence.clamp(50.0, 95.0);

    return confidence;
  }

  /// Get recommended action based on confidence
  static String getRecommendedAction(double confidence) {
    if (confidence >= 75.0) return 'EXECUTE';
    if (confidence >= 65.0) return 'MONITOR';
    if (confidence >= 55.0) return 'WAIT';
    return 'SKIP';
  }

  // ═══════════════════════════════════════════════════
  // 📊 PRIVATE HELPER METHODS
  // ═══════════════════════════════════════════════════

  static double _calculateTrendStrength(List<Map<String, dynamic>> candles) {
    if (candles.length < 20) return 0.0;

    final closes = candles.map((c) => (c['close'] as num).toDouble()).toList();
    final sma20 =
        closes.sublist(closes.length - 20).reduce((a, b) => a + b) / 20;
    final currentPrice = closes.last;

    // Calculate trend slope
    double sum = 0;
    for (int i = closes.length - 20; i < closes.length; i++) {
      sum += closes[i] - sma20;
    }

    final slope = sum / 20 / sma20;

    // Use current price in trend evaluation
    return (slope * (currentPrice / sma20)).clamp(-1.0, 1.0);
  }

  static double _calculateVolatility(List<Map<String, dynamic>> candles) {
    if (candles.length < 20) return 0.5;

    final recentCandles = candles.sublist(math.max(0, candles.length - 20));
    final ranges = recentCandles.map((c) {
      final high = (c['high'] as num).toDouble();
      final low = (c['low'] as num).toDouble();
      return high - low;
    }).toList();

    final avgRange = ranges.reduce((a, b) => a + b) / ranges.length;
    final currentPrice = (candles.last['close'] as num).toDouble();

    return (avgRange / currentPrice * 100).clamp(0.0, 1.0);
  }

  static double _calculateMomentum(List<Map<String, dynamic>> candles) {
    if (candles.length < 10) return 0.0;

    final closes = candles.map((c) => (c['close'] as num).toDouble()).toList();
    final roc =
        (closes.last - closes[closes.length - 10]) / closes[closes.length - 10];

    return (roc * 10).clamp(-1.0, 1.0);
  }

  static double _calculateVolumeProfile(List<Map<String, dynamic>> candles) {
    if (candles.length < 20) return 0.5;

    final recentCandles = candles.sublist(math.max(0, candles.length - 20));
    final volumes = recentCandles
        .map((c) => (c['volume'] as num?)?.toDouble() ?? 1000000)
        .toList();

    final avgVolume = volumes.reduce((a, b) => a + b) / volumes.length;
    final currentVolume = volumes.last;

    return (currentVolume / avgVolume).clamp(0.0, 1.0);
  }

  static double _calculateBuyPressure(List<Map<String, dynamic>> candles) {
    if (candles.isEmpty) return 0.5;

    int bullish = 0;
    for (var candle in candles.sublist(math.max(0, candles.length - 10))) {
      final close = (candle['close'] as num).toDouble();
      final open = (candle['open'] as num).toDouble();
      if (close > open) bullish++;
    }

    return (bullish / 10.0).clamp(0.0, 1.0);
  }

  static double _evaluateRSI(double rsi) {
    if (rsi < 30) return 0.9; // Oversold - strong signal
    if (rsi < 40) return 0.7;
    if (rsi > 70) return 0.9; // Overbought - strong signal
    if (rsi > 60) return 0.7;
    return 0.5; // Neutral
  }

  static double _evaluateMACD(double macd, double signal) {
    final diff = macd - signal;
    if (diff.abs() < 0.1) return 0.3; // Weak signal
    if (diff.abs() < 0.5) return 0.6;
    return 0.9; // Strong signal
  }

  static double _evaluateSupportResistance(
      double price, double support, double resistance) {
    final range = resistance - support;
    if (range == 0) return 0.5;

    final distToSupport = (price - support).abs() / range;
    final distToResistance = (price - resistance).abs() / range;

    final minDist = math.min(distToSupport, distToResistance);
    return (1 - minDist).clamp(0.0, 1.0);
  }

  static double _detectMarketRegime(List<Map<String, dynamic>> candles) {
    if (candles.length < 50) return 0.5;

    final closes = candles.map((c) => (c['close'] as num).toDouble()).toList();
    final sma50 =
        closes.sublist(closes.length - 50).reduce((a, b) => a + b) / 50;

    // Calculate price deviation from SMA
    double deviation = 0;
    for (int i = closes.length - 20; i < closes.length; i++) {
      deviation += (closes[i] - sma50).abs();
    }
    deviation /= 20;

    // High deviation = trending, low = ranging
    return (deviation / sma50 * 100).clamp(0.0, 1.0);
  }

  static double _calculateLiquidity(List<Map<String, dynamic>> candles) {
    if (candles.isEmpty) return 0.5;

    final recentCandles = candles.sublist(math.max(0, candles.length - 10));
    final volumes = recentCandles
        .map((c) => (c['volume'] as num?)?.toDouble() ?? 1000000)
        .toList();

    final avgVolume = volumes.reduce((a, b) => a + b) / volumes.length;
    final threshold = 1500000; // Adjust based on XAUUSD typical volume

    return (avgVolume / threshold).clamp(0.0, 1.0);
  }

  static double _calculateHigherTFAlignment(Map<String, dynamic> indicators) {
    // Simulate higher timeframe alignment
    final rsi = indicators['rsi'] ?? 50.0;
    final macd = indicators['macd'] ?? 0.0;

    double score = 0.5;
    if ((rsi > 50 && macd > 0) || (rsi < 50 && macd < 0)) {
      score = 0.8; // Aligned
    }

    return score;
  }

  static double _calculateLowerTFAlignment(Map<String, dynamic> indicators) {
    // Simulate lower timeframe alignment
    final momentum = indicators['momentum'] ?? 0.0;
    return (0.5 + momentum * 0.3).clamp(0.0, 1.0);
  }

  static double _calculateRiskLevel(
      double volatility, double liquidity, double regime) {
    // High risk = high volatility + low liquidity + uncertain regime
    return ((volatility * 0.5) + ((1 - liquidity) * 0.3) + ((1 - regime) * 0.2))
        .clamp(0.0, 1.0);
  }

  static bool _hasMixedSignals(MarketFeatures features) {
    // Check for conflicting signals
    final bullish = features.momentum > 0 && features.buyPressure > 0.5;
    final bearish = features.momentum < 0 && features.buyPressure < 0.5;

    return !(bullish || bearish); // Neither clearly bullish nor bearish
  }

  /// Generate synthetic candles from current price and indicators
  static List<Map<String, dynamic>> _generateSyntheticCandles(
    double currentPrice,
    TechnicalIndicators indicators,
  ) {
    final candles = <Map<String, dynamic>>[];
    final atr = indicators.atr;

    // Generate last 50 candles based on price movement
    double price = currentPrice - (atr * 25); // Start from lower

    for (int i = 0; i < 50; i++) {
      // Random walk with ATR-based volatility
      final change = (math.Random().nextDouble() - 0.5) * atr * 2;
      final open = price;
      final close = price + change;
      final high = math.max(open, close) + (atr * 0.3);
      final low = math.min(open, close) - (atr * 0.3);
      final volume = 1000000 + (math.Random().nextDouble() * 500000);

      candles.add({
        'open': open,
        'high': high,
        'low': low,
        'close': close,
        'volume': volume,
      });

      price = close;
    }

    // Adjust last candle to match current price
    candles.last['close'] = currentPrice;
    candles.last['high'] = currentPrice + (atr * 0.2);
    candles.last['low'] = currentPrice - (atr * 0.2);

    return candles;
  }
}
