import 'package:flutter/material.dart';

// استيراد نظام الألوان الملكي الجديد
export 'royal_colors.dart';

/// 👑 Royal Gold Nightmare Color System
///
/// نظام الألوان الملكي الكامل لتطبيق الكابوس الذهبي
///
/// **الألوان الأساسية:**
/// - Black Obsidian: الأسود الملكي
/// - Royal Gold: الذهب الملكي
/// - Imperial Purple: البنفسجي الإمبراطوري
///
/// **الفلسفة:**
/// - الفخامة والقوة
/// - الوضوح والتباين العالي
/// - التدرجات الذهبية الناعمة
@immutable
class AppColors {
  const AppColors._(); // منع الإنشاء

  // ============================================================================
  // PRIMARY COLORS - الألوان الأساسية (مُحسّنة)
  // ============================================================================

  /// Black Obsidian - الأسود الملكي (Midnight Blue)
  /// الخلفية الرئيسية للتطبيق - أزرق داكن بدل الأسود
  static const Color blackObsidian = Color(0xFF0A1128);

  /// Royal Gold - الذهب الملكي
  /// اللون الرئيسي للعناصر المهمة
  static const Color royalGold = Color(0xFFD4AF37);

  /// Imperial Purple - البنفسجي الإمبراطوري
  /// لون الإبراز والعناصر الثانوية
  static const Color imperialPurple = Color(0xFF4A148C);

  /// Champagne Gold - ذهب الشمبانيا
  static const Color champagneGold = Color(0xFFF7E7CE);

  /// Sapphire Blue - أزرق الياقوت
  static const Color sapphireBlue = Color(0xFF0F3460);

  // ============================================================================
  // BACKGROUND COLORS - ألوان الخلفيات (مُحسّنة)
  // ============================================================================

  /// الخلفية الرئيسية - أزرق منتصف الليل
  static const Color background = blackObsidian;

  /// الخلفية الثانوية (للكروت والعناصر) - أزرق ياقوت
  static const Color backgroundSecondary = Color(0xFF16213E);

  /// الخلفية الثالثة (للعناصر المرتفعة) - أزرق كريستالي
  static const Color backgroundTertiary = Color(0xFF1A2332);

  /// الخلفية مع تأثير زجاجي
  static const Color backgroundGlass = Color(0x33FFFFFF);

  /// خلفية البطاقات الملكية
  static const Color cardBackgroundRoyal = Color(0xFF0F3460);

  // ============================================================================
  // GOLD GRADIENT - تدرجات الذهب (مُحسّنة)
  // ============================================================================

