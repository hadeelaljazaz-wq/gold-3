import 'package:flutter/material.dart';

/// 👑 أيقونات ملكية مخصصة لتطبيق Gold Nightmare Pro
class RoyalIcons {
  RoyalIcons._();

  // ═══════════════════════════════════════════════════════════════
  // 🎨 SVG Icons Data
  // ═══════════════════════════════════════════════════════════════

  /// 👑 تاج ملكي
  static const String crownSVG = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 2L9 12h6l-3-10zm-7 8l-3 10h22l-3-10-5 4-4-6-4 6-3-4z" fill="#D4AF37"/>
  <path d="M2 20h20v2H2z" fill="#B89029"/>
</svg>
''';

  /// 🥇 سبيكة ذهب
  static const String goldBarSVG = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M4 8h16v10H4z" fill="#D4AF37"/>
  <path d="M4 8l2-3h12l2 3z" fill="#F7E7CE"/>
  <path d="M4 8l2-3h12l2 3H4z" stroke="#B89029" stroke-width="0.5"/>
  <path d="M6 11h12v1H6z" fill="#B89029" opacity="0.3"/>
</svg>
''';

  /// 📈 سهم صعود
  static const String bullArrowSVG = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M7 17l5-10 5 10" stroke="#10B981" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M12 7v10" stroke="#10B981" stroke-width="2" stroke-linecap="round"/>
</svg>
''';

  /// 📉 سهم هبوط
  static const String bearArrowSVG = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M7 7l5 10 5-10" stroke="#DC2626" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M12 17V7" stroke="#DC2626" stroke-width="2" stroke-linecap="round"/>
</svg>
''';

  /// 💎 ألماس
  static const String diamondSVG = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 2L2 9l10 13 10-13z" fill="#00D9FF"/>
  <path d="M12 2L7 9h10z" fill="#80ECFF"/>
  <path d="M2 9l5 0 5 13z" fill="#00B8D4"/>
  <path d="M22 9l-5 0-5 13z" fill="#00B8D4"/>
</svg>
''';

  /// 🔔 جرس إشعار
  static const String notificationBellSVG = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9" fill="#D4AF37"/>
  <path d="M13.73 21a2 2 0 0 1-3.46 0" stroke="#D4AF37" stroke-width="2" stroke-linecap="round"/>
</svg>
''';

  /// 📊 شارت
  static const String chartSVG = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M3 3v18h18" stroke="#D4AF37" stroke-width="2" stroke-linecap="round"/>
  <path d="M7 14l4-4 4 4 5-6" stroke="#10B981" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';

  /// 🎯 هدف
  static const String targetSVG = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="12" cy="12" r="10" stroke="#D4AF37" stroke-width="2"/>
  <circle cx="12" cy="12" r="6" stroke="#D4AF37" stroke-width="2"/>
  <circle cx="12" cy="12" r="2" fill="#D4AF37"/>
</svg>
''';

  /// 🔒 قفل
  static const String lockSVG = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="3" y="11" width="18" height="11" rx="2" fill="#D4AF37"/>
  <path d="M7 11V7a5 5 0 0 1 10 0v4" stroke="#D4AF37" stroke-width="2" stroke-linecap="round"/>
</svg>
''';

  /// 🔓 قفل مفتوح
  static const String unlockSVG = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="3" y="11" width="18" height="11" rx="2" fill="#10B981"/>
  <path d="M7 11V7a5 5 0 0 1 9.9-1" stroke="#10B981" stroke-width="2" stroke-linecap="round"/>
</svg>
''';

  /// ⚡ صاعقة
  static const String boltSVG = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z" fill="#FBBF24"/>
</svg>
''';

  /// 🌟 نجمة
  static const String starSVG = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" fill="#D4AF37"/>
</svg>
''';

  /// 💰 كيس نقود
  static const String moneyBagSVG = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 2c-1.5 0-3 2-3 4h6c0-2-1.5-4-3-4z" fill="#D4AF37"/>
  <path d="M5 10c0 6 3 10 7 10s7-4 7-10H5z" fill="#D4AF37"/>
  <circle cx="12" cy="14" r="3" fill="#B89029"/>
</svg>
''';

  /// 🏆 كأس
  static const String trophySVG = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M8 21h8v-2H8v2z" fill="#B89029"/>
  <path d="M10 19h4v-4h-4v4z" fill="#D4AF37"/>
  <path d="M6 3h12v6c0 3.3-2.7 6-6 6s-6-2.7-6-6V3z" fill="#D4AF37"/>
  <path d="M6 5H4c0 2.2 1.8 4 4 4V5z" fill="#F7E7CE"/>
  <path d="M18 5h2c0 2.2-1.8 4-4 4V5z" fill="#F7E7CE"/>
</svg>
''';

  /// 🔥 نار
  static const String fireSVG = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 2c-4 4-6 7-6 11 0 4 2.7 6 6 6s6-2 6-6c0-4-2-7-6-11z" fill="#DC2626"/>
  <path d="M12 8c-2 2-3 3.5-3 5.5 0 2 1.3 3 3 3s3-1 3-3c0-2-1-3.5-3-5.5z" fill="#FBBF24"/>
</svg>
''';

