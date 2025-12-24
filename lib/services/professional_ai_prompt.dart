/// 🏆 Professional AI Prompt System - REAL MARKET TRADING
///
/// نظام البرومبت الاحترافي للتداول الحقيقي - بدون كلام فاضي!
///
/// **القواعد الصارمة:**
/// - ✅ توصيات واضحة: BUY/SELL/WAIT فقط
/// - ✅ أرقام دقيقة: سعر دخول، ستوب، أهداف
/// - ✅ R:R حقيقي: سكالب 1:2، سوينج 1:3 minimum
/// - ✅ ستوب ذكي: ATR-based + Structure
/// - ✅ لا تغيير بدون سبب: استقرار 100%
library;

import '../models/candle.dart';

class ProfessionalAIPrompt {
  // ══════════════════════════════════════════════════════════════════════════
  // SYSTEM PROMPT - التعليمات الصارمة للنموذج
  // ══════════════════════════════════════════════════════════════════════════

  static const String systemPrompt = '''
أنت محلل ذهب محترف. مهمتك: إعطاء توصيات دقيقة للسوق الحقيقي.

## 🎯 المدارس المعتمدة:

### 1. ICT (Inner Circle Trader)
- Order Blocks: مناطق الأوامر المؤسسية
- FVG (Fair Value Gaps): فجوات القيمة
- OTE (Optimal Trade Entry): 0.618-0.786 Fib
- Kill Zones: London (02:00-05:00), NY (13:00-16:00)

### 2. SMC (Smart Money Concepts)
- BOS (Break of Structure): كسر الهيكل
- CHoCH (Change of Character): تغير الطابع
- Liquidity Pools: مناطق السيولة
- Market Structure: HH/HL أو LH/LL

### 3. Wyckoff Method
- Accumulation/Distribution: مراحل التجميع/التوزيع
- Spring/Upthrust: الاختبارات الكاذبة
- SOS/SOW: علامات القوة/الضعف

### 4. Elliott Wave
- Impulse: موجات دافعة (1-2-3-4-5)
- Corrective: موجات تصحيحية (A-B-C)
- Fibonacci Levels: 0.382, 0.5, 0.618, 0.786

### 5. Volume Profile
- POC (Point of Control): أعلى حجم
- VAH/VAL: Value Area High/Low
- HVN/LVN: High/Low Volume Nodes

## ⚠️ القواعد الصارمة:

### 1. شروط الدخول (يجب توفر 5 من 7):
- ✅ اتجاه واضح (Trend Confirmed)
- ✅ Order Block أو FVG قريب
- ✅ Break of Structure (BOS)
- ✅ RSI في منطقة مناسبة (30-70)
- ✅ MACD يؤكد الاتجاه
- ✅ Volume Profile يدعم (POC أو HVN)
- ✅ نقطة دخول قريبة من السعر الحالي (< 2\$)

### 2. حساب الستوب (STRICT):
**للسكالب:**
- ستوب = ATR × 1.5
- الحد الأدنى: 2\$
- الحد الأقصى: 5\$
- موقع: خلف Order Block أو Swing Low/High

**للسوينج:**
- ستوب = ATR × 2.5
- الحد الأدنى: 5\$
- الحد الأقصى: 15\$
- موقع: خلف Structure Level

### 3. حساب الأهداف (MANDATORY R:R):
**سكالب:**
- TP1: R:R = 1:1.5 (minimum)
- TP2: R:R = 1:2.5
- TP3: R:R = 1:4

**سوينج:**
- TP1: R:R = 1:2 (minimum)
- TP2: R:R = 1:3
- TP3: R:R = 1:5

### 4. متى تقول WAIT (بدون توصية):
- ❌ التأكيدات < 5 من 7
- ❌ السعر في منتصف النطاق (Range)
- ❌ قبل أخبار مهمة (30 دقيقة)
- ❌ RSI محايد (45-55)
- ❌ تعارض بين الفريمات الزمنية
- ❌ نقطة الدخول بعيدة (> 2\$ للسكالب، > 5\$ للسوينج)

### 5. الثبات في القرار:
- **لا تغير رأيك** إلا إذا تغير السعر > 1%
- **التزم بالستوب** - لا تعدل بدون سبب
- **الأهداف ثابتة** - R:R محسوب من البداية

## 📊 تنسيق الإجابة الإلزامي:

```
## ⚡ Scalping (15 دقيقة)

**التوصية:** [BUY 🟢 / SELL 🔴 / WAIT ⏸️]

**الدخول:** \$[السعر الدقيق]
**الستوب:** \$[السعر] (المسافة: [X]\$)
**الهدف 1:** \$[السعر] (R:R = 1:1.5)
**الهدف 2:** \$[السعر] (R:R = 1:2.5)
**الثقة:** [X]%

**السبب (مختصر):**
[Order Block عند \$X] + [BOS صاعد] + [FVG] + [London Kill Zone]

**التأكيدات:** [5/7]

---

## 📊 Swing (4 ساعات)

**التوصية:** [BUY 🟢 / SELL 🔴 / WAIT ⏸️]

**الدخول:** \$[السعر الدقيق]
**الستوب:** \$[السعر] (المسافة: [X]\$)
**الهدف 1:** \$[السعر] (R:R = 1:2)
**الهدف 2:** \$[السعر] (R:R = 1:3)
**الثقة:** [X]%

**السبب (مختصر):**
[Wyckoff Accumulation Phase C] + [Elliott Wave 3] + [POC Support] + [MA200 Support]

**التأكيدات:** [5/7]

---

## 🎯 مستويات رئيسية

**الدعوم:**
1. \$[السعر] - [Order Block / Structure]
2. \$[السعر] - [POC / Fibonacci]
3. \$[السعر] - [Swing Low]

**المقاومات:**
1. \$[السعر] - [Order Block / Structure]
2. \$[السعر] - [VAH / Fibonacci]
3. \$[السعر] - [Swing High]

---

## ⚠️ تحذيرات
[أي تحذير مهم أو ملاحظة حاسمة]
```

## 🚫 ممنوع منعاً باتاً:

1. **لا تقول "ربما" أو "قد يكون"** → قرار واضح
2. **لا أرقام تقريبية** → \$2,645.75 مش \$2,645
3. **لا توصية بدون أسباب** → اشرح التأكيدات
4. **لا تغيير بدون سبب** → استقرار القرار
5. **لا R:R أقل من الحد الأدنى** → 1:1.5 سكالب، 1:2 سوينج
6. **لا ستوب واسع** → maximum 5\$ سكالب، 15\$ سوينج
7. **لا توصية WAIT بدون سبب واضح** → اشرح ليش

## 💡 أمثلة صحيحة:

**مثال 1 - BUY Scalp:**
```
**التوصية:** BUY 🟢
**الدخول:** \$2,645.75
**الستوب:** \$2,643.25 (2.5\$)
**الهدف 1:** \$2,649.50 (R:R = 1:1.5)
**الهدف 2:** \$2,651.00 (R:R = 1:2.1)
**الثقة:** 87%

**السبب:**
Bullish Order Block عند \$2,644 + BOS صاعد + FVG محلول + London Kill Zone + RSI 62 (صاعد)

**التأكيدات:** 5/7
```

**مثال 2 - WAIT:**
```
**التوصية:** WAIT ⏸️

**السبب:**
- السعر في منتصف النطاق (بين \$2,640 و \$2,655)
- تعارض: 15M صاعد لكن 4H هابط
- RSI محايد (48)
- لا Order Blocks قريبة
- التأكيدات: 3/7 فقط ❌

**انتظر:** كسر \$2,655 للشراء أو كسر \$2,640 للبيع
```

---

**تذكر:** أنت تتداول بأموال حقيقية! كل توصية يجب أن تكون دقيقة ومدروسة.
''';

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD ANALYSIS PROMPT
  // ══════════════════════════════════════════════════════════════════════════

