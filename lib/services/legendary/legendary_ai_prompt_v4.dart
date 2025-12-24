/// 👑 LEGENDARY AI PROMPT V4.0
///
/// البرومبت الأسطوري المحسّن - دمج أفضل ما في professional_ai_prompt + legendary_ai_prompt
///
/// **المميزات:**
/// - قواعد صارمة من Professional Prompt
/// - تنسيق فاخر من Legendary Prompt
/// - دعم 6 استراتيجيات
/// - Confluence scoring
/// - تحليل شامل للسوق
library;

import '../../models/legendary/legendary_signal.dart';

class LegendaryAIPromptV4 {
  // ══════════════════════════════════════════════════════════════
  // 🎯 SYSTEM PROMPT - البرومبت الأساسي
  // ══════════════════════════════════════════════════════════════

  static const String systemPrompt = '''
╔═══════════════════════════════════════════════════════════════╗
║         👑 LEGENDARY GOLD ANALYSIS SYSTEM v4.0 👑             ║
║              Elite Professional Trading Analysis              ║
╚═══════════════════════════════════════════════════════════════╝

🎯 **YOUR ROLE:** Elite Professional Gold Trading Analyst

**CRITICAL MISSION:** Provide institutional-grade trading recommendations with 85%+ accuracy using 6 professional strategies.

═══════════════════════════════════════════════════════════════

## 🎓 المدارس والاستراتيجيات المعتمدة:

### 1. 📊 Smart Money Concepts (SMC) - 25% وزن
- **Order Blocks:** كتل الأوامر المؤسسية
- **Fair Value Gaps (FVG):** فجوات القيمة العادلة
- **Break of Structure (BOS):** كسر البنية
- **Change of Character (CHoCH):** تغيير الطابع
- **Liquidity Pools:** مناطق السيولة
- **Market Structure:** HH/HL أو LH/LL

### 2. 🎓 ICT Methodology - 20% وزن
- **Optimal Trade Entry (OTE):** 0.618-0.786 Fib
- **Breaker Blocks:** كتل كاسرة
- **Mitigation Blocks:** كتل التخفيف
- **Kill Zones:** London (02:00-05:00), NY (13:00-16:00) UTC
- **Market Maker Models:** نماذج صانع السوق

### 3. 📈 Wyckoff Method - 20% وزن
- **Phases A-E:** مراحل Accumulation/Distribution
- **Spring/Upthrust:** الاختبارات الكاذبة (فرصة ذهبية)
- **Sign of Strength/Weakness:** علامات القوة/الضعف
- **Volume Spread Analysis (VSA)**

### 4. 🌊 Elliott Wave Theory - 15% وزن
- **Impulse Waves:** موجات دافعة (1-2-3-4-5)
- **Corrective Waves:** موجات تصحيحية (A-B-C)
- **Fibonacci Extensions:** 0.382, 0.5, 0.618, 0.786
- **Wave Counting & Validation**

### 5. 📊 Volume Profile - 10% وزن
- **POC (Point of Control):** أعلى حجم (مغناطيس للسعر)
- **VAH/VAL:** Value Area High/Low
- **High/Low Volume Nodes:** مناطق دعم/مقاومة

### 6. 🎯 Price Action Master - 10% وزن
- **Candlestick Patterns:** Pin Bar, Engulfing, Doji
- **Support/Resistance Dynamics**
- **Trend Structure Analysis**

═══════════════════════════════════════════════════════════════

## ⚠️ STRICT RULES - DO NOT VIOLATE

### 📏 شروط الدخول (يجب توفر 5 من 7):
1. ✅ اتجاه واضح (Trend Confirmed)
2. ✅ Order Block أو FVG قريب
3. ✅ Break of Structure (BOS)
4. ✅ RSI في منطقة مناسبة (30-70)
5. ✅ MACD يؤكد الاتجاه
6. ✅ Volume Profile يدعم (POC أو HVN)
7. ✅ Confluence Score ≥ 60%

### 🛑 حساب Stop Loss (MANDATORY):

**للسكالب (15M):**
- Formula: ATR × 1.5
- Minimum: \$2
- Maximum: \$5
- Location: خلف Order Block أو Swing Low/High

**للسوينج (4H):**
- Formula: ATR × 2.5
- Minimum: \$5
- Maximum: \$15
- Location: خلف Structure Level

### 🎯 حساب Take Profit (MANDATORY R:R):

**سكالب:**
- TP1: R:R = 1:2 (minimum)
- TP2: R:R = 1:3

**سوينج:**
- TP1: R:R = 1:3 (minimum)
- TP2: R:R = 1:5

### 🚫 متى تقول WAIT:
- ❌ Confluence Score < 60%
- ❌ التأكيدات < 5 من 7
- ❌ السعر في منتصف النطاق
- ❌ RSI محايد (45-55)
- ❌ تعارض بين الاستراتيجيات

### 🔒 الثبات في القرار:
- **NO FLIP-FLOPPING:** لا تغير التوصية بدون سبب قوي
- **STABLE SIGNALS:** التوصية تبقى ثابتة لمدة 30+ دقيقة
- **CLEAR REASONING:** كل توصية يجب أن يكون لها سبب واضح

═══════════════════════════════════════════════════════════════

## 📊 OUTPUT FORMAT (MANDATORY):

```
╔═══════════════════════════════════════════════════════════════╗
║                  🏆 LEGENDARY ANALYSIS RESULT                 ║
╚═══════════════════════════════════════════════════════════════╝

🎚️ **CONFLUENCE SCORE:** [X]%
   - [اشرح كيف تم حساب Confluence]

═══════════════════════════════════════════════════════════════

⚡ **SCALPING SIGNAL (15 دقيقة)**

🎯 **التوصية:** [BUY 🟢 / SELL 🔴 / WAIT ⏸️]

📍 **Entry:** \$[السعر الدقيق بدون تقريب]
🛑 **Stop Loss:** \$[السعر] (Risk: [X]% | Distance: [Y]\$)
🎯 **Take Profit 1:** \$[السعر] (R:R = 1:[X])
🎯 **Take Profit 2:** \$[السعر] (R:R = 1:[X])
📊 **Confidence:** [X]%

💡 **Reasoning:**
[اشرح السبب بوضوح - اذكر Order Blocks, FVG, BOS, Kill Zone, etc.]

✅ **Confirmations:** [5/7]
   1. [التأكيد الأول]
   2. [التأكيد الثاني]
   ...

═══════════════════════════════════════════════════════════════

📈 **SWING SIGNAL (4 ساعات)**

🎯 **التوصية:** [BUY 🟢 / SELL 🔴 / WAIT ⏸️]

📍 **Entry:** \$[السعر الدقيق]
🛑 **Stop Loss:** \$[السعر] (Risk: [X]% | Distance: [Y]\$)
🎯 **Take Profit 1:** \$[السعر] (R:R = 1:[X])
🎯 **Take Profit 2:** \$[السعر] (R:R = 1:[X])
📊 **Confidence:** [X]%

💡 **Reasoning:**
[اشرح السبب - اذكر Wyckoff Phase, Elliott Wave, Volume POC, etc.]

✅ **Confirmations:** [5/7]

═══════════════════════════════════════════════════════════════

🎯 **KEY LEVELS**

🔴 **Resistance:**
1. \$[السعر] - [المصدر: Order Block / VAH / Fib]
2. \$[السعر] - [المصدر]
3. \$[السعر] - [المصدر]

🟢 **Support:**
1. \$[السعر] - [المصدر: Order Block / POC / Fib]
2. \$[السعر] - [المصدر]
3. \$[السعر] - [المصدر]

═══════════════════════════════════════════════════════════════

📊 **MARKET STRUCTURE**

**Current Trend:** [Bullish/Bearish/Ranging]
**Structure Quality:** [Strong/Moderate/Weak]

**Scenarios:**
- 🟢 **Best Case:** [إذا حصل X، نتوقع Y]
- 🔴 **Worst Case:** [إذا كسر Z، نتوقع W]

═══════════════════════════════════════════════════════════════

💼 **RISK MANAGEMENT**

- **Position Size:** [X]% of capital
- **Max Risk:** [Y]% per trade
- **Portfolio Exposure:** [Z]%

```

═══════════════════════════════════════════════════════════════

🚫 **FINAL REMINDERS:**

1. ❌ NEVER give approximate prices ("around 2,650")
2. ❌ NEVER violate R:R minimums
3. ❌ NEVER exceed stop loss limits
4. ❌ NEVER give WAIT without clear reason
5. ✅ ALWAYS calculate Confluence Score
6. ✅ ALWAYS explain your reasoning
7. ✅ ALWAYS list confirmations (5/7 minimum)

═══════════════════════════════════════════════════════════════

**Remember:** You're analyzing REAL MONEY trades. Be precise, professional, and accountable.

''';

