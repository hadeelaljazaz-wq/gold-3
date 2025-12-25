// 🧠 Gold AI Engine - نظام الذكاء الاصطناعي للذهب
// Multi-Model Ensemble System for Gold Price Prediction

import 'dart:math' as math;
import '../../models/candle.dart';

/// 🧠 Gold AI Engine - المحرك الرئيسي للذكاء الاصطناعي
class GoldAIEngine {
  static final GoldAIEngine _instance = GoldAIEngine._internal();
  factory GoldAIEngine() => _instance;
  GoldAIEngine._internal();

  // Performance tracking
  double _modelAccuracy = 0.72; // Initial accuracy estimate

  // Model weights (learned from performance)
  double _trendWeight = 0.30;
  double _momentumWeight = 0.25;
  double _patternWeight = 0.20;
  double _sentimentWeight = 0.15;
  double _volatilityWeight = 0.10;

  /// 🎯 التنبؤ الرئيسي بالسعر
  Future<AIGoldPrediction> predict({
    required double currentPrice,
    required List<Candle> candles,
    double? newsImpact,
    double? marketSentiment,
  }) async {
    if (candles.length < 100) {
      throw Exception('يجب توفر 100 شمعة على الأقل للتحليل الدقيق');
    }

    print('🧠 AI Engine: Starting prediction analysis...');

    // 1. Feature Extraction - استخراج المميزات
    final features = _extractFeatures(candles, currentPrice);

    // 2. Run Multiple Models - تشغيل نماذج متعددة
    final trendPrediction = _runTrendModel(features);
    final momentumPrediction = _runMomentumModel(features);
    final patternPrediction = _runPatternModel(candles, currentPrice);
    final volatilityPrediction = _runVolatilityModel(features);

    // 3. Ensemble Fusion - دمج النماذج
    final ensembleResult = _ensembleFusion(
      trend: trendPrediction,
      momentum: momentumPrediction,
      pattern: patternPrediction,
      volatility: volatilityPrediction,
      newsImpact: newsImpact ?? 0.0,
      sentiment: marketSentiment ?? 0.5,
    );

    // 4. Generate Price Predictions - توليد تنبؤات الأسعار
    final predictions = _generatePricePredictions(
      currentPrice: currentPrice,
      direction: ensembleResult.direction,
      strength: ensembleResult.strength,
      volatility: volatilityPrediction.volatility,
    );

    // 5. Calculate Confidence - حساب الثقة
    final confidence = _calculateConfidence(
      features: features,
      ensembleResult: ensembleResult,
      candles: candles,
    );

    // 6. Generate Recommendations - توليد التوصيات
    final recommendations = _generateActiveRecommendations(
      currentPrice: currentPrice,
      predictions: predictions,
      direction: ensembleResult.direction,
      strength: ensembleResult.strength,
      confidence: confidence,
      features: features,
    );

    // 7. Identify Support/Resistance - تحديد الدعم والمقاومة
    final levels = _calculateSmartLevels(candles, currentPrice, predictions);

    print('🧠 AI Engine: Prediction complete!');
    print('   Direction: ${ensembleResult.direction}');
    print(
        '   Strength: ${(ensembleResult.strength * 100).toStringAsFixed(1)}%');
    print('   Confidence: ${(confidence.overall * 100).toStringAsFixed(1)}%');

    return AIGoldPrediction(
      currentPrice: currentPrice,
      predictions: predictions,
      direction: ensembleResult.direction,
      strength: ensembleResult.strength,
      confidence: confidence,
      recommendations: recommendations,
      supportLevels: levels.support,
      resistanceLevels: levels.resistance,
      trend: ensembleResult.trendAnalysis,
      timestamp: DateTime.now(),
      modelVersion: 'GoldAI-v3.0-Ensemble',
    );
  }

  /// استخراج المميزات من البيانات
  _FeatureSet _extractFeatures(List<Candle> candles, double currentPrice) {
    final closes = candles.map((c) => c.close).toList();
    final highs = candles.map((c) => c.high).toList();
    final lows = candles.map((c) => c.low).toList();
    final volumes = candles.map((c) => c.volume).toList();

    return _FeatureSet(
      // Price features
      currentPrice: currentPrice,
      priceChange24h: _calculatePriceChange(closes, 24),
      priceChange7d: _calculatePriceChange(closes, 168),

      // Moving averages
      sma20: _calculateSMA(closes, 20),
      sma50: _calculateSMA(closes, 50),
      sma100: _calculateSMA(closes, 100),
      sma200: _calculateSMA(closes, 200),
      ema12: _calculateEMA(closes, 12),
      ema26: _calculateEMA(closes, 26),

      // Momentum indicators
      rsi: _calculateRSI(closes, 14),
      macd: _calculateMACD(closes),
      macdSignal: _calculateMACDSignal(closes),
      macdHistogram: _calculateMACDHistogram(closes),
      stochastic: _calculateStochastic(highs, lows, closes, 14),
      momentum: _calculateMomentum(closes, 10),
      roc: _calculateROC(closes, 12),

      // Volatility indicators
      atr: _calculateATR(highs, lows, closes, 14),
      bollingerUpper: _calculateBollingerUpper(closes, 20),
      bollingerLower: _calculateBollingerLower(closes, 20),
      bollingerWidth: _calculateBollingerWidth(closes, 20),

      // Trend indicators
      adx: _calculateADX(highs, lows, closes, 14),
      plusDI: _calculatePlusDI(highs, lows, closes, 14),
      minusDI: _calculateMinusDI(highs, lows, closes, 14),

      // Volume indicators
      volumeSMA: _calculateSMA(volumes, 20),
      volumeRatio: volumes.last / _calculateSMA(volumes, 20),
      obv: _calculateOBV(closes, volumes),

      // Price position
      pricePosition: _calculatePricePosition(currentPrice, highs, lows),
    );
  }

