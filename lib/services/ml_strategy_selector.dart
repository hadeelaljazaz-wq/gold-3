import 'dart:math';
import '../core/utils/logger.dart';
import '../models/recommendation.dart';
import '../models/market_models.dart';

/// 🤖 ML-Powered Strategy Selector
///
/// Uses machine learning techniques to select the optimal analysis strategy
/// based on historical performance and current market conditions.
///
/// **Features:**
/// - ✅ Performance tracking per strategy
/// - ✅ Multi-armed bandit algorithm (Thompson Sampling)
/// - ✅ Adaptive learning from user feedback
/// - ✅ Context-aware strategy selection
/// - ✅ A/B testing capabilities
/// - ✅ Strategy performance analytics
///
/// **How it works:**
/// 1. Tracks success rate of each strategy
/// 2. Uses Thompson Sampling to balance exploration/exploitation
/// 3. Adapts based on market conditions
/// 4. Learns from user feedback (thumbs up/down)
///
/// **Usage:**
/// ```dart
/// // Get best strategy for current market
/// final strategy = MLStrategySelector.selectStrategy(
///   indicators: technicalIndicators,
///   scalp: scalpSignal,
///   swing: swingSignal,
/// );
///
/// // After analysis, provide feedback
/// MLStrategySelector.recordFeedback(
///   strategyId: strategy.id,
///   wasSuccessful: true,
///   userRating: 4.5,
/// );
/// ```
class MLStrategySelector {
  // ══════════════════════════════════════════════════════════
  // STRATEGY PERFORMANCE TRACKING
  // ══════════════════════════════════════════════════════════
  
  static final Map<String, _StrategyStats> _strategyStats = {};
  static final List<_StrategySelection> _selectionHistory = [];
  static const int _maxHistorySize = 1000;
  
  // Thompson Sampling parameters (Beta distribution)
  static const double _initialAlpha = 1.0; // Prior successes
  static const double _initialBeta = 1.0;  // Prior failures
  
  // Exploration vs Exploitation balance
  static double _explorationRate = 0.15; // 15% exploration
  static const double _minExplorationRate = 0.05;
  static const double _explorationDecay = 0.995;

  // ══════════════════════════════════════════════════════════
  // AVAILABLE STRATEGIES
  // ══════════════════════════════════════════════════════════

  static final List<AnalysisStrategy> _availableStrategies = [
    AnalysisStrategy(
      id: 'aggressive_trend',
      name: 'اتجاه قوي هجومي',
      description: 'استراتيجية هجومية للأسواق ذات الاتجاه الواضح',
      targetConditions: [MarketCondition.strongTrend],
      riskProfile: RiskProfile.aggressive,
      promptStyle: PromptStyle.assertive,
    ),
    AnalysisStrategy(
      id: 'conservative_trend',
      name: 'اتجاه محافظ',
      description: 'استراتيجية محافظة تركز على نقاط الدخول الآمنة',
      targetConditions: [MarketCondition.strongTrend],
      riskProfile: RiskProfile.conservative,
      promptStyle: PromptStyle.cautious,
    ),
    AnalysisStrategy(
      id: 'range_scalper',
      name: 'سكالبينج المدى',
      description: 'استراتيجية سكالبينج للأسواق العرضية',
      targetConditions: [MarketCondition.ranging],
      riskProfile: RiskProfile.moderate,
      promptStyle: PromptStyle.tactical,
    ),
    AnalysisStrategy(
      id: 'volatility_trader',
      name: 'متداول التقلب',
      description: 'استراتيجية للاستفادة من التقلبات العالية',
      targetConditions: [MarketCondition.volatile],
      riskProfile: RiskProfile.aggressive,
      promptStyle: PromptStyle.aggressive,
    ),
    AnalysisStrategy(
      id: 'breakout_hunter',
      name: 'صائد الاختراقات',
      description: 'استراتيجية تستهدف اختراقات التماسك',
      targetConditions: [MarketCondition.consolidation],
      riskProfile: RiskProfile.moderate,
      promptStyle: PromptStyle.patient,
    ),
    AnalysisStrategy(
      id: 'multi_timeframe',
      name: 'أطر زمنية متعددة',
      description: 'تحليل شامل عبر عدة أطر زمنية',
      targetConditions: [
        MarketCondition.strongTrend,
        MarketCondition.ranging,
        MarketCondition.volatile,
      ],
      riskProfile: RiskProfile.balanced,
      promptStyle: PromptStyle.analytical,
    ),
    AnalysisStrategy(
      id: 'news_aware',
      name: 'واعي بالأخبار',
      description: 'استراتيجية تأخذ الأحداث الإخبارية بعين الاعتبار',
      targetConditions: [MarketCondition.volatile, MarketCondition.uncertain],
      riskProfile: RiskProfile.conservative,
      promptStyle: PromptStyle.cautious,
    ),
    AnalysisStrategy(
      id: 'probability_based',
      name: 'احتمالي',
      description: 'تحليل يعتمد على الاحتماليات والإحصاء',
      targetConditions: [
        MarketCondition.ranging,
        MarketCondition.consolidation,
      ],
      riskProfile: RiskProfile.moderate,
      promptStyle: PromptStyle.statistical,
    ),
  ];