  /// 🌙 قمر
  static const String moonSVG = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z" fill="#F7E7CE"/>
</svg>
''';

  /// ☀️ شمس
  static const String sunSVG = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="12" cy="12" r="5" fill="#FBBF24"/>
  <path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42" stroke="#FBBF24" stroke-width="2" stroke-linecap="round"/>
</svg>
''';

  // ═══════════════════════════════════════════════════════════════
  // 🎯 Icon Widgets
  // ═══════════════════════════════════════════════════════════════

  /// أيقونة مخصصة من IconData
  static Widget icon(
    IconData iconData, {
    double size = 24,
    Color? color,
  }) {
    return Icon(
      iconData,
      size: size,
      color: color ?? const Color(0xFFD4AF37),
    );
  }

  /// أيقونة مع توهج ذهبي
  static Widget glowingIcon(
    IconData iconData, {
    double size = 24,
    Color color = const Color(0xFFD4AF37),
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        iconData,
        size: size,
        color: color,
      ),
    );
  }

  /// أيقونة داخل دائرة ذهبية
  static Widget circularIcon(
    IconData iconData, {
    double size = 48,
    Color iconColor = const Color(0xFF0A1128),
    Color backgroundColor = const Color(0xFFD4AF37),
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.4),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        iconData,
        size: size * 0.5,
        color: iconColor,
      ),
    );
  }

  /// أيقونة متحركة (نبض)
  static Widget pulsingIcon(
    IconData iconData, {
    double size = 24,
    Color color = const Color(0xFFD4AF37),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.9, end: 1.1),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Icon(
            iconData,
            size: size,
            color: color,
          ),
        );
      },
    );
  }

  /// أيقونة مع شارة
  static Widget badgedIcon(
    IconData iconData, {
    double size = 24,
    Color color = const Color(0xFFD4AF37),
    String? badgeText,
    Color badgeColor = const Color(0xFFDC2626),
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(iconData, size: size, color: color),
        if (badgeText != null)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 📦 مجموعة الأيقونات الملكية
class RoyalIconData {
  RoyalIconData._();

  // التداول
  static const IconData chart = Icons.candlestick_chart_outlined;
  static const IconData trendUp = Icons.trending_up;
  static const IconData trendDown = Icons.trending_down;
  static const IconData trendFlat = Icons.trending_flat;

  // المال
  static const IconData gold = Icons.monetization_on;
  static const IconData dollar = Icons.attach_money;
  static const IconData wallet = Icons.account_balance_wallet;
  static const IconData bank = Icons.account_balance;

  // التحليل
  static const IconData analytics = Icons.analytics;
  static const IconData insights = Icons.insights;
  static const IconData assessment = Icons.assessment;
  static const IconData pieChart = Icons.pie_chart;

  // الإجراءات
  static const IconData buy = Icons.add_shopping_cart;
  static const IconData sell = Icons.remove_shopping_cart;
  static const IconData hold = Icons.pause_circle;
  static const IconData alert = Icons.notification_important;

  // الأدوات
  static const IconData settings = Icons.settings;
  static const IconData tune = Icons.tune;
  static const IconData filter = Icons.filter_list;
  static const IconData search = Icons.search;

  // الحالة
  static const IconData success = Icons.check_circle;
  static const IconData error = Icons.error;
  static const IconData warning = Icons.warning;
  static const IconData info = Icons.info;

  // التنقل
  static const IconData home = Icons.home;
  static const IconData dashboard = Icons.dashboard;
  static const IconData menu = Icons.menu;
  static const IconData back = Icons.arrow_back_ios;
  static const IconData forward = Icons.arrow_forward_ios;

  // الوقت
  static const IconData clock = Icons.access_time;
  static const IconData calendar = Icons.calendar_today;
  static const IconData history = Icons.history;
  static const IconData schedule = Icons.schedule;

  // الأمان
  static const IconData lock = Icons.lock;
  static const IconData unlock = Icons.lock_open;
  static const IconData shield = Icons.shield;
  static const IconData verified = Icons.verified;

  // المستخدم
  static const IconData user = Icons.person;
  static const IconData profile = Icons.account_circle;
  static const IconData logout = Icons.logout;
  static const IconData login = Icons.login;

  // الإضافات
  static const IconData star = Icons.star;
  static const IconData favorite = Icons.favorite;
  static const IconData bookmark = Icons.bookmark;
  static const IconData share = Icons.share;

  // الذكاء الاصطناعي
  static const IconData ai = Icons.psychology;
  static const IconData brain = Icons.smart_toy;
  static const IconData magic = Icons.auto_awesome;
  static const IconData robot = Icons.android;
}