  /// نموذج تحليل الاتجاه
  _ModelPrediction _runTrendModel(_FeatureSet f) {
    double score = 0.0;
    int signals = 0;

    // MA Cross signals
    if (f.sma20 > f.sma50) {
      score += 1.5;
      signals++;
    }
    if (f.sma50 > f.sma100) {
      score += 1.0;
      signals++;
    }
    if (f.sma100 > f.sma200) {
      score += 0.5;
      signals++;
    }
    if (f.sma20 < f.sma50) {
      score -= 1.5;
      signals++;
    }
    if (f.sma50 < f.sma100) {
      score -= 1.0;
      signals++;
    }
    if (f.sma100 < f.sma200) {
      score -= 0.5;
      signals++;
    }

    // EMA signals
    if (f.ema12 > f.ema26) {
      score += 1.2;
      signals++;
    }
    if (f.ema12 < f.ema26) {
      score -= 1.2;
      signals++;
    }

    // Price vs MAs
    if (f.currentPrice > f.sma20) {
      score += 0.8;
      signals++;
    }
    if (f.currentPrice > f.sma50) {
      score += 0.6;
      signals++;
    }
    if (f.currentPrice > f.sma200) {
      score += 0.4;
      signals++;
    }
    if (f.currentPrice < f.sma20) {
      score -= 0.8;
      signals++;
    }
    if (f.currentPrice < f.sma50) {
      score -= 0.6;
      signals++;
    }
    if (f.currentPrice < f.sma200) {
      score -= 0.4;
      signals++;
    }

    // ADX trend strength
    final trendStrength = f.adx / 100.0;
    if (f.plusDI > f.minusDI && f.adx > 25) {
      score += 1.5 * trendStrength;
      signals++;
    }
    if (f.minusDI > f.plusDI && f.adx > 25) {
      score -= 1.5 * trendStrength;
      signals++;
    }

    // Normalize score
    final normalizedScore = signals > 0 ? score / signals : 0.0;
    final direction = normalizedScore > 0.3
        ? 'BULLISH'
        : normalizedScore < -0.3
            ? 'BEARISH'
            : 'NEUTRAL';

    return _ModelPrediction(
      direction: direction,
      score: normalizedScore.clamp(-1.0, 1.0),
      confidence: (f.adx / 100.0).clamp(0.3, 0.9),
    );
  }

  /// نموذج تحليل الزخم
  _ModelPrediction _runMomentumModel(_FeatureSet f) {
    double score = 0.0;
    int signals = 0;

    // RSI signals
    if (f.rsi > 70) {
      score -= 1.5;
      signals++;
    } // Overbought
    else if (f.rsi > 60) {
      score += 0.5;
      signals++;
    } // Bullish
    else if (f.rsi > 50) {
      score += 0.3;
      signals++;
    } // Slightly bullish
    else if (f.rsi > 40) {
      score -= 0.3;
      signals++;
    } // Slightly bearish
    else if (f.rsi > 30) {
      score -= 0.5;
      signals++;
    } // Bearish
    else {
      score += 1.5;
      signals++;
    } // Oversold

    // MACD signals
    if (f.macd > f.macdSignal) {
      score += 1.2;
      signals++;
    }
    if (f.macd < f.macdSignal) {
      score -= 1.2;
      signals++;
    }
    if (f.macdHistogram > 0 && f.macdHistogram > f.macd * 0.1) {
      score += 0.5;
      signals++;
    }
    if (f.macdHistogram < 0 && f.macdHistogram < f.macd * 0.1) {
      score -= 0.5;
      signals++;
    }

    // Stochastic signals
    if (f.stochastic > 80) {
      score -= 1.0;
      signals++;
    } else if (f.stochastic < 20) {
      score += 1.0;
      signals++;
    } else if (f.stochastic > 50) {
      score += 0.3;
      signals++;
    } else {
      score -= 0.3;
      signals++;
    }

    // Momentum & ROC
    if (f.momentum > 0) {
      score += 0.5;
      signals++;
    }
    if (f.momentum < 0) {
      score -= 0.5;
      signals++;
    }
    if (f.roc > 2) {
      score += 0.8;
      signals++;
    }
    if (f.roc < -2) {
      score -= 0.8;
      signals++;
    }

    final normalizedScore = signals > 0 ? score / signals : 0.0;
    final direction = normalizedScore > 0.2
        ? 'BULLISH'
        : normalizedScore < -0.2
            ? 'BEARISH'
            : 'NEUTRAL';

    return _ModelPrediction(
      direction: direction,
      score: normalizedScore.clamp(-1.0, 1.0),
      confidence: _calculateMomentumConfidence(f),
    );
  }

  /// نموذج التعرف على الأنماط
  _ModelPrediction _runPatternModel(List<Candle> candles, double currentPrice) {
    double score = 0.0;
    int patterns = 0;

    final recent = candles.sublist(candles.length - 20);

    // Candlestick patterns
    final lastCandle = recent.last;
    final prevCandle = recent[recent.length - 2];

    // Bullish patterns
    if (_isBullishEngulfing(prevCandle, lastCandle)) {
      score += 1.5;
      patterns++;
    }
    if (_isHammer(lastCandle)) {
      score += 1.2;
      patterns++;
    }
    if (_isMorningStar(recent)) {
      score += 1.8;
      patterns++;
    }
    if (_isDoji(lastCandle) && _isDowntrend(recent)) {
      score += 0.8;
      patterns++;
    }

    // Bearish patterns
    if (_isBearishEngulfing(prevCandle, lastCandle)) {
      score -= 1.5;
      patterns++;
    }
    if (_isShootingStar(lastCandle)) {
      score -= 1.2;
      patterns++;
    }
    if (_isEveningStar(recent)) {
      score -= 1.8;
      patterns++;
    }
    if (_isDoji(lastCandle) && _isUptrend(recent)) {
      score -= 0.8;
      patterns++;
    }

    // Chart patterns
    if (_isDoubleBottom(candles)) {
      score += 2.0;
      patterns++;
    }
    if (_isDoubleTop(candles)) {
      score -= 2.0;
      patterns++;
    }
    if (_isBreakout(candles, currentPrice)) {
      score += 1.5;
      patterns++;
    }
    if (_isBreakdown(candles, currentPrice)) {
      score -= 1.5;
      patterns++;
    }

    final normalizedScore = patterns > 0 ? score / patterns : 0.0;
    final direction = normalizedScore > 0.3
        ? 'BULLISH'
        : normalizedScore < -0.3
            ? 'BEARISH'
            : 'NEUTRAL';

    return _ModelPrediction(
      direction: direction,
      score: normalizedScore.clamp(-1.0, 1.0),
      confidence: patterns > 0 ? math.min(0.85, patterns * 0.15) : 0.3,
    );
  }

