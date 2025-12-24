// ignore: unnecessary_import
import 'dart:ui';
import 'package:flutter/material.dart';

/// 👑 Royal Typography System
///
/// نظام الطباعة الملكي المستقبلي
///
/// **الفلسفة:**
/// - أرقام واضحة مع Tabular Figures
/// - تباعد محسّن للقراءة
/// - أحجام متدرجة للتسلسل الهرمي البصري
@immutable
class RoyalTypography {
  const RoyalTypography._(); // منع الإنشاء

  // ============================================================================
  // DISPLAY TEXTS - نصوص العرض (Hero Numbers)
  // ============================================================================

  /// Price Display - عرض السعر الرئيسي (48px)
  static const TextStyle priceDisplay = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.5,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Display Large - عرض كبير (40px)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.bold,
    letterSpacing: -1.2,
    height: 1.1,
  );

  /// Display Medium - عرض متوسط (36px)
  static const TextStyle displayMedium = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    letterSpacing: -1.0,
    height: 1.1,
  );

  /// Display Small - عرض صغير (32px)
  static const TextStyle displaySmall = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    height: 1.2,
  );

  // ============================================================================
  // HEADERS - العناوين
  // ============================================================================

  /// H1 - عنوان المستوى الأول (28px)
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
  );

  /// H2 - عنوان المستوى الثاني (22px)
  static const TextStyle h2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.3,
  );

  /// H3 - عنوان المستوى الثالث (18px)
  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );

  /// H4 - عنوان المستوى الرابع (16px)
  static const TextStyle h4 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );

  // ============================================================================
  // BODY TEXTS - نصوص الجسم
  // ============================================================================

  /// Body Large - جسم كبير (16px)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.5,
  );

  /// Body Medium - جسم متوسط (14px)
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
    height: 1.5,
  );

  /// Body Small - جسم صغير (12px)
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.4,
  );

  // ============================================================================
  // NUMBER STYLES - أنماط الأرقام
  // ============================================================================

  /// Number Hero - رقم بطولي (32px)
  /// للأرقام الكبيرة المهمة مثل الأسعار
  static const TextStyle numberHero = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Number Large - رقم كبير (20px)
  /// للأرقام الرئيسية في الكروت
  static const TextStyle numberLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Number Medium - رقم متوسط (16px)
  /// للأرقام الثانوية
  static const TextStyle numberMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Number Small - رقم صغير (14px)
  /// للأرقام التفصيلية
  static const TextStyle numberSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.3,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // ============================================================================
  // LABELS - التسميات
  // ============================================================================

  /// Label Large - تسمية كبيرة (14px)
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.4,
  );

  /// Label Medium - تسمية متوسطة (12px)
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.3,
  );

  /// Label Small - تسمية صغيرة (10px)
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    height: 1.2,
  );

  // ============================================================================
  // BUTTONS - الأزرار
  // ============================================================================

  /// Button Large - زر كبير (16px)
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );

  /// Button Medium - زر متوسط (14px)
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );

  /// Button Small - زر صغير (12px)
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    height: 1.2,
  );

  // ============================================================================
  // SPECIAL STYLES - أنماط خاصة
  // ============================================================================

  /// Caption - نص توضيحي (11px)
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
    height: 1.3,
  );

  /// Overline - نص علوي (10px)
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    height: 1.2,
  );

  /// Monospace - أحرف أحادية المسافة
  /// للأكواد والمعرفات
  static const TextStyle monospace = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
    fontFamily: 'monospace',
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // ============================================================================
  // TRADING SPECIFIC - أنماط خاصة بالتداول
  // ============================================================================

  /// Entry Price Style - نمط سعر الدخول
  static const TextStyle entryPrice = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Stop/Target Style - نمط الستوب والهدف
  static const TextStyle stopTarget = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Risk/Reward Style - نمط المخاطرة/المكافأة
  static const TextStyle riskReward = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    height: 1.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Confidence Score Style - نمط درجة الثقة
  static const TextStyle confidenceScore = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // ============================================================================
  // INDICATOR STYLES - أنماط المؤشرات
  // ============================================================================

  /// Indicator Value - قيمة المؤشر
  static const TextStyle indicatorValue = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Indicator Label - تسمية المؤشر
  static const TextStyle indicatorLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.3,
  );

  // ============================================================================
  // UTILITY METHODS - دوال مساعدة
  // ============================================================================

  /// Apply Color to TextStyle
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply Gradient to TextStyle (returns Shader Callback)
  static ShaderCallback createGradientShader(Gradient gradient) {
    return (Rect bounds) => gradient.createShader(bounds);
  }

  /// Create Bold Variant
  static TextStyle toBold(TextStyle style) {
    return style.copyWith(
      fontWeight: FontWeight.bold,
    );
  }

  /// Create Semibold Variant
  static TextStyle toSemibold(TextStyle style) {
    return style.copyWith(
      fontWeight: FontWeight.w600,
    );
  }

  /// Add Shadow to TextStyle
  static TextStyle withShadow(
    TextStyle style, {
    Color color = const Color(0x99000000),
    double blurRadius = 4,
    Offset offset = const Offset(0, 2),
  }) {
    return style.copyWith(
      shadows: [
        Shadow(
          color: color,
          blurRadius: blurRadius,
          offset: offset,
        ),
      ],
    );
  }
}
