import 'package:flutter/services.dart';

/// 👑 نظام التغذية الراجعة الملكي
/// اهتزازات وأصوات فاخرة للتفاعلات
class RoyalFeedback {
  RoyalFeedback._();

  // ═══════════════════════════════════════════════════════════════
  // 📳 Haptic Feedback - الاهتزازات
  // ═══════════════════════════════════════════════════════════════

  /// اهتزاز خفيف - للنقرات البسيطة
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// اهتزاز متوسط - للتأكيدات
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// اهتزاز قوي - للإجراءات المهمة
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// نقرة اختيار - للقوائم والخيارات
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// اهتزاز - للتنبيهات
  static Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }

  /// 🎉 نمط النجاح الملكي - قوي ثم خفيف
  static Future<void> royalSuccess() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// ❌ نمط الخطأ الملكي - قوي متكرر
  static Future<void> royalError() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.mediumImpact();
  }

  /// ⚠️ نمط التحذير الملكي
  static Future<void> royalWarning() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
  }

  /// 🔔 نمط الإشعار الملكي
  static Future<void> royalNotification() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.mediumImpact();
  }

  /// 💰 نمط الصفقة الناجحة
  static Future<void> tradingSuccess() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.lightImpact();
  }

  /// 📊 نمط تحديث البيانات
  static Future<void> dataRefresh() async {
    await HapticFeedback.lightImpact();
  }

  /// 🎯 نمط الإجراء المكتمل
  static Future<void> actionComplete() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.lightImpact();
  }

  /// 🔄 نمط التبديل
  static Future<void> toggle() async {
    await HapticFeedback.selectionClick();
  }

  /// 📱 نمط الضغط المطول
  static Future<void> longPress() async {
    await HapticFeedback.mediumImpact();
  }

  /// 🎪 نمط الاحتفال (للإنجازات)
  static Future<void> celebration() async {
    for (int i = 0; i < 3; i++) {
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 100));
    }
    await HapticFeedback.heavyImpact();
  }

  /// 💎 نمط القيمة العالية
  static Future<void> highValue() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    await HapticFeedback.heavyImpact();
  }

  /// 🔓 نمط فتح القفل
  static Future<void> unlock() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }

  // ═══════════════════════════════════════════════════════════════
  // 🎵 أنماط الاهتزاز المخصصة
  // ═══════════════════════════════════════════════════════════════

  /// نمط مخصص - سلسلة من الاهتزازات
  static Future<void> customPattern(List<HapticPattern> patterns) async {
    for (final pattern in patterns) {
      switch (pattern.type) {
        case HapticType.light:
          await HapticFeedback.lightImpact();
          break;
        case HapticType.medium:
          await HapticFeedback.mediumImpact();
          break;
        case HapticType.heavy:
          await HapticFeedback.heavyImpact();
          break;
        case HapticType.selection:
          await HapticFeedback.selectionClick();
          break;
        case HapticType.vibrate:
          await HapticFeedback.vibrate();
          break;
      }
      if (pattern.delay.inMilliseconds > 0) {
        await Future.delayed(pattern.delay);
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 🎯 اهتزازات حسب السياق
  // ═══════════════════════════════════════════════════════════════

  /// اهتزاز حسب نوع الإجراء التجاري
  static Future<void> forTradeAction(TradeActionType action) async {
    switch (action) {
      case TradeActionType.buy:
        await tradingSuccess();
        break;
      case TradeActionType.sell:
        await tradingSuccess();
        break;
      case TradeActionType.hold:
        await lightImpact();
        break;
      case TradeActionType.alert:
        await royalNotification();
        break;
      case TradeActionType.error:
        await royalError();
        break;
    }
  }

  /// اهتزاز حسب مستوى الثقة
  static Future<void> forConfidenceLevel(double confidence) async {
    if (confidence >= 0.8) {
      await heavyImpact();
    } else if (confidence >= 0.6) {
      await mediumImpact();
    } else {
      await lightImpact();
    }
  }

  /// اهتزاز حسب نوع الإشعار
  static Future<void> forNotificationType(NotificationType type) async {
    switch (type) {
      case NotificationType.success:
        await royalSuccess();
        break;
      case NotificationType.error:
        await royalError();
        break;
      case NotificationType.warning:
        await royalWarning();
        break;
      case NotificationType.info:
        await royalNotification();
        break;
    }
  }
}

/// أنواع الاهتزاز
enum HapticType {
  light,
  medium,
  heavy,
  selection,
  vibrate,
}

/// نمط اهتزاز مخصص
class HapticPattern {
  final HapticType type;
  final Duration delay;

  const HapticPattern({
    required this.type,
    this.delay = Duration.zero,
  });
}

/// أنواع الإجراءات التجارية
enum TradeActionType {
  buy,
  sell,
  hold,
  alert,
  error,
}

/// أنواع الإشعارات
enum NotificationType {
  success,
  error,
  warning,
  info,
}

/// 🎨 أنماط اهتزاز جاهزة
class HapticPatterns {
  HapticPatterns._();

  /// نمط الترحيب
  static const List<HapticPattern> welcome = [
    HapticPattern(type: HapticType.light, delay: Duration(milliseconds: 100)),
    HapticPattern(type: HapticType.medium, delay: Duration(milliseconds: 100)),
    HapticPattern(type: HapticType.light),
  ];

  /// نمط النجاح
  static const List<HapticPattern> success = [
    HapticPattern(type: HapticType.heavy, delay: Duration(milliseconds: 100)),
    HapticPattern(type: HapticType.light),
  ];

  /// نمط الخطأ
  static const List<HapticPattern> error = [
    HapticPattern(type: HapticType.heavy, delay: Duration(milliseconds: 50)),
    HapticPattern(type: HapticType.heavy, delay: Duration(milliseconds: 50)),
    HapticPattern(type: HapticType.medium),
  ];

  /// نمط الموجة
  static const List<HapticPattern> wave = [
    HapticPattern(type: HapticType.light, delay: Duration(milliseconds: 80)),
    HapticPattern(type: HapticType.medium, delay: Duration(milliseconds: 80)),
    HapticPattern(type: HapticType.heavy, delay: Duration(milliseconds: 80)),
    HapticPattern(type: HapticType.medium, delay: Duration(milliseconds: 80)),
    HapticPattern(type: HapticType.light),
  ];

  /// نمط النبض
  static const List<HapticPattern> pulse = [
    HapticPattern(type: HapticType.medium, delay: Duration(milliseconds: 200)),
    HapticPattern(type: HapticType.medium, delay: Duration(milliseconds: 200)),
    HapticPattern(type: HapticType.medium),
  ];

  /// نمط السريع
  static const List<HapticPattern> rapid = [
    HapticPattern(type: HapticType.light, delay: Duration(milliseconds: 30)),
    HapticPattern(type: HapticType.light, delay: Duration(milliseconds: 30)),
    HapticPattern(type: HapticType.light, delay: Duration(milliseconds: 30)),
    HapticPattern(type: HapticType.light),
  ];
}