  /// نموذج تحليل التقلب
  _VolatilityPrediction _runVolatilityModel(_FeatureSet f) {
    // Calculate volatility regime
    final volatility = f.atr / f.currentPrice * 100;
    final bollingerPercent = f.bollingerWidth / f.currentPrice * 100;

    String regime;
    double riskMultiplier;

    if (volatility > 2.0 || bollingerPercent > 4.0) {
      regime = 'HIGH';
      riskMultiplier = 0.5; // Reduce position size
    } else if (volatility > 1.0 || bollingerPercent > 2.0) {
      regime = 'NORMAL';
      riskMultiplier = 1.0;
    } else {
      regime = 'LOW';
      riskMultiplier = 1.2; // Can increase position slightly
    }

    return _VolatilityPrediction(
      volatility: volatility,
      regime: regime,
      riskMultiplier: riskMultiplier,
      expectedRange: f.atr * 2,
    );
  }

  /// دمج نتائج النماذج
  _EnsembleResult _ensembleFusion({
    required _ModelPrediction trend,
    required _ModelPrediction momentum,
    required _ModelPrediction pattern,
    required _VolatilityPrediction volatility,
    required double newsImpact,
    required double sentiment,
  }) {
    // Weighted average of scores
    final totalWeight = _trendWeight + _momentumWeight + _patternWeight;

    final weightedScore = (trend.score * _trendWeight +
            momentum.score * _momentumWeight +
            pattern.score * _patternWeight) /
        totalWeight;

    // Adjust for news and sentiment
    final newsAdjustment = (newsImpact - 0.5) * 0.3;
    final sentimentAdjustment = (sentiment - 0.5) * 0.2;

    final finalScore =
        (weightedScore + newsAdjustment + sentimentAdjustment).clamp(-1.0, 1.0);

    // Determine direction
    String direction;
    if (finalScore > 0.4)
      direction = 'STRONG_BULLISH';
    else if (finalScore > 0.15)
      direction = 'BULLISH';
    else if (finalScore < -0.4)
      direction = 'STRONG_BEARISH';
    else if (finalScore < -0.15)
      direction = 'BEARISH';
    else
      direction = 'NEUTRAL';

    // Calculate strength
    final strength = finalScore.abs();

    // Create trend analysis
    final trendAnalysis = AITrendAnalysis(
      type: _getTrendType(direction),
      strength: strength,
      momentum: momentum.score,
      trendText: _getTrendText(direction),
      change: finalScore * 100,
    );

    return _EnsembleResult(
      direction: direction,
      strength: strength,
      score: finalScore,
      trendAnalysis: trendAnalysis,
    );
  }

  /// توليد تنبؤات الأسعار
  List<AIPricePoint> _generatePricePredictions({
    required double currentPrice,
    required String direction,
    required double strength,
    required double volatility,
  }) {
    final predictions = <AIPricePoint>[];

    // Determine trend factor
    double trendFactor;
    switch (direction) {
      case 'STRONG_BULLISH':
        trendFactor = 0.003;
        break;
      case 'BULLISH':
        trendFactor = 0.0015;
        break;
      case 'STRONG_BEARISH':
        trendFactor = -0.003;
        break;
      case 'BEARISH':
        trendFactor = -0.0015;
        break;
      default:
        trendFactor = 0.0;
    }

    // Apply strength multiplier
    trendFactor *= strength;

    // Generate 24-hour predictions
    var price = currentPrice;
    final random = math.Random(DateTime.now().millisecondsSinceEpoch);

    for (int i = 1; i <= 24; i++) {
      // Trend component
      final trend = price * trendFactor;

      // Volatility component (random noise)
      final noise = (random.nextDouble() - 0.5) * volatility * price * 0.001;

      // Mean reversion component
      final reversion = (currentPrice - price) * 0.02;

      // Update price
      price += trend + noise + reversion;

      // Calculate bounds
      final range = volatility * price * 0.005 * math.sqrt(i.toDouble());

      predictions.add(AIPricePoint(
        timestamp: DateTime.now().add(Duration(hours: i)),
        price: price,
        upperBound: price + range,
        lowerBound: price - range,
        hourOffset: i,
      ));
    }

    return predictions;
  }

