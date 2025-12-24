/// GoldNews - خبر متعلق بالذهب
class GoldNews {
  final String title;
  final String? description;
  final String url;
  final String source;
  final DateTime publishedAt;
  final String? imageUrl;

  NewsSentiment? sentiment;
  NewsImportance? importance;

  GoldNews({
    required this.title,
    this.description,
    required this.url,
    required this.source,
    required this.publishedAt,
    this.imageUrl,
  });

  factory GoldNews.fromJson(Map<String, dynamic> json) {
    return GoldNews(
      title: json['title'] ?? '',
      description: json['description'],
      url: json['url'] ?? '',
      source: json['source']?['name'] ?? 'Unknown',
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      imageUrl: json['urlToImage'],
    );
  }
}

/// NewsSentiment - تحليل معنويات الخبر
class NewsSentiment {
  final double score; // -1 to 1
  final double magnitude; // 0 to 1
  final bool isPositive;
  final bool isNegative;
  final bool isNeutral;
  final Map<String, double> emotions;

  NewsSentiment({
    required this.score,
    required this.magnitude,
    required this.isPositive,
    required this.isNegative,
    required this.isNeutral,
    required this.emotions,
  });

  factory NewsSentiment.neutral() => NewsSentiment(
        score: 0.0,
        magnitude: 0.0,
        isPositive: false,
        isNegative: false,
        isNeutral: true,
        emotions: {},
      );
}

/// NewsImportance - أهمية الخبر
enum NewsImportance { critical, high, medium, low }

/// NewsDirection - اتجاه تأثير الأخبار
enum NewsDirection { bullish, bearish, neutral }

/// MarketImpactScore - تأثير الأخبار على السوق
class MarketImpactScore {
  final double score; // 0 to 1
  final NewsDirection direction;
  final double confidence;
  final int recentNews;

  MarketImpactScore({
    required this.score,
    required this.direction,
    required this.confidence,
    required this.recentNews,
  });

  factory MarketImpactScore.neutral() {
    return MarketImpactScore(
      score: 0.0,
      direction: NewsDirection.neutral,
      confidence: 0.0,
      recentNews: 0,
    );
  }
}

/// EconomicIndicator - مؤشر اقتصادي
class EconomicIndicator {
  final String name;
  final bool mentioned;

  EconomicIndicator({
    required this.name,
    required this.mentioned,
  });
}

