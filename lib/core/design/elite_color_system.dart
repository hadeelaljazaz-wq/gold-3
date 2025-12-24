// lib/core/design/elite_color_system.dart

import 'package:flutter/material.dart';

/// نظام ألوان متقدم مستوحى من أفضل التطبيقات العالمية
class EliteColorSystem {
  
  // ═══════════════════════════════════════════════════════
  // ⚫ Dark Mode Premium (Primary Theme)
  // ═══════════════════════════════════════════════════════
  
  /// الخلفية الرئيسية - أسود نقي بتدرجات
  static const deepBlack = Color(0xFF000000);
  static const richBlack = Color(0xFF0A0A0A);
  static const softBlack = Color(0xFF141414);
  static const charcoal = Color(0xFF1E1E1E);
  static const slate = Color(0xFF2A2A2A);
  
  /// الذهب الفاخر - 5 تدرجات
  static const pureGold = Color(0xFFFFD700);        // #FFD700
  static const richGold = Color(0xFFFFC107);        // #FFC107
  static const warmGold = Color(0xFFFFB300);        // #FFB300
  static const deepGold = Color(0xFFFF8F00);        // #FF8F00
  static const roseGold = Color(0xFFE91E63);        // Rose Gold Accent
  
  /// الأخضر الزمردي - للإيجابي
  static const vibrantGreen = Color(0xFF00E676);    // Neon Green
  static const richGreen = Color(0xFF00C853);       // Rich Green
  static const deepGreen = Color(0xFF00BFA5);       // Teal Green
  static const emerald = Color(0xFF1DE9B6);         // Emerald
  
  /// الأحمر الياقوتي - للسلبي
  static const vibrantRed = Color(0xFFFF1744);      // Neon Red
  static const richRed = Color(0xFFD50000);         // Rich Red
  static const deepRed = Color(0xFFC62828);         // Deep Red
  static const ruby = Color(0xFFE91E63);            // Ruby
  
  /// الأزرق الكريستالي - للمعلومات
  static const neonBlue = Color(0xFF00B8D4);        // Neon Cyan
  static const electricBlue = Color(0xFF2979FF);    // Electric Blue
  static const deepBlue = Color(0xFF1976D2);        // Deep Blue
  static const sapphire = Color(0xFF0D47A1);        // Sapphire
  
  /// البنفسجي الإمبراطوري - للتميز
  static const neonPurple = Color(0xFFD500F9);      // Neon Purple
  static const richPurple = Color(0xFFAA00FF);      // Rich Purple
  static const deepPurple = Color(0xFF6A1B9A);      // Deep Purple
  static const amethyst = Color(0xFF9C27B0);        // Amethyst
  
  /// الرمادي الحريري - للنصوص
  static const pureWhite = Color(0xFFFFFFFF);       // Pure White
  static const platinum = Color(0xFFF5F5F5);        // Platinum
  static const silver = Color(0xFFE0E0E0);          // Silver
  static const steel = Color(0xFFBDBDBD);           // Steel
  static const smoke = Color(0xFF9E9E9E);           // Smoke
  static const ash = Color(0xFF757575);             // Ash
  static const graphite = Color(0xFF616161);        // Graphite
  static const iron = Color(0xFF424242);            // Iron
  
  // ═══════════════════════════════════════════════════════
  // 🌈 Glassmorphism Colors
  // ═══════════════════════════════════════════════════════
  
  /// الشفافيات للزجاج
  static const glass5 = Color(0x0DFFFFFF);          // 5% white
  static const glass10 = Color(0x1AFFFFFF);         // 10% white
  static const glass15 = Color(0x26FFFFFF);         // 15% white
  static const glass20 = Color(0x33FFFFFF);         // 20% white
  static const glass30 = Color(0x4DFFFFFF);         // 30% white
  
  static const glassBlack5 = Color(0x0D000000);     // 5% black
  static const glassBlack10 = Color(0x1A000000);    // 10% black
  static const glassBlack20 = Color(0x33000000);    // 20% black
  static const glassBlack30 = Color(0x4D000000);    // 30% black
  
  static const glassGold10 = Color(0x1AFFD700);     // 10% gold
  static const glassGold15 = Color(0x26FFD700);     // 15% gold
  static const glassGold20 = Color(0x33FFD700);     // 20% gold
  
  // ═══════════════════════════════════════════════════════
  // 🎨 Gradient Systems
  // ═══════════════════════════════════════════════════════
  
