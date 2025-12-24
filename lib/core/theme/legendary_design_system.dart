/// 👑 LEGENDARY UI DESIGN SYSTEM 👑
///
/// **الفلسفة:** تصميم ملكي فاخر مع وظائفية احترافية
///
/// **المبادئ:**
/// 1. 🏆 الفخامة الملكية (Royal Luxury)
/// 2. ⚡ الوضوح والقرائية (Clear Readability)
/// 3. 🎯 التركيز على المعلومات المهمة
/// 4. ✨ الأنيميشن الاحترافي
/// 5. 🎨 التدرجات الذهبية الفاخرة
///
library;

import 'package:flutter/material.dart';

class LegendaryDesignSystem {
  // ═══════════════════════════════════════════════════════════════
  // 🎨 COLOR PALETTE - الألوان الملكية
  // ═══════════════════════════════════════════════════════════════

  /// الأسود الملكي العميق
  static const deepRoyalBlack = Color(0xFF0A0A0F);

  /// الأسود الداكن للخلفيات
  static const darkBackground = Color(0xFF12121A);

  /// الرمادي الداكن للكروت
  static const cardBackground = Color(0xFF1A1A25);

  /// الذهبي الملكي الأساسي
  static const royalGold = Color(0xFFFFD700);

  /// الذهبي الفاتح للإضاءة
  static const lightGold = Color(0xFFFFF4CC);

  /// الذهبي الداكن للظلال
  static const darkGold = Color(0xFFB8860B);

  /// الذهبي الوردي الفاخر
  static const roseGold = Color(0xFFE6B8A2);

  /// الأخضر للشراء/الصعود
  static const emeraldGreen = Color(0xFF00D9A3);

  /// الأحمر للبيع/الهبوط
  static const rubyRed = Color(0xFFFF4757);

  /// البرتقالي للتحذيرات
  static const amberWarning = Color(0xFFFFA502);

  /// الأزرق للمعلومات
  static const sapphireBlue = Color(0xFF5352ED);

  // ═══════════════════════════════════════════════════════════════
  // 🔗 COLOR ALIASES - أسماء بديلة للألوان (for compatibility)
  // ═══════════════════════════════════════════════════════════════

  /// Gold primary alias
  static const goldPrimary = royalGold;

  /// Gold shimmer alias
  static const goldShimmer = lightGold;

  /// Gold light alias
  static const goldLight = Color(0xFFFFE55C);

  /// Champagne color
  static const champagne = Color(0xFFF7E7CE);

  /// Obsidian (same as deepRoyalBlack)
  static const obsidian = deepRoyalBlack;

  // ═══════════════════════════════════════════════════════════════
  // ✨ GRADIENTS - التدرجات الذهبية
  // ═══════════════════════════════════════════════════════════════

