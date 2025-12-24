// 🚀 Real-Time AI Service - خدمة الذكاء الاصطناعي اللحظية
// Connects AI Engine with Real-Time Gold Price

import 'dart:async';
import '../../models/candle.dart';
import '../gold_price_service.dart';
import '../csv_data_service.dart';
import 'gold_ai_engine.dart';

/// 🚀 Real-Time AI Service
/// يربط نظام AI بالسعر اللحظي والبيانات التاريخية
class RealTimeAIService {
  static final RealTimeAIService _instance = RealTimeAIService._internal();
  factory RealTimeAIService() => _instance;
  RealTimeAIService._internal();

  final _aiEngine = GoldAIEngine();

  // Cache
  AIGoldPrediction? _lastPrediction;
  DateTime? _lastPredictionTime;
  double? _lastRealTimePrice;
  List<Candle>? _cachedCandles;

  // Stream controller for real-time updates
  final _predictionController = StreamController<AIGoldPrediction>.broadcast();
  Stream<AIGoldPrediction> get predictionStream => _predictionController.stream;

  Timer? _updateTimer;
  bool _isInitialized = false;

  /// تهيئة الخدمة
  Future<void> initialize() async {
    if (_isInitialized) return;

    print('🚀 Initializing Real-Time AI Service...');

    try {
      // 1. تحميل البيانات التاريخية
      await _loadHistoricalData();

      // 2. جلب السعر اللحظي
      await _fetchRealTimePrice();

      // 3. توليد التنبؤ الأولي
      await _generatePrediction();

      // 4. بدء التحديث التلقائي
      _startAutoUpdate();

      _isInitialized = true;
      print('✅ Real-Time AI Service initialized successfully!');
    } catch (e) {
      print('❌ Failed to initialize Real-Time AI Service: $e');
      rethrow;
    }
  }

  /// تحميل البيانات التاريخية
  Future<void> _loadHistoricalData() async {
    print('📊 Loading historical data...');

    try {
      // جرب تحميل بيانات 15 دقيقة أولاً
      _cachedCandles = await CsvDataService.loadScalpData();

      if (_cachedCandles == null || _cachedCandles!.length < 100) {
        // جرب بيانات 4 ساعات
        _cachedCandles = await CsvDataService.loadSwingData();
      }

      if (_cachedCandles != null && _cachedCandles!.isNotEmpty) {
        print('✅ Loaded ${_cachedCandles!.length} candles');
      } else {
        throw Exception('لا توجد بيانات تاريخية متاحة');
      }
    } catch (e) {
      print('⚠️ Error loading historical data: $e');
      // إنشاء بيانات افتراضية
      _cachedCandles = _generateDefaultCandles();
    }
  }

  /// جلب السعر اللحظي الحقيقي
  Future<double> _fetchRealTimePrice() async {
    print('💰 Fetching real-time gold price...');

    try {
      final goldPrice = await GoldPriceService.getCurrentPrice();
      _lastRealTimePrice = goldPrice.price;
      print('✅ Real-time price: \$${_lastRealTimePrice!.toStringAsFixed(2)}');
      return _lastRealTimePrice!;
    } catch (e) {
      print('⚠️ Error fetching real-time price: $e');
      // استخدام آخر سعر من البيانات التاريخية
      if (_cachedCandles != null && _cachedCandles!.isNotEmpty) {
        _lastRealTimePrice = _cachedCandles!.last.close;
        print(
            '📊 Using last historical price: \$${_lastRealTimePrice!.toStringAsFixed(2)}');
      } else {
        _lastRealTimePrice = 2620.0; // سعر افتراضي
      }
      return _lastRealTimePrice!;
    }
  }

  /// توليد التنبؤ
  Future<AIGoldPrediction> _generatePrediction() async {
    if (_cachedCandles == null || _cachedCandles!.isEmpty) {
      throw Exception('لا توجد بيانات متاحة للتنبؤ');
    }

    final currentPrice = _lastRealTimePrice ?? _cachedCandles!.last.close;

    print('🧠 Generating AI prediction...');
    print('   Current Price: \$${currentPrice.toStringAsFixed(2)}');
    print('   Historical Data: ${_cachedCandles!.length} candles');

    final prediction = await _aiEngine.predict(
      currentPrice: currentPrice,
      candles: _cachedCandles!,
    );

    _lastPrediction = prediction;
    _lastPredictionTime = DateTime.now();

    // إرسال التحديث للمستمعين
    _predictionController.add(prediction);

    return prediction;
  }

