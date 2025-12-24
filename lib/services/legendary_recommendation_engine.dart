import 'dart:math';
import '../services/gold_price_service.dart';

// ════════════════════════════════════════════════════════════════
// 🏆 LEGENDARY RECOMMENDATION ENGINE
// ════════════════════════════════════════════════════════════════

/// قوة الإشارة
enum SignalStrength {
  weak, // ضعيف: 1-3
  medium, // متوسط: 4-6
  strong, // قوي: 7-8
  extreme, // قوي جداً: 9-10
}

/// نوع التوصية
enum RecommendationType {
  strongBuy, // شراء قوي
  buy, // شراء
  hold, // انتظار
  sell, // بيع
  strongSell, // بيع قوي
}

/// نتيجة التحليل الشاملة
class LegendarySignal {
  final RecommendationType type;
  final SignalStrength strength;
  final double confidence; // 0-100%
  final String reason;
  final Map<String, double> indicators;
  final DateTime timestamp;
  final double? entryPrice;
  final double? stopLoss;
  final double? takeProfit;

  LegendarySignal({
    required this.type,
    required this.strength,
    required this.confidence,
    required this.reason,
    required this.indicators,
    required this.timestamp,
    this.entryPrice,
    this.stopLoss,
    this.takeProfit,
  });

  @override
  String toString() {
    return '''
╔═══════════════════════════════════════╗
║     🎯 LEGENDARY SIGNAL DETECTED      ║
╚═══════════════════════════════════════╝
📊 Type: ${type.name.toUpperCase()}
💪 Strength: ${strength.name.toUpperCase()} (${confidence.toStringAsFixed(1)}%)
💡 Reason: $reason
${entryPrice != null ? '💰 Entry: \$${entryPrice!.toStringAsFixed(2)}' : ''}
${stopLoss != null ? '🛑 Stop Loss: \$${stopLoss!.toStringAsFixed(2)}' : ''}
${takeProfit != null ? '🎯 Take Profit: \$${takeProfit!.toStringAsFixed(2)}' : ''}
⏰ Time: ${timestamp.toLocal()}
''';
  }
}

/// ════════════════════════════════════════════════════════════════
/// 🧠 المحرك الأسطوري
/// ════════════════════════════════════════════════════════════════
class LegendaryRecommendationEngine {
  // ═══ Memory & State ═══
  final List<double> _priceHistory = [];
  final List<LegendarySignal> _signalHistory = [];
  LegendarySignal? _currentSignal;
  DateTime _lastSignalTime = DateTime.now();

  // ═══ Configuration ═══
  final int historySize;
  final int cooldownSeconds;
  final double minPriceChangePercent;
  final bool useAIModel;

  LegendaryRecommendationEngine({
    this.historySize = 200,
    this.cooldownSeconds = 30,
    this.minPriceChangePercent = 0.08,
    this.useAIModel = true,
  });

  /// ═══════════════════════════════════════════════════════════════
  /// 🎯 التحليل الرئيسي - نقطة الدخول
  /// ═══════════════════════════════════════════════════════════════
  Future<LegendarySignal?> analyze(
    double currentPrice, {
    Map<String, dynamic>? aiModelOutput,
  }) async {
    // 1. فحص حالة السوق - CRITICAL CHECK
    final marketStatus = GoldPriceService.getMarketStatus();
    if (!marketStatus.isOpen) {
      return null; // لا توصيات عندما السوق مغلق
    }

    // 2. فحص استقرار السعر - CRITICAL CHECK
    final goldPrice = await GoldPriceService.getCurrentPrice();
    final priceChange = goldPrice.change.abs();
    final priceChangePercent = goldPrice.changePercent.abs();

    // إذا السعر ثابت (تغير أقل من 0.1$ أو 0.01%) → لا توصية
    if (priceChange < 0.1 && priceChangePercent < 0.01) {
      return null; // السعر ثابت - لا توصيات
    }

    // 3. تحديث السجل
    _updatePriceHistory(currentPrice);

    // 4. فحص Cooldown
    if (!_canGenerateNewSignal()) {
      return _currentSignal;
    }

    // 5. فحص استقرار السعر (من السجل)
    if (!_hasSignificantPriceMovement(currentPrice)) {
      return null;
    }

    // 6. تحليل متعدد الطبقات
    final technicalScore = _analyzeTechnicalIndicators();
    final momentumScore = _analyzeMomentum();
    final volatilityScore = _analyzeVolatility();
    final trendScore = _analyzeTrend();
    final aiScore = aiModelOutput != null && useAIModel
        ? _extractAIScore(aiModelOutput)
        : 0.5;

    // 7. دمج النتائج (Weighted Average)
    final compositeScore = _calculateCompositeScore({
      'technical': technicalScore * 0.25,
      'momentum': momentumScore * 0.20,
      'volatility': volatilityScore * 0.15,
      'trend': trendScore * 0.25,
      'ai': aiScore * 0.15,
    });

    // 8. اتخاذ القرار
    final signal = _generateSignal(currentPrice, compositeScore, {
      'technical': technicalScore,
      'momentum': momentumScore,
      'volatility': volatilityScore,
      'trend': trendScore,
      'ai': aiScore,
    });

    // 9. حفظ الإشارة
    if (signal != null) {
      _currentSignal = signal;
      _signalHistory.add(signal);
      _lastSignalTime = DateTime.now();
    }

    return signal;
  }