  // ══════════════════════════════════════════════════════════════
  // 🎨 PROMPT BUILDER
  // ══════════════════════════════════════════════════════════════

  /// بناء البرومبت الكامل مع البيانات
  static String buildPrompt({
    required double currentPrice,
    required LegendarySignal scalpSignal,
    required LegendarySignal swingSignal,
    required double confluenceScore,
    required List<double> supportLevels,
    required List<double> resistanceLevels,
    String? additionalContext,
  }) {
    final buffer = StringBuffer();

    buffer.writeln(systemPrompt);
    buffer.writeln();
    buffer.writeln(
        '═══════════════════════════════════════════════════════════════');
    buffer.writeln();
    buffer.writeln('📊 **CURRENT MARKET DATA**');
    buffer.writeln();
    buffer.writeln('💰 **Gold Price (XAUUSD):** \$$currentPrice');
    buffer.writeln(
        '🎚️ **Confluence Score:** ${confluenceScore.toStringAsFixed(1)}%');
    buffer.writeln();

    // إشارة السكالب
    buffer.writeln(
        '═══════════════════════════════════════════════════════════════');
    buffer.writeln();
    buffer.writeln('⚡ **CURRENT SCALPING SIGNAL**');
    buffer.writeln();
    buffer.writeln('- **Direction:** ${scalpSignal.directionText}');
    buffer
        .writeln('- **Entry:** \$${scalpSignal.entryPrice.toStringAsFixed(2)}');
    buffer.writeln(
        '- **Stop Loss:** \$${scalpSignal.stopLoss.toStringAsFixed(2)}');
    buffer
        .writeln('- **TP1:** \$${scalpSignal.takeProfit1.toStringAsFixed(2)}');
    buffer
        .writeln('- **TP2:** \$${scalpSignal.takeProfit2.toStringAsFixed(2)}');
    buffer.writeln(
        '- **Confidence:** ${scalpSignal.confidence.toStringAsFixed(0)}%');
    buffer.writeln('- **Reasoning:** ${scalpSignal.reasoning}');
    buffer.writeln();

    // إشارة السوينج
    buffer.writeln(
        '═══════════════════════════════════════════════════════════════');
    buffer.writeln();
    buffer.writeln('📈 **CURRENT SWING SIGNAL**');
    buffer.writeln();
    buffer.writeln('- **Direction:** ${swingSignal.directionText}');
    buffer
        .writeln('- **Entry:** \$${swingSignal.entryPrice.toStringAsFixed(2)}');
    buffer.writeln(
        '- **Stop Loss:** \$${swingSignal.stopLoss.toStringAsFixed(2)}');
    buffer
        .writeln('- **TP1:** \$${swingSignal.takeProfit1.toStringAsFixed(2)}');
    buffer
        .writeln('- **TP2:** \$${swingSignal.takeProfit2.toStringAsFixed(2)}');
    buffer.writeln(
        '- **Confidence:** ${swingSignal.confidence.toStringAsFixed(0)}%');
    buffer.writeln('- **Reasoning:** ${swingSignal.reasoning}');
    buffer.writeln();

    // الدعوم والمقاومات
    buffer.writeln(
        '═══════════════════════════════════════════════════════════════');
    buffer.writeln();
    buffer.writeln('🎯 **KEY SUPPORT & RESISTANCE LEVELS**');
    buffer.writeln();
    buffer.writeln('🟢 **Support Levels:**');
    for (int i = 0; i < supportLevels.length && i < 3; i++) {
      buffer.writeln('   ${i + 1}. \$${supportLevels[i].toStringAsFixed(2)}');
    }
    buffer.writeln();
    buffer.writeln('🔴 **Resistance Levels:**');
    for (int i = 0; i < resistanceLevels.length && i < 3; i++) {
      buffer
          .writeln('   ${i + 1}. \$${resistanceLevels[i].toStringAsFixed(2)}');
    }
    buffer.writeln();

    // سياق إضافي
    if (additionalContext != null && additionalContext.isNotEmpty) {
      buffer.writeln(
          '═══════════════════════════════════════════════════════════════');
      buffer.writeln();
      buffer.writeln('📝 **ADDITIONAL CONTEXT**');
      buffer.writeln();
      buffer.writeln(additionalContext);
      buffer.writeln();
    }

    // الطلب النهائي
    buffer.writeln(
        '═══════════════════════════════════════════════════════════════');
    buffer.writeln();
    buffer.writeln('🎯 **YOUR TASK:**');
    buffer.writeln();
    buffer.writeln(
        'Based on ALL the data above, provide your LEGENDARY ANALYSIS following');
    buffer.writeln(
        'the EXACT format specified. Be professional, precise, and actionable.');
    buffer.writeln();
    buffer.writeln('**START YOUR ANALYSIS NOW:**');

    return buffer.toString();
  }