  /// تدرج ذهبي رئيسي (أفقي)
  static const LinearGradient royalGoldGradient = LinearGradient(
    colors: [
      Color(0xFFFFD700), // Gold
      Color(0xFFFFF4CC), // Light Gold
      Color(0xFFFFD700), // Gold
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// تدرج ذهبي مع وردي (فاخر)
  static const LinearGradient luxuryGradient = LinearGradient(
    colors: [
      Color(0xFFFFD700), // Gold
      Color(0xFFE6B8A2), // Rose Gold
      Color(0xFFFFD700), // Gold
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// تدرج خلفية داكنة مع ذهبي
  static const LinearGradient darkGoldGradient = LinearGradient(
    colors: [
      Color(0xFF12121A), // Dark
      Color(0xFF1A1A25), // Card Background
      Color(0xFF0A0A0F), // Deep Black
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// تدرج للكروت (شفاف مع ذهبي)
  static const LinearGradient cardGradient = LinearGradient(
    colors: [
      Color(0xFF1A1A25),
      Color(0xFF252530),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// تدرج للشراء (أخضر)
  static const LinearGradient buyGradient = LinearGradient(
    colors: [
      Color(0xFF00D9A3),
      Color(0xFF00C48C),
    ],
  );

  /// تدرج للبيع (أحمر)
  static const LinearGradient sellGradient = LinearGradient(
    colors: [
      Color(0xFFFF4757),
      Color(0xFFFF3838),
    ],
  );

  // ═══════════════════════════════════════════════════════════════
  // 🌟 SHADOWS & GLOWS - الظلال والتوهج
  // ═══════════════════════════════════════════════════════════════

  /// توهج ذهبي للكروت المهمة
  static List<BoxShadow> get royalGoldGlow => [
        BoxShadow(
          color: royalGold.withValues(alpha: 0.3),
          blurRadius: 20,
          spreadRadius: 2,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: royalGold.withValues(alpha: 0.15),
          blurRadius: 40,
          spreadRadius: 4,
          offset: const Offset(0, 8),
        ),
      ];

  /// ظل داكن ناعم للكروت
  static List<BoxShadow> get softDarkShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 15,
          spreadRadius: 1,
          offset: const Offset(0, 4),
        ),
      ];

  /// توهج أخضر للشراء
  static List<BoxShadow> get emeraldGlow => [
        BoxShadow(
          color: emeraldGreen.withValues(alpha: 0.25),
          blurRadius: 20,
          spreadRadius: 2,
          offset: const Offset(0, 4),
        ),
      ];

  /// توهج أحمر للبيع
  static List<BoxShadow> get rubyGlow => [
        BoxShadow(
          color: rubyRed.withValues(alpha: 0.25),
          blurRadius: 20,
          spreadRadius: 2,
          offset: const Offset(0, 4),
        ),
      ];

  // ═══════════════════════════════════════════════════════════════
  // 📏 SPACING & SIZING - المسافات والأحجام
  // ═══════════════════════════════════════════════════════════════

  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;

  static const double borderRadius8 = 8.0;
  static const double borderRadius12 = 12.0;
  static const double borderRadius16 = 16.0;
  static const double borderRadius20 = 20.0;
  static const double borderRadius24 = 24.0;

  // ═══════════════════════════════════════════════════════════════
  // 🔤 TYPOGRAPHY - الخطوط
  // ═══════════════════════════════════════════════════════════════

  /// عنوان رئيسي كبير
  static TextStyle get headlineLarge => const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: -0.5,
        height: 1.2,
      );

  /// عنوان متوسط
  static TextStyle get headlineMedium => const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: -0.3,
        height: 1.3,
      );

  /// عنوان صغير
  static TextStyle get headlineSmall => const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.4,
      );

  /// نص أساسي
  static TextStyle get bodyLarge => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Colors.white.withValues(alpha: 0.7),
        height: 1.5,
      );

  /// نص متوسط
  static TextStyle get bodyMedium => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Colors.white.withValues(alpha: 0.6),
        height: 1.5,
      );

  /// نص صغير
  static TextStyle get bodySmall => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: Colors.white.withValues(alpha: 0.5),
        height: 1.4,
      );

