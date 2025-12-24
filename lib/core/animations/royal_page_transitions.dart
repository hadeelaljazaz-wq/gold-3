import 'package:flutter/material.dart';

/// 👑 انتقالات الصفحات الملكية
/// تأثيرات حركية فاخرة للتنقل بين الشاشات
class RoyalPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final TransitionType type;
  final Duration duration;
  final Duration reverseDuration;

  RoyalPageRoute({
    required this.page,
    this.type = TransitionType.shimmer,
    this.duration = const Duration(milliseconds: 600),
    this.reverseDuration = const Duration(milliseconds: 400),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: reverseDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            switch (type) {
              case TransitionType.shimmer:
                return _shimmerTransition(animation, child);
              case TransitionType.luxury:
                return _luxuryTransition(animation, child);
              case TransitionType.royal:
                return _royalTransition(animation, secondaryAnimation, child);
              case TransitionType.fade:
                return _fadeTransition(animation, child);
              case TransitionType.scale:
                return _scaleTransition(animation, child);
              case TransitionType.slideUp:
                return _slideUpTransition(animation, child);
              case TransitionType.slideRight:
                return _slideRightTransition(animation, child);
              case TransitionType.rotateScale:
                return _rotateScaleTransition(animation, child);
              case TransitionType.gold:
                return _goldTransition(animation, child);
            }
          },
        );

  /// ✨ انتقال لامع (Shimmer)
  static Widget _shimmerTransition(Animation<double> animation, Widget child) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.3, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      ),
    );
  }

  /// 💎 انتقال فاخر (Luxury)
  static Widget _luxuryTransition(Animation<double> animation, Widget child) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
        ),
      ),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeIn,
        ),
        child: child,
      ),
    );
  }

  /// 👑 انتقال ملكي (Royal)
  static Widget _royalTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return Stack(
      children: [
        // الصفحة القديمة تخرج
        SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(-0.3, 0),
          ).animate(CurvedAnimation(
            parent: secondaryAnimation,
            curve: Curves.easeInCubic,
          )),
          child: FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.5).animate(secondaryAnimation),
          ),
        ),
        // الصفحة الجديدة تدخل
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      ],
    );
  }

  /// 🌟 انتقال تلاشي (Fade)
  static Widget _fadeTransition(Animation<double> animation, Widget child) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      ),
      child: child,
    );
  }

  /// 📏 انتقال تكبير (Scale)
  static Widget _scaleTransition(Animation<double> animation, Widget child) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.fastOutSlowIn,
        ),
      ),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// ⬆️ انتقال من الأسفل
  static Widget _slideUpTransition(Animation<double> animation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// ➡️ انتقال من اليمين
  static Widget _slideRightTransition(Animation<double> animation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// 🔄 انتقال دوران مع تكبير
  static Widget _rotateScaleTransition(Animation<double> animation, Widget child) {
    return RotationTransition(
      turns: Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        ),
      ),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
        ),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }

  /// 🥇 انتقال ذهبي خاص
  static Widget _goldTransition(Animation<double> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFD4AF37).withValues(alpha: (1 - animation.value) * 0.3),
                Colors.transparent,
              ],
            ),
          ),
          child: Transform.scale(
            scale: 0.9 + (animation.value * 0.1),
            child: Opacity(
              opacity: animation.value,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

/// أنواع الانتقالات المتاحة
enum TransitionType {
  shimmer,     // ✨ لامع
  luxury,      // 💎 فاخر
  royal,       // 👑 ملكي
  fade,        // 🌟 تلاشي
  scale,       // 📏 تكبير
  slideUp,     // ⬆️ من الأسفل
  slideRight,  // ➡️ من اليمين
  rotateScale, // 🔄 دوران مع تكبير
  gold,        // 🥇 ذهبي
}

/// امتداد للتنقل السهل
extension RoyalNavigation on BuildContext {
  /// انتقال ملكي إلى صفحة جديدة
  Future<T?> pushRoyal<T>(Widget page, {TransitionType type = TransitionType.shimmer}) {
    return Navigator.of(this).push<T>(
      RoyalPageRoute<T>(page: page, type: type),
    );
  }

  /// استبدال ملكي للصفحة
  Future<T?> replaceRoyal<T>(Widget page, {TransitionType type = TransitionType.shimmer}) {
    return Navigator.of(this).pushReplacement(
      RoyalPageRoute<T>(page: page, type: type),
    );
  }

  /// انتقال ملكي مع إزالة كل الصفحات السابقة
  Future<T?> pushAndRemoveAllRoyal<T>(Widget page, {TransitionType type = TransitionType.shimmer}) {
    return Navigator.of(this).pushAndRemoveUntil(
      RoyalPageRoute<T>(page: page, type: type),
      (route) => false,
    );
  }
}

/// 🎭 حركات مخصصة للعناصر
class RoyalAnimations {
  RoyalAnimations._();

  /// حركة النبض الذهبي
  static Widget pulseGold({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1.05),
      duration: duration,
      curve: Curves.easeInOut,
      builder: (context, scale, _) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
    );
  }

  /// حركة التوهج
  static Widget glow({
    required Widget child,
    Color glowColor = const Color(0xFFD4AF37),
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeInOut,
      builder: (context, value, _) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: 0.3 + (value * 0.2)),
                blurRadius: 20 + (value * 10),
                spreadRadius: value * 5,
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }

  /// حركة الانزلاق من الأعلى
  static Widget slideFromTop({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    Duration delay = Duration.zero,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -1.0, end: 0.0),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, value * 50),
          child: Opacity(
            opacity: 1 + value,
            child: child,
          ),
        );
      },
    );
  }

  /// حركة الظهور التدريجي
  static Widget fadeIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 800),
    Curve curve = Curves.easeOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, opacity, _) {
        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
    );
  }

  /// حركة الدوران البطيء
  static Widget slowRotate({
    required Widget child,
    Duration duration = const Duration(seconds: 10),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      builder: (context, value, _) {
        return Transform.rotate(
          angle: value * 2 * 3.14159,
          child: child,
        );
      },
    );
  }
}

/// 🎨 بناء متحرك مخصص
class AnimatedBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: builder,
      child: child,
    );
  }
}

