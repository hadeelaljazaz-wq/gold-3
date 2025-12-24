import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/recommendation.dart';
import '../../../widgets/shared_widgets.dart';
import '../../../core/theme/app_colors.dart';
// import '../../../features/notifications/services/notification_service.dart'; // REMOVED

class SwingCard extends StatelessWidget {
  final Recommendation recommendation;

  const SwingCard({super.key, required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.show_chart, color: AppColors.info),
                    const SizedBox(width: 8),
                    Text(
                      'إعداد السوينج',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                ConfidenceBadge(confidence: recommendation.confidenceText),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: DirectionBadge(direction: recommendation.directionText),
            ),
            const SizedBox(height: 16),
            if (recommendation.direction != Direction.noTrade) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  PriceDisplay(
                    label: 'الدخول',
                    price: recommendation.entry,
                    color: AppColors.royalGold,
                  ),
                  PriceDisplay(
                    label: 'وقف الخسارة',
                    price: recommendation.stopLoss,
                    color: AppColors.sell,
                  ),
                  PriceDisplay(
                    label: 'جني الربح',
                    price: recommendation.takeProfit,
                    color: AppColors.buy,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (recommendation.liquidityTarget != null)
                _buildLiquidityTarget(context, recommendation.liquidityTarget!),
            ],
            const SizedBox(height: 16),
            _buildReasoning(context, recommendation.reasoning),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copyToClipboard(context),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('نسخ'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Notification feature removed
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('ميزة التنبيهات غير متوفرة حالياً'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications_off, size: 16),
                    label: const Text('تنبيه'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiquidityTarget(BuildContext context, String target) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.water_drop, size: 16, color: AppColors.info),
          const SizedBox(width: 8),
          Text(
            'هدف السيولة: $target',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasoning(BuildContext context, String reasoning) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'التحليل:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            reasoning,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    final text = '''
📊 SWING SETUP - ${recommendation.directionText}
Entry: \$${recommendation.entry?.toStringAsFixed(2) ?? 'N/A'}
Stop Loss: \$${recommendation.stopLoss?.toStringAsFixed(2) ?? 'N/A'}
Take Profit: \$${recommendation.takeProfit?.toStringAsFixed(2) ?? 'N/A'}
Confidence: ${recommendation.confidenceText}
${recommendation.liquidityTarget != null ? 'Target: ${recommendation.liquidityTarget}' : ''}

${recommendation.reasoning}
''';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم النسخ!')),
    );
  }
}
