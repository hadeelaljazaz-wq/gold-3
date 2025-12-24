import 'package:flutter/material.dart';

/// 👑 Royal Futurism Theme
/// نظام الألوان الملكي + Design Tokens
class RoyalTheme {
  // ═══════════════════════════════════════════════════════════════════════
  // 🎨 ROYAL PALETTE - الألوان الملكية
  // ═══════════════════════════════════════════════════════════════════════

  // Primary Colors - مُحسّنة للوضوح والجمال
  static const Color royalPurple =
      Color(0xFF9C27B0); // Amethyst Violet (أكثر إشراقاً)
  static const Color imperialGold =
      Color(0xFFFFD700); // Imperial Gold (أكثر لمعاناً)
  static const Color iridescentLight = Color(0xFFBA68C8); // Accent Iridescent
  static const Color deepEmerald =
      Color(0xFF10B981); // Deep Emerald (أكثر حيوية)
  static const Color midnightNavy =
      Color(0xFF0A1128); // Midnight Navy (أزرق عميق)
  static const Color charcoal =
      Color(0xFF0F1629); // Charcoal Base (مع لمسة زرقاء)

  // ألوان ملكية إضافية
  static const Color royalGoldMain = Color(0xFFD4AF37); // الذهب الملكي الأصلي
  static const Color champagneGold = Color(0xFFF7E7CE); // ذهب الشمبانيا
  static const Color sapphireBlue = Color(0xFF0F3460); // أزرق الياقوت
  static const Color crystalBlue = Color(0xFF1A2332); // أزرق كريستالي

  // Semantic Colors
  static const Color success = Color(0xFF10b981);
  static const Color successMuted = Color(0xFF166856);
  static const Color danger = Color(0xFFef4444);
  static const Color dangerMuted = Color(0xFF7f1d1d);
  static const Color warning = Color(0xFFfbbf24);

  // Glass & Overlays
  static const Color glassBg = Color(0x0FFFFFFF); // rgba(255,255,255,0.06)
  static const Color glassBorder = Color(0x23FFFFFF); // rgba(255,255,255,0.14)
  static const Color softLavender = Color(0x406e3cc3); // rgba(110,60,195,0.25)
  static const Color softGold = Color(0x26d4af37); // rgba(212,175,55,0.15)
  static const Color softEmerald = Color(0x33059669); // rgba(5,150,105,0.20)

  // Text Colors
  static const Color textPrimary = Color(0xF0FFFFFF); // rgba(255,255,255,0.94)
  static const Color textSecondary = Color(0x99FFFFFF); // rgba(255,255,255,0.6)
  static const Color textTertiary = Color(0xB3FFFFFF); // rgba(255,255,255,0.7)

  // ═══════════════════════════════════════════════════════════════════════
  // 🎨 GRADIENTS - التدرجات
  // ═══════════════════════════════════════════════════════════════════════