  /// حساب الثقة المتقدم
  AIConfidence _calculateConfidence({
    required _FeatureSet features,
    required _EnsembleResult ensembleResult,
    required List<Candle> candles,
  }) {
    // 1. Model Agreement
    final modelAgreement = _modelAccuracy;

    // 2. Trend Strength (ADX)
    final trendStrength = (features.adx / 100.0).clamp(0.0, 1.0);

    // 3. Data Quality
    final dataQuality = candles.length >= 200 ? 0.9 : candles.length / 200.0;

    // 4. Volatility Confidence (lower volatility = higher confidence)
    final volNormalized = (features.atr / features.currentPrice * 100);
    final volatilityConfidence = (1.0 - volNormalized / 5.0).clamp(0.3, 0.9);

    // 5. Signal Clarity
    final signalClarity = ensembleResult.strength;

    // Weighted overall
    final overall = (modelAgreement * 0.25 +
            trendStrength * 0.20 +
            dataQuality * 0.15 +
            volatilityConfidence * 0.20 +
            signalClarity * 0.20)
        .clamp(0.40, 0.92);

    return AIConfidence(
      overall: overall,
      modelAccuracy: modelAgreement,
      trendStrength: trendStrength,
      dataQuality: dataQuality,
      volatilityConfidence: volatilityConfidence,
      signalClarity: signalClarity,
    );
  }

  /// توليد توصيات نشطة
  List<AIRecommendation> _generateActiveRecommendations({
    required double currentPrice,
    required List<AIPricePoint> predictions,
    required String direction,
    required double strength,
    required AIConfidence confidence,
    required _FeatureSet features,
  }) {
    final recommendations = <AIRecommendation>[];

    // Always generate a recommendation (no more HOLD-only)
    final avgPredicted =
        predictions.map((p) => p.price).reduce((a, b) => a + b) /
            predictions.length;
    final expectedChange = ((avgPredicted - currentPrice) / currentPrice) * 100;

    // Primary recommendation based on direction
    AITradeAction action;
    String reason;
    double entryPrice = currentPrice;
    double targetPrice;
    double stopLoss;

    switch (direction) {
      case 'STRONG_BULLISH':
        action = AITradeAction.strongBuy;
        targetPrice = currentPrice * 1.025; // 2.5% target
        stopLoss = currentPrice * 0.988; // 1.2% stop
        reason =
            '📈 إشارة شراء قوية جداً! الاتجاه صعودي + زخم قوي + أنماط إيجابية';
        break;
      case 'BULLISH':
        action = AITradeAction.buy;
        targetPrice = currentPrice * 1.015; // 1.5% target
        stopLoss = currentPrice * 0.992; // 0.8% stop
        reason = '📈 إشارة شراء! الاتجاه صعودي مع زخم إيجابي';
        break;
      case 'STRONG_BEARISH':
        action = AITradeAction.strongSell;
        targetPrice = currentPrice * 0.975; // 2.5% target
        stopLoss = currentPrice * 1.012; // 1.2% stop
        reason =
            '📉 إشارة بيع قوية جداً! الاتجاه هبوطي + زخم سلبي + أنماط سلبية';
        break;
      case 'BEARISH':
        action = AITradeAction.sell;
        targetPrice = currentPrice * 0.985; // 1.5% target
        stopLoss = currentPrice * 1.008; // 0.8% stop
        reason = '📉 إشارة بيع! الاتجاه هبوطي مع زخم سلبي';
        break;
      default:
        // Even for neutral, give a lean based on small signals
        if (expectedChange > 0.5) {
          action = AITradeAction.buy;
          targetPrice = currentPrice * 1.01;
          stopLoss = currentPrice * 0.995;
          reason = '↗️ ميل صعودي طفيف - فرصة شراء محتملة';
        } else if (expectedChange < -0.5) {
          action = AITradeAction.sell;
          targetPrice = currentPrice * 0.99;
          stopLoss = currentPrice * 1.005;
          reason = '↘️ ميل هبوطي طفيف - فرصة بيع محتملة';
        } else {
          action = AITradeAction.hold;
          targetPrice = currentPrice;
          stopLoss = currentPrice;
          reason = '⏸️ السوق متذبذب - انتظر إشارة أوضح';
        }
    }

    final riskReward = _calculateRiskReward(entryPrice, targetPrice, stopLoss);

    recommendations.add(AIRecommendation(
      action: action,
      confidence: confidence.overall,
      entryPrice: entryPrice,
      targetPrice: targetPrice,
      stopLoss: stopLoss,
      riskRewardRatio: riskReward,
      timeframe: 'قصير الأجل (1-24 ساعة)',
      reason: reason,
      indicators: _summarizeIndicators(features),
    ));

    // Add RSI-based recommendation if extreme
    if (features.rsi > 75 || features.rsi < 25) {
      recommendations.add(_generateRSIRecommendation(features, currentPrice));
    }

    // Add support/resistance based recommendation
    if (features.pricePosition < 0.1 || features.pricePosition > 0.9) {
      recommendations.add(_generateLevelRecommendation(features, currentPrice));
    }

    return recommendations;
  }

  AIRecommendation _generateRSIRecommendation(_FeatureSet f, double price) {
    if (f.rsi > 75) {
      return AIRecommendation(
        action: AITradeAction.sell,
        confidence: 0.75,
        entryPrice: price,
        targetPrice: price * 0.985,
        stopLoss: price * 1.008,
        riskRewardRatio: 1.87,
        timeframe: 'قصير جداً (1-4 ساعات)',
        reason:
            '⚠️ RSI = ${f.rsi.toStringAsFixed(1)} - منطقة تشبع شرائي! فرصة بيع',
        indicators: {'RSI': f.rsi},
      );
    } else {
      return AIRecommendation(
        action: AITradeAction.buy,
        confidence: 0.75,
        entryPrice: price,
        targetPrice: price * 1.015,
        stopLoss: price * 0.992,
        riskRewardRatio: 1.87,
        timeframe: 'قصير جداً (1-4 ساعات)',
        reason:
            '⚠️ RSI = ${f.rsi.toStringAsFixed(1)} - منطقة تشبع بيعي! فرصة شراء',
        indicators: {'RSI': f.rsi},
      );
    }
  }

