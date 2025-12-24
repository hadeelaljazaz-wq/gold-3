import 'package:flutter_test/flutter_test.dart';
import 'package:golden_nightmare_pro/models/candle.dart';
import 'package:golden_nightmare_pro/models/advanced/candle_data.dart';
import 'package:golden_nightmare_pro/models/advanced/market_context.dart';
import 'package:golden_nightmare_pro/models/advanced/alert_models.dart';
import 'package:golden_nightmare_pro/services/ml/lstm_predictor.dart';
import 'package:golden_nightmare_pro/services/news/news_service.dart';
import 'package:golden_nightmare_pro/services/alerts/smart_alert_manager.dart';
import 'package:golden_nightmare_pro/services/advanced_analysis/advanced_analysis_service.dart';

void main() {
  group('Advanced Analysis System Tests', () {
    test('LSTM Predictor should initialize', () async {
      final predictor = LSTMPricePredictor();
      await predictor.initialize();
      expect(predictor, isNotNull);
    });

    test('CandleData should convert from Candle', () {
      final candle = Candle(
        time: DateTime.now(),
        open: 2100.0,
        high: 2110.0,
        low: 2090.0,
        close: 2105.0,
        volume: 1000.0,
      );

      final candleData = CandleData.fromCandle(candle);
      
      expect(candleData.timestamp, candle.time);
      expect(candleData.open, candle.open);
      expect(candleData.close, candle.close);
    });

    test('MarketContext should create empty context', () {
      final context = MarketContext.empty();
      
      expect(context.economicSentiment, 0.0);
      expect(context.volatilityIndex, 50.0);
      expect(context.newsImpactScore, 0.0);
      expect(context.upcomingEvents, isEmpty);
    });

    test('NewsService should initialize', () {
      final newsService = NewsService();
      newsService.initialize();
      expect(newsService, isNotNull);
    });

    test('SmartAlertManager should add alerts', () {
      final manager = SmartAlertManager();
      
      manager.addPriceAlert(
        price: 2150.0,
        type: AlertType.priceAbove,
        label: 'Test Alert',
      );
      
      expect(manager.alerts.length, 1);
      expect(manager.alerts.first.price, 2150.0);
    });

    test('SmartAlertManager should trigger alerts', () {
      final manager = SmartAlertManager();
      
      manager.addPriceAlert(
        price: 2150.0,
        type: AlertType.priceAbove,
        label: 'Test Alert',
      );
      
      // فحص عند سعر أعلى
      manager.checkAlerts(2155.0);
      
      expect(manager.alerts.first.triggered, true);
    });

    test('AdvancedAnalysisService should initialize', () async {
      final service = AdvancedAnalysisService();
      await service.initialize();
      expect(service, isNotNull);
    });
  });

  group('LSTM Predictor Confidence Tests', () {
    test('Confidence should be between 0.35 and 0.85', () async {
      final predictor = LSTMPricePredictor();
      await predictor.initialize();

      // بيانات اختبار
      final testData = List.generate(
        100,
        (i) => CandleData(
          timestamp: DateTime.now().subtract(Duration(hours: 100 - i)),
          open: 2100.0 + (i * 0.5),
          high: 2110.0 + (i * 0.5),
          low: 2090.0 + (i * 0.5),
          close: 2105.0 + (i * 0.5),
          volume: 1000.0,
        ),
      );

      final context = MarketContext.empty();
      final result = await predictor.predictPrice(
        historicalData: testData,
        context: context,
      );

      expect(result.confidence.overall, greaterThanOrEqualTo(0.35));
      expect(result.confidence.overall, lessThanOrEqualTo(0.85));
    });

    test('Predictions should have 24 points', () async {
      final predictor = LSTMPricePredictor();
      await predictor.initialize();

      final testData = List.generate(
        100,
        (i) => CandleData(
          timestamp: DateTime.now().subtract(Duration(hours: 100 - i)),
          open: 2100.0,
          high: 2110.0,
          low: 2090.0,
          close: 2105.0,
          volume: 1000.0,
        ),
      );

      final context = MarketContext.empty();
      final result = await predictor.predictPrice(
        historicalData: testData,
        context: context,
      );

      expect(result.predictions.length, 24);
    });
  });
}

