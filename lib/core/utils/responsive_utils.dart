import 'package:flutter/material.dart';

/// 📱 Responsive Utilities
///
/// أدوات للتعامل مع أحجام الشاشات المختلفة
///
/// **الميزات:**
/// - دعم Mobile, Tablet, Desktop
/// - حسابات ديناميكية للـ Padding والـ Spacing
/// - توجيه الشاشة (Portrait/Landscape)

class ResponsiveUtils {
  /// حجم الشاشة الحالي
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// عرض الشاشة
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// ارتفاع الشاشة
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// نسبة العرض للشاشة
  static double getWidthRatio(BuildContext context) {
    return getScreenWidth(context) / 375.0; // Base width (iPhone)
  }

  /// نسبة الارتفاع للشاشة
  static double getHeightRatio(BuildContext context) {
    return getScreenHeight(context) / 812.0; // Base height (iPhone)
  }

  /// حجم متجاوب بناءً على العرض
  static double getResponsiveSize(BuildContext context, double size) {
    return size * getWidthRatio(context);
  }

  /// حجم Font متجاوب
  static double getResponsiveFontSize(BuildContext context, double fontSize) {
    final ratio = getWidthRatio(context);
    return fontSize * ratio.clamp(0.8, 1.2); // محدود بين 80% و 120%
  }

  /// Padding متجاوب
  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    double horizontal = 16,
    double vertical = 16,
  }) {
    final ratio = getWidthRatio(context);
    return EdgeInsets.symmetric(
      horizontal: horizontal * ratio,
      vertical: vertical * ratio,
    );
  }

  /// هل الجهاز Mobile؟
  static bool isMobile(BuildContext context) {
    return getScreenWidth(context) < 600;
  }

  /// هل الجهاز Tablet؟
  static bool isTablet(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= 600 && width < 1200;
  }

  /// هل الجهاز Desktop؟
  static bool isDesktop(BuildContext context) {
    return getScreenWidth(context) >= 1200;
  }

  /// هل الشاشة Portrait؟
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// هل الشاشة Landscape؟
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// عدد الأعمدة في الـ Grid
  static int getGridCrossAxisCount(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return isPortrait(context) ? 2 : 3;
    return isPortrait(context) ? 1 : 2;
  }

  /// مساحة بين عناصر الـ Grid
  static double getGridSpacing(BuildContext context) {
    if (isDesktop(context)) return 24;
    if (isTablet(context)) return 16;
    return 12;
  }

  /// الحد الأقصى لعرض المحتوى
  static double getMaxContentWidth(BuildContext context) {
    if (isDesktop(context)) return 1200;
    if (isTablet(context)) return 800;
    return double.infinity;
  }

  /// Padding للصفحة بناءً على نوع الجهاز
  static EdgeInsets getPagePadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(32);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(16);
    }
  }

  /// حجم الكارد بناءً على نوع الجهاز
  static double getCardHeight(BuildContext context, {double baseHeight = 150}) {
    if (isDesktop(context)) return baseHeight * 1.2;
    if (isTablet(context)) return baseHeight * 1.1;
    return baseHeight;
  }

  /// حجم الأيقونة بناءً على نوع الجهاز
  static double getIconSize(BuildContext context, {double baseSize = 24}) {
    if (isDesktop(context)) return baseSize * 1.3;
    if (isTablet(context)) return baseSize * 1.15;
    return baseSize;
  }

  /// BorderRadius متجاوب
  static double getResponsiveBorderRadius(BuildContext context,
      {double baseRadius = 12}) {
    if (isDesktop(context)) return baseRadius * 1.2;
    if (isTablet(context)) return baseRadius * 1.1;
    return baseRadius;
  }
}

/// Widget متجاوب
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(
          BuildContext context, bool isMobile, bool isTablet, bool isDesktop)
      builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return builder(context, isMobile, isTablet, isDesktop);
  }
}

/// محدد عرض المحتوى
class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;

  const MaxWidthContainer({
    super.key,
    required this.child,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final width = maxWidth ?? ResponsiveUtils.getMaxContentWidth(context);

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: width),
        child: child,
      ),
    );
  }
}

/// Padding متجاوب
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? ResponsiveUtils.getPagePadding(context),
      child: child,
    );
  }
}