  /// نص ذهبي فاخر
  static TextStyle get goldText => const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: royalGold,
        letterSpacing: 0.5,
      );

  /// سعر كبير
  static TextStyle get priceDisplay => const TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: royalGold,
        letterSpacing: -1,
        height: 1.1,
      );

  // ═══════════════════════════════════════════════════════════════
  // 🎨 DECORATION BUILDERS - بناة التزيين
  // ═══════════════════════════════════════════════════════════════

  /// كارت ملكي فاخر
  static BoxDecoration buildRoyalCard({
    bool withGlow = true,
    Color? borderColor,
  }) {
    return BoxDecoration(
      gradient: cardGradient,
      borderRadius: BorderRadius.circular(borderRadius20),
      border: Border.all(
        color: borderColor ?? royalGold.withValues(alpha: 0.3),
        width: 1,
      ),
      boxShadow: withGlow ? royalGoldGlow : softDarkShadow,
    );
  }

  /// كارت للشراء
  static BoxDecoration buildBuyCard({bool withGlow = true}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color(0xFF1A1A25),
          Color(0xFF1A2A25),
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius16),
      border: Border.all(
        color: emeraldGreen.withValues(alpha: 0.5),
        width: 2,
      ),
      boxShadow: withGlow ? emeraldGlow : softDarkShadow,
    );
  }

  /// كارت للبيع
  static BoxDecoration buildSellCard({bool withGlow = true}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color(0xFF1A1A25),
          Color(0xFF2A1A1A),
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius16),
      border: Border.all(
        color: rubyRed.withValues(alpha: 0.5),
        width: 2,
      ),
      boxShadow: withGlow ? rubyGlow : softDarkShadow,
    );
  }

  /// كارت محايد (انتظار)
  static BoxDecoration buildNeutralCard({bool withGlow = true}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color(0xFF1A1A25),
          Color(0xFF252530),
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius16),
      border: Border.all(
        color: amberWarning.withValues(alpha: 0.5),
        width: 2,
      ),
      boxShadow: withGlow
          ? [
              BoxShadow(
                color: amberWarning.withValues(alpha: 0.25),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ]
          : softDarkShadow,
    );
  }

  /// خلفية متدرجة للشاشة
  static BoxDecoration get screenBackground => const BoxDecoration(
        gradient: darkGoldGradient,
      );

  // ═══════════════════════════════════════════════════════════════
  // ⚡ ANIMATION CURVES - منحنيات الأنيميشن
  // ═══════════════════════════════════════════════════════════════

  static const Curve smoothCurve = Curves.easeInOutCubic;
  static const Curve bouncyCurve = Curves.elasticOut;
  static const Curve quickCurve = Curves.easeOut;

  static const Duration fastDuration = Duration(milliseconds: 200);
  static const Duration normalDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 500);

  // ═══════════════════════════════════════════════════════════════
  // 🎯 COMMON WIDGETS - ويدجتات شائعة
  // ═══════════════════════════════════════════════════════════════

  /// أيقونة ذهبية فاخرة
  static Widget buildGoldenIcon(IconData icon, {double size = 24}) {
    return ShaderMask(
      shaderCallback: (bounds) => royalGoldGradient.createShader(bounds),
      child: Icon(
        icon,
        size: size,
        color: Colors.white,
      ),
    );
  }

  /// نص ذهبي متدرج
  static Widget buildGoldenText(String text, {TextStyle? style}) {
    return ShaderMask(
      shaderCallback: (bounds) => royalGoldGradient.createShader(bounds),
      child: Text(
        text,
        style: (style ?? headlineMedium).copyWith(color: Colors.white),
      ),
    );
  }

  /// مؤشر تحميل ذهبي
  static Widget get goldenLoader => ShaderMask(
        shaderCallback: (bounds) => royalGoldGradient.createShader(bounds),
        child: const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 3,
        ),
      );

  /// شريط توهج ذهبي
  static Widget buildGoldenDivider({double thickness = 2}) {
    return Container(
      height: thickness,
      decoration: BoxDecoration(
        gradient: royalGoldGradient,
        borderRadius: BorderRadius.circular(thickness / 2),
        boxShadow: royalGoldGlow,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🏆 SIGNAL BADGES - شارات الإشارات
  // ═══════════════════════════════════════════════════════════════

  /// شارة شراء
  static Widget buildBuyBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: buyGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: emeraldGlow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.trending_up, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// شارة بيع
  static Widget buildSellBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: sellGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: rubyGlow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.trending_down, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// شارة انتظار
  static Widget buildWaitBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.remove,
              color: Colors.white.withValues(alpha: 0.7), size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 📊 CONFIDENCE INDICATORS - مؤشرات الثقة
  // ═══════════════════════════════════════════════════════════════

  /// شريط مؤشر الثقة
  static Widget buildConfidenceBar(double confidence) {
    Color color;
    if (confidence >= 80) {
      color = emeraldGreen;
    } else if (confidence >= 60) {
      color = amberWarning;
    } else {
      color = rubyRed;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'نسبة الثقة',
              style: bodyMedium,
            ),
            Text(
              '${confidence.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: confidence / 100,
            minHeight: 8,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 🎭 CUSTOM PAINTERS - رسامات مخصصة
// ═══════════════════════════════════════════════════════════════

/// رسام ذرات الذهب المتحركة
class GoldenParticlesPainter extends CustomPainter {
  final Animation<double> animation;
  final List<Particle> particles;

  GoldenParticlesPainter(this.animation, this.particles)
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = LegendaryDesignSystem.royalGold.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    for (final particle in particles) {
      final x = particle.x * size.width;
      final y = (particle.y + (animation.value * 0.5)) % size.height;
      canvas.drawCircle(
        Offset(x, y),
        particle.size * (1 + animation.value * 0.3),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Particle {
  final double x;
  final double y;
  final double size;

  Particle(this.x, this.y, this.size);
}
