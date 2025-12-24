import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/royal_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/royal/animated_background.dart';
import '../../../widgets/royal/price_card.dart';
import '../../../widgets/royal/signal_card.dart';
import '../../../widgets/real_levels_display.dart';
import '../providers/real_unified_analysis_provider.dart';
import '../../../services/technical_analysis_engine.dart' as tae;

/// 👑 Royal Analysis Screen
/// الشاشة الرئيسية الملكية مع التحليل التقني الحقيقي
/// ✅ يستخدم 7 مؤشرات تقنية
/// ✅ إشارات ثابتة (15 دقيقة سكالب / 4 ساعات سوينج)
class RoyalAnalysisScreen extends ConsumerStatefulWidget {
  const RoyalAnalysisScreen({super.key});

  @override
  ConsumerState<RoyalAnalysisScreen> createState() =>
      _RoyalAnalysisScreenState();
}

class _RoyalAnalysisScreenState extends ConsumerState<RoyalAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _crownController;
  late Animation<double> _crownAnimation;

  @override
  void initState() {
    super.initState();
    _crownController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _crownAnimation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _crownController, curve: Curves.easeInOut),
    );

    // Load real analysis on init
    Future.microtask(
        () => ref.read(realUnifiedAnalysisProvider.notifier).refresh());
  }

  @override
  void dispose() {
    _crownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(realUnifiedAnalysisProvider);

    return Scaffold(
      backgroundColor: RoyalTheme.midnightNavy,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // 🧠 فتح شاشة تحليل الذكاء الاصطناعي
          context.push('/ai-analytics');
        },
        icon: const Icon(Icons.psychology),
        label: Text(
          '🧠 تحليل AI',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.goldMain,
        foregroundColor: AppColors.bgPrimary,
      ),
      body: Stack(
        children: [
          // Animated Background
          const Positioned.fill(
            child: AnimatedRoyalBackground(),
          ),

          // Content
          SafeArea(
            child: analysisState.isLoading
                ? _buildLoadingState()
                : RefreshIndicator(
                    onRefresh: () async {
                      await ref
                          .read(realUnifiedAnalysisProvider.notifier)
                          .refresh();
                    },
                    color: RoyalTheme.imperialGold,
                    backgroundColor: RoyalTheme.charcoal,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          // Header
                          _buildHeader(),
                          const SizedBox(height: RoyalTheme.gapXl),

                          // Error State
                          if (analysisState.error != null)
                            _buildErrorBanner(analysisState.error!),

                          // Price Card
                          RoyalPriceCard(
                            price: analysisState.currentPrice,
                            change: analysisState.priceChange,
                            changePercent: analysisState.changePercent,
                          ),
                          const SizedBox(height: RoyalTheme.gapXl),

                          // Scalp Signal - Real Technical Analysis
                          _buildSignalFromTradingSignal(
                            analysisState.scalpSignal,
                            'scalp',
                          ),
                          const SizedBox(height: 28),

                          // Swing Signal - Real Technical Analysis
                          _buildSignalFromTradingSignal(
                            analysisState.swingSignal,
                            'swing',
                          ),
                          const SizedBox(height: 28),

                          // 🆕 Real Support & Resistance Levels
                          if (analysisState.realLevels != null)
                            RealLevelsDisplay(
                              levels: analysisState.realLevels!,
                              currentPrice: analysisState.currentPrice,
                            ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// بناء كارت الإشارة من TradingSignal
  Widget _buildSignalFromTradingSignal(tae.TradingSignal signal, String type) {
    // ✅ FIXED: نرسل 'BUY' أو 'SELL' للكارت
    String direction;
    switch (signal.direction) {
      case tae.SignalDirection.buy:
        direction = 'BUY'; // ✅ بالإنجليزي للكارت
        break;
      case tae.SignalDirection.sell:
        direction = 'SELL'; // ✅ بالإنجليزي للكارت
        break;
      case tae.SignalDirection.neutral:
        direction = 'NEUTRAL';
        break;
    }

    if (signal.direction == tae.SignalDirection.neutral) {
      return _buildNoSignalCard(type);
    }

    // حساب Risk:Reward
    final risk = (signal.entryPrice - signal.stopLoss).abs();
    final reward = (signal.target1 - signal.entryPrice).abs();
    final riskReward = risk > 0 ? reward / risk : 0.0;

    return RoyalSignalCard(
      type: type,
      direction: direction,
      confidence: signal.confidence,
      entryPrice: signal.entryPrice,
      stopLoss: signal.stopLoss,
      target1: signal.target1,
      target2: signal.target2,
      riskReward: riskReward,
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Loading Animation
          const SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                RoyalTheme.imperialGold,
              ),
              backgroundColor: RoyalTheme.glassBg,
            ),
          ),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) =>
                RoyalTheme.goldGradient.createShader(bounds),
            child: const Text(
              'جاري التحليل...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'تحليل السوق بدقة عالية',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.5,
              color: RoyalTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      margin: const EdgeInsets.only(bottom: RoyalTheme.gapXl),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x1Aef4444),
        borderRadius: BorderRadius.circular(RoyalTheme.radiusLg),
        border: Border.all(
          color: const Color(0x4Def4444),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: RoyalTheme.danger,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: RoyalTheme.bodySmall.copyWith(
                color: RoyalTheme.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSignalCard(String type) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xA30e122d),
        borderRadius: BorderRadius.circular(RoyalTheme.radiusCard),
        border: Border.all(
          color: RoyalTheme.glassBorder,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            type == 'scalp' ? Icons.flash_on : Icons.insights,
            color: RoyalTheme.textSecondary,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد إشارة ${type == 'scalp' ? 'سكالبينج' : 'سوينج'}',
            style: RoyalTheme.bodyMedium.copyWith(
              color: RoyalTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'انتظر تحليل جديد',
            style: RoyalTheme.bodySmall.copyWith(
              color: RoyalTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, -14 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          // Crown
          AnimatedBuilder(
            animation: _crownAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _crownAnimation.value),
                child: Transform.rotate(
                  angle: (_crownAnimation.value / -8) * 0.05,
                  child: const Text(
                    '👑',
                    style: TextStyle(
                      fontSize: 48,
                      shadows: [
                        Shadow(
                          color: Color(0x66d4af37),
                          blurRadius: 22,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: RoyalTheme.gapSm),

          // Title
          ShaderMask(
            shaderCallback: (bounds) =>
                RoyalTheme.goldGradient.createShader(bounds),
            child: const Text(
              'GOLD NIGHTMARE PRO',
              style: RoyalTheme.titleStyle,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: RoyalTheme.gapSm),

          // Tagline
          Text(
            'Royal Futurism • Elite Edition',
            style: RoyalTheme.caption.copyWith(
              color: const Color(0xA6d4af37),
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: RoyalTheme.gapSm),

          // Live Indicator
          _buildLiveIndicator(),
        ],
      ),
    );
  }

  Widget _buildLiveIndicator() {
    final analysisState = ref.watch(realUnifiedAnalysisProvider);
    final lastUpdate = analysisState.lastUpdate;
    final updateText = _getTimeAgo(lastUpdate);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RoyalTheme.spaceLg,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: RoyalTheme.glassBg,
        borderRadius: BorderRadius.circular(RoyalTheme.radiusFull),
        border: Border.all(
          color: RoyalTheme.glassBorder,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LiveDot(),
          const SizedBox(width: RoyalTheme.gapXs),
          Text(
            'LIVE • آخر تحديث: $updateText',
            style: RoyalTheme.bodySmall.copyWith(
              color: RoyalTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inSeconds < 60) {
      return 'منذ لحظات';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} د';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} س';
    } else {
      return 'منذ ${difference.inDays} يوم';
    }
  }
}

/// 🔴 Live Dot Animation
class _LiveDot extends StatefulWidget {
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: RoyalTheme.success,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: RoyalTheme.success,
                    blurRadius: 10,
                  ),
                  BoxShadow(
                    color: RoyalTheme.success,
                    blurRadius: 22,
                  ),
                  BoxShadow(
                    color: Color(0x9910b981),
                    blurRadius: 30,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