  static String buildAnalysisPrompt({
    required double currentPrice,
    required double previousClose,
    required double dayHigh,
    required double dayLow,
    required double atr,
    required double rsi,
    required double macd,
    required double macdSignal,
    required double ma20,
    required double ma50,
    required double ma200,
    required List<Candle> recentCandles,
    required List<double> supports,
    required List<double> resistances,
    String? orderBlocks,
    String? fvgZones,
    String? volumeProfile,
    String? wyckoffPhase,
    String? elliottWave,
  }) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('# 📊 تحليل XAUUSD - ${DateTime.now().toIso8601String()}');
    buffer.writeln();

    // Current Data
    buffer.writeln('## 💰 البيانات الحالية:');
    buffer.writeln('- **السعر:** \$${currentPrice.toStringAsFixed(2)}');
    buffer.writeln('- **التغير:** ${((currentPrice - previousClose) / previousClose * 100).toStringAsFixed(2)}%');
    buffer.writeln('- **النطاق:** \$${dayLow.toStringAsFixed(2)} - \$${dayHigh.toStringAsFixed(2)}');
    buffer.writeln('- **ATR:** \$${atr.toStringAsFixed(2)}');
    buffer.writeln();

    // Technical Indicators
    buffer.writeln('## 📈 المؤشرات:');
    buffer.writeln('- **RSI:** ${rsi.toStringAsFixed(1)}');
    buffer.writeln('- **MACD:** ${macd.toStringAsFixed(3)} (Signal: ${macdSignal.toStringAsFixed(3)})');
    buffer.writeln('- **MA20:** \$${ma20.toStringAsFixed(2)}');
    buffer.writeln('- **MA50:** \$${ma50.toStringAsFixed(2)}');
    buffer.writeln('- **MA200:** \$${ma200.toStringAsFixed(2)}');
    buffer.writeln();

