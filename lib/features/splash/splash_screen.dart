import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

/// 🌟 شاشة البداية الأسطورية - Legendary Splash Screen
class LegendarySplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const LegendarySplashScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<LegendarySplashScreen> createState() => _LegendarySplashScreenState();
}

class _LegendarySplashScreenState extends State<LegendarySplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _rotateController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Scale Animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Fade Animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Rotate Animation
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();
    _fadeController.forward();
    _rotateController.forward();

    // انتظار 3 ثواني ثم الانتقال
    await Future.delayed(const Duration(milliseconds: 3500));
    widget.onComplete();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.bgPrimary,
              const Color(0xFF1A1F2E),
              AppColors.bgPrimary,
            ],
          ),
        ),
        child: Stack(
          children: [
            // خلفية متحركة
            _buildAnimatedBackground(),

            // المحتوى الرئيسي
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo مع انيميشن
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: RotationTransition(
                      turns: Tween<double>(begin: 0, end: 0.5)
                          .animate(_rotateController),
                      child: _buildLogo(),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // العنوان
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'كابوس ذهبي برو',
                          style: GoogleFonts.cairo(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..shader = LinearGradient(
                                colors: [
                                  AppColors.goldMain,
                                  const Color(0xFFFFD700),
                                  AppColors.goldMain,
                                ],
                              ).createShader(
                                const Rect.fromLTWH(0, 0, 200, 70),
                              ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gold Nightmare Pro',
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.goldMain.withValues(alpha: 0.8),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildLoadingIndicator(),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // النسخة في الأسفل
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'v3.1.1 - Professional Edition',
                      style: GoogleFonts.montserrat(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'محلل الذهب الاحترافي بالذكاء الاصطناعي',
                      style: GoogleFonts.cairo(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _rotateController,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: GoldParticlesPainter(
            animation: _rotateController.value,
          ),
        );
      },
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.goldMain,
            AppColors.goldMain.withValues(alpha: 0.6),
            Colors.transparent,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldMain.withValues(alpha: 0.5),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.goldMain,
              const Color(0xFFFFD700),
              AppColors.goldMain,
            ],
          ),
        ),
        child: Icon(
          Icons.auto_graph_rounded,
          size: 60,
          color: AppColors.bgPrimary,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 200,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 3000),
        builder: (context, value, child) {
          return Column(
            children: [
              LinearProgressIndicator(
                value: value,
                backgroundColor: AppColors.goldMain.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldMain),
                minHeight: 4,
              ),
              const SizedBox(height: 12),
              Text(
                'جاري التحميل... ${(value * 100).toInt()}%',
                style: GoogleFonts.cairo(
                  color: AppColors.goldMain,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// رسام الجزيئات الذهبية المتحركة
class GoldParticlesPainter extends CustomPainter {
  final double animation;

  GoldParticlesPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.goldMain.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // رسم دوائر ذهبية متحركة
    for (int i = 0; i < 15; i++) {
      final x = (size.width / 15) * i + (animation * 100) * (i.isEven ? 1 : -1);
      final y = size.height / 2 + 50 * (i.isEven ? 1 : -1) * (1 - animation);

      canvas.drawCircle(
        Offset(x % size.width, y),
        3 + (animation * 5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GoldParticlesPainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}
