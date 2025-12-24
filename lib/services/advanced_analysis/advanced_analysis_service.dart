import '../../models/candle.dart';
import '../../models/advanced/candle_data.dart';
import '../../models/advanced/market_context.dart';
import '../../models/advanced/prediction_result.dart';
import '../../models/advanced/news_models.dart';
import '../../models/advanced/price_level.dart';
import '../../models/advanced/trading_recommendation.dart';
import '../../models/advanced/trend_analysis.dart';
import '../ml/lstm_predictor.dart';
import '../ml/technical_indicators_calculator.dart';
import '../news/news_service.dart';
import '../news/sentiment_analyzer.dart';
import '../alerts/smart_alert_manager.dart';
import '../golden_nightmare/golden_nightmare_engine.dart';
import '../support_resistance_service.dart';

/// CompleteAnalysis - تحليل شامل يجمع النظام الأساسي والمتقدم
class CompleteAnalysis {
  final Map<String, dynamic> baseAnalysis;
  final AdvancedPredictionResult advancedPrediction;
  final List<GoldNews> news;
  final MarketImpactScore newsImpact;

  CompleteAnalysis({
    required this.baseAnalysis,
    required this.advancedPrediction,
    required this.news,
    required this.newsImpact,
  });
}

/// AdvancedAnalysisService - الخدمة المركزية للتحليل المتقدم
class AdvancedAnalysisService {
  static final AdvancedAnalysisService _instance =
      AdvancedAnalysisService._internal();

  factory AdvancedAnalysisService() => _instance;

  final _lstmPredictor = LSTMPricePredictor();
  final _newsService = NewsService();
  final _sentimentAnalyzer = NewsSentimentAnalyzer();
  final _alertManager = SmartAlertManager();

  bool _initialized = false;

  AdvancedAnalysisService._internal();

  /// تهيئة الخدمة
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await _lstmPredictor.initialize();
      await _sentimentAnalyzer.initialize();
      _newsService.initialize();