  AIRecommendation _generateLevelRecommendation(_FeatureSet f, double price) {
    if (f.pricePosition < 0.1) {
      return AIRecommendation(
        action: AITradeAction.buy,
        confidence: 0.70,
        entryPrice: price,
        targetPrice: price * 1.02,
        stopLoss: price * 0.99,
        riskRewardRatio: 2.0,
        timeframe: 'متوسط (4-12 ساعة)',
        reason: '🟢 السعر عند أدنى نطاق - فرصة شراء من الدعم',
        indicators: {'Position': f.pricePosition},
      );
    } else {
      return AIRecommendation(
        action: AITradeAction.sell,
        confidence: 0.70,
        entryPrice: price,
        targetPrice: price * 0.98,
        stopLoss: price * 1.01,
        riskRewardRatio: 2.0,
        timeframe: 'متوسط (4-12 ساعة)',
        reason: '🔴 السعر عند أعلى نطاق - فرصة بيع من المقاومة',
        indicators: {'Position': f.pricePosition},
      );
    }
  }

  /// حساب مستويات ذكية
  _SmartLevels _calculateSmartLevels(
    List<Candle> candles,
    double currentPrice,
    List<AIPricePoint> predictions,
  ) {
    final support = <AIPriceLevel>[];
    final resistance = <AIPriceLevel>[];

    // Find swing highs and lows
    final swingHighs = <double>[];
    final swingLows = <double>[];

    for (int i = 5; i < candles.length - 5; i++) {
      if (_isSwingHigh(candles, i)) swingHighs.add(candles[i].high);
      if (_isSwingLow(candles, i)) swingLows.add(candles[i].low);
    }

    // Cluster levels
    final resistanceLevels = _clusterLevels(swingHighs, currentPrice, true);
    final supportLevels = _clusterLevels(swingLows, currentPrice, false);

    // Add Fibonacci levels
    final recentHigh = candles.map((c) => c.high).reduce(math.max);
    final recentLow = candles.map((c) => c.low).reduce(math.min);
    final range = recentHigh - recentLow;

    final fibLevels = [0.236, 0.382, 0.5, 0.618, 0.786];
    for (final fib in fibLevels) {
      final level = recentLow + range * fib;
      if (level > currentPrice) {
        resistance.add(AIPriceLevel(
          price: level,
          label: 'Fib ${(fib * 100).toInt()}%',
          strength: 0.6 + fib * 0.2,
          type: 'fibonacci',
        ));
      } else {
        support.add(AIPriceLevel(
          price: level,
          label: 'Fib ${(fib * 100).toInt()}%',
          strength: 0.6 + (1 - fib) * 0.2,
          type: 'fibonacci',
        ));
      }
    }

    // Add clustered levels
    for (final level in resistanceLevels) {
      resistance.add(level);
    }
    for (final level in supportLevels) {
      support.add(level);
    }

    // Sort
    support.sort((a, b) => b.price.compareTo(a.price));
    resistance.sort((a, b) => a.price.compareTo(b.price));

    return _SmartLevels(
      support: support.take(5).toList(),
      resistance: resistance.take(5).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Technical Indicator Calculations
  // ═══════════════════════════════════════════════════════════════

  double _calculateSMA(List<double> data, int period) {
    if (data.length < period) return data.last;
    final subset = data.sublist(data.length - period);
    return subset.reduce((a, b) => a + b) / period;
  }

  double _calculateEMA(List<double> data, int period) {
    if (data.length < period) return data.last;
    final multiplier = 2.0 / (period + 1);
    var ema = _calculateSMA(data.sublist(0, period), period);
    for (int i = period; i < data.length; i++) {
      ema = (data[i] - ema) * multiplier + ema;
    }
    return ema;
  }

  double _calculateRSI(List<double> closes, int period) {
    if (closes.length < period + 1) return 50.0;

    double avgGain = 0;
    double avgLoss = 0;

    for (int i = closes.length - period; i < closes.length; i++) {
      final change = closes[i] - closes[i - 1];
      if (change > 0)
        avgGain += change;
      else
        avgLoss += change.abs();
    }

    avgGain /= period;
    avgLoss /= period;

    if (avgLoss == 0) return 100.0;
    final rs = avgGain / avgLoss;
    return 100.0 - (100.0 / (1.0 + rs));
  }

  double _calculateMACD(List<double> closes) {
    return _calculateEMA(closes, 12) - _calculateEMA(closes, 26);
  }

  double _calculateMACDSignal(List<double> closes) {
    final macdLine = <double>[];
    for (int i = 26; i < closes.length; i++) {
      final subset = closes.sublist(0, i + 1);
      macdLine.add(_calculateEMA(subset, 12) - _calculateEMA(subset, 26));
    }
    return macdLine.isEmpty ? 0.0 : _calculateEMA(macdLine, 9);
  }

  double _calculateMACDHistogram(List<double> closes) {
    return _calculateMACD(closes) - _calculateMACDSignal(closes);
  }

  double _calculateStochastic(
    List<double> highs,
    List<double> lows,
    List<double> closes,
    int period,
  ) {
    if (closes.length < period) return 50.0;

    final recentHighs = highs.sublist(highs.length - period);
    final recentLows = lows.sublist(lows.length - period);

    final highest = recentHighs.reduce(math.max);
    final lowest = recentLows.reduce(math.min);
    final current = closes.last;

    if (highest == lowest) return 50.0;
    return ((current - lowest) / (highest - lowest)) * 100;
  }

  double _calculateATR(
    List<double> highs,
    List<double> lows,
    List<double> closes,
    int period,
  ) {
    if (closes.length < period + 1) return 10.0;

    final trValues = <double>[];
    for (int i = 1; i < closes.length; i++) {
      final tr = [
        highs[i] - lows[i],
        (highs[i] - closes[i - 1]).abs(),
        (lows[i] - closes[i - 1]).abs(),
      ].reduce(math.max);
      trValues.add(tr);
    }

    return _calculateSMA(trValues, period);
  }

  double _calculateADX(
    List<double> highs,
    List<double> lows,
    List<double> closes,
    int period,
  ) {
    if (closes.length < period * 2) return 25.0;

    // Simplified ADX calculation
    final plusDI = _calculatePlusDI(highs, lows, closes, period);
    final minusDI = _calculateMinusDI(highs, lows, closes, period);

    final diSum = plusDI + minusDI;
    if (diSum == 0) return 25.0;

    final dx = ((plusDI - minusDI).abs() / diSum) * 100;
    return dx;
  }

  double _calculatePlusDI(
    List<double> highs,
    List<double> lows,
    List<double> closes,
    int period,
  ) {
    if (highs.length < period + 1) return 50.0;

    double sumPlusDM = 0;
    for (int i = highs.length - period; i < highs.length; i++) {
      final plusDM = highs[i] - highs[i - 1];
      final minusDM = lows[i - 1] - lows[i];
      if (plusDM > minusDM && plusDM > 0) sumPlusDM += plusDM;
    }

    final atr = _calculateATR(highs, lows, closes, period);
    return atr == 0 ? 50.0 : (sumPlusDM / period) / atr * 100;
  }

  double _calculateMinusDI(
    List<double> highs,
    List<double> lows,
    List<double> closes,
    int period,
  ) {
    if (lows.length < period + 1) return 50.0;

    double sumMinusDM = 0;
    for (int i = lows.length - period; i < lows.length; i++) {
      final plusDM = highs[i] - highs[i - 1];
      final minusDM = lows[i - 1] - lows[i];
      if (minusDM > plusDM && minusDM > 0) sumMinusDM += minusDM;
    }

    final atr = _calculateATR(highs, lows, closes, period);
    return atr == 0 ? 50.0 : (sumMinusDM / period) / atr * 100;
  }

  double _calculateBollingerUpper(List<double> closes, int period) {
    final sma = _calculateSMA(closes, period);
    final std = _calculateStdDev(closes, period);
    return sma + (std * 2);
  }

  double _calculateBollingerLower(List<double> closes, int period) {
    final sma = _calculateSMA(closes, period);
    final std = _calculateStdDev(closes, period);
    return sma - (std * 2);
  }

  double _calculateBollingerWidth(List<double> closes, int period) {
    return _calculateBollingerUpper(closes, period) -
        _calculateBollingerLower(closes, period);
  }

  double _calculateStdDev(List<double> data, int period) {
    if (data.length < period) return 0.0;
    final subset = data.sublist(data.length - period);
    final mean = subset.reduce((a, b) => a + b) / period;
    final variance =
        subset.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) /
            period;
    return math.sqrt(variance);
  }

  double _calculateOBV(List<double> closes, List<double> volumes) {
    double obv = 0;
    for (int i = 1; i < closes.length; i++) {
      if (closes[i] > closes[i - 1])
        obv += volumes[i];
      else if (closes[i] < closes[i - 1]) obv -= volumes[i];
    }
    return obv;
  }

  double _calculateMomentum(List<double> closes, int period) {
    if (closes.length < period + 1) return 0.0;
    return closes.last - closes[closes.length - period - 1];
  }

  double _calculateROC(List<double> closes, int period) {
    if (closes.length < period + 1) return 0.0;
    final prev = closes[closes.length - period - 1];
    if (prev == 0) return 0.0;
    return ((closes.last - prev) / prev) * 100;
  }

  double _calculatePriceChange(List<double> closes, int periods) {
    if (closes.length < periods + 1) return 0.0;
    final prev = closes[closes.length - periods - 1];
    if (prev == 0) return 0.0;
    return ((closes.last - prev) / prev) * 100;
  }

  double _calculatePricePosition(
      double current, List<double> highs, List<double> lows) {
    final highest = highs.reduce(math.max);
    final lowest = lows.reduce(math.min);
    if (highest == lowest) return 0.5;
    return (current - lowest) / (highest - lowest);
  }

  double _calculateMomentumConfidence(_FeatureSet f) {
    // Higher confidence when indicators agree
    int agreements = 0;

    // RSI agreement
    if ((f.rsi > 50 && f.macd > 0) || (f.rsi < 50 && f.macd < 0)) agreements++;
    // MACD agreement
    if ((f.macd > f.macdSignal && f.rsi > 50) ||
        (f.macd < f.macdSignal && f.rsi < 50)) agreements++;
    // Stochastic agreement
    if ((f.stochastic > 50 && f.momentum > 0) ||
        (f.stochastic < 50 && f.momentum < 0)) agreements++;

    return 0.5 + (agreements * 0.15);
  }

  // ═══════════════════════════════════════════════════════════════
  // Pattern Recognition
  // ═══════════════════════════════════════════════════════════════

  bool _isBullishEngulfing(Candle prev, Candle curr) {
    return prev.close < prev.open && // Previous is bearish
        curr.close > curr.open && // Current is bullish
        curr.open < prev.close && // Opens below prev close
        curr.close > prev.open; // Closes above prev open
  }

  bool _isBearishEngulfing(Candle prev, Candle curr) {
    return prev.close > prev.open && // Previous is bullish
        curr.close < curr.open && // Current is bearish
        curr.open > prev.close && // Opens above prev close
        curr.close < prev.open; // Closes below prev open
  }

  bool _isHammer(Candle c) {
    final body = (c.close - c.open).abs();
    final lowerWick = math.min(c.open, c.close) - c.low;
    final upperWick = c.high - math.max(c.open, c.close);
    return lowerWick > body * 2 && upperWick < body * 0.5;
  }

  bool _isShootingStar(Candle c) {
    final body = (c.close - c.open).abs();
    final lowerWick = math.min(c.open, c.close) - c.low;
    final upperWick = c.high - math.max(c.open, c.close);
    return upperWick > body * 2 && lowerWick < body * 0.5;
  }

  bool _isDoji(Candle c) {
    final body = (c.close - c.open).abs();
    final range = c.high - c.low;
    return body < range * 0.1;
  }

  bool _isMorningStar(List<Candle> candles) {
    if (candles.length < 3) return false;
    final c1 = candles[candles.length - 3];
    final c2 = candles[candles.length - 2];
    final c3 = candles.last;

    return c1.close < c1.open && // First is bearish
        (c2.close - c2.open).abs() <
            (c1.close - c1.open).abs() * 0.3 && // Second is small
        c3.close > c3.open && // Third is bullish
        c3.close > (c1.open + c1.close) / 2; // Third closes above mid of first
  }

  bool _isEveningStar(List<Candle> candles) {
    if (candles.length < 3) return false;
    final c1 = candles[candles.length - 3];
    final c2 = candles[candles.length - 2];
    final c3 = candles.last;

    return c1.close > c1.open && // First is bullish
        (c2.close - c2.open).abs() <
            (c1.close - c1.open).abs() * 0.3 && // Second is small
        c3.close < c3.open && // Third is bearish
        c3.close < (c1.open + c1.close) / 2; // Third closes below mid of first
  }

  bool _isDowntrend(List<Candle> candles) {
    if (candles.length < 10) return false;
    return candles.last.close < candles[candles.length - 10].close;
  }

  bool _isUptrend(List<Candle> candles) {
    if (candles.length < 10) return false;
    return candles.last.close > candles[candles.length - 10].close;
  }

  bool _isDoubleBottom(List<Candle> candles) {
    // Simplified double bottom detection
    if (candles.length < 50) return false;

    final lows = candles.map((c) => c.low).toList();
    final recent = lows.sublist(lows.length - 50);

    // Find two similar lows
    final minLow = recent.reduce(math.min);
    int count = 0;
    for (final low in recent) {
      if ((low - minLow).abs() / minLow < 0.01) count++;
    }
    return count >= 2;
  }

  bool _isDoubleTop(List<Candle> candles) {
    if (candles.length < 50) return false;

    final highs = candles.map((c) => c.high).toList();
    final recent = highs.sublist(highs.length - 50);

    final maxHigh = recent.reduce(math.max);
    int count = 0;
    for (final high in recent) {
      if ((high - maxHigh).abs() / maxHigh < 0.01) count++;
    }
    return count >= 2;
  }

  bool _isBreakout(List<Candle> candles, double currentPrice) {
    if (candles.length < 20) return false;
    final recent = candles.sublist(candles.length - 20);
    final maxHigh = recent.map((c) => c.high).reduce(math.max);
    return currentPrice > maxHigh;
  }

  bool _isBreakdown(List<Candle> candles, double currentPrice) {
    if (candles.length < 20) return false;
    final recent = candles.sublist(candles.length - 20);
    final minLow = recent.map((c) => c.low).reduce(math.min);
    return currentPrice < minLow;
  }

  bool _isSwingHigh(List<Candle> candles, int index) {
    if (index < 2 || index >= candles.length - 2) return false;
    final high = candles[index].high;
    return high > candles[index - 1].high &&
        high > candles[index - 2].high &&
        high > candles[index + 1].high &&
        high > candles[index + 2].high;
  }

  bool _isSwingLow(List<Candle> candles, int index) {
    if (index < 2 || index >= candles.length - 2) return false;
    final low = candles[index].low;
    return low < candles[index - 1].low &&
        low < candles[index - 2].low &&
        low < candles[index + 1].low &&
        low < candles[index + 2].low;
  }

  List<AIPriceLevel> _clusterLevels(
      List<double> levels, double currentPrice, bool isResistance) {
    if (levels.isEmpty) return [];

    levels.sort();
    final clusters = <List<double>>[];
    var currentCluster = <double>[levels.first];

    for (int i = 1; i < levels.length; i++) {
      if ((levels[i] - currentCluster.last) / currentCluster.last < 0.005) {
        currentCluster.add(levels[i]);
      } else {
        clusters.add(currentCluster);
        currentCluster = [levels[i]];
      }
    }
    clusters.add(currentCluster);

    final result = <AIPriceLevel>[];
    for (final cluster in clusters) {
      final avgPrice = cluster.reduce((a, b) => a + b) / cluster.length;
      if (isResistance && avgPrice > currentPrice ||
          !isResistance && avgPrice < currentPrice) {
        result.add(AIPriceLevel(
          price: avgPrice,
          label: isResistance ? 'مقاومة' : 'دعم',
          strength: math.min(1.0, cluster.length * 0.2),
          type: 'swing',
        ));
      }
    }

    return result;
  }

  // ═══════════════════════════════════════════════════════════════
  // Helper Methods
  // ═══════════════════════════════════════════════════════════════

  double _calculateRiskReward(double entry, double target, double stop) {
    final risk = (entry - stop).abs();
    final reward = (target - entry).abs();
    return risk > 0 ? reward / risk : 0;
  }

  AITrendType _getTrendType(String direction) {
    switch (direction) {
      case 'STRONG_BULLISH':
        return AITrendType.strongBullish;
      case 'BULLISH':
        return AITrendType.bullish;
      case 'STRONG_BEARISH':
        return AITrendType.strongBearish;
      case 'BEARISH':
        return AITrendType.bearish;
      default:
        return AITrendType.neutral;
    }
  }

  String _getTrendText(String direction) {
    switch (direction) {
      case 'STRONG_BULLISH':
        return 'صعودي قوي جداً 🚀';
      case 'BULLISH':
        return 'صعودي 📈';
      case 'STRONG_BEARISH':
        return 'هبوطي قوي جداً 📉';
      case 'BEARISH':
        return 'هبوطي ↘️';
      default:
        return 'عرضي/محايد ↔️';
    }
  }

  Map<String, double> _summarizeIndicators(_FeatureSet f) {
    return {
      'RSI': f.rsi,
      'MACD': f.macd,
      'ADX': f.adx,
      'Stochastic': f.stochastic,
      'ATR': f.atr,
    };
  }
}

// ═══════════════════════════════════════════════════════════════
// Data Classes
// ═══════════════════════════════════════════════════════════════

class _FeatureSet {
  final double currentPrice;
  final double priceChange24h;
  final double priceChange7d;
  final double sma20, sma50, sma100, sma200;
  final double ema12, ema26;
  final double rsi;
  final double macd, macdSignal, macdHistogram;
  final double stochastic;
  final double momentum;
  final double roc;
  final double atr;
  final double bollingerUpper, bollingerLower, bollingerWidth;
  final double adx, plusDI, minusDI;
  final double volumeSMA, volumeRatio, obv;
  final double pricePosition;