  static const LinearGradient royalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A1128), // Midnight Blue
      Color(0xFF16213E), // Royal Navy
      Color(0xFF0F3460), // Sapphire
    ],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFD700), // Bright Gold ⭐
      Color(0xFFD4AF37), // Royal Gold
      Color(0xFFF7E7CE), // Champagne
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10B981), // Emerald
      Color(0xFF059669), // Deep Emerald
    ],
  );

  static const LinearGradient purpleGoldGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF9C27B0), // Amethyst
      Color(0xFFFFD700), // Gold
      Color(0xFF9C27B0), // Amethyst
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// 🌟 تدرج الخلفية الملكي الجديد
  static const LinearGradient royalBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0A1128), // Midnight
      Color(0xFF16213E), // Navy
      Color(0xFF1A2332), // Crystal
    ],
  );

  /// ✨ تدرج لامع ذهبي
  static const LinearGradient shimmerGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFD700),
      Color(0xFFF7E7CE),
      Color(0xFFD4AF37),
      Color(0xFFFFD700),
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  // ═══════════════════════════════════════════════════════════════════════
  // 📏 SPACING - المسافات
  // ═══════════════════════════════════════════════════════════════════════

  static const double spaceXs = 6.0;
  static const double spaceSm = 10.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 34.0;
  static const double space2Xl = 40.0;

  static const double gapXs = 8.0;
  static const double gapSm = 12.0;
  static const double gapMd = 18.0;
  static const double gapLg = 24.0;
  static const double gapXl = 36.0;

  // ═══════════════════════════════════════════════════════════════════════
  // 🔘 RADIUS - الحواف
  // ═══════════════════════════════════════════════════════════════════════

  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusCard = 26.0;
  static const double radiusPill = 22.0;
  static const double radiusFull = 9999.0;

  // ═══════════════════════════════════════════════════════════════════════
  // 🌑 SHADOWS - الظلال
  // ═══════════════════════════════════════════════════════════════════════

  static List<BoxShadow> get softShadow => [
        const BoxShadow(
          color: Color(0x73000000),
          blurRadius: 30,
          offset: Offset(0, 10),
        ),
        const BoxShadow(
          color: Color(0x59000000),
          blurRadius: 10,
          offset: Offset(0, 3),
        ),
      ];

  static List<BoxShadow> get hardShadow => [
        const BoxShadow(
          color: Color(0x8C000000),
          blurRadius: 60,
          offset: Offset(0, 30),
        ),
        const BoxShadow(
          color: Color(0x80000000),
          blurRadius: 30,
          offset: Offset(0, 12),
        ),
      ];

  static List<BoxShadow> get glowGold => [
        const BoxShadow(
          color: Color(0x99FFD700), // 60% Gold - أكثر سطوعاً
          blurRadius: 30,
          spreadRadius: 2,
        ),
        const BoxShadow(
          color: Color(0x66D4AF37), // 40% Royal Gold
          blurRadius: 45,
          spreadRadius: 5,
        ),
      ];

  static List<BoxShadow> get glowPurple => [
        const BoxShadow(
          color: Color(0x999C27B0), // 60% Amethyst - أكثر سطوعاً
          blurRadius: 28,
          spreadRadius: 2,
        ),
        const BoxShadow(
          color: Color(0x664A148C), // 40% Deep Purple
          blurRadius: 40,
        ),
      ];

  static List<BoxShadow> get glowEmerald => [
        const BoxShadow(
          color: Color(0x9910B981), // 60% Emerald - أكثر سطوعاً
          blurRadius: 25,
          spreadRadius: 2,
        ),
        const BoxShadow(
          color: Color(0x66059669), // 40% Deep Emerald
          blurRadius: 35,
        ),
      ];

  /// ✨ توهج ذهبي قوي
  static List<BoxShadow> get intenseGoldGlow => [
        const BoxShadow(
          color: Color(0xCCFFD700), // 80% Gold
          blurRadius: 40,
          spreadRadius: 5,
        ),
        const BoxShadow(
          color: Color(0x99D4AF37), // 60% Royal Gold
          blurRadius: 60,
          spreadRadius: 10,
        ),
      ];

  /// 💎 توهج نيون
  static List<BoxShadow> get neonGlow => [
        const BoxShadow(
          color: Color(0x9900D9FF), // Cyan Neon
          blurRadius: 30,
          spreadRadius: 3,
        ),
      ];

  // ═══════════════════════════════════════════════════════════════════════
  // 🎭 DECORATIONS - التزيينات الجاهزة
  // ═══════════════════════════════════════════════════════════════════════

  static BoxDecoration get glassCard => BoxDecoration(
        gradient: royalGradient,
        borderRadius: BorderRadius.circular(radiusCard),
        border: Border.all(
          color: glassBorder,
          width: 1,
        ),
        boxShadow: hardShadow,
      );

  static BoxDecoration get pillDecoration => BoxDecoration(
        color: glassBg,
        borderRadius: BorderRadius.circular(radiusFull),
        border: Border.all(
          color: glassBorder,
          width: 1,
        ),
      );

  // ═══════════════════════════════════════════════════════════════════════
  // 📝 TYPOGRAPHY - الخطوط
  // ═══════════════════════════════════════════════════════════════════════

  static const TextStyle titleStyle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    letterSpacing: 2,
    height: 1.2,
  );

  static const TextStyle headlineStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 1.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  // ═══════════════════════════════════════════════════════════════════════
  // 🎯 THEME DATA
  // ═══════════════════════════════════════════════════════════════════════

  static ThemeData get theme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: midnightNavy,
        primaryColor: royalPurple,
        colorScheme: const ColorScheme.dark(
          primary: royalPurple,
          secondary: imperialGold,
          surface: charcoal,
          error: danger,
        ),
        textTheme: const TextTheme(
          displayLarge: titleStyle,
          headlineMedium: headlineStyle,
          bodyLarge: bodyLarge,
          bodyMedium: bodyMedium,
          bodySmall: bodySmall,
          labelSmall: caption,
        ),
        fontFamily: 'Segoe UI',
        useMaterial3: true,
      );
}