      _initialized = true;
      print('✅ Advanced Analysis Service initialized');
    } catch (e) {
      print('⚠️ Advanced Analysis Service initialization warning: $e');
      // سيعمل النظام بوضع fallback
      _initialized = true;
    }
  }

  /// التحليل الشامل - مع بيانات حقيقية 100%
  Future<CompleteAnalysis> getCompleteAnalysis({
    required double currentPrice,
    required List<Candle> candles,
    required Map<String, double> indicators,
  }) async {
    await initialize();

    try {
      print('🔍 Starting complete analysis with real data...');

      // 1. حساب المؤشرات الفنية الحقيقية من البيانات
      final realIndicators = TechnicalIndicatorsCalculator.calculateAll(candles);
      print('✅ Real indicators calculated');

      // 2. النظام الأساسي (Golden Nightmare Engine - 10 Layers)
      final baseAnalysis = await GoldenNightmareEngine.generate(
        currentPrice: currentPrice,
        candles: candles,
        rsi: realIndicators['rsi']!,
        macd: realIndicators['macd']!,
        macdSignal: realIndicators['macdSignal']!,
        ma20: realIndicators['ma20']!,
        ma50: realIndicators['ma50']!,
        ma100: realIndicators['ma100']!,
        ma200: realIndicators['ma200']!,
        atr: realIndicators['atr']!,
      );
      print('✅ Golden Nightmare analysis completed');

      // 3. جلب الأخبار الحقيقية
      final news = await _newsService.fetchGoldNews(limit: 15);
      final newsImpact = await _newsService.calculateImpactScore(news);
      print('✅ News fetched: ${news.length} articles');

      // 4. بناء سياق السوق الحقيقي
      final context = await _buildRealMarketContext(
        realIndicators,
        newsImpact,
        candles,
      );

      // 5. LSTM Prediction مع البيانات الحقيقية
      final prediction = await _lstmPredictor.predictPrice(
        historicalData: candles.map(CandleData.fromCandle).toList(),
        context: context,
      );
      print('✅ LSTM predictions generated');

      // 6. استخراج مستويات الدعم/المقاومة الحقيقية من SupportResistanceService
      final realLevels = SupportResistanceService.calculate(candles, currentPrice);
      print('✅ Real S/R levels: ${realLevels.supports.length} supports, ${realLevels.resistances.length} resistances');

      // 7. دمج مستويات الدعم/المقاومة من مصادر متعددة
      _mergeSupportResistanceLevels(
        prediction: prediction,
        realLevels: realLevels,
        goldenNightmareLevels: baseAnalysis,
      );
      print('✅ Merged S/R levels: ${prediction.supportLevels.length} supports, ${prediction.resistanceLevels.length} resistances');

      // 8. تحسين التوصيات بناءً على التحليل الحقيقي
      _enhanceRecommendationsWithRealData(
        prediction,
        baseAnalysis,
        currentPrice,
        realIndicators,
      );

      // 9. فحص التنبيهات
      _alertManager.checkAlerts(currentPrice);

      print('✅ Complete analysis finished');

      return CompleteAnalysis(
        baseAnalysis: baseAnalysis,
        advancedPrediction: prediction,
        news: news,
        newsImpact: newsImpact,
      );
    } catch (e) {
      print('❌ Complete analysis error: $e');
      rethrow;
    }
  }

  /// بناء سياق السوق الحقيقي
  Future<MarketContext> _buildRealMarketContext(
    Map<String, double> realIndicators,
    MarketImpactScore newsImpact,
    List<Candle> candles,
  ) async {
    final volatility =
        TechnicalIndicatorsCalculator.calculateVolatility(candles);

    final sentiment = _calculateSentimentFromNews(newsImpact);

    return MarketContext(
      economicSentiment: sentiment,
      volatilityIndex: volatility,
      newsImpactScore: newsImpact.score,
      upcomingEvents: [],
    );
  }

  /// حساب المعنويات من الأخبار
  double _calculateSentimentFromNews(MarketImpactScore impact) {
    switch (impact.direction) {
      case NewsDirection.bullish:
        return impact.score;
      case NewsDirection.bearish:
        return -impact.score;
      case NewsDirection.neutral:
        return 0.0;
    }
  }

  /// دمج مستويات الدعم والمقاومة من مصادر متعددة
  void _mergeSupportResistanceLevels({
    required AdvancedPredictionResult prediction,
    required dynamic realLevels,
    required Map<String, dynamic> goldenNightmareLevels,
  }) {
    final allSupports = <PriceLevel>[];
    final allResistances = <PriceLevel>[];
    
    // 1. من SupportResistanceService (الأولوية الأعلى)
    if (realLevels.supports != null) {
      for (final support in realLevels.supports.take(5)) {
        allSupports.add(PriceLevel(
          support.price,
          '${support.source} (${support.touchCount}x)',
          support.strength / 100.0,
        ));
      }
    }
    
    if (realLevels.resistances != null) {
      for (final resistance in realLevels.resistances.take(5)) {
        allResistances.add(PriceLevel(
          resistance.price,
          '${resistance.source} (${resistance.touchCount}x)',
          resistance.strength / 100.0,
        ));
      }
    }
    
    // 2. من LSTM Pivot Points (المحسوبة سابقاً)
    allSupports.addAll(prediction.supportLevels);
    allResistances.addAll(prediction.resistanceLevels);
    
    // 3. من Golden Nightmare (إذا وجدت)
    final gnSupports = _extractGoldenNightmareSupports(goldenNightmareLevels);
    final gnResistances = _extractGoldenNightmareResistances(goldenNightmareLevels);
    allSupports.addAll(gnSupports);
    allResistances.addAll(gnResistances);
    
    // 4. إزالة التكرار ودمج المستويات القريبة
    prediction.supportLevels.clear();
    prediction.resistanceLevels.clear();
    
    prediction.supportLevels.addAll(_deduplicateAndMergeLevels(allSupports));
    prediction.resistanceLevels.addAll(_deduplicateAndMergeLevels(allResistances));
  }

  /// استخراج مستويات الدعم من Golden Nightmare
  List<PriceLevel> _extractGoldenNightmareSupports(Map<String, dynamic> analysis) {
    final supports = <PriceLevel>[];
    
    try {
      // من توصيات SCALP
      if (analysis['SCALP'] != null) {
        final scalpRec = analysis['SCALP'] as Map<String, dynamic>;
        if (scalpRec['stopLoss'] != null && scalpRec['direction'] == 'BUY') {
          final stopLoss = double.tryParse(scalpRec['stopLoss'].toString());
          if (stopLoss != null) {
            supports.add(PriceLevel(stopLoss, 'GN Scalp SL', 0.75));
          }
        }
      }
      
      // من توصيات SWING
      if (analysis['SWING'] != null) {
        final swingRec = analysis['SWING'] as Map<String, dynamic>;
        if (swingRec['stopLoss'] != null && swingRec['direction'] == 'BUY') {
          final stopLoss = double.tryParse(swingRec['stopLoss'].toString());
          if (stopLoss != null) {
            supports.add(PriceLevel(stopLoss, 'GN Swing SL', 0.80));
          }
        }
      }
    } catch (e) {
      print('⚠️ Failed to extract GN supports: $e');
    }
    
    return supports;
  }

  /// استخراج مستويات المقاومة من Golden Nightmare
  List<PriceLevel> _extractGoldenNightmareResistances(Map<String, dynamic> analysis) {
    final resistances = <PriceLevel>[];
    
    try {
      // من توصيات SCALP
      if (analysis['SCALP'] != null) {
        final scalpRec = analysis['SCALP'] as Map<String, dynamic>;
        if (scalpRec['takeProfit'] != null) {
          final tp = double.tryParse(scalpRec['takeProfit'].toString());
          if (tp != null) {
            resistances.add(PriceLevel(tp, 'GN Scalp TP', 0.75));
          }
        }
      }
      
      // من توصيات SWING
      if (analysis['SWING'] != null) {
        final swingRec = analysis['SWING'] as Map<String, dynamic>;
        if (swingRec['takeProfit'] != null) {
          final tp = double.tryParse(swingRec['takeProfit'].toString());
          if (tp != null) {
            resistances.add(PriceLevel(tp, 'GN Swing TP', 0.80));
          }
        }
      }
    } catch (e) {
      print('⚠️ Failed to extract GN resistances: $e');
    }
    
    return resistances;
  }

  /// إزالة المستويات المكررة ودمج القريبة
  List<PriceLevel> _deduplicateAndMergeLevels(List<PriceLevel> levels) {
    if (levels.isEmpty) return [];
    
    // ترتيب حسب القوة (الأقوى أولاً)
    levels.sort((a, b) => b.strength.compareTo(a.strength));
    
    final merged = <PriceLevel>[];
    
    for (final level in levels) {
      bool isDuplicate = false;
      
      for (int i = 0; i < merged.length; i++) {
        final existing = merged[i];
        final priceDiff = (level.price - existing.price).abs();
        final threshold = existing.price * 0.003; // 0.3% threshold
        
        if (priceDiff < threshold) {
          isDuplicate = true;
          
          // دمج المستويات القريبة (متوسط موزون)
          final totalStrength = level.strength + existing.strength;
          final weightedPrice = (level.price * level.strength + 
                                existing.price * existing.strength) / totalStrength;
          
          merged[i] = PriceLevel(
            weightedPrice,
            '${existing.label} + ${level.label}',
            totalStrength / 2, // متوسط القوة
          );
          break;
        }
      }
      
      if (!isDuplicate) {
        merged.add(level);
      }
    }
    
    // إرجاع أقوى 5 مستويات
    return merged.take(5).toList();
  }

  /// تحسين التوصيات بالبيانات الحقيقية - دمج ذكي
  void _enhanceRecommendationsWithRealData(
    AdvancedPredictionResult prediction,
    Map<String, dynamic> baseAnalysis,
    double currentPrice,
    Map<String, double> realIndicators,
  ) {
    // توليد توصية ذكية من مصادر متعددة
    final enhanced = _generateSmartRecommendation(
      currentPrice: currentPrice,
      goldenNightmareAnalysis: baseAnalysis,
      lstmPrediction: prediction,
      supportLevels: prediction.supportLevels,
      resistanceLevels: prediction.resistanceLevels,
      realIndicators: realIndicators,
    );

    // استبدل التوصيات القديمة بالتوصية الذكية
    prediction.recommendations.clear();
    prediction.recommendations.add(enhanced);

    print('✅ Smart recommendation generated: ${enhanced.actionText} @ \$${enhanced.entryPrice.toStringAsFixed(2)}');
  }

  /// توليد توصية ذكية من مصادر متعددة
  TradingRecommendation _generateSmartRecommendation({
    required double currentPrice,
    required Map<String, dynamic> goldenNightmareAnalysis,
    required AdvancedPredictionResult lstmPrediction,
    required List<PriceLevel> supportLevels,
    required List<PriceLevel> resistanceLevels,
    required Map<String, double> realIndicators,
  }) {
    // استخراج التوصيات من Golden Nightmare
    final scalpRec = goldenNightmareAnalysis['SCALP'];
    final swingRec = goldenNightmareAnalysis['SWING'];
    
    String action;
    double entryPrice;
    double stopLoss;
    double targetPrice;
    double confidence;
    String reason;
    
    final atr = realIndicators['atr'] ?? 10.0;
    final trend = lstmPrediction.trend;
    
    // 1. أولوية لـ Golden Nightmare إذا كان التوصية واضحة
    if (scalpRec != null && scalpRec['direction'] != 'NO_TRADE') {
      action = scalpRec['direction'] as String;
      entryPrice = _parsePrice(scalpRec['entry']) ?? currentPrice;
      stopLoss = _parsePrice(scalpRec['stopLoss']) ?? currentPrice;
      targetPrice = _parsePrice(scalpRec['takeProfit']) ?? currentPrice;
      confidence = _parseConfidence(scalpRec['confidence']) ?? 0.7;
      reason = 'Golden Nightmare Engine (Scalp): ${scalpRec['reasoning'] ?? ""}';
    } 
    else if (swingRec != null && swingRec['direction'] != 'NO_TRADE') {
      action = swingRec['direction'] as String;
      entryPrice = _parsePrice(swingRec['entry']) ?? currentPrice;
      stopLoss = _parsePrice(swingRec['stopLoss']) ?? currentPrice;
      targetPrice = _parsePrice(swingRec['takeProfit']) ?? currentPrice;
      confidence = _parseConfidence(swingRec['confidence']) ?? 0.65;
      reason = 'Golden Nightmare Engine (Swing): ${swingRec['reasoning'] ?? ""}';
    }
    // 2. إذا لا يوجد توصية، استخدم LSTM + مستويات الدعم/المقاومة
    else {
      if (trend.type == TrendType.strongBullish || trend.type == TrendType.bullish) {
        action = 'BUY';
        entryPrice = currentPrice;
        
        // Stop Loss: أقرب دعم أو ATR
        if (supportLevels.isNotEmpty) {
          final nearestSupport = supportLevels.first;
          stopLoss = nearestSupport.price;
        } else {
          stopLoss = currentPrice - (atr * 1.5);
        }
        
        // Target: أقرب مقاومة أو ATR * 2.5
        if (resistanceLevels.isNotEmpty) {
          final nearestResistance = resistanceLevels.first;
          targetPrice = nearestResistance.price;
        } else {
          targetPrice = currentPrice + (atr * 2.5);
        }
        
        confidence = lstmPrediction.confidence.overall;
        reason = 'LSTM Prediction: ${trend.trendText} مع ثقة ${(confidence * 100).toStringAsFixed(0)}%';
      } 
      else if (trend.type == TrendType.strongBearish || trend.type == TrendType.bearish) {
        action = 'SELL';
        entryPrice = currentPrice;
        
        // Stop Loss: أقرب مقاومة أو ATR
        if (resistanceLevels.isNotEmpty) {
          final nearestResistance = resistanceLevels.first;
          stopLoss = nearestResistance.price;
        } else {
          stopLoss = currentPrice + (atr * 1.5);
        }
        
        // Target: أقرب دعم أو ATR * 2.5
        if (supportLevels.isNotEmpty) {
          final nearestSupport = supportLevels.first;
          targetPrice = nearestSupport.price;
        } else {
          targetPrice = currentPrice - (atr * 2.5);
        }
        
        confidence = lstmPrediction.confidence.overall;
        reason = 'LSTM Prediction: ${trend.trendText} مع ثقة ${(confidence * 100).toStringAsFixed(0)}%';
      } 
      else {
        // عرضي - انتظار
        action = 'HOLD';
        entryPrice = currentPrice;
        stopLoss = currentPrice;
        targetPrice = currentPrice;
        confidence = 0.5;
        reason = 'السوق ${trend.trendText}. انتظر إشارة أوضح.';
      }
    }
    
    // 3. التحقق من صحة الأسعار وتصحيحها
    if (action == 'BUY') {
      // التأكد أن الهدف أعلى من الدخول
      if (targetPrice <= entryPrice) {
        targetPrice = entryPrice * 1.015; // +1.5% على الأقل
      }
      // التأكد أن الستوب أقل من الدخول
      if (stopLoss >= entryPrice) {
        stopLoss = entryPrice * 0.992; // -0.8% على الأقل
      }
    } 
    else if (action == 'SELL') {
      // التأكد أن الهدف أقل من الدخول
      if (targetPrice >= entryPrice) {
        targetPrice = entryPrice * 0.985; // -1.5% على الأقل
      }
      // التأكد أن الستوب أعلى من الدخول
      if (stopLoss <= entryPrice) {
        stopLoss = entryPrice * 1.008; // +0.8% على الأقل
      }
    }
    
    // 4. حساب نسبة المخاطرة للعائد
    final riskReward = _calculateRiskReward(entryPrice, targetPrice, stopLoss);
    
    return TradingRecommendation(
      action: _mapToTradeAction(action),
      confidence: confidence,
      entryPrice: entryPrice,
      targetPrice: targetPrice,
      stopLoss: stopLoss,
      timeframe: 'قصير-متوسط الأجل',
      reason: reason,
      riskRewardRatio: riskReward,
    );
  }

  /// تحليل السعر من string أو double
  double? _parsePrice(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleaned);
    }
    return null;
  }

  /// تحليل الثقة من string أو double
  double? _parseConfidence(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble() / 100;
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
      final parsed = double.tryParse(cleaned);
      return parsed != null && parsed > 1 ? parsed / 100 : parsed;
    }
    return null;
  }

  /// حساب نسبة المخاطرة للعائد
  double _calculateRiskReward(double entry, double target, double stopLoss) {
    final potentialProfit = (target - entry).abs();
    final potentialLoss = (entry - stopLoss).abs();
    
    if (potentialLoss == 0) return 0.0;
    return potentialProfit / potentialLoss;
  }

  /// تحويل string إلى TradeAction
  TradeAction _mapToTradeAction(String action) {
    switch (action.toUpperCase()) {
      case 'BUY':
        return TradeAction.buy;
      case 'SELL':
        return TradeAction.sell;
      case 'STRONG_BUY':
        return TradeAction.strongBuy;
      case 'STRONG_SELL':
        return TradeAction.strongSell;
      default:
        return TradeAction.hold;
    }
  }

  /// احصل على LSTM Predictor
  LSTMPricePredictor get predictor => _lstmPredictor;

  /// احصل على News Service
  NewsService get newsService => _newsService;

  /// احصل على Alert Manager
  SmartAlertManager get alertManager => _alertManager;
}

