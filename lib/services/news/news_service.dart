import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import '../../models/advanced/news_models.dart';
import 'sentiment_analyzer.dart';

/// NewsService - خدمة جلب وتحليل أخبار الذهب
class NewsService {
  static final NewsService _instance = NewsService._internal();

  final dio = Dio();
  static const String _newsApiKey = 'c01e4fc68767432b876c89b71643cd06';
  
  StreamController<List<GoldNews>>? _newsStreamController;
  Timer? _updateTimer;

  NewsService._internal();

  factory NewsService() => _instance;

  void initialize() {
    _newsStreamController = StreamController<List<GoldNews>>.broadcast();
    _startNewsUpdates();
  }

  /// جلب أخبار الذهب
  Future<List<GoldNews>> fetchGoldNews({
    int limit = 20,
    Duration recency = const Duration(hours: 24),
  }) async {
    try {
      final now = DateTime.now();
      final yesterday = now.subtract(recency);

      print('📰 Fetching gold news from NewsAPI...');

      // جلب من NewsAPI
      final response = await dio.get(
        'https://newsapi.org/v2/everything',
        queryParameters: {
          'q': 'gold OR XAU OR "gold prices" OR "gold market"',
          'apiKey': _newsApiKey,
          'sortBy': 'publishedAt',
          'language': 'en',
          'from': yesterday.toIso8601String(),
          'pageSize': limit,
        },
        options: Options(
          validateStatus: (status) => status != null && status < 500,
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode != 200) {
        print('⚠️ NewsAPI returned ${response.statusCode}: ${response.data}');
        return _getMockNews();
      }

      if (response.data['articles'] == null) {
        print('⚠️ No articles in response');
        return _getMockNews();
      }

      final articles = (response.data['articles'] as List)
          .map((a) => GoldNews.fromJson(a))
          .toList();

      if (articles.isEmpty) {
        print('⚠️ No articles found');
        return _getMockNews();
      }

      print('✅ Fetched ${articles.length} news articles');

      // تحليل المعنويات لكل خبر
      final analyzer = NewsSentimentAnalyzer();
      for (final article in articles) {
        final titleSentiment = await analyzer.analyzeSentiment(article.title);
        final descriptionSentiment = article.description != null
            ? await analyzer.analyzeSentiment(article.description!)
            : NewsSentiment.neutral();

        article.sentiment = NewsSentiment(
          score: (titleSentiment.score * 0.7 + descriptionSentiment.score * 0.3),
          magnitude: max(titleSentiment.magnitude, descriptionSentiment.magnitude),
          isPositive: titleSentiment.score > 0 || descriptionSentiment.score > 0,
          isNegative: titleSentiment.score < 0 || descriptionSentiment.score < 0,
          isNeutral: titleSentiment.isNeutral && descriptionSentiment.isNeutral,
          emotions: {},
        );

        article.importance = _assessNewsImportance(article);
      }

      return articles;
    } catch (e) {
      print('❌ Failed to fetch gold news: $e');
      return _getMockNews();
    }
  }

  /// تقييم أهمية الخبر
  NewsImportance _assessNewsImportance(GoldNews article) {
    double importance = 0.0;

    // العنوان يحتوي على كلمات مهمة
    final keywords = [
      'crash',
      'surge',
      'rally',
      'collapse',
      'record',
      'spike',
      'plunge',
      'soar'
    ];
    if (keywords.any((k) => article.title.toLowerCase().contains(k))) {
      importance += 0.3;
    }

    // معنويات قوية
    if (article.sentiment != null && article.sentiment!.magnitude > 0.7) {
      importance += 0.3;
    }

    // من مصدر موثوق
    final trustedSources = [
      'bloomberg',
      'reuters',
      'cnbc',
      'marketwatch',
      'investing.com'
    ];
    if (trustedSources.any((s) => article.source.toLowerCase().contains(s))) {
      importance += 0.2;
    }

    // تاريخ حديث جداً
    final age = DateTime.now().difference(article.publishedAt);
    if (age.inHours < 2) {
      importance += 0.2;
    }

    if (importance > 0.75) return NewsImportance.critical;
    if (importance > 0.5) return NewsImportance.high;
    if (importance > 0.25) return NewsImportance.medium;
    return NewsImportance.low;
  }

  /// بث الأخبار المباشر
  Stream<List<GoldNews>> get newsStream => _newsStreamController!.stream;

  void _startNewsUpdates() {
    _updateTimer = Timer.periodic(const Duration(minutes: 30), (_) async {
      final news = await fetchGoldNews();
      _newsStreamController?.add(news);
    });
  }

  /// حساب تأثير الأخبار على السوق
  Future<MarketImpactScore> calculateImpactScore(List<GoldNews> news) async {
    if (news.isEmpty) {
      return MarketImpactScore.neutral();
    }

    double totalSentiment = 0.0;
    int weightedCount = 0;

    for (final article in news) {
      if (article.sentiment == null || article.importance == null) continue;

      final weight = _getArticleWeight(article.importance!);
      totalSentiment += article.sentiment!.score * weight;
      weightedCount += weight;
    }

    final averageSentiment =
        weightedCount > 0 ? totalSentiment / weightedCount : 0.0;

    return MarketImpactScore(
      score: averageSentiment.abs(),
      direction: averageSentiment > 0.1
          ? NewsDirection.bullish
          : averageSentiment < -0.1
              ? NewsDirection.bearish
              : NewsDirection.neutral,
      confidence: min(1.0, news.length / 10.0),
      recentNews: news.length,
    );
  }

  int _getArticleWeight(NewsImportance importance) {
    switch (importance) {
      case NewsImportance.critical:
        return 5;
      case NewsImportance.high:
        return 3;
      case NewsImportance.medium:
        return 2;
      case NewsImportance.low:
        return 1;
    }
  }

  /// أخبار وهمية عند فشل API
  List<GoldNews> _getMockNews() {
    final now = DateTime.now();
    return [
      GoldNews(
        title: 'Gold prices edge higher on safe-haven demand',
        description: 'Spot gold gained amid market uncertainty',
        url: 'https://example.com/news1',
        source: 'Reuters',
        publishedAt: now.subtract(const Duration(hours: 1)),
      )..sentiment = NewsSentiment(
          score: 0.4,
          magnitude: 0.6,
          isPositive: true,
          isNegative: false,
          isNeutral: false,
          emotions: {},
        )..importance = NewsImportance.medium,
      GoldNews(
        title: 'Central bank gold purchases continue',
        description: 'Global central banks maintain gold reserves',
        url: 'https://example.com/news2',
        source: 'Bloomberg',
        publishedAt: now.subtract(const Duration(hours: 3)),
      )..sentiment = NewsSentiment(
          score: 0.2,
          magnitude: 0.4,
          isPositive: true,
          isNegative: false,
          isNeutral: false,
          emotions: {},
        )..importance = NewsImportance.low,
    ];
  }

  void dispose() {
    _updateTimer?.cancel();
    _newsStreamController?.close();
  }
}