  /// التدرج الذهبي الرئيسي - أكثر إشراقاً
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFD700), // Gold Bright
      Color(0xFFD4AF37), // Royal Gold
      Color(0xFFF7E7CE), // Champagne
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// التدرج الذهبي الخفيف
  static const LinearGradient goldGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF7E7CE), // Champagne
      Color(0xFFFFD700), // Gold
      Color(0xFFD4AF37), // Royal Gold
    ],
  );

  /// التدرج الذهبي الداكن
  static const LinearGradient goldGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD4AF37), // Royal Gold
      Color(0xFF9B7E3B), // Dark Gold
    ],
  );

  /// ✨ التدرج الذهبي اللامع (Shimmer)
  static const LinearGradient goldShimmerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFD700), // Bright Gold
      Color(0xFFF7E7CE), // Champagne
      Color(0xFFD4AF37), // Royal Gold
      Color(0xFFFFD700), // Bright Gold
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  // ============================================================================
  // PURPLE GRADIENT - تدرجات البنفسجي (مُحسّنة)
  // ============================================================================

  /// التدرج البنفسجي الإمبراطوري
  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF9C27B0), // Amethyst
      Color(0xFF6A1B9A), // Imperial Purple
      Color(0xFF4A148C), // Deep Royal Purple
    ],
  );

  // ============================================================================
  // MIXED GRADIENTS - تدرجات مختلطة (مُحسّنة)
  // ============================================================================

  /// التدرج الملكي (ذهبي + بنفسجي)
  static const LinearGradient royalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD4AF37), // Royal Gold
      Color(0xFF9C27B0), // Amethyst
      Color(0xFF4A148C), // Deep Purple
    ],
  );

  /// التدرج الداكن (للخلفيات) - أزرق ملكي
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0A1128), // Midnight Blue
      Color(0xFF0F3460), // Sapphire
      Color(0xFF16213E), // Royal Navy
    ],
  );

  /// 🌟 تدرج الخلفية الملكية
  static const LinearGradient royalBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A1128), // Midnight Blue
      Color(0xFF16213E), // Royal Navy
      Color(0xFF0F3460), // Sapphire
      Color(0xFF1A2332), // Crystal Blue
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  /// 💎 تدرج البطاقة الملكية
  static const LinearGradient royalCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A2332),
      Color(0xFF16213E),
      Color(0xFF0F3460),
    ],
  );

  // ============================================================================
  // TEXT COLORS - ألوان النصوص
  // ============================================================================

  /// النص الأساسي (أبيض)
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// النص الثانوي (رمادي فاتح)
  static const Color textSecondary = Color(0xFFB0B0B0);

  /// النص الثالث (رمادي)
  static const Color textTertiary = Color(0xFF808080);

  /// النص الذهبي
  static const Color textGold = royalGold;

  /// النص البنفسجي
  static const Color textPurple = imperialPurple;

  /// النص الباهت
  static const Color textMuted = Color(0xFF606060);

  // ============================================================================
  // SEMANTIC COLORS - الألوان الدلالية
  // ============================================================================

  /// اللون الإيجابي (أخضر)
  static const Color success = Color(0xFF00FF88);
  static const Color successDark = Color(0xFF00CC6A);

  /// اللون السلبي (أحمر)
  static const Color error = Color(0xFFFF3366);
  static const Color errorDark = Color(0xFFCC0033);

  /// اللون التحذيري (برتقالي)
  static const Color warning = Color(0xFFFFAA00);
  static const Color warningDark = Color(0xFFCC8800);

  /// اللون المعلوماتي (أزرق)
  static const Color info = Color(0xFF00AAFF);
  static const Color infoDark = Color(0xFF0088CC);

  /// اللون السماوي (Cyan) - للتحليل الكمومي
  static const Color cyan = Color(0xFF00D9FF);

  // ============================================================================
  // TRADING COLORS - ألوان التداول
  // ============================================================================

  /// BUY - شراء (أخضر ذهبي)
  static const Color buy = Color(0xFF00FF88);
  static const LinearGradient buyGradient = LinearGradient(
    colors: [Color(0xFF00FF88), Color(0xFF00CC6A)],
  );

  /// SELL - بيع (أحمر ذهبي)
  static const Color sell = Color(0xFFFF3366);
  static const LinearGradient sellGradient = LinearGradient(
    colors: [Color(0xFFFF3366), Color(0xFFCC0033)],
  );

  /// NEUTRAL - محايد (ذهبي)
  static const Color neutral = royalGold;

  // ============================================================================
  // BORDER COLORS - ألوان الحدود
  // ============================================================================

  /// الحد الأساسي
  static const Color border = Color(0xFF2A2A2A);

  /// الحد الذهبي
  static const Color borderGold = royalGold;

  /// الحد البنفسجي
  static const Color borderPurple = imperialPurple;

  /// الحد الشفاف
  static const Color borderTransparent = Color(0x33FFFFFF);

  /// Alias for border (for compatibility)
  static const Color borderColor = border;

  /// Alias for background (for compatibility)
  static const Color backgroundPrimary = background;

  // ============================================================================
  // ADDITIONAL ALIASES - أسماء بديلة إضافية
  // ============================================================================

  /// Background aliases for compatibility
  static const Color bgPrimary = background;
  static const Color bgSecondary = backgroundSecondary;
  static const Color bgCard = backgroundSecondary;
  static const Color bgHover = backgroundTertiary;

  /// Gold aliases for compatibility
  static const Color goldMain = royalGold;

  /// Badge colors for trading signals
  static const Color sellBadgeBg = Color(0x33FF4757);
  static const Color buyBadgeBg = Color(0x3300D9A3);
  static const Color sellBadgeText = error;
  static const Color buyBadgeText = success;

  /// Trading profit color
  static const Color profit = success;

  /// Shadow alias
  static const Color cardShadow = shadowDark;

  // ============================================================================
  // SHADOW COLORS - ألوان الظلال (مُحسّنة)
  // ============================================================================

  /// ظل ذهبي
  static const Color shadowGold = Color(0x66D4AF37);

  /// ظل بنفسجي
  static const Color shadowPurple = Color(0x664A148C);

  /// ظل أسود
  static const Color shadowDark = Color(0x99000000);

  /// ظل أزرق
  static const Color shadowBlue = Color(0x660F3460);

  // ============================================================================
  // GLOW EFFECTS - تأثيرات التوهج
  // ============================================================================

  /// توهج ذهبي
  static List<BoxShadow> get goldGlow => [
        BoxShadow(
          color: royalGold.withValues(alpha: 0.4),
          blurRadius: 20,
          spreadRadius: 2,
        ),
        BoxShadow(
          color: royalGold.withValues(alpha: 0.2),
          blurRadius: 40,
          spreadRadius: 5,
        ),
      ];

  /// توهج بنفسجي
  static List<BoxShadow> get purpleGlow => [
        BoxShadow(
          color: imperialPurple.withValues(alpha: 0.4),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];

  /// توهج أزرق
  static List<BoxShadow> get blueGlow => [
        BoxShadow(
          color: sapphireBlue.withValues(alpha: 0.4),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];

  /// توهج نجاح
  static List<BoxShadow> get successGlow => [
        BoxShadow(
          color: success.withValues(alpha: 0.4),
          blurRadius: 15,
          spreadRadius: 0,
        ),
      ];

  /// توهج خطأ
  static List<BoxShadow> get errorGlow => [
        BoxShadow(
          color: error.withValues(alpha: 0.4),
          blurRadius: 15,
          spreadRadius: 0,
        ),
      ];

  // ============================================================================
  // OVERLAY COLORS - ألوان الطبقات
  // ============================================================================

  /// طبقة داكنة
  static const Color overlayDark = Color(0xCC000000);

  /// طبقة خفيفة
  static const Color overlayLight = Color(0x33FFFFFF);

  /// طبقة ذهبية
  static const Color overlayGold = Color(0x33D4AF37);

  // ============================================================================
  // CHART COLORS - ألوان الرسوم البيانية
  // ============================================================================

  /// شمعة صاعدة
  static const Color candleBullish = success;

  /// شمعة هابطة
  static const Color candleBearish = error;

  /// خط الترند
  static const Color trendLine = royalGold;

  /// مستوى الدعم
  static const Color supportLevel = success;

  /// مستوى المقاومة
  static const Color resistanceLevel = error;

  // ============================================================================
  // SHIMMER COLORS - ألوان التأثيرات
  // ============================================================================

  /// ألوان Shimmer الذهبية
  static const Color shimmerBase = Color(0xFF1F1F1F);
  static const Color shimmerHighlight = Color(0x33D4AF37);

  // ============================================================================
  // HELPER METHODS - دوال مساعدة
  // ============================================================================

  /// الحصول على لون بناءً على قيمة (موجب/سالب)
  static Color getColorByValue(double value) {
    if (value > 0) return success;
    if (value < 0) return error;
    return textSecondary;
  }

  /// الحصول على لون الاتجاه
  static Color getTrendColor(String trend) {
    switch (trend.toUpperCase()) {
      case 'UP':
      case 'BULLISH':
        return success;
      case 'DOWN':
      case 'BEARISH':
        return error;
      case 'NEUTRAL':
      case 'SIDEWAYS':
      default:
        return neutral;
    }
  }

  /// الحصول على تدرج بناءً على الاتجاه
  static LinearGradient getTrendGradient(String trend) {
    switch (trend.toUpperCase()) {
      case 'UP':
      case 'BULLISH':
        return buyGradient;
      case 'DOWN':
      case 'BEARISH':
        return sellGradient;
      default:
        return goldGradient;
    }
  }
}
