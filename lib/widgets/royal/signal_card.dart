import 'package:flutter/material.dart';
import '../../core/theme/royal_theme.dart';
import 'dart:math' as math;
import '../../core/utils/logger.dart';

/// 📊 Royal Signal Card
/// بطاقة الإشارة الملكية (Scalp/Swing)
class RoyalSignalCard extends StatefulWidget {
  final String type; // 'scalp' or 'swing'
  final String direction; // 'BUY' or 'SELL'
  final int confidence;
  final double entryPrice;
  final double stopLoss;
  final double target1;
  final double target2;
  final double riskReward;

  const RoyalSignalCard({
    super.key,
    required this.type,
    required this.direction,
    required this.confidence,
    required this.entryPrice,
    required this.stopLoss,
    required this.target1,
    required this.target2,
    required this.riskReward,
  });

  @override
  State<RoyalSignalCard> createState() => _RoyalSignalCardState();
}

class _RoyalSignalCardState extends State<RoyalSignalCard>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      duration: const Duration(seconds: 28),
      vsync: this,
    )..repeat();

    // 🔍 DEBUG: Log royal signal card display (legacy widget)
    AppLogger.info('📊 RoyalSignalCard Display (Legacy):');
    AppLogger.info('   Type: ${widget.type}');
    AppLogger.info('   Direction: ${widget.direction}');
    AppLogger.info('   Entry: \$${widget.entryPrice}');
    AppLogger.info('   Stop Loss: \$${widget.stopLoss}');
    AppLogger.info('   Target1: \$${widget.target1}');
    AppLogger.info('   Target2: \$${widget.target2}');
    
    // Validate logic
    if (widget.direction == 'BUY' && !(widget.stopLoss < widget.entryPrice && widget.target1 > widget.entryPrice)) {
      AppLogger.error('❌ LEGACY BUY signal but prices wrong: SL(${widget.stopLoss}) should be < Entry(${widget.entryPrice}) < T1(${widget.target1})', null);
    } else if (widget.direction == 'SELL' && !(widget.stopLoss > widget.entryPrice && widget.target1 < widget.entryPrice)) {
      AppLogger.error('❌ LEGACY SELL signal but prices wrong: T1(${widget.target1}) should be < Entry(${widget.entryPrice}) < SL(${widget.stopLoss})', null);
    } else {
      AppLogger.success('✅ LEGACY Signal prices are logically correct');
    }

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.confidence / 100,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    ));

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _progressController.forward();
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBuy = widget.direction == 'BUY';
    final isScalp = widget.type == 'scalp';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - value)),
            child: Transform.scale(
              scale: 0.98 + (0.02 * value),
              child: child,
            ),
          ),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: const Color(0xA30e122d), // rgba(14,18,45,0.64)
            borderRadius: BorderRadius.circular(RoyalTheme.radiusCard),
            border: Border.all(
              color: RoyalTheme.glassBorder,
              width: 1,
            ),
            boxShadow: RoyalTheme.softShadow,
          ),
          child: Stack(
            children: [
              // Rotating Glow
              AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  return Positioned.fill(
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(RoyalTheme.radiusCard),
                      child: CustomPaint(
                        painter: _RotatingGlowPainter(_glowController.value),
                      ),
                    ),
                  );
                },
              ),

              // Content
              Column(
                children: [
                  // Header
                  _SignalHeader(
                    type: widget.type,
                    direction: widget.direction,
                    isScalp: isScalp,
                    isBuy: isBuy,
                  ),

                  // Body
                  Padding(
                    padding: const EdgeInsets.all(RoyalTheme.spaceLg),
                    child: Column(
                      children: [
                        // Confidence Bar
                        _ConfidenceBar(
                          confidence: widget.confidence,
                          animation: _progressAnimation,
                        ),
                        const SizedBox(height: 28),

                        // Levels
                        _LevelsList(
                          entryPrice: widget.entryPrice,
                          stopLoss: widget.stopLoss,
                          target1: widget.target1,
                          target2: widget.target2,
                        ),

                        // Risk/Reward
                        _RiskRewardSection(riskReward: widget.riskReward),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🎨 Rotating Glow Painter
class _RotatingGlowPainter extends CustomPainter {
  final double progress;

  _RotatingGlowPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final angle = progress * 2 * math.pi;

    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          math.cos(angle) * 0.5,
          math.sin(angle) * 0.5,
        ),
        radius: 1.5,
        colors: const [
          Color(0x1F6e3cc3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_RotatingGlowPainter oldDelegate) =>
      progress != oldDelegate.progress;
}

/// 📋 Signal Header
class _SignalHeader extends StatelessWidget {
  final String type;
  final String direction;
  final bool isScalp;
  final bool isBuy;

  const _SignalHeader({
    required this.type,
    required this.direction,
    required this.isScalp,
    required this.isBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(RoyalTheme.spaceLg),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0x0FFFFFFF), // rgba(255,255,255,0.06)
            Color(0x03FFFFFF), // rgba(255,255,255,0.01)
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Color(0x0FFFFFFF),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon + Text
          Row(
            children: [
              _SignalIcon(
                icon: isScalp ? '⚡' : '📊',
                color:
                    isScalp ? const Color(0xFFf59e0b) : const Color(0xFF60a5fa),
              ),
              const SizedBox(width: 14),
              Text(
                isScalp ? 'سكالبينج (15 دقيقة)' : 'سوينج (4 ساعات)',
                style: RoyalTheme.bodyMedium.copyWith(
                  color: RoyalTheme.textPrimary,
                  fontWeight: FontWeight.w800,
                  shadows: const [
                    Shadow(
                      color: Colors.black38,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Direction Badge
          _DirectionBadge(
            direction: direction,
            isBuy: isBuy,
          ),
        ],
      ),
    );
  }
}

/// 🔘 Signal Icon
class _SignalIcon extends StatefulWidget {
  final String icon;
  final Color color;

  const _SignalIcon({
    required this.icon,
    required this.color,
  });

  @override
  State<_SignalIcon> createState() => _SignalIconState();
}

class _SignalIconState extends State<_SignalIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: RoyalTheme.glassBg,
          borderRadius: BorderRadius.circular(RoyalTheme.radiusLg),
          border: Border.all(
            color:
                _isHovered ? const Color(0xFFCC23FF) : RoyalTheme.glassBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.35),
              blurRadius: _isHovered ? 24 : 18,
            ),
          ],
        ),
        transform: _isHovered
            ? (Matrix4.identity()
              ..setTranslationRaw(0.0, -2.0, 0.0)
              ..rotateZ(0.035))
            : Matrix4.identity(),
        child: Center(
          child: Text(
            widget.icon,
            style: TextStyle(
              fontSize: 22,
              color: widget.color,
            ),
          ),
        ),
      ),
    );
  }
}

/// 🎯 Direction Badge
class _DirectionBadge extends StatelessWidget {
  final String direction;
  final bool isBuy;

  const _DirectionBadge({
    required this.direction,
    required this.isBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isBuy
              ? const [
                  Color(0x3310b981),
                  Color(0x1410b981),
                ]
              : const [
                  Color(0x33ef4444),
                  Color(0x14ef4444),
                ],
        ),
        borderRadius: BorderRadius.circular(RoyalTheme.radiusFull),
        border: Border.all(
          color: isBuy ? const Color(0x6B10b981) : const Color(0x6Bef4444),
          width: 1,
        ),
        boxShadow: isBuy
            ? RoyalTheme.glowEmerald
            : const [
                BoxShadow(
                  color: Color(0x59ef4444),
                  blurRadius: 18,
                ),
              ],
      ),
      child: Text(
        direction == 'BUY' ? 'شراء' : 'بيع',
        style: RoyalTheme.bodyMedium.copyWith(
          color: isBuy ? RoyalTheme.success : RoyalTheme.danger,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// 📊 Confidence Bar
class _ConfidenceBar extends StatefulWidget {
  final int confidence;
  final Animation<double> animation;

  const _ConfidenceBar({
    required this.confidence,
    required this.animation,
  });

  @override
  State<_ConfidenceBar> createState() => _ConfidenceBarState();
}

class _ConfidenceBarState extends State<_ConfidenceBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'مستوى الثقة',
              style: RoyalTheme.bodySmall.copyWith(
                color: RoyalTheme.textTertiary,
                fontWeight: FontWeight.w700,
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) =>
                  RoyalTheme.goldGradient.createShader(bounds),
              child: Text(
                '${widget.confidence}%',
                style: RoyalTheme.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 14,
          decoration: BoxDecoration(
            color: RoyalTheme.glassBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0x0AFFFFFF),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x59000000),
                blurRadius: 6,
                offset: Offset(0, 3),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: Color(0x406e3cc3),
                blurRadius: 14,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Animated Fill
              AnimatedBuilder(
                animation: widget.animation,
                builder: (context, child) {
                  return FractionallySizedBox(
                    widthFactor: widget.animation.value,
                    child: AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: const [
                                RoyalTheme.royalPurple,
                                RoyalTheme.imperialGold,
                                RoyalTheme.royalPurple,
                              ],
                              stops: [
                                (_shimmerController.value * 2 - 1)
                                    .clamp(0.0, 1.0),
                                _shimmerController.value,
                                (_shimmerController.value * 2).clamp(0.0, 1.0),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x80d4af37),
                                blurRadius: 24,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              // Gloss Effect
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [
                      Color(0x3DFFFFFF),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 📍 Levels List
class _LevelsList extends StatelessWidget {
  final double entryPrice;
  final double stopLoss;
  final double target1;
  final double target2;

  const _LevelsList({
    required this.entryPrice,
    required this.stopLoss,
    required this.target1,
    required this.target2,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _LevelItem(
          icon: '💰',
          label: 'سعر الدخول',
          price: entryPrice,
          color: RoyalTheme.warning,
          type: 'entry',
        ),
        const SizedBox(height: 14),
        _LevelItem(
          icon: '🛑',
          label: 'وقف الخسارة',
          price: stopLoss,
          color: RoyalTheme.danger,
          type: 'stop',
        ),
        const SizedBox(height: 14),
        _LevelItem(
          icon: '🎯',
          label: 'الهدف الأول',
          price: target1,
          color: RoyalTheme.success,
          type: 'target',
        ),
        const SizedBox(height: 14),
        _LevelItem(
          icon: '🎯',
          label: 'الهدف الثاني',
          price: target2,
          color: RoyalTheme.success,
          type: 'target',
        ),
      ],
    );
  }
}

/// 📍 Level Item
class _LevelItem extends StatefulWidget {
  final String icon;
  final String label;
  final double price;
  final Color color;
  final String type;

  const _LevelItem({
    required this.icon,
    required this.label,
    required this.price,
    required this.color,
    required this.type,
  });

  @override
  State<_LevelItem> createState() => _LevelItemState();
}

class _LevelItemState extends State<_LevelItem>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 3200),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: _isHovered ? const Color(0x0FFFFFFF) : const Color(0x09FFFFFF),
          borderRadius: BorderRadius.circular(RoyalTheme.radiusLg),
          border: Border.all(
            color:
                _isHovered ? const Color(0x1AFFFFFF) : const Color(0x0FFFFFFF),
            width: 1,
          ),
        ),
        transform: _isHovered
            ? (Matrix4.identity()..setTranslationRaw(-4.0, -1.0, 0.0))
            : Matrix4.identity(),
        child: Row(
          children: [
            // Dot Icon
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1 + (_pulseController.value * 0.06),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.color,
                          widget.color.withValues(alpha: 0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.32),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.icon,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 14),

            // Label
            Expanded(
              child: Text(
                widget.label,
                style: RoyalTheme.bodySmall.copyWith(
                  color: const Color(0xFFD9F0FF),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // Price
            Text(
              '\$${widget.price.toStringAsFixed(2)}',
              style: RoyalTheme.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
                shadows: const [
                  Shadow(
                    color: Colors.black38,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),

            // Side Bar
            if (_isHovered)
              Container(
                width: 7,
                height: 36,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      widget.color,
                      widget.color.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.6),
                      blurRadius: 16,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 📈 Risk/Reward Section
class _RiskRewardSection extends StatefulWidget {
  final double riskReward;

  const _RiskRewardSection({required this.riskReward});

  @override
  State<_RiskRewardSection> createState() => _RiskRewardSectionState();
}

class _RiskRewardSectionState extends State<_RiskRewardSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 22),
      padding: const EdgeInsets.only(top: 22),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0x0FFFFFFF),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'RISK/REWARD',
            style: RoyalTheme.bodySmall.copyWith(
              color: const Color(0xFFB8B3FF),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return ShaderMask(
                shaderCallback: (bounds) =>
                    RoyalTheme.goldGradient.createShader(bounds),
                child: Text(
                  '1:${widget.riskReward.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Color(0x73d4af37),
                        blurRadius: 10 + 8, // 10 + (_glowController.value * 8)
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