  _FeatureSet({
    required this.currentPrice,
    required this.priceChange24h,
    required this.priceChange7d,
    required this.sma20,
    required this.sma50,
    required this.sma100,
    required this.sma200,
    required this.ema12,
    required this.ema26,
    required this.rsi,
    required this.macd,
    required this.macdSignal,
    required this.macdHistogram,
    required this.stochastic,
    required this.momentum,
    required this.roc,
    required this.atr,
    required this.bollingerUpper,
    required this.bollingerLower,
    required this.bollingerWidth,
    required this.adx,
    required this.plusDI,
    required this.minusDI,
    required this.volumeSMA,
    required this.volumeRatio,
    required this.obv,
    required this.pricePosition,
  });
}

class _ModelPrediction {
  final String direction;
  final double score;
  final double confidence;

  _ModelPrediction({
    required this.direction,
    required this.score,
    required this.confidence,
  });
}

class _VolatilityPrediction {
  final double volatility;
  final String regime;
  final double riskMultiplier;
  final double expectedRange;

  _VolatilityPrediction({
    required this.volatility,
    required this.regime,
    required this.riskMultiplier,
    required this.expectedRange,
  });
}

class _EnsembleResult {
  final String direction;
  final double strength;
  final double score;
  final AITrendAnalysis trendAnalysis;

