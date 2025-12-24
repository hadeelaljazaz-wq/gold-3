import 'package:flutter/material.dart';
import 'dart:async';
import '../services/gold_price_service.dart';
import '../core/theme/royal_colors.dart';
import '../core/theme/royal_typography.dart';

/// 💰 Live Price Indicator Widget
/// مؤشر السعر الحي المتحرك
class LivePriceIndicator extends StatefulWidget {
  const LivePriceIndicator({super.key});

  @override
  State<LivePriceIndicator> createState() => _LivePriceIndicatorState();
}

class _LivePriceIndicatorState extends State<LivePriceIndicator>
    with SingleTickerProviderStateMixin {
  double _currentPrice = 0.0;
  double _previousPrice = 0.0;
  bool _isLoading = true;
  Timer? _refreshTimer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _loadPrice();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadPrice() async {
    try {
      final goldPrice = await GoldPriceService.getCurrentPrice();
      if (mounted) {
        setState(() {
          _previousPrice = _currentPrice > 0 ? _currentPrice : goldPrice.price;
          _currentPrice = goldPrice.price;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadPrice(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    final priceChange = _currentPrice - _previousPrice;
    final isUp = priceChange > 0;
    final isDown = priceChange < 0;

    return FadeTransition(
      opacity: _pulseController,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              RoyalColors.deepPurple.withValues(alpha: 0.3),
              RoyalColors.imperialBlue.withValues(alpha: 0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: RoyalColors.royalGold.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: RoyalColors.royalGold.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gold Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: RoyalColors.goldGradient,
                shape: BoxShape.circle,
                boxShadow: RoyalColors.goldNeonGlow,
              ),
              child: const Icon(
                Icons.currency_exchange,
                color: Colors.black,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'XAU/USD',
                  style: RoyalTypography.labelSmall.copyWith(
                    color: RoyalColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '\$${_currentPrice.toStringAsFixed(2)}',
                      style: RoyalTypography.h2.copyWith(
                        color: RoyalColors.royalGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Change indicator
                    if (isUp || isDown)
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isUp
                                    ? RoyalColors.neonGreen.withValues(alpha: 0.2)
                                    : RoyalColors.crimsonRed.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isUp
                                      ? RoyalColors.neonGreen
                                      : RoyalColors.crimsonRed,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isUp ? Icons.arrow_upward : Icons.arrow_downward,
                                    size: 12,
                                    color: isUp
                                        ? RoyalColors.neonGreen
                                        : RoyalColors.crimsonRed,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '\$${priceChange.abs().toStringAsFixed(2)}',
                                    style: RoyalTypography.labelSmall.copyWith(
                                      color: isUp
                                          ? RoyalColors.neonGreen
                                          : RoyalColors.crimsonRed,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(width: 12),

            // Live indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: RoyalColors.neonGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: RoyalColors.neonGreen,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: RoyalColors.neonGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: RoyalColors.neonGreen.withValues(alpha: 0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'LIVE',
                    style: RoyalTypography.labelSmall.copyWith(
                      color: RoyalColors.neonGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            RoyalColors.deepPurple.withValues(alpha: 0.3),
            RoyalColors.imperialBlue.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: RoyalColors.royalGold.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(RoyalColors.royalGold),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'جاري تحميل السعر...',
            style: RoyalTypography.labelSmall.copyWith(
              color: RoyalColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

