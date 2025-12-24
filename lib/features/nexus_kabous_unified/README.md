# 🔀 NEXUS + KABOUS Unified System

## نظرة عامة

نظام موحد يجمع أفضل ما في نظامي **NEXUS Quantum Engine** و **KABOUS Elite** لتحليل تداول الذهب.

## الميزات

### من NEXUS:
- ✅ **NEXUS Quantum Score** (0-10): نظام تقييم متقدم
- ✅ **10-Layer System**: استخدام Golden Nightmare Engine
- ✅ **High R:R Ratios**: نسب مخاطرة/مكافأة عالية
- ✅ **Quantum Physics Concepts**: مفاهيم فيزياء الكم

### من KABOUS:
- ✅ **ML Score** (0-100): تقييم بالذكاء الاصطناعي
- ✅ **Market Regime Detection**: اكتشاف حالة السوق (HMM simulation)
- ✅ **Advanced Risk Management**: إدارة مخاطر متقدمة
- ✅ **LSTM-like Predictions**: تنبؤات مشابهة لـ LSTM

### ميزات موحدة:
- ✅ **Caching System**: تخزين مؤقت ذكي
- ✅ **Rate Limiting**: تحديد معدل الطلبات
- ✅ **Auto-refresh**: تحديث تلقائي
- ✅ **Error Recovery**: استعادة من الأخطاء
- ✅ **Professional Logging**: تسجيل احترافي
- ✅ **Agreement Detection**: اكتشاف الاتفاق/الاختلاف بين النظامين

## الوصول

### Route:
```
/nexus-kabous
```

### من الكود:
```dart
context.push('/nexus-kabous');
```

### من Home Screen:
زر "NEXUS + KABOUS" في Quick Actions

## البنية

```
lib/features/nexus_kabous_unified/
├── providers/
│   └── nexus_kabous_provider.dart    # Provider الرئيسي
├── models/
│   ├── nexus_signal_model.dart        # نموذج إشارة NEXUS
│   ├── kabous_signal_model.dart       # نموذج إشارة KABOUS
│   └── unified_metrics_model.dart     # نموذج المؤشرات الموحدة
├── screens/
│   └── nexus_kabous_screen.dart       # الشاشة الرئيسية
└── widgets/
    ├── nexus_signal_card.dart         # بطاقة إشارة NEXUS
    ├── kabous_signal_card.dart        # بطاقة إشارة KABOUS
    ├── unified_comparison_card.dart   # بطاقة المقارنة
    └── unified_metrics_card.dart      # بطاقة المؤشرات
```

## الاستخدام

1. افتح الشاشة من Route `/nexus-kabous`
2. سيتم تحميل التحليل تلقائياً
3. انتظر حتى يكتمل التحليل (عادة 5-10 ثواني)
4. راجع النتائج:
   - **Unified Metrics**: المؤشرات الموحدة
   - **Comparison Card**: مقارنة بين النظامين
   - **NEXUS Signals**: إشارات NEXUS (Scalp & Swing)
   - **KABOUS Signals**: إشارات KABOUS (Scalp & Swing)

## الحالة

✅ **جاهز للاستخدام**
- لا توجد أخطاء في الكود
- جميع الملفات متصلة بشكل صحيح
- Provider يعمل مع Caching و Rate Limiting
- UI جاهز بنفس التصميم

## ملاحظات

- النظام يستخدم **Golden Nightmare Engine** كأساس لـ NEXUS
- النظام يستخدم **ScalpingEngineV2** و **SwingEngineV2** كأساس لـ KABOUS
- ML Score و Market Regime هي محاكاة (simulation) وليست ML حقيقي