  /// بدء التحديث التلقائي
  void _startAutoUpdate() {
    _updateTimer?.cancel();

    // تحديث كل 5 دقائق
    _updateTimer = Timer.periodic(const Duration(minutes: 5), (_) async {
      try {
        await _fetchRealTimePrice();
        await _generatePrediction();
      } catch (e) {
        print('⚠️ Auto-update error: $e');
      }
    });

    print('⏰ Auto-update started (every 5 minutes)');
  }

  /// الحصول على التنبؤ الحالي
  Future<AIGoldPrediction> getCurrentPrediction(
      {bool forceRefresh = false}) async {
    await initialize();

    // إذا التنبؤ قديم (أكثر من 5 دقائق) أو مطلوب تحديث
    if (forceRefresh ||
        _lastPrediction == null ||
        _lastPredictionTime == null ||
        DateTime.now().difference(_lastPredictionTime!).inMinutes >= 5) {
      await _fetchRealTimePrice();
      return await _generatePrediction();
    }

    return _lastPrediction!;
  }

  /// الحصول على السعر اللحظي
  Future<double> getRealTimePrice() async {
    return await _fetchRealTimePrice();
  }

  /// الحصول على البيانات التاريخية
  List<Candle>? getHistoricalCandles() => _cachedCandles;

  /// تحديث فوري
  Future<AIGoldPrediction> forceUpdate() async {
    print('🔄 Force updating prediction...');
    await _fetchRealTimePrice();
    return await _generatePrediction();
  }

  /// إيقاف الخدمة
  void dispose() {
    _updateTimer?.cancel();
    _predictionController.close();
    _isInitialized = false;
    print('🛑 Real-Time AI Service disposed');
  }

  /// إنشاء بيانات افتراضية
  List<Candle> _generateDefaultCandles() {
    final candles = <Candle>[];
    var price = 2620.0;
    final now = DateTime.now();

    for (int i = 200; i >= 0; i--) {
      final change = (DateTime.now().millisecond % 10 - 5) * 0.5;
      price += change;

      candles.add(Candle(
        time: now.subtract(Duration(hours: i)),
        open: price - 2,
        high: price + 5,
        low: price - 5,
        close: price,
        volume: 1000000.0 + (i * 10000),
      ));
    }

    return candles;
  }

  /// الحصول على ملخص سريع
  Future<QuickSummary> getQuickSummary() async {
    final prediction = await getCurrentPrediction();
    final price = await getRealTimePrice();

    return QuickSummary(
      currentPrice: price,
      direction: prediction.direction,
      confidence: prediction.confidence.overall,
      primaryRecommendation: prediction.recommendations.isNotEmpty
          ? prediction.recommendations.first
          : null,
      nextTarget: prediction.predictions.isNotEmpty
          ? prediction.predictions.last.price
          : price,
    );
  }
}

/// ملخص سريع
class QuickSummary {
  final double currentPrice;
  final String direction;
  final double confidence;
  final AIRecommendation? primaryRecommendation;
  final double nextTarget;

  QuickSummary({
    required this.currentPrice,
    required this.direction,
    required this.confidence,
    required this.primaryRecommendation,
    required this.nextTarget,
  });

  String get directionEmoji {
    switch (direction) {
      case 'STRONG_BULLISH':
        return '🚀';
      case 'BULLISH':
        return '📈';
      case 'STRONG_BEARISH':
        return '📉';
      case 'BEARISH':
        return '↘️';
      default:
        return '↔️';
    }
  }

  String get directionText {
    switch (direction) {
      case 'STRONG_BULLISH':
        return 'صعود قوي';
      case 'BULLISH':
        return 'صعود';
      case 'STRONG_BEARISH':
        return 'هبوط قوي';
      case 'BEARISH':
        return 'هبوط';
      default:
        return 'محايد';
    }
  }
}
