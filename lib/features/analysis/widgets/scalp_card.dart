import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/recommendation.dart';
import '../../../widgets/shared_widgets.dart';
import '../../../core/theme/app_colors.dart';
// import '../../../features/notifications/services/notification_service.dart'; // REMOVED

class ScalpCard extends StatelessWidget {
  final Recommendation recommendation;

  const ScalpCard({super.key, required this.recommendation});

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
                    const Icon(Icons.flash_on, color: AppColors.royalGold),
                    const SizedBox(width: 8),
                    Text(
                      'إعداد السكالب',
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
              if (recommendation.riskRewardRatio != null)
                _buildRiskReward(context, recommendation.riskRewardRatio!),
            ] else ...[
              // Show NO-TRADE message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.sell.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.sell,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'لا توجد فرصة تداول حالياً',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.sell,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    if (recommendation.reasoning.isNotEmpty)
                      Text(
                        recommendation.reasoning,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (recommendation.direction != Direction.noTrade)
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

  Widget _buildRiskReward(BuildContext context, double rr) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.trending_up, size: 16, color: AppColors.buy),
          const SizedBox(width: 8),
          Text(
            'المخاطرة/العائد: 1:${rr.toStringAsFixed(2)}',
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
                  color: AppColors.royalGold,
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
🔥 SCALP SETUP - ${recommendation.directionText}
Entry: \$${recommendation.entry?.toStringAsFixed(2) ?? 'N/A'}
Stop Loss: \$${recommendation.stopLoss?.toStringAsFixed(2) ?? 'N/A'}
Take Profit: \$${recommendation.takeProfit?.toStringAsFixed(2) ?? 'N/A'}
Confidence: ${recommendation.confidenceText}
${recommendation.riskRewardRatio != null ? 'R:R = 1:${recommendation.riskRewardRatio!.toStringAsFixed(2)}' : ''}

${recommendation.reasoning}
''';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم النسخ!')),
    );
  }
}