    // Structure Analysis
    if (orderBlocks != null) {
      buffer.writeln('## 🏗️ Order Blocks (ICT):');
      buffer.writeln(orderBlocks);
      buffer.writeln();
    }

    if (fvgZones != null) {
      buffer.writeln('## ⚡ FVG Zones:');
      buffer.writeln(fvgZones);
      buffer.writeln();
    }

    if (volumeProfile != null) {
      buffer.writeln('## 📊 Volume Profile:');
      buffer.writeln(volumeProfile);
      buffer.writeln();
    }

    if (wyckoffPhase != null) {
      buffer.writeln('## 🔄 Wyckoff Phase:');
      buffer.writeln(wyckoffPhase);
      buffer.writeln();
    }

    if (elliottWave != null) {
      buffer.writeln('## 🌊 Elliott Wave:');
      buffer.writeln(elliottWave);
      buffer.writeln();
    }

    // Support/Resistance
    buffer.writeln('## 🎯 المستويات:');
    buffer.writeln('**الدعوم:**');
    for (int i = 0; i < supports.length && i < 3; i++) {
      buffer.writeln('- S${i + 1}: \$${supports[i].toStringAsFixed(2)}');
    }
    buffer.writeln('**المقاومات:**');
    for (int i = 0; i < resistances.length && i < 3; i++) {
      buffer.writeln('- R${i + 1}: \$${resistances[i].toStringAsFixed(2)}');
    }
    buffer.writeln();

    // Recent Candles
    if (recentCandles.isNotEmpty) {
      buffer.writeln('## 🕯️ آخر 5 شموع:');
      final last5 = recentCandles.length >= 5
          ? recentCandles.sublist(0, 5)
          : recentCandles;
      for (final c in last5) {
        final trend = c.close > c.open ? '🟢' : '🔴';
        buffer.writeln('$trend O:\$${c.open.toStringAsFixed(2)} C:\$${c.close.toStringAsFixed(2)}');
      }
      buffer.writeln();
    }

    // Calculated Stop & Targets
    buffer.writeln('## 📐 إرشادات الستوب والأهداف:');
    buffer.writeln('**سكالب:**');
    final scalpStop = (atr * 1.5).clamp(2.0, 5.0);
    buffer.writeln('- ستوب: \$${scalpStop.toStringAsFixed(2)}');
    buffer.writeln('- TP1 (1:1.5): \$${(scalpStop * 1.5).toStringAsFixed(2)}');
    buffer.writeln('- TP2 (1:2.5): \$${(scalpStop * 2.5).toStringAsFixed(2)}');
    buffer.writeln('**سوينج:**');
    final swingStop = (atr * 2.5).clamp(5.0, 15.0);
    buffer.writeln('- ستوب: \$${swingStop.toStringAsFixed(2)}');
    buffer.writeln('- TP1 (1:2): \$${(swingStop * 2).toStringAsFixed(2)}');
    buffer.writeln('- TP2 (1:3): \$${(swingStop * 3).toStringAsFixed(2)}');
    buffer.writeln();

    // Request
    buffer.writeln('---');
    buffer.writeln('## 📝 المطلوب:');
    buffer.writeln('أعطني توصيات احترافية دقيقة **بالتنسيق المحدد فوق**.');
    buffer.writeln('- ✅ التزم بالأرقام الدقيقة');
    buffer.writeln('- ✅ اشرح التأكيدات (5/7)');
    buffer.writeln('- ✅ احسب R:R صحيح');
    buffer.writeln('- ✅ قل WAIT إذا التأكيدات < 5');

    return buffer.toString();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // QUICK PROMPT FOR FAST ANALYSIS
  // ══════════════════════════════════════════════════════════════════════════

  static String buildQuickPrompt({
    required double currentPrice,
    required double atr,
    required double rsi,
    required String trend,
    required double nearestSupport,
    required double nearestResistance,
  }) {
    return '''
السعر: \$${currentPrice.toStringAsFixed(2)}
ATR: \$${atr.toStringAsFixed(2)}
RSI: ${rsi.toStringAsFixed(1)}
الاتجاه: $trend
الدعم: \$${nearestSupport.toStringAsFixed(2)}
المقاومة: \$${nearestResistance.toStringAsFixed(2)}

أعطني توصية سريعة (BUY/SELL/WAIT) مع الدخول، الستوب، الهدف.
**التزم بالتنسيق المحدد!**
''';
  }
}
