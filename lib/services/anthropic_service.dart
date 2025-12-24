import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../core/constants/api_keys.dart';
import '../core/utils/logger.dart';
import '../models/recommendation.dart';
import '../models/market_models.dart';
import 'telemetry_service.dart';

/// 🚀 Enterprise-Grade Anthropic AI Service
///
/// **Features:**
/// - ✅ Streaming responses (real-time analysis)
/// - ✅ Context management (conversation memory)
/// - ✅ Advanced caching (reduce API calls)
/// - ✅ Retry logic with exponential backoff
/// - ✅ Response validation & quality scoring
/// - ✅ Multiple prompt strategies
/// - ✅ Circuit breaker pattern
/// - ✅ Performance metrics tracking
///
/// **Usage:**
/// ```dart
/// // Streaming analysis
/// await for (final chunk in AnthropicServicePro.streamAnalysis(...)) {
///   print(chunk); // Real-time updates
/// }
///
/// // Standard analysis
/// final analysis = await AnthropicServicePro.getAnalysis(...);
/// ```
class AnthropicServicePro {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 15),
    ),
  );

  // ══════════════════════════════════════════════════════════
  // RATE LIMITING & CIRCUIT BREAKER
  // ══════════════════════════════════════════════════════════

  static DateTime? _lastRequestTime;
  static const Duration _minRequestInterval = Duration(milliseconds: 1500);
  static int _requestCount = 0;
  static const int _maxRequestsPerMinute = 25;
  static DateTime? _requestCountResetTime;

  // Circuit Breaker
  static int _consecutiveFailures = 0;
  static const int _maxConsecutiveFailures = 3;
  static DateTime? _circuitBreakerResetTime;
  static const Duration _circuitBreakerTimeout = Duration(minutes: 2);

  // ══════════════════════════════════════════════════════════
  // CACHING SYSTEM
  // ══════════════════════════════════════════════════════════

  static final Map<String, _CachedAnalysis> _cache = {};
  static const Duration _cacheLifetime = Duration(minutes: 3);
  static const int _maxCacheSize = 20;

  // ══════════════════════════════════════════════════════════
  // CONTEXT MANAGEMENT (Conversation Memory)
  // ══════════════════════════════════════════════════════════

  static final List<Map<String, String>> _conversationHistory = [];
  static const int _maxHistoryLength = 5;

  // ══════════════════════════════════════════════════════════
  // PERFORMANCE METRICS
  // ══════════════════════════════════════════════════════════

  static final List<int> _responseTimesMs = [];
  static int _totalRequests = 0;
  static int _successfulRequests = 0;
  static int _cachedResponses = 0;

  // Error counters for telemetry (reserved for future use)
  // ignore: unused_field
  static int _error401Count = 0;
  // ignore: unused_field
  static int _error5xxCount = 0;

  /// Check if API is available
  static bool get isAvailable =>
      ApiKeys.anthropicApiKey.isNotEmpty && !_isCircuitBreakerOpen;

  /// Check if circuit breaker is open
  static bool get _isCircuitBreakerOpen {
    if (_consecutiveFailures < _maxConsecutiveFailures) return false;

    if (_circuitBreakerResetTime == null) {
      _circuitBreakerResetTime = DateTime.now().add(_circuitBreakerTimeout);
      return true;
    }

    if (DateTime.now().isAfter(_circuitBreakerResetTime!)) {
      _consecutiveFailures = 0;
      _circuitBreakerResetTime = null;
      AppLogger.info('Circuit breaker reset - attempting recovery');
      return false;
    }

    return true;
  }

  // ══════════════════════════════════════════════════════════
  // STREAMING ANALYSIS (Real-time responses)
  // ══════════════════════════════════════════════════════════

  /// Stream AI Analysis in real-time
  ///
  /// Returns a stream of text chunks as they arrive from Claude.
  /// Perfect for showing analysis progressively in UI.
  ///
  /// **Example:**
  /// ```dart
  /// await for (final chunk in AnthropicServicePro.streamAnalysis(...)) {
  ///   setState(() {
  ///     analysisText += chunk;
  ///   });
  /// }
  /// ```
  static Stream<String> streamAnalysis({
    required Recommendation scalp,
    required Recommendation swing,
    required TechnicalIndicators indicators,
    required double currentPrice,
    MarketCondition? marketCondition,
  }) async* {
    try {
      // Check availability
      if (!isAvailable) {
        yield* Stream.value(
            _generateFallbackAnalysis(scalp, swing, indicators));
        return;
      }

      // Check rate limiting
      if (!_checkRateLimit()) {
        AppLogger.warn('Rate limit - using fallback');
        yield* Stream.value(
            _generateFallbackAnalysis(scalp, swing, indicators));
        return;
      }

      final prompt = _buildAdvancedPrompt(
        scalp: scalp,
        swing: swing,
        indicators: indicators,
        currentPrice: currentPrice,
        marketCondition: marketCondition,
      );

      _totalRequests++;
      final startTime = DateTime.now();

      AppLogger.api('POST', '${ApiKeys.anthropicBaseUrl}/messages (STREAMING)');

      final response = await _dio.post(
        '${ApiKeys.anthropicBaseUrl}/messages',
        options: Options(
          headers: {
            'x-api-key': ApiKeys.anthropicApiKey,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
          },
          responseType: ResponseType.stream,
        ),
        data: {
          'model': ApiKeys.anthropicModel,
          'max_tokens': 1500,
          'temperature': 0.7,
          'stream': true,
          'messages': _buildMessagesWithContext(prompt),
        },
      );

      _updateRateLimit();

      final stream = response.data.stream;
      String buffer = '';

      await for (final chunk in stream) {
        final lines = utf8.decode(chunk).split('\n');

        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') continue;

            try {
              final json = jsonDecode(data);

              if (json['type'] == 'content_block_delta') {
                final text = json['delta']?['text'] as String?;
                if (text != null) {
                  buffer += text;
                  yield text;
                }
              }
            } catch (e) {
              // Skip invalid JSON chunks
            }
          }
        }
      }

      final responseTime = DateTime.now().difference(startTime).inMilliseconds;
      _responseTimesMs.add(responseTime);
      _successfulRequests++;
      _consecutiveFailures = 0;

      // Telemetry: AI call latency
      TelemetryService.instance.recordAICall('anthropic', responseTime, 200);

      // Add to conversation history
      _addToHistory('user', prompt);
      _addToHistory('assistant', buffer);

      // Validate response quality
      final quality = _validateResponse(buffer);
      AppLogger.success(
          'Streaming analysis completed - Quality: ${quality.toStringAsFixed(1)}/10');
    } on DioException catch (e, stackTrace) {
      _consecutiveFailures++;
      _handleDioException(e, stackTrace);
      yield* Stream.value(_generateFallbackAnalysis(scalp, swing, indicators));
    } catch (e, stackTrace) {
      _consecutiveFailures++;
      AppLogger.error('Streaming error', e, stackTrace);
      yield* Stream.value(_generateFallbackAnalysis(scalp, swing, indicators));
    }
  }

  // ══════════════════════════════════════════════════════════
  // STANDARD ANALYSIS (with Caching & Retry)
  // ══════════════════════════════════════════════════════════

  /// Get AI Analysis with advanced caching and retry logic
  static Future<String> getAnalysis({
    required Recommendation scalp,
    required Recommendation swing,
    required TechnicalIndicators indicators,
    required double currentPrice,
    MarketCondition? marketCondition,
    bool forceRefresh = false,
  }) async {
    try {
      // Generate cache key
      final cacheKey = _generateCacheKey(
        currentPrice,
        scalp.direction,
        swing.direction,
        indicators.rsi,
      );

      // Check cache (unless force refresh)
      if (!forceRefresh && _cache.containsKey(cacheKey)) {
        final cached = _cache[cacheKey]!;
        if (DateTime.now().difference(cached.timestamp) < _cacheLifetime) {
          _cachedResponses++;
          AppLogger.info(
              'Using cached analysis (age: ${DateTime.now().difference(cached.timestamp).inSeconds}s)');
          return cached.analysis;
        }
      }

      // Check availability
      if (!isAvailable) {
        return _generateFallbackAnalysis(scalp, swing, indicators);
      }

      // Check rate limiting
      if (!_checkRateLimit()) {
        AppLogger.warn('Rate limit exceeded - checking cache or fallback');
        if (_cache.containsKey(cacheKey)) {
          return _cache[cacheKey]!.analysis;
        }
        return _generateFallbackAnalysis(scalp, swing, indicators);
      }

      // Attempt analysis with retry
      String? analysis;
      int attempts = 0;
      const maxAttempts = 3;

      while (attempts < maxAttempts && analysis == null) {
        attempts++;

        try {
          analysis = await _performAnalysis(
            scalp: scalp,
            swing: swing,
            indicators: indicators,
            currentPrice: currentPrice,
            marketCondition: marketCondition,
          );

          if (analysis != null) {
            // Cache successful response
            _cacheAnalysis(cacheKey, analysis);
            _consecutiveFailures = 0;
            return analysis;
          }
        } catch (e) {
          if (attempts < maxAttempts) {
            final delaySeconds = attempts * 2; // Exponential backoff
            AppLogger.warn(
                'Attempt $attempts failed, retrying in ${delaySeconds}s...');
            await Future.delayed(Duration(seconds: delaySeconds));
          }
        }
      }

      // All attempts failed
      _consecutiveFailures++;
      return _generateFallbackAnalysis(scalp, swing, indicators);
    } catch (e, stackTrace) {
      _consecutiveFailures++;
      AppLogger.error('Analysis failed', e, stackTrace);
      return _generateFallbackAnalysis(scalp, swing, indicators);
    }
  }

  /// Perform actual API analysis
  static Future<String?> _performAnalysis({
    required Recommendation scalp,
    required Recommendation swing,
    required TechnicalIndicators indicators,
    required double currentPrice,
    MarketCondition? marketCondition,
  }) async {
    final prompt = _buildAdvancedPrompt(
      scalp: scalp,
      swing: swing,
      indicators: indicators,
      currentPrice: currentPrice,
      marketCondition: marketCondition,
    );

    _totalRequests++;
    final startTime = DateTime.now();

    AppLogger.api('POST', '${ApiKeys.anthropicBaseUrl}/messages');

    final response = await _dio.post(
      '${ApiKeys.anthropicBaseUrl}/messages',
      options: Options(
        headers: {
          'x-api-key': ApiKeys.anthropicApiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
      data: {
        'model': ApiKeys.anthropicModel,
        'max_tokens': 1500,
        'temperature': 0.7,
        'messages': _buildMessagesWithContext(prompt),
      },
    );

    _updateRateLimit();

    final responseTime = DateTime.now().difference(startTime).inMilliseconds;
    _responseTimesMs.add(responseTime);

    // Telemetry: record latency regardless of status
    TelemetryService.instance
        .recordAICall('anthropic', responseTime, response.statusCode);

    if (response.statusCode == 200) {
      final content = response.data['content'][0]['text'] as String;

      // Validate response
      final quality = _validateResponse(content);
      if (quality < 6.0) {
        AppLogger.warn(
            'Low quality response (${quality.toStringAsFixed(1)}/10) - retrying...');
        return null; // Trigger retry
      }

      _successfulRequests++;

      // Add to conversation history
      _addToHistory('user', prompt);
      _addToHistory('assistant', content);

      AppLogger.success(
          'Analysis received - Quality: ${quality.toStringAsFixed(1)}/10, Time: ${responseTime}ms');
      return content;
    } else if (response.statusCode == 429) {
      AppLogger.warn('Rate limit hit (429)', response.data);
      return null;
    } else if (response.statusCode == 401) {
      _error401Count++;
      TelemetryService.instance.recordApiError('anthropic', 401);
      AppLogger.error('Authentication failed (401)', 'Invalid API key');
      return null;
    } else {
      if (response.statusCode != null && response.statusCode! >= 500) {
        _error5xxCount++;
        TelemetryService.instance
            .recordApiError('anthropic', response.statusCode!);
      }
      AppLogger.error('API error (${response.statusCode})', response.data);
      return null;
    }
  }

  // ══════════════════════════════════════════════════════════
  // ADVANCED PROMPT BUILDER
  // ══════════════════════════════════════════════════════════

  /// Build advanced prompt with market condition awareness
  static String _buildAdvancedPrompt({
    required Recommendation scalp,
    required Recommendation swing,
    required TechnicalIndicators indicators,
    required double currentPrice,
    MarketCondition? marketCondition,
  }) {
    // Determine market condition if not provided
    marketCondition ??= _detectMarketCondition(indicators, scalp, swing);

    final strategyPrompt = _getStrategyPrompt(marketCondition);
    final technicalAnalysis = _buildTechnicalAnalysis(indicators, currentPrice);
    final riskLevel = _assessRiskLevel(indicators, scalp, swing);

    return '''
أنت خبير ذهب عالمي بخبرة 15+ سنة في الأسواق المالية. تحليلك دقيق، احترافي، ومبني على البيانات الحقيقية فقط.

═══════════════════════════════════════════════════════════════
📊 **السوق الحالي - بيانات حية (LIVE DATA)**
═══════════════════════════════════════════════════════════════

💰 **السعر**: \$${currentPrice.toStringAsFixed(2)}
🎯 **حالة السوق**: ${marketCondition.nameAr}
⚠️ **مستوى المخاطرة**: ${riskLevel.nameAr}

─────────────────────────────────────────────────────────────
📈 **توصيات التداول**
─────────────────────────────────────────────────────────────

**🔥 سكالبينج (5-15 دقيقة):**
   • القرار: ${scalp.directionText} ${scalp.directionEmoji}
   • الدخول: \$${scalp.entry?.toStringAsFixed(2) ?? 'منتظر'}
   • الإيقاف: \$${scalp.stopLoss?.toStringAsFixed(2) ?? 'N/A'}
   • الهدف: \$${scalp.takeProfit?.toStringAsFixed(2) ?? 'N/A'}
   • الثقة: ${scalp.confidenceText} (${(scalp.confidence.index * 25)}%)

**📊 سوينج (4-24 ساعة):**
   • القرار: ${swing.directionText} ${swing.directionEmoji}
   • الدخول: \$${swing.entry?.toStringAsFixed(2) ?? 'منتظر'}
   • الإيقاف: \$${swing.stopLoss?.toStringAsFixed(2) ?? 'N/A'}
   • الهدف: \$${swing.takeProfit?.toStringAsFixed(2) ?? 'N/A'}
   • الثقة: ${swing.confidenceText} (${(swing.confidence.index * 25)}%)

$technicalAnalysis

═══════════════════════════════════════════════════════════════
🎯 **المطلوب منك**
═══════════════════════════════════════════════════════════════

$strategyPrompt

**هيكل التحليل (200-250 كلمة):**

**1️⃣ التوصية الفورية** (30 كلمة)
   • القرار: [🟢 شراء قوي / 🟢 شراء / ⚪ انتظار / 🔴 بيع / 🔴 بيع قوي]
   • السعر المثالي للدخول
   • السبب الرئيسي

**2️⃣ التحليل الفني العميق** (80 كلمة)
   • قراءة المؤشرات (RSI, MACD, MAs)
   • تقييم الزخم والاتجاه
   • نقاط التقاء الإشارات

**3️⃣ إدارة المخاطر** (40 كلمة)
   • وقف الخسارة الدقيق (بالدولار)
   • هدف الربح الأول والثاني
   • حجم الصفقة الموصى به (% من رأس المال)

**4️⃣ المستويات الحرجة** (30 كلمة)
   • الدعم الأقرب (مع السعر)
   • المقاومة الأقربة (مع السعر)
   • مناطق السيولة

**5️⃣ السيناريوهات** (20 كلمة)
   • السيناريو الأساسي (60%)
   • السيناريو البديل (40%)

═══════════════════════════════════════════════════════════════
⚡ **قواعد صارمة**
═══════════════════════════════════════════════════════════════

✅ استخدم البيانات الحقيقية فقط - لا تخمين
✅ كن حاسماً - قرار واحد واضح
✅ أرقام دقيقة (منزلتين عشريتين)
✅ اكتب بعربية احترافية وواضحة
✅ ركز على الجودة لا الكمية
✅ تجنب التكرار والحشو

❌ لا عموميات أو كليشيهات
❌ لا تعليقات تحفظية زائدة
❌ لا تحليل "ربما" أو "محتمل" بدون أدلة

═══════════════════════════════════════════════════════════════

ابدأ التحليل الآن 👇
''';
  }

  /// Build technical analysis section
  static String _buildTechnicalAnalysis(
    TechnicalIndicators indicators,
    double currentPrice,
  ) {
    final rsiStatus = indicators.rsiOverbought
        ? '🔴 تشبع شرائي'
        : indicators.rsiOversold
            ? '🟢 تشبع بيعي'
            : '⚪ محايد';

    final macdStatus = indicators.macdBullish ? '🟢 صاعد' : '🔴 هابط';

    final ma20Position = currentPrice > indicators.ma20 ? '⬆️ فوق' : '⬇️ تحت';
    final ma50Position = currentPrice > indicators.ma50 ? '⬆️ فوق' : '⬇️ تحت';

    final priceTrend =
        currentPrice > indicators.ma20 && currentPrice > indicators.ma50
            ? '🟢 اتجاه صاعد قوي'
            : currentPrice < indicators.ma20 && currentPrice < indicators.ma50
                ? '🔴 اتجاه هابط قوي'
                : '⚪ اتجاه متذبذب';

    return '''
─────────────────────────────────────────────────────────────
🔍 **المؤشرات الفنية (Real-time)**
─────────────────────────────────────────────────────────────

📊 **RSI(14)**: ${indicators.rsi.toStringAsFixed(1)} → $rsiStatus
   └─ ${indicators.rsiLevel}

📉 **MACD**: $macdStatus
   └─ ${indicators.macdTrend}

📈 **المتوسطات المتحركة**:
   • MA(20): \$${indicators.ma20.toStringAsFixed(2)} → السعر $ma20Position
   • MA(50): \$${indicators.ma50.toStringAsFixed(2)} → السعر $ma50Position
   • الاتجاه العام: $priceTrend

💹 **تحليل الزخم**:
   • ${indicators.volumeTrend ?? 'حجم تداول طبيعي'}
   • ${_getMomentumAnalysis(indicators)}
''';
  }

  /// Get momentum analysis
  static String _getMomentumAnalysis(TechnicalIndicators indicators) {
    if (indicators.rsi > 60 && indicators.macdBullish) {
      return 'زخم صاعد قوي مع تأكيد من المؤشرات';
    } else if (indicators.rsi < 40 && !indicators.macdBullish) {
      return 'زخم هابط قوي مع ضغط بيعي';
    } else if (indicators.rsi > 50 && !indicators.macdBullish) {
      return 'تضارب في الإشارات - حذر من الانعكاس';
    } else if (indicators.rsi < 50 && indicators.macdBullish) {
      return 'بداية زخم صاعد - فرصة دخول مبكر';
    }
    return 'زخم محايد - انتظر إشارات أوضح';
  }

  /// Get strategy prompt based on market condition
  static String _getStrategyPrompt(MarketCondition condition) {
    switch (condition) {
      case MarketCondition.strongTrend:
        return '''
**🎯 الاستراتيجية المطلوبة:** اتجاه قوي - استراتيجية الركوب مع الاتجاه (Trend Following)
- ركز على فرص الدخول مع الاتجاه السائد
- استخدم أهداف ربح موسعة
- وقف خسارة أوسع قليلاً للسماح بتنفس السوق
- ابحث عن نقاط ارتداد (pullbacks) للدخول بسعر أفضل
''';

      case MarketCondition.ranging:
        return '''
**🎯 الاستراتيجية المطلوبة:** سوق عرضي - استراتيجية المدى (Range Trading)
- ركز على الشراء عند الدعم والبيع عند المقاومة
- أهداف ربح قصيرة (السوق محدود الحركة)
- وقف خسارة ضيق لحماية رأس المال
- تجنب المراكز الكبيرة - السوق غير واضح
''';

      case MarketCondition.volatile:
        return '''
**🎯 الاستراتيجية المطلوبة:** تقلب عالي - استراتيجية الحذر والسكالبينج
- تفضيل السكالبينج على السوينج
- وقف خسارة ضيق جداً (التقلب خطير)
- أهداف ربح سريعة - خذ الربح وأغلق
- حجم صفقة صغير (50% من المعتاد)
- تجنب التداول إذا كان التقلب غير مبرر
''';

      case MarketCondition.consolidation:
        return '''
**🎯 الاستراتيجية المطلوبة:** تماسك - انتظر الاختراق (Breakout Strategy)
- الصبر مهم - لا تتسرع بالدخول
- راقب مناطق التماسك للاختراق
- عند الاختراق: دخول سريع مع حجم صفقة متوسط
- وقف خسارة تحت/فوق منطقة التماسك مباشرة
- هدف ربح = عرض منطقة التماسك (مضاعف 1.5×)
''';

      case MarketCondition.uncertain:
        return '''
**🎯 الاستراتيجية المطلوبة:** عدم وضوح - نقدية أفضل من خسارة
- **توصية قوية:** تجنب التداول الآن
- إذا كان لديك مراكز مفتوحة: تشديد وقف الخسارة
- انتظر إشارات أوضح أو أخبار تحرك السوق
- إذا أصررت على الدخول: حجم صفقة 25% فقط من المعتاد
- النقد (Cash) هو مركز أيضاً - لا تُضَغط على نفسك
''';
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

    // Uncertain: Everything else
    return MarketCondition.uncertain;
  }

  /// Assess risk level
  static RiskLevel _assessRiskLevel(
    TechnicalIndicators indicators,
    Recommendation scalp,
    Recommendation swing,
  ) {
    int riskScore = 0;

    // RSI extremes add risk
    if (indicators.rsi > 75 || indicators.rsi < 25) riskScore += 2;
    if (indicators.rsi > 65 || indicators.rsi < 35) riskScore += 1;

    // Conflicting signals add risk
    if (scalp.direction != swing.direction) riskScore += 2;

    // Low confidence adds risk
    if (scalp.confidence.index < 2 || swing.confidence.index < 2)
      riskScore += 1;

    if (riskScore >= 4) return RiskLevel.high;
    if (riskScore >= 2) return RiskLevel.medium;
    return RiskLevel.low;
  }

  // ══════════════════════════════════════════════════════════
  // CONTEXT & HISTORY MANAGEMENT
  // ══════════════════════════════════════════════════════════

  /// Build messages with conversation context
  static List<Map<String, String>> _buildMessagesWithContext(String prompt) {
    final messages = <Map<String, String>>[];

    // Add relevant conversation history
    for (final message in _conversationHistory) {
      messages.add(message);
    }

    // Add current prompt
    messages.add({'role': 'user', 'content': prompt});

    return messages;
  }

  /// Add message to conversation history
  static void _addToHistory(String role, String content) {
    _conversationHistory.add({'role': role, 'content': content});

    // Keep only recent messages
    if (_conversationHistory.length > _maxHistoryLength * 2) {
      _conversationHistory.removeRange(
          0, 2); // Remove oldest user+assistant pair
    }
  }

  /// Clear conversation history
  static void clearHistory() {
    _conversationHistory.clear();
    AppLogger.info('Conversation history cleared');
  }

  // ══════════════════════════════════════════════════════════
  // CACHING SYSTEM
  // ══════════════════════════════════════════════════════════

  /// Generate cache key
  static String _generateCacheKey(
    double price,
    Direction scalpDirection,
    Direction swingDirection,
    double rsi,
  ) {
    final priceRounded = (price / 0.5).round() * 0.5; // Round to nearest $0.50
    final rsiRounded = (rsi / 5).round() * 5; // Round to nearest 5
    return 'analysis_${priceRounded}_${scalpDirection.name}_${swingDirection.name}_$rsiRounded';
  }

  /// Cache analysis
  static void _cacheAnalysis(String key, String analysis) {
    // Clean old cache entries if needed
    if (_cache.length >= _maxCacheSize) {
      final oldestKey = _cache.entries
          .reduce(
              (a, b) => a.value.timestamp.isBefore(b.value.timestamp) ? a : b)
          .key;
      _cache.remove(oldestKey);
    }

    _cache[key] = _CachedAnalysis(
      analysis: analysis,
      timestamp: DateTime.now(),
    );

    AppLogger.info('Analysis cached (key: $key, total: ${_cache.length})');
  }

  /// Clear cache
  static void clearCache() {
    _cache.clear();
    AppLogger.info('Analysis cache cleared');
  }

  // ══════════════════════════════════════════════════════════
  // RESPONSE VALIDATION
  // ══════════════════════════════════════════════════════════

  /// Validate response quality (returns score 0-10)
  static double _validateResponse(String response) {
    double score = 10.0;

    // Check minimum length
    if (response.length < 200) score -= 3.0;
    if (response.length < 100) score -= 3.0;

    // Check for key elements
    if (!response.contains('شراء') && !response.contains('بيع')) score -= 2.0;
    if (!response.contains('وقف') && !response.contains('إيقاف')) score -= 1.5;
    if (!response.contains('هدف') && !response.contains('ربح')) score -= 1.5;
    if (!response.contains('\$') && !response.contains('دولار')) score -= 1.0;

    // Check for structure indicators
    final hasStructure = response.contains('**') ||
        response.contains('##') ||
        response.contains('•') ||
        response.contains('─');
    if (!hasStructure) score -= 1.0;

    // Bonus for detailed analysis
    if (response.length > 800) score += 0.5;
    if (response.contains('RSI') && response.contains('MACD')) score += 0.5;

    return score.clamp(0.0, 10.0);
  }

  // ══════════════════════════════════════════════════════════
  // RATE LIMITING
  // ══════════════════════════════════════════════════════════

  static bool _checkRateLimit() {
    final now = DateTime.now();

    // Reset counter every minute
    if (_requestCountResetTime == null ||
        now.difference(_requestCountResetTime!) > const Duration(minutes: 1)) {
      _requestCount = 0;
      _requestCountResetTime = now;
    }

    // Check requests per minute
    if (_requestCount >= _maxRequestsPerMinute) {
      return false;
    }

    // Check minimum interval
    if (_lastRequestTime != null &&
        now.difference(_lastRequestTime!) < _minRequestInterval) {
      return false;
    }

    return true;
  }

  static void _updateRateLimit() {
    _lastRequestTime = DateTime.now();
    _requestCount++;
  }

  static void resetRateLimit() {
    _lastRequestTime = null;
    _requestCount = 0;
    _requestCountResetTime = null;
    AppLogger.info('Rate limit reset');
  }

  // ══════════════════════════════════════════════════════════
  // ERROR HANDLING
  // ══════════════════════════════════════════════════════════

  static void _handleDioException(DioException e, StackTrace stackTrace) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        AppLogger.error('Connection timeout (15s)', e.message);
        break;
      case DioExceptionType.receiveTimeout:
        AppLogger.error('Receive timeout (60s)', e.message);
        break;
      case DioExceptionType.sendTimeout:
        AppLogger.error('Send timeout (15s)', e.message);
        break;
      case DioExceptionType.badResponse:
        AppLogger.error(
          'Bad response (${e.response?.statusCode})',
          e.response?.data,
        );
        break;
      default:
        AppLogger.error('Network error', e, stackTrace);
    }
  }

  // ══════════════════════════════════════════════════════════
  // FALLBACK ANALYSIS (Enhanced)
  // ══════════════════════════════════════════════════════════

  static String _generateFallbackAnalysis(
    Recommendation scalp,
    Recommendation swing,
    TechnicalIndicators indicators,
  ) {
    AppLogger.info('Generating enhanced fallback analysis');

    final primarySignal =
        scalp.confidence.index > swing.confidence.index ? scalp : swing;
    final timeframe =
        scalp.confidence.index > swing.confidence.index ? 'سكالبينج' : 'سوينج';

    final decision =
        primarySignal.direction == Direction.buy ? '🟢 شراء' : '🔴 بيع';
    final riskLevel = _assessRiskLevel(indicators, scalp, swing);

    final rsiAnalysis = indicators.rsiOverbought
        ? 'تشبع شرائي (RSI: ${indicators.rsi.toStringAsFixed(1)}) يتطلب حذر من الانعكاس'
        : indicators.rsiOversold
            ? 'تشبع بيعي (RSI: ${indicators.rsi.toStringAsFixed(1)}) يشير لفرصة ارتداد'
            : 'زخم محايد (RSI: ${indicators.rsi.toStringAsFixed(1)})';

    final macdAnalysis = indicators.macdBullish
        ? 'MACD يظهر زخماً صاعداً إيجابياً'
        : 'MACD يشير لضغط هابط سلبي';

    final trendAnalysis = indicators.ma20 > indicators.ma50
        ? 'اتجاه صاعد (MA20 > MA50)'
        : 'اتجاه هابط (MA20 < MA50)';

    return '''
**⚡ تحليل سريع (وضع الطوارئ)**

═══════════════════════════════════

**1️⃣ التوصية الفورية:**
$decision عبر $timeframe
• الدخول: \$${primarySignal.entry?.toStringAsFixed(2) ?? 'انتظر تأكيد'}
• الإيقاف: \$${primarySignal.stopLoss?.toStringAsFixed(2) ?? 'N/A'}
• الهدف: \$${primarySignal.takeProfit?.toStringAsFixed(2) ?? 'N/A'}
• مستوى الثقة: ${primarySignal.confidenceText}

**2️⃣ التحليل الفني:**
• $rsiAnalysis
• $macdAnalysis  
• $trendAnalysis

**3️⃣ المستويات الرئيسية:**
• الدعم: \$${indicators.ma50.toStringAsFixed(2)} (MA50)
• المقاومة: \$${indicators.ma20.toStringAsFixed(2)} (MA20)

**4️⃣ إدارة المخاطر:**
• مستوى المخاطرة: ${riskLevel.nameAr}
• حجم الصفقة الموصى: ${riskLevel == RiskLevel.high ? '50%' : riskLevel == RiskLevel.medium ? '75%' : '100%'} من المعتاد
• R:R = 1:${(primarySignal.takeProfit! - primarySignal.entry!) / (primarySignal.entry! - primarySignal.stopLoss!).abs() > 2 ? '2+' : '1.5'}

**⚠️ ملاحظة:**
هذا تحليل مبسط (AI مؤقت غير متاح). للحصول على تحليل عميق، يرجى المحاولة مرة أخرى.

═══════════════════════════════════
''';
  }

  // ══════════════════════════════════════════════════════════
  // PERFORMANCE METRICS
  // ══════════════════════════════════════════════════════════

  /// Get performance statistics
  static Map<String, dynamic> getMetrics() {
    final avgResponseTime = _responseTimesMs.isEmpty
        ? 0
        : _responseTimesMs.reduce((a, b) => a + b) / _responseTimesMs.length;

    final successRate = _totalRequests == 0
        ? 0.0
        : (_successfulRequests / _totalRequests) * 100;

    final cacheHitRate =
        _totalRequests == 0 ? 0.0 : (_cachedResponses / _totalRequests) * 100;

    return {
      'total_requests': _totalRequests,
      'successful_requests': _successfulRequests,
      'cached_responses': _cachedResponses,
      'avg_response_time_ms': avgResponseTime.round(),
      'success_rate_percent': successRate.toStringAsFixed(1),
      'cache_hit_rate_percent': cacheHitRate.toStringAsFixed(1),
      'circuit_breaker_open': _isCircuitBreakerOpen,
      'consecutive_failures': _consecutiveFailures,
      'cache_size': _cache.length,
      'history_length': _conversationHistory.length,
    };
  }

  /// Print metrics to console
  static void printMetrics() {
    final metrics = getMetrics();
    AppLogger.info('═══ ANTHROPIC SERVICE METRICS ═══');
    AppLogger.info('Total Requests: ${metrics['total_requests']}');
    AppLogger.info('Success Rate: ${metrics['success_rate_percent']}%');
    AppLogger.info('Cache Hit Rate: ${metrics['cache_hit_rate_percent']}%');
    AppLogger.info('Avg Response: ${metrics['avg_response_time_ms']}ms');
    AppLogger.info(
        'Circuit Breaker: ${metrics['circuit_breaker_open'] ? 'OPEN ⚠️' : 'CLOSED ✅'}');
    AppLogger.info('═══════════════════════════════');
  }

  /// Reset all metrics
  static void resetMetrics() {
    _responseTimesMs.clear();
    _totalRequests = 0;
    _successfulRequests = 0;
    _cachedResponses = 0;
    _consecutiveFailures = 0;
    _circuitBreakerResetTime = null;
    AppLogger.info('Metrics reset');
  }

  /// Reset everything (for testing)
  static void resetAll() {
    resetRateLimit();
    resetMetrics();
    clearCache();
    clearHistory();
    AppLogger.info('Complete service reset');
  }
}

// ══════════════════════════════════════════════════════════
// HELPER MODELS
// ══════════════════════════════════════════════════════════

class _CachedAnalysis {
  final String analysis;
  final DateTime timestamp;

  _CachedAnalysis({
    required this.analysis,
    required this.timestamp,
  });
}

/// Market condition types
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

/// Risk level assessment
enum RiskLevel {
  low,
  medium,
  high;

  String get nameAr {
    switch (this) {
      case RiskLevel.low:
        return '🟢 منخفض';
      case RiskLevel.medium:
        return '🟡 متوسط';
      case RiskLevel.high:
        return '🔴 عالي';
    }
  }
}