  /// التدرج الذهبي الفاخر
  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFD700),  // Pure Gold
      Color(0xFFFFC107),  // Rich Gold
      Color(0xFFFF8F00),  // Deep Gold
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  /// التدرج الأخضر الحيوي
  static const successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00E676),  // Vibrant Green
      Color(0xFF00C853),  // Rich Green
      Color(0xFF00BFA5),  // Teal Green
    ],
  );
  
  /// التدرج الأحمر الديناميكي
  static const dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF1744),  // Vibrant Red
      Color(0xFFD50000),  // Rich Red
      Color(0xFFC62828),  // Deep Red
    ],
  );
  
  /// التدرج الأزرق الكهربائي
  static const infoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00B8D4),  // Neon Cyan
      Color(0xFF2979FF),  // Electric Blue
      Color(0xFF1976D2),  // Deep Blue
    ],
  );
  
  /// التدرج البنفسجي الملكي
  static const premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD500F9),  // Neon Purple
      Color(0xFFAA00FF),  // Rich Purple
      Color(0xFF6A1B9A),  // Deep Purple
    ],
  );
  
  /// التدرج الداكن الفاخر (للخلفيات)
  static const darkBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF000000),  // Deep Black
      Color(0xFF0A0A0A),  // Rich Black
      Color(0xFF141414),  // Soft Black
      Color(0xFF1E1E1E),  // Charcoal
    ],
  );
  
  /// Radial Gradient للتوهج
  static const glowGradient = RadialGradient(
    center: Alignment.center,
    radius: 1.0,
    colors: [
      Color(0xFFFFD700),      // Gold center
      Color(0x80FFD700),      // 50% gold
      Color(0x00FFD700),      // Transparent
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  /// Sweep Gradient للحركة
  static const animatedGradient = SweepGradient(
    center: Alignment.center,
    colors: [
      Color(0xFFFFD700),  // Gold
      Color(0xFFFF8F00),  // Deep Gold
      Color(0xFFE91E63),  // Rose Gold
      Color(0xFFD500F9),  // Neon Purple
      Color(0xFF2979FF),  // Electric Blue
      Color(0xFF00E676),  // Vibrant Green
      Color(0xFFFFD700),  // Back to Gold
    ],
  );
}

/// نظام الطباعة المتقدم
class EliteTypography {
  // Display - للعناوين الضخمة
  static const display1 = TextStyle(
    fontSize: 96,
    fontWeight: FontWeight.w900,
    letterSpacing: -1.5,
    color: EliteColorSystem.pureWhite,
    height: 1.0,
  );
  
  static const display2 = TextStyle(
    fontSize: 60,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
    color: EliteColorSystem.pureWhite,
    height: 1.1,
  );
  
  // Headline - للعناوين
  static const headline1 = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.0,
    color: EliteColorSystem.pureWhite,
    height: 1.2,
  );
  
  static const headline2 = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.25,
    color: EliteColorSystem.pureWhite,
    height: 1.2,
  );
  
  static const headline3 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.0,
    color: EliteColorSystem.pureWhite,
    height: 1.3,
  );
  
  static const headline4 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    color: EliteColorSystem.pureWhite,
    height: 1.3,
  );
  
  // Body - للنصوص العادية
  static const bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    color: EliteColorSystem.platinum,
    height: 1.5,
  );
  
  static const bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: EliteColorSystem.platinum,
    height: 1.5,
  );
  
  static const bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: EliteColorSystem.silver,
    height: 1.4,
  );
  
  // Labels - للتسميات
  static const labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: EliteColorSystem.pureWhite,
    height: 1.2,
  );
  
  static const labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: EliteColorSystem.platinum,
    height: 1.2,
  );
  
  static const labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: EliteColorSystem.silver,
    height: 1.2,
  );
  
  // Caption - للنصوص الصغيرة
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: EliteColorSystem.smoke,
    height: 1.3,
  );
  
  // Data - للأرقام
  static const dataLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    fontFamily: 'monospace',
    color: EliteColorSystem.pureGold,
    height: 1.1,
  );
  
  static const dataMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.0,
    fontFamily: 'monospace',
    color: EliteColorSystem.pureGold,
    height: 1.2,
  );
  
  static const dataSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    fontFamily: 'monospace',
    color: EliteColorSystem.richGold,
    height: 1.2,
  );
}