  // ══════════════════════════════════════════════════════════
  // STRATEGY SELECTION (Thompson Sampling)
  // ══════════════════════════════════════════════════════════

  /// Select best strategy using Thompson Sampling
  ///
  /// **Algorithm:** Thompson Sampling (Bayesian Multi-Armed Bandit)
  /// - Balances exploration (trying new strategies) vs exploitation (using best known)
  /// - Uses Beta distribution based on historical success/failure
  /// - Adapts to market conditions
  ///
  /// **Parameters:**
  /// - [indicators]: Current technical indicators
  /// - [scalp]: Scalping recommendation
  /// - [swing]: Swing recommendation
  /// - [marketCondition]: Current market condition (optional)
  /// - [forceStrategy]: Force specific strategy (for testing)
  ///
  /// **Returns:** Selected AnalysisStrategy
  static AnalysisStrategy selectStrategy({
    required TechnicalIndicators indicators,
    required Recommendation scalp,
    required Recommendation swing,
    MarketCondition? marketCondition,
    String? forceStrategy,
  }) {
    // Force specific strategy if requested
    if (forceStrategy != null) {
      final strategy = _availableStrategies.firstWhere(
        (s) => s.id == forceStrategy,
        orElse: () => _availableStrategies.first,
      );
      AppLogger.info('Forced strategy: ${strategy.name}');
      return strategy;
    }

    // Detect market condition if not provided
    marketCondition ??= _detectMarketCondition(indicators, scalp, swing);
    
    // Filter strategies suitable for current market condition
    final suitableStrategies = _availableStrategies.where(
      (s) => s.targetConditions.contains(marketCondition),
    ).toList();

    if (suitableStrategies.isEmpty) {
      AppLogger.warn('No suitable strategies for ${marketCondition.nameAr}, using default');
      return _availableStrategies[5]; // Multi-timeframe as fallback
    }

    // Initialize stats for new strategies
    for (final strategy in suitableStrategies) {
      _strategyStats.putIfAbsent(
        strategy.id,
        () => _StrategyStats(
          strategyId: strategy.id,
          alpha: _initialAlpha,
          beta: _initialBeta,
        ),
      );
    }

    // Exploration vs Exploitation decision
    final random = Random();
    final shouldExplore = random.nextDouble() < _explorationRate;

    AnalysisStrategy selected;

    if (shouldExplore) {
      // EXPLORATION: Random selection from suitable strategies
      selected = suitableStrategies[random.nextInt(suitableStrategies.length)];
      AppLogger.debug('Exploring strategy: ${selected.name}');
    } else {
      // EXPLOITATION: Thompson Sampling
      selected = _thompsonSampling(suitableStrategies);
      AppLogger.debug('Exploiting strategy: ${selected.name}');
    }

    // Record selection
    _recordSelection(selected, marketCondition, indicators);

    // Decay exploration rate over time
    _explorationRate = max(_minExplorationRate, _explorationRate * _explorationDecay);

    AppLogger.info('Selected strategy: ${selected.name} (${selected.id})');
    return selected;
  }