  /// ═══════════════════════════════════════════════════════════════
  /// 📊 التحليل الفني (RSI, MACD-like, Bollinger)
  /// ═══════════════════════════════════════════════════════════════
  double _analyzeTechnicalIndicators() {
    if (_priceHistory.length < 20) return 0.5;

    final rsi = _calculateRSI(14);
    final bollingerPosition = _calculateBollingerPosition();
    final smaRelation = _calculateSMARelation();

    double score = 0.5;

    // RSI Analysis
    if (rsi < 30) {
      score += 0.2; // Oversold - إشارة شراء
    } else if (rsi > 70) {
      score -= 0.2; // Overbought - إشارة بيع
    }

    // Bollinger Analysis
    if (bollingerPosition < 0.2) {
      score += 0.15; // قرب الحد السفلي
    } else if (bollingerPosition > 0.8) {
      score -= 0.15; // قرب الحد العلوي
    }

    // SMA Relation
    score += smaRelation * 0.15;

    return score.clamp(0.0, 1.0);
  }

  /// ═══════════════════════════════════════════════════════════════
  /// 🚀 تحليل الزخم (Momentum)
  /// ═══════════════════════════════════════════════════════════════
  double _analyzeMomentum() {
    if (_priceHistory.length < 10) return 0.5;

    final recentPrices = _priceHistory.sublist(_priceHistory.length - 10);
    final momentum =
        (recentPrices.last - recentPrices.first) / recentPrices.first;

    // تحويل Momentum إلى Score (0-1)
    return (0.5 + (momentum * 10)).clamp(0.0, 1.0);
  }

  /// ═══════════════════════════════════════════════════════════════
  /// 📈 تحليل الاتجاه (Trend)
  /// ═══════════════════════════════════════════════════════════════
  double _analyzeTrend() {
    if (_priceHistory.length < 50) return 0.5;

    final sma20 = _calculateSMA(20);
    final sma50 = _calculateSMA(50);
    final currentPrice = _priceHistory.last;

    double score = 0.5;

    // Golden Cross / Death Cross
    if (sma20 > sma50) {
      score += 0.2; // اتجاه صاعد
    } else {
      score -= 0.2; // اتجاه هابط
    }

    // السعر فوق/تحت المتوسطات
    if (currentPrice > sma20 && currentPrice > sma50) {
      score += 0.15;
    } else if (currentPrice < sma20 && currentPrice < sma50) {
      score -= 0.15;
    }

    return score.clamp(0.0, 1.0);
  }

  /// ═══════════════════════════════════════════════════════════════
  /// 📊 تحليل التقلب (Volatility)
  /// ═══════════════════════════════════════════════════════════════
  double _analyzeVolatility() {
    if (_priceHistory.length < 20) return 0.5;

    final volatility = _calculateVolatility(20);

    // تقلب منخفض = سوق مستقر (0.5)
    // تقلب مرتفع = فرص أكبر (نحو 0.3 أو 0.7 حسب الاتجاه)
    if (volatility < 0.01) {
      return 0.5; // مستقر جداً
    } else if (volatility > 0.05) {
      return 0.4; // متقلب جداً - حذر
    }

    return 0.5 + (volatility * 2); // تقلب معتدل
  }

  /// ═══════════════════════════════════════════════════════════════
  /// 🤖 استخراج نتيجة الذكاء الاصطناعي
  /// ═══════════════════════════════════════════════════════════════
  double _extractAIScore(Map<String, dynamic> aiOutput) {
    // افترض أن النموذج يعطي: {"recommendation": "BUY/SELL", "confidence": 0.85}
    final recommendation =
        aiOutput['recommendation']?.toString().toUpperCase() ?? '';
    final confidence = (aiOutput['confidence'] as num?)?.toDouble() ?? 0.5;

    if (recommendation.contains('BUY')) {
      return 0.5 + (confidence * 0.5); // 0.5 - 1.0
    } else if (recommendation.contains('SELL')) {
      return 0.5 - (confidence * 0.5); // 0.0 - 0.5
    }

    return 0.5;
  }

  /// ═══════════════════════════════════════════════════════════════
  /// 🎯 حساب النتيجة المركبة
  /// ═══════════════════════════════════════════════════════════════
  double _calculateCompositeScore(Map<String, double> scores) {
    return scores.values.reduce((a, b) => a + b);
  }

