import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/market_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/animations/pulse_animation.dart';
// ignore: unused_import
import '../providers/home_provider.dart';
import '../../../features/trade_history/providers/trade_history_provider.dart';

/// Price Card Widget
class PriceCard extends StatelessWidget {
  final GoldPrice goldPrice;

  const PriceCard({super.key, required this.goldPrice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.royalGold.withValues(alpha: 0.2),
            AppColors.warning.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.royalGold.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'XAU/USD',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.royalGold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              PulseAnimation(
                isPositive: goldPrice.change >= 0,
                enabled: goldPrice.change != 0,
                child: Text(
                  '\$${goldPrice.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              _buildChangeChip(goldPrice),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPriceInfo('High', goldPrice.high24h, context),
              _buildPriceInfo('Low', goldPrice.low24h, context),
              _buildPriceInfo('Open', goldPrice.open24h, context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChangeChip(GoldPrice price) {
    final isPositive = price.change > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (isPositive ? AppColors.buy : AppColors.sell).withValues(
          alpha: 0.2,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            size: 16,
            color: isPositive ? AppColors.buy : AppColors.sell,
          ),
          const SizedBox(width: 4),
          Text(
            '${isPositive ? '+' : ''}${price.change.toStringAsFixed(2)} (${price.changePercent.toStringAsFixed(2)}%)',
            style: TextStyle(
              color: isPositive ? AppColors.buy : AppColors.sell,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInfo(String label, double value, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Market Status Card
class MarketStatusCard extends StatelessWidget {
  final MarketStatus status;

  const MarketStatusCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: status.isOpen ? AppColors.buy : AppColors.sell,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (status.isOpen ? AppColors.buy : AppColors.sell)
                      .withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.isOpen ? 'Market Open' : 'Market Closed',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  status.sessionName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick Stats Card
class QuickStatsCard extends ConsumerWidget {
  final PerformanceStats stats;

  const QuickStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calculate today's trades
    final tradeHistoryState = ref.watch(tradeHistoryProvider);
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayTrades = tradeHistoryState.trades.where((trade) {
      return trade.entryTime.isAfter(todayStart);
    }).length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(
            'Total',
            stats.totalTrades.toString(),
            Icons.analytics,
            context,
          ),
          _buildStat('Today', todayTrades.toString(), Icons.today, context),
          _buildStat(
            'Win Rate',
            '${stats.winRate.toStringAsFixed(0)}%',
            Icons.trending_up,
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildStat(
    String label,
    String value,
    IconData icon,
    BuildContext context,
  ) {
    return Column(
      children: [
        Icon(icon, color: AppColors.royalGold, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

/// Quick Action Buttons
class QuickActionButtons extends StatelessWidget {
  const QuickActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Analyze',
                Icons.analytics,
                AppColors.royalGold,
                () {
                  context.go('/');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Charts',
                Icons.candlestick_chart,
                AppColors.info,
                () {
                  context.push('/charts');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          'NEXUS + KABOUS',
          Icons.auto_awesome,
          AppColors.imperialPurple,
          () {
            context.push('/nexus-kabous');
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Builder(
      builder: (context) => Material(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