  /// Thompson Sampling algorithm
  static AnalysisStrategy _thompsonSampling(List<AnalysisStrategy> strategies) {
    final random = Random();
    double maxSample = -1;
    AnalysisStrategy? bestStrategy;

    for (final strategy in strategies) {
      final stats = _strategyStats[strategy.id]!;
      
      // Sample from Beta distribution
      final sample = _sampleBeta(stats.alpha, stats.beta, random);
      
      if (sample > maxSample) {
        maxSample = sample;
        bestStrategy = strategy;
      }
    }

    return bestStrategy ?? strategies.first;
  }

  /// Sample from Beta distribution (approximation)
  static double _sampleBeta(double alpha, double beta, Random random) {
    // Using Gamma distribution to sample Beta
    // Beta(α, β) = Gamma(α) / (Gamma(α) + Gamma(β))
    
    final gammaAlpha = _sampleGamma(alpha, random);
    final gammaBeta = _sampleGamma(beta, random);
    
    return gammaAlpha / (gammaAlpha + gammaBeta);
  }

  /// Sample from Gamma distribution (approximation using Marsaglia & Tsang)
  static double _sampleGamma(double shape, Random random) {
    if (shape < 1.0) {
      // Use Gamma(shape + 1) * U^(1/shape)
      return _sampleGamma(shape + 1, random) * pow(random.nextDouble(), 1.0 / shape);
    }

    final d = shape - 1.0 / 3.0;
    final c = 1.0 / sqrt(9.0 * d);

    while (true) {
      double x, v;
      
      do {
        x = _sampleNormal(random);
        v = 1.0 + c * x;
      } while (v <= 0);

      v = v * v * v;
      final u = random.nextDouble();
      final x2 = x * x;

      if (u < 1.0 - 0.0331 * x2 * x2) {
        return d * v;
      }

      if (log(u) < 0.5 * x2 + d * (1.0 - v + log(v))) {
        return d * v;
      }
    }
  }