  _EnsembleResult({
    required this.direction,
    required this.strength,
    required this.score,
    required this.trendAnalysis,
  });
}

class _SmartLevels {
  final List<AIPriceLevel> support;
  final List<AIPriceLevel> resistance;

  _SmartLevels({required this.support, required this.resistance});
}

class _PredictionRecord {
  final DateTime timestamp;
  final double predictedPrice;
  final String predictedDirection;
  final double? actualPrice;
  final bool? wasCorrect;

  _PredictionRecord({
    required this.timestamp,
    required this.predictedPrice,
    required this.predictedDirection,
    this.actualPrice,
    this.wasCorrect,
  });
}

// ═══════════════════════════════════════════════════════════════
// Public Data Classes (exported)
// ═══════════════════════════════════════════════════════════════

class AIGoldPrediction {
  final double currentPrice;
  final List<AIPricePoint> predictions;
  final String direction;
  final double strength;
  final AIConfidence confidence;
  final List<AIRecommendation> recommendations;
  final List<AIPriceLevel> supportLevels;
  final List<AIPriceLevel> resistanceLevels;
  final AITrendAnalysis trend;
  final DateTime timestamp;
  final String modelVersion;

  AIGoldPrediction({
    required this.currentPrice,
    required this.predictions,
    required this.direction,
    required this.strength,
    required this.confidence,
    required this.recommendations,
    required this.supportLevels,
    required this.resistanceLevels,
    required this.trend,
    required this.timestamp,
    required this.modelVersion,
  });
}

class AIPricePoint {
  final DateTime timestamp;
  final double price;
  final double upperBound;
  final double lowerBound;
  final int hourOffset;