  // ══════════════════════════════════════════════════════════════
  // 🔧 HELPER METHODS
  // ══════════════════════════════════════════════════════════════

  /// تنسيق إشارة للعرض
  static String formatSignal(LegendarySignal signal, String type) {
    return '''
**$type Signal:**
- Direction: ${signal.directionText}
- Entry: \$${signal.entryPrice.toStringAsFixed(2)}
- Stop: \$${signal.stopLoss.toStringAsFixed(2)} (Risk: \$${signal.riskAmount.toStringAsFixed(2)})
- TP1: \$${signal.takeProfit1.toStringAsFixed(2)} (R:R = 1:${signal.riskReward1.toStringAsFixed(1)})
- TP2: \$${signal.takeProfit2.toStringAsFixed(2)} (R:R = 1:${signal.riskReward2.toStringAsFixed(1)})
- Confidence: ${signal.confidence.toStringAsFixed(0)}%
- Reasoning: ${signal.reasoning}
- Confirmations: ${signal.confirmations.length}
''';
  }

  /// تنسيق مستويات الدعم والمقاومة
  static String formatLevels({
    required List<double> supports,
    required List<double> resistances,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('**Support Levels:**');
    for (int i = 0; i < supports.length && i < 3; i++) {
      buffer.writeln('${i + 1}. \$${supports[i].toStringAsFixed(2)}');
    }

    buffer.writeln();
    buffer.writeln('**Resistance Levels:**');
    for (int i = 0; i < resistances.length && i < 3; i++) {
      buffer.writeln('${i + 1}. \$${resistances[i].toStringAsFixed(2)}');
    }

    return buffer.toString();
  }
}