  /// Sample from standard normal distribution (Box-Muller transform)
  static double _sampleNormal(Random random) {
    final u1 = random.nextDouble();
    final u2 = random.nextDouble();
    return sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);
  }

  // ══════════════════════════════════════════════════════════
  // FEEDBACK & LEARNING
  // ══════════════════════════════════════════════════════════

  /// Record feedback for a strategy
  ///
  /// **Parameters:**
  /// - [strategyId]: ID of the strategy that was used
  /// - [wasSuccessful]: Whether the analysis was successful (true/false)
  /// - [userRating]: Optional user rating (1-5 stars)
  /// - [profitLoss]: Optional P/L if user actually traded
  ///
  /// **Learning:**
  /// Updates the strategy's Beta distribution parameters:
  /// - Success → α += 1 (increase alpha)
  /// - Failure → β += 1 (increase beta)
  static void recordFeedback({
    required String strategyId,
    required bool wasSuccessful,
    double? userRating,
    double? profitLoss,
  }) {
    final stats = _strategyStats[strategyId];
    if (stats == null) {
      AppLogger.warn('Strategy not found: $strategyId');
      return;
    }

    // Update Beta distribution parameters
    if (wasSuccessful) {
      stats.alpha += 1.0;
      stats.successCount++;
      
      // Bonus for high user rating
      if (userRating != null && userRating >= 4.0) {
        stats.alpha += 0.5;
      }
    } else {
      stats.beta += 1.0;
      stats.failureCount++;
    }

    stats.totalSelections++;
    
    // Track profit/loss if provided
    if (profitLoss != null) {
      stats.totalProfitLoss += profitLoss;
      if (profitLoss > 0) {
        stats.profitableCount++;
      }
    }

    // Track user ratings
    if (userRating != null) {
      stats.ratingsSum += userRating;
      stats.ratingsCount++;
    }

    stats.lastUpdated = DateTime.now();

    final successRate = (stats.successCount / stats.totalSelections * 100).toStringAsFixed(1);
    AppLogger.info('Feedback recorded for $strategyId: ${wasSuccessful ? '✅' : '❌'} (Success rate: $successRate%)');
  }

  /// Record automatic feedback based on analysis quality
  static void recordAutoFeedback({
    required String strategyId,
    required double qualityScore, // 0-10
    required double responseTime, // milliseconds
  }) {
    // Convert quality score to success/failure
    final wasSuccessful = qualityScore >= 7.0;
    
    // Penalize slow responses
    final timeBonus = responseTime < 3000 ? 0.2 : 0.0;
    final adjustedSuccess = wasSuccessful && (qualityScore + timeBonus) >= 7.2;
    
    recordFeedback(
      strategyId: strategyId,
      wasSuccessful: adjustedSuccess,
      userRating: qualityScore / 2, // Convert 0-10 to 0-5
    );
  }

  // ══════════════════════════════════════════════════════════
  // HELPER METHODS
  // ══════════════════════════════════════════════════════════

  /// Record strategy selection in history
  static void _recordSelection(
    AnalysisStrategy strategy,
    MarketCondition condition,
    TechnicalIndicators indicators,
  ) {
    _selectionHistory.add(_StrategySelection(
      strategyId: strategy.id,
      marketCondition: condition,
      rsi: indicators.rsi,
      timestamp: DateTime.now(),
    ));

    // Trim history if too large
    if (_selectionHistory.length > _maxHistorySize) {
      _selectionHistory.removeRange(0, _selectionHistory.length - _maxHistorySize);
    }
  }

  /// Detect market condition from indicators
  static MarketCondition _detectMarketCondition(
    TechnicalIndicators indicators,
    Recommendation scalp,
    Recommendation swing,
  ) {
    // Strong trend: Both scalp and swing agree + strong indicators
    if (scalp.direction == swing.direction &&
        scalp.confidence.index >= 2 &&
        swing.confidence.index >= 2) {
      return MarketCondition.strongTrend;
    }

    // Volatile: High RSI variance or conflicting signals
    if ((indicators.rsi > 70 || indicators.rsi < 30) &&
        scalp.direction != swing.direction) {
      return MarketCondition.volatile;
    }

    // Ranging: RSI near middle, conflicting directions
    if (indicators.rsi > 45 &&
        indicators.rsi < 55 &&
        scalp.direction != swing.direction) {
      return MarketCondition.ranging;
    }

    // Consolidation: Low confidence signals
    if (scalp.confidence.index < 2 && swing.confidence.index < 2) {
      return MarketCondition.consolidation;
    }

    return MarketCondition.uncertain;
  }

  // ══════════════════════════════════════════════════════════
  // ANALYTICS & REPORTING
  // ══════════════════════════════════════════════════════════

  /// Get performance statistics for all strategies
  static Map<String, dynamic> getPerformanceStats() {
    final stats = <String, dynamic>{};

    for (final strategy in _availableStrategies) {
      final strategyStats = _strategyStats[strategy.id];
      
      if (strategyStats == null) {
        stats[strategy.id] = {
          'name': strategy.name,
          'selections': 0,
          'success_rate': 0.0,
          'avg_rating': 0.0,
          'profit_loss': 0.0,
        };
        continue;
      }

      final successRate = strategyStats.totalSelections > 0
          ? (strategyStats.successCount / strategyStats.totalSelections) * 100
          : 0.0;

      final avgRating = strategyStats.ratingsCount > 0
          ? strategyStats.ratingsSum / strategyStats.ratingsCount
          : 0.0;

      stats[strategy.id] = {
        'name': strategy.name,
        'selections': strategyStats.totalSelections,
        'success_rate': successRate.toStringAsFixed(1),
        'successes': strategyStats.successCount,
        'failures': strategyStats.failureCount,
        'avg_rating': avgRating.toStringAsFixed(2),
        'profit_loss': strategyStats.totalProfitLoss.toStringAsFixed(2),
        'profitable_trades': strategyStats.profitableCount,
        'thompson_score': (strategyStats.alpha / (strategyStats.alpha + strategyStats.beta) * 100).toStringAsFixed(1),
      };
    }

    return stats;
  }

  /// Print performance report
  static void printPerformanceReport() {
    AppLogger.info('═══════════════════════════════════════');
    AppLogger.info('📊 ML STRATEGY PERFORMANCE REPORT');
    AppLogger.info('═══════════════════════════════════════');

    final stats = getPerformanceStats();
    
    // Sort by success rate
    final sortedStats = stats.entries.toList()
      ..sort((a, b) {
        final aRate = double.parse(a.value['success_rate'].toString());
        final bRate = double.parse(b.value['success_rate'].toString());
        return bRate.compareTo(aRate);
      });

    for (final entry in sortedStats) {
      final data = entry.value as Map<String, dynamic>;
      
      if (data['selections'] == 0) continue;
      
      AppLogger.info('');
      AppLogger.info('🎯 ${data['name']}');
      AppLogger.info('   Selections: ${data['selections']}');
      AppLogger.info('   Success Rate: ${data['success_rate']}%');
      AppLogger.info('   User Rating: ${data['avg_rating']}/5.0');
      AppLogger.info('   Thompson Score: ${data['thompson_score']}%');
      
      if (data['profit_loss'] != '0.00') {
        AppLogger.info('   P/L: \$${data['profit_loss']}');
      }
    }

    AppLogger.info('');
    AppLogger.info('═══════════════════════════════════════');
    AppLogger.info('Exploration Rate: ${(_explorationRate * 100).toStringAsFixed(1)}%');
    AppLogger.info('Total Selections: ${_selectionHistory.length}');
    AppLogger.info('═══════════════════════════════════════');
  }

  /// Get best performing strategy overall
  static AnalysisStrategy getBestStrategy() {
    final stats = getPerformanceStats();
    
    String? bestId;
    double bestScore = -1;

    for (final entry in stats.entries) {
      final data = entry.value as Map<String, dynamic>;
      final selections = data['selections'] as int;
      
      if (selections < 5) continue; // Need minimum sample size
      
      final thompsonScore = double.parse(data['thompson_score'].toString());
      
      if (thompsonScore > bestScore) {
        bestScore = thompsonScore;
        bestId = entry.key;
      }
    }

    if (bestId == null) {
      return _availableStrategies[5]; // Multi-timeframe as default
    }

    return _availableStrategies.firstWhere((s) => s.id == bestId);
  }

  /// Reset all learning data (for testing)
  static void resetLearning() {
    _strategyStats.clear();
    _selectionHistory.clear();
    _explorationRate = 0.15;
    AppLogger.info('ML learning data reset');
  }

  /// Export learning data (for backup/analysis)
  static Map<String, dynamic> exportData() {
    return {
      'stats': _strategyStats.map((k, v) => MapEntry(k, v.toJson())),
      'history': _selectionHistory.map((s) => s.toJson()).toList(),
      'exploration_rate': _explorationRate,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Import learning data (for restore)
  static void importData(Map<String, dynamic> data) {
    try {
      _strategyStats.clear();
      _selectionHistory.clear();

      final statsData = data['stats'] as Map<String, dynamic>;
      for (final entry in statsData.entries) {
        _strategyStats[entry.key] = _StrategyStats.fromJson(entry.value);
      }

      final historyData = data['history'] as List<dynamic>;
      for (final item in historyData) {
        _selectionHistory.add(_StrategySelection.fromJson(item));
      }

      _explorationRate = data['exploration_rate'] as double;

      AppLogger.success('ML learning data imported successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to import ML data', e, stackTrace);
    }
  }
}

// ══════════════════════════════════════════════════════════
// MODELS
// ══════════════════════════════════════════════════════════

/// Analysis strategy definition
class AnalysisStrategy {
  final String id;
  final String name;
  final String description;
  final List<MarketCondition> targetConditions;
  final RiskProfile riskProfile;
  final PromptStyle promptStyle;

  AnalysisStrategy({
    required this.id,
    required this.name,
    required this.description,
    required this.targetConditions,
    required this.riskProfile,
    required this.promptStyle,
  });
}

/// Risk profile types
enum RiskProfile {
  conservative,
  moderate,
  balanced,
  aggressive;

  String get nameAr {
    switch (this) {
      case RiskProfile.conservative:
        return 'محافظ';
      case RiskProfile.moderate:
        return 'معتدل';
      case RiskProfile.balanced:
        return 'متوازن';
      case RiskProfile.aggressive:
        return 'هجومي';
    }
  }
}

/// Prompt style types
enum PromptStyle {
  assertive,
  cautious,
  tactical,
  aggressive,
  patient,
  analytical,
  statistical;

  String get nameAr {
    switch (this) {
      case PromptStyle.assertive:
        return 'حاسم';
      case PromptStyle.cautious:
        return 'حذر';
      case PromptStyle.tactical:
        return 'تكتيكي';
      case PromptStyle.aggressive:
        return 'هجومي';
      case PromptStyle.patient:
        return 'صبور';
      case PromptStyle.analytical:
        return 'تحليلي';
      case PromptStyle.statistical:
        return 'إحصائي';
    }
  }
}

/// Strategy performance statistics (Beta distribution)
class _StrategyStats {
  final String strategyId;
  double alpha; // Successes + prior
  double beta;  // Failures + prior
  
  int totalSelections = 0;
  int successCount = 0;
  int failureCount = 0;
  int profitableCount = 0;
  
  double totalProfitLoss = 0.0;
  double ratingsSum = 0.0;
  int ratingsCount = 0;
  
  DateTime lastUpdated;

  _StrategyStats({
    required this.strategyId,
    required this.alpha,
    required this.beta,
  }) : lastUpdated = DateTime.now();

  Map<String, dynamic> toJson() => {
    'strategy_id': strategyId,
    'alpha': alpha,
    'beta': beta,
    'total_selections': totalSelections,
    'success_count': successCount,
    'failure_count': failureCount,
    'profitable_count': profitableCount,
    'total_profit_loss': totalProfitLoss,
    'ratings_sum': ratingsSum,
    'ratings_count': ratingsCount,
    'last_updated': lastUpdated.toIso8601String(),
  };

  factory _StrategyStats.fromJson(Map<String, dynamic> json) {
    return _StrategyStats(
      strategyId: json['strategy_id'],
      alpha: json['alpha'],
      beta: json['beta'],
    )
      ..totalSelections = json['total_selections']
      ..successCount = json['success_count']
      ..failureCount = json['failure_count']
      ..profitableCount = json['profitable_count']
      ..totalProfitLoss = json['total_profit_loss']
      ..ratingsSum = json['ratings_sum']
      ..ratingsCount = json['ratings_count']
      ..lastUpdated = DateTime.parse(json['last_updated']);
  }
}

/// Strategy selection record
class _StrategySelection {
  final String strategyId;
  final MarketCondition marketCondition;
  final double rsi;
  final DateTime timestamp;

  _StrategySelection({
    required this.strategyId,
    required this.marketCondition,
    required this.rsi,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'strategy_id': strategyId,
    'market_condition': marketCondition.name,
    'rsi': rsi,
    'timestamp': timestamp.toIso8601String(),
  };

  factory _StrategySelection.fromJson(Map<String, dynamic> json) {
    return _StrategySelection(
      strategyId: json['strategy_id'],
      marketCondition: MarketCondition.values.firstWhere(
        (c) => c.name == json['market_condition'],
      ),
      rsi: json['rsi'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

/// Market condition (imported from other file, replicated here for completeness)
enum MarketCondition {
  strongTrend,
  ranging,
  volatile,
  consolidation,
  uncertain;

  String get nameAr {
    switch (this) {
      case MarketCondition.strongTrend:
        return '🎯 اتجاه قوي';
      case MarketCondition.ranging:
        return '↔️ سوق عرضي';
      case MarketCondition.volatile:
        return '⚡ تقلب عالي';
      case MarketCondition.consolidation:
        return '🔄 تماسك';
      case MarketCondition.uncertain:
        return '❓ غير واضح';
    }
  }
}