  /// ═══════════════════════════════════════════════════════════════
  /// 📤 توليد الإشارة النهائية
  /// ═══════════════════════════════════════════════════════════════
  LegendarySignal? _generateSignal(
    double currentPrice,
    double compositeScore,
    Map<String, double> indicators,
  ) {
    // تحديد نوع التوصية
    RecommendationType type;
    SignalStrength strength;
    String reason;

    if (compositeScore >= 0.75) {
      type = RecommendationType.strongBuy;
      strength = SignalStrength.extreme;
      reason = 'Multiple strong bullish indicators aligned';
    } else if (compositeScore >= 0.60) {
      type = RecommendationType.buy;
      strength = SignalStrength.strong;
      reason = 'Bullish trend with good momentum';
    } else if (compositeScore >= 0.45 && compositeScore <= 0.55) {
      // منطقة محايدة - لا نصدر إشارة
      return null;
    } else if (compositeScore >= 0.30) {
      type = RecommendationType.sell;
      strength = SignalStrength.strong;
      reason = 'Bearish trend detected';
    } else {
      type = RecommendationType.strongSell;
      strength = SignalStrength.extreme;
      reason = 'Multiple strong bearish indicators';
    }

    // حساب Stop Loss & Take Profit
    final atr = _calculateVolatility(14) * currentPrice;
    final stopLoss =
        type == RecommendationType.buy || type == RecommendationType.strongBuy
        ? currentPrice - (atr * 2)
        : currentPrice + (atr * 2);
    final takeProfit =
        type == RecommendationType.buy || type == RecommendationType.strongBuy
        ? currentPrice + (atr * 3)
        : currentPrice - (atr * 3);

    return LegendarySignal(
      type: type,
      strength: strength,
      confidence: (compositeScore - 0.5).abs() * 200, // 0-100%
      reason: reason,
      indicators: indicators,
      timestamp: DateTime.now(),
      entryPrice: currentPrice,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// 🛠️ Helper Functions
  /// ═══════════════════════════════════════════════════════════════

  void _updatePriceHistory(double price) {
    _priceHistory.add(price);
    if (_priceHistory.length > historySize) {
      _priceHistory.removeAt(0);
    }
  }

  bool _canGenerateNewSignal() {
    final elapsed = DateTime.now().difference(_lastSignalTime).inSeconds;
    return elapsed >= cooldownSeconds;
  }

  bool _hasSignificantPriceMovement(double currentPrice) {
    if (_priceHistory.isEmpty) return true;

    final lastPrice = _priceHistory.last;
    final changePercent = ((currentPrice - lastPrice) / lastPrice * 100).abs();

    return changePercent >= minPriceChangePercent;
  }

  double _calculateRSI(int period) {
    if (_priceHistory.length < period + 1) return 50;

    final changes = <double>[];
    for (int i = _priceHistory.length - period; i < _priceHistory.length; i++) {
      changes.add(_priceHistory[i] - _priceHistory[i - 1]);
    }

    final gains = changes.where((c) => c > 0).toList();
    final losses = changes.where((c) => c < 0).map((c) => -c).toList();

    final avgGain = gains.isEmpty ? 0 : gains.reduce((a, b) => a + b) / period;
    final avgLoss = losses.isEmpty
        ? 0
        : losses.reduce((a, b) => a + b) / period;

    if (avgLoss == 0) return 100;
    final rs = avgGain / avgLoss;
    return 100 - (100 / (1 + rs));
  }

  double _calculateSMA(int period) {
    if (_priceHistory.length < period) return _priceHistory.last;

    final subset = _priceHistory.sublist(_priceHistory.length - period);
    return subset.reduce((a, b) => a + b) / period;
  }

  double _calculateBollingerPosition() {
    if (_priceHistory.length < 20) return 0.5;

    final sma = _calculateSMA(20);
    final stdDev = _calculateStdDev(20);
    final currentPrice = _priceHistory.last;

    final upperBand = sma + (stdDev * 2);
    final lowerBand = sma - (stdDev * 2);

    if (upperBand == lowerBand) return 0.5;
    return ((currentPrice - lowerBand) / (upperBand - lowerBand)).clamp(
      0.0,
      1.0,
    );
  }

  double _calculateSMARelation() {
    if (_priceHistory.length < 20) return 0;

    final sma = _calculateSMA(20);
    final currentPrice = _priceHistory.last;

    return ((currentPrice - sma) / sma).clamp(-0.5, 0.5);
  }

  double _calculateVolatility(int period) {
    if (_priceHistory.length < period) return 0;

    return _calculateStdDev(period) / _calculateSMA(period);
  }

  double _calculateStdDev(int period) {
    if (_priceHistory.length < period) return 0;

    final subset = _priceHistory.sublist(_priceHistory.length - period);
    final mean = subset.reduce((a, b) => a + b) / period;
    final variance =
        subset.map((p) => pow(p - mean, 2)).reduce((a, b) => a + b) / period;

    return sqrt(variance);
  }

  /// ═══════════════════════════════════════════════════════════════
  /// 📊 الحصول على آخر إشارة
  /// ═══════════════════════════════════════════════════════════════
  LegendarySignal? get currentSignal => _currentSignal;

  List<LegendarySignal> get signalHistory => List.unmodifiable(_signalHistory);
}
