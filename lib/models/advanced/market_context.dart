/// MarketContext - سياق السوق للتنبؤات
class MarketContext {
  final double economicSentiment; // -1 to 1
  final double volatilityIndex; // 0 to 100
  final double newsImpactScore; // 0 to 1
  final List<EconomicEvent> upcomingEvents;

  MarketContext({
    required this.economicSentiment,
    required this.volatilityIndex,
    required this.newsImpactScore,
    required this.upcomingEvents,
  });

  factory MarketContext.empty() {
    return MarketContext(
      economicSentiment: 0.0,
      volatilityIndex: 50.0,
      newsImpactScore: 0.0,
      upcomingEvents: [],
    );
  }
}

/// EconomicEvent - حدث اقتصادي
class EconomicEvent {
  final String name;
  final DateTime timestamp;
  final String importance; // low, medium, high
  final String? expectedImpact;

  EconomicEvent({
    required this.name,
    required this.timestamp,
    required this.importance,
    this.expectedImpact,
  });
}

