import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/gold_price_service.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/type_converter.dart';

/// 📊 Chart Data State
class ChartDataState {
  final List<PricePoint> historicalData;
  final bool isLoading;
  final String? error;
  final String timeframe; // '1H', '4H', '1D', '1W', '1M'

  ChartDataState({
    this.historicalData = const [],
    this.isLoading = false,
    this.error,
    this.timeframe = '1H',
  });

  ChartDataState copyWith({
    List<PricePoint>? historicalData,
    bool? isLoading,
    String? error,
    String? timeframe,
  }) {
    return ChartDataState(
      historicalData: historicalData ?? this.historicalData,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      timeframe: timeframe ?? this.timeframe,
    );
  }
}

/// 📊 Price Point Model
class PricePoint {
  final DateTime timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  PricePoint({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.volume = 0,
  });

  factory PricePoint.fromJson(Map<String, dynamic> json) {
    return PricePoint(
      timestamp: DateTime.parse(json['timestamp']),
      open: TypeConverter.safeToDouble(json['open']) ?? 0.0,
      high: TypeConverter.safeToDouble(json['high']) ?? 0.0,
      low: TypeConverter.safeToDouble(json['low']) ?? 0.0,
      close: TypeConverter.safeToDouble(json['close']) ?? 0.0,
      volume: TypeConverter.safeToDouble(json['volume']) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
    };
  }
}

/// 📊 Chart Data Notifier
class ChartDataNotifier extends StateNotifier<ChartDataState> {
  ChartDataNotifier() : super(ChartDataState()) {
    _init();
  }

  Future<void> _init() async {
    await loadHistoricalData();
  }

  /// Load historical data
  Future<void> loadHistoricalData({String? timeframe}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final tf = timeframe ?? state.timeframe;
      AppLogger.info('Loading chart data for timeframe: $tf');

      // Generate mock historical data (في الإنتاج، استبدل بـ API حقيقي)
      final data = await _generateMockData(tf);

      state = state.copyWith(
        historicalData: data,
        isLoading: false,
        timeframe: tf,
      );

      AppLogger.success('Chart data loaded: ${data.length} points');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load chart data', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'فشل تحميل بيانات الرسم البياني',
      );
    }
  }

  /// Change timeframe
  Future<void> changeTimeframe(String timeframe) async {
    if (timeframe == state.timeframe) return;
    await loadHistoricalData(timeframe: timeframe);
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadHistoricalData();
  }

  /// Generate mock historical data
  Future<List<PricePoint>> _generateMockData(String timeframe) async {
    // الحصول على السعر الحالي
    final currentPrice = await GoldPriceService.getCurrentPrice();
    final basePrice = currentPrice.price;

    // تحديد عدد النقاط بناءً على الإطار الزمني
    int dataPoints;
    Duration interval;

    switch (timeframe) {
      case '1H':
        dataPoints = 60;
        interval = const Duration(minutes: 1);
        break;
      case '4H':
        dataPoints = 48;
        interval = const Duration(minutes: 5);
        break;
      case '1D':
        dataPoints = 24;
        interval = const Duration(hours: 1);
        break;
      case '1W':
        dataPoints = 7;
        interval = const Duration(days: 1);
        break;
      case '1M':
        dataPoints = 30;
        interval = const Duration(days: 1);
        break;
      default:
        dataPoints = 60;
        interval = const Duration(minutes: 1);
    }

    final data = <PricePoint>[];
    final now = DateTime.now();
    double currentOpen = basePrice;

    for (int i = dataPoints - 1; i >= 0; i--) {
      final timestamp = now.subtract(interval * i);

      // توليد تقلبات عشوائية واقعية
      final volatility = basePrice * 0.002; // 0.2% volatility
      final change =
          (DateTime.now().millisecondsSinceEpoch % 100 - 50) / 50 * volatility;

      final open = currentOpen;
      final close = open + change;
      final high =
          [open, close].reduce((a, b) => a > b ? a : b) + volatility * 0.5;
      final low =
          [open, close].reduce((a, b) => a < b ? a : b) - volatility * 0.5;
      final volume =
          1000 + (DateTime.now().millisecondsSinceEpoch % 5000).toDouble();

      data.add(PricePoint(
        timestamp: timestamp,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume,
      ));

      currentOpen = close;
    }

    return data;
  }
}

/// 📊 Chart Data Provider Instance
final chartDataProvider =
    StateNotifierProvider.autoDispose<ChartDataNotifier, ChartDataState>((ref) {
  return ChartDataNotifier();
});