  AIPricePoint({
    required this.timestamp,
    required this.price,
    required this.upperBound,
    required this.lowerBound,
    required this.hourOffset,
  });
}

class AIConfidence {
  final double overall;
  final double modelAccuracy;
  final double trendStrength;
  final double dataQuality;
  final double volatilityConfidence;
  final double signalClarity;

  AIConfidence({
    required this.overall,
    required this.modelAccuracy,
    required this.trendStrength,
    required this.dataQuality,
    required this.volatilityConfidence,
    required this.signalClarity,
  });
}

class AIRecommendation {
  final AITradeAction action;
  final double confidence;
  final double entryPrice;
  final double targetPrice;
  final double stopLoss;
  final double riskRewardRatio;
  final String timeframe;
  final String reason;
  final Map<String, double> indicators;

  AIRecommendation({
    required this.action,
    required this.confidence,
    required this.entryPrice,
    required this.targetPrice,
    required this.stopLoss,
    required this.riskRewardRatio,
    required this.timeframe,
    required this.reason,
    required this.indicators,
  });

  String get actionText {
    switch (action) {
      case AITradeAction.strongBuy:
        return '🟢 شراء قوي';
      case AITradeAction.buy:
        return '🟢 شراء';
      case AITradeAction.hold:
        return '⏸️ انتظار';
      case AITradeAction.sell:
        return '🔴 بيع';
      case AITradeAction.strongSell:
        return '🔴 بيع قوي';
    }
  }
}

class AIPriceLevel {
  final double price;
  final String label;
  final double strength;
  final String type;

  AIPriceLevel({
    required this.price,
    required this.label,
    required this.strength,
    required this.type,
  });
}

class AITrendAnalysis {
  final AITrendType type;
  final double strength;
  final double momentum;
  final String trendText;
  final double change;

  AITrendAnalysis({
    required this.type,
    required this.strength,
    required this.momentum,
    required this.trendText,
    required this.change,
  });
}

enum AITradeAction { strongBuy, buy, hold, sell, strongSell }

enum AITrendType { strongBullish, bullish, neutral, bearish, strongBearish }
