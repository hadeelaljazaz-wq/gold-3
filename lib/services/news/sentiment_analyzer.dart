import 'dart:async';
import '../../models/advanced/news_models.dart';

/// NewsSentimentAnalyzer - تحليل معنويات الأخبار
class NewsSentimentAnalyzer {
  static final NewsSentimentAnalyzer _instance =
      NewsSentimentAnalyzer._internal();

  final Map<String, NewsSentiment> _sentimentCache = {};

  NewsSentimentAnalyzer._internal();

  factory NewsSentimentAnalyzer() => _instance;

  Future<void> initialize() async {
    try {
      print('✅ Sentiment Analyzer initialized');
    } catch (e) {
      print('❌ Sentiment analyzer init failed: $e');
    }
  }

  /// تحليل معنويات النص (Lexicon-based)
  Future<NewsSentiment> analyzeSentiment(String text) async {
    try {
      if (_sentimentCache.containsKey(text)) {
        return _sentimentCache[text]!;
      }

      final result = _fallbackSentimentAnalysis(text);
      _sentimentCache[text] = result;
      return result;
    } catch (e) {
      print('❌ Sentiment analysis failed: $e');
      return NewsSentiment.neutral();
    }
  }

  /// تحليل المعنويات بديل (Lexicon-based)
  NewsSentiment _fallbackSentimentAnalysis(String text) {
    final lowerText = text.toLowerCase();

    // قاموس الكلمات الإيجابية والسلبية
    final positiveWords = [
      'rise',
      'gain',
      'bullish',
      'strong',
      'recovery',
      'boom',
      'rally',
      'surge',
      'soar',
      'up',
      'high',
      'growth',
      'ارتفاع',
      'قوي',
      'نمو',
      'إيجابي',
      'تحسن',
      'انتعاش',
    ];

    final negativeWords = [
      'fall',
      'decline',
      'bearish',
      'weak',
      'crash',
      'plunge',
      'drop',
      'down',
      'low',
      'recession',
      'هبوط',
      'ضعيف',
      'تراجع',
      'سلبي',
      'أزمة',
      'انهيار',
    ];

    double score = 0.0;
    int matchCount = 0;

    for (final word in positiveWords) {
      if (lowerText.contains(word)) {
        score += 0.1;
        matchCount++;
      }
    }

    for (final word in negativeWords) {
      if (lowerText.contains(word)) {
        score -= 0.1;
        matchCount++;
      }
    }

    final magnitude = matchCount > 0 ? (matchCount * 0.1).clamp(0.0, 1.0) : 0.0;
    final finalScore = score.clamp(-1.0, 1.0);

    return NewsSentiment(
      score: finalScore,
      magnitude: magnitude,
      isPositive: finalScore > 0.1,
      isNegative: finalScore < -0.1,
      isNeutral: finalScore.abs() <= 0.1,
      emotions: {},
    );
  }

  /// استخراج المؤشرات الاقتصادية
  List<EconomicIndicator> extractEconomicIndicators(String text) {
    final indicators = <EconomicIndicator>[];

    final indicatorPatterns = {
      'inflation': RegExp(r'inflat\w*', caseSensitive: false),
      'unemployment': RegExp(r'unemploy\w*', caseSensitive: false),
      'gdp': RegExp(r'\bGDP\b|gross.*product', caseSensitive: false),
      'interest_rate': RegExp(r'interest.*rate|fed.*rate', caseSensitive: false),
      'dollar': RegExp(r'\$|dollar|USD', caseSensitive: false),
      'fed': RegExp(r'federal.*reserve|FED|central.*bank', caseSensitive: false),
    };

    for (final entry in indicatorPatterns.entries) {
      if (entry.value.hasMatch(text)) {
        indicators.add(EconomicIndicator(
          name: entry.key,
          mentioned: true,
        ));
      }
    }

    return indicators;
  }
}

