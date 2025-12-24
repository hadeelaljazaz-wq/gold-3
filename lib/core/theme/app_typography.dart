import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 👑 Royal Gold Typography System
///
/// نظام الخطوط الملكي الكامل
///
/// **الأنماط:**
/// - Display: للعناوين الضخمة
/// - Headline: للعناوين الرئيسية
/// - Title: للعناوين الفرعية
/// - Body: للنصوص العادية
/// - Label: للتسميات
@immutable
class AppTypography {
  const AppTypography._();

  // ============================================================================
  // FONT FAMILY - عائلة الخط
  // ============================================================================

  static const String fontFamily = 'SF Pro Display'; // iOS style
  static const String fontFamilyArabic = 'Cairo'; // Arabic support

  // ============================================================================
  // DISPLAY STYLES - أنماط العرض الضخمة
  // ============================================================================

  /// Display Large - عرض كبير جداً
  /// استخدام: الصفحات الرئيسية، الشعارات
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.12,
    color: AppColors.textPrimary,
  );

  /// Display Medium - عرض متوسط
  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.16,
    color: AppColors.textPrimary,
  );

  /// Display Small - عرض صغير
  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.22,
    color: AppColors.textPrimary,
  );

  // ============================================================================
  // HEADLINE STYLES - أنماط العناوين
  // ============================================================================

  /// Headline Large - عنوان كبير
  /// استخدام: عناوين الأقسام الرئيسية
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  /// Headline Medium - عنوان متوسط
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
    color: AppColors.textPrimary,
  );

  /// Headline Small - عنوان صغير
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
    color: AppColors.textPrimary,
  );

  // ============================================================================
  // TITLE STYLES - أنماط العناوين الفرعية
  // ============================================================================

  /// Title Large - عنوان فرعي كبير
  /// استخدام: عناوين الكروت، الأقسام الفرعية
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
    color: AppColors.textPrimary,
  );

  /// Title Medium - عنوان فرعي متوسط
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// Title Small - عنوان فرعي صغير
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
    color: AppColors.textPrimary,
  );

  // ============================================================================
  // BODY STYLES - أنماط النصوص
  // ============================================================================

  /// Body Large - نص كبير
  /// استخدام: النصوص الرئيسية
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// Body Medium - نص متوسط
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
    color: AppColors.textSecondary,
  );

  /// Body Small - نص صغير
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
    color: AppColors.textTertiary,
  );

  // ============================================================================
  // LABEL STYLES - أنماط التسميات
  // ============================================================================

  /// Label Large - تسمية كبيرة
  /// استخدام: الأزرار، التبويبات
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
    color: AppColors.textPrimary,
  );

  /// Label Medium - تسمية متوسطة
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.33,
    color: AppColors.textSecondary,
  );

  /// Label Small - تسمية صغيرة
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
    color: AppColors.textTertiary,
  );

  // ============================================================================
  // SPECIAL STYLES - أنماط خاصة
  // ============================================================================

  /// Gold Text - نص ذهبي
  static const TextStyle goldText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1.5,
    color: AppColors.royalGold,
  );

  /// Purple Text - نص بنفسجي
  static const TextStyle purpleText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1.5,
    color: AppColors.imperialPurple,
  );

  /// Price Text - نص السعر
  static const TextStyle priceText = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.25,
    color: AppColors.royalGold,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Percentage Text - نص النسبة المئوية
  static const TextStyle percentageText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.33,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Monospace Text - نص أحادي المسافة (للأرقام)
  static const TextStyle monospaceText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.43,
    fontFamily: 'Courier New',
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // ============================================================================
  // BUTTON STYLES - أنماط الأزرار
  // ============================================================================

  /// Button Large - زر كبير
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1.25,
    color: AppColors.blackObsidian,
  );

  /// Button Medium - زر متوسط
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1.43,
    color: AppColors.blackObsidian,
  );

  /// Button Small - زر صغير
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.33,
    color: AppColors.blackObsidian,
  );

  // ============================================================================
  // HELPER METHODS - دوال مساعدة
  // ============================================================================

  /// تطبيق لون على نمط
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// تطبيق وزن على نمط
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// تطبيق حجم على نمط
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// الحصول على نمط النص بناءً على قيمة (موجب/سالب)
  static TextStyle getValueStyle(double value, {TextStyle? baseStyle}) {
    final base = baseStyle ?? bodyLarge;
    return base.copyWith(
      color: AppColors.getColorByValue(value),
      fontWeight: FontWeight.w700,
    );
  }

  /// الحصول على نمط الترند
  static TextStyle getTrendStyle(String trend, {TextStyle? baseStyle}) {
    final base = baseStyle ?? bodyLarge;
    return base.copyWith(
      color: AppColors.getTrendColor(trend),
      fontWeight: FontWeight.w700,
    );
  }
}
