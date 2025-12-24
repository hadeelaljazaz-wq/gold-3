import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/trade_record.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class TradeCard extends StatelessWidget {
  final TradeRecord trade;
  final Function(double exitPrice, String? notes)? onClose;
  final Function(String? notes)? onCancel;
  final VoidCallback? onDelete;

  const TradeCard({
    super.key,
    required this.trade,
    this.onClose,
    this.onCancel,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isProfit = trade.isProfitable;
    final statusColor = trade.status == 'open'
        ? AppColors.warning
        : trade.status == 'cancelled'
            ? AppColors.textSecondary
            : isProfit
                ? AppColors.success
                : AppColors.error;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                // Type & Direction
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: trade.direction == 'BUY'
                        ? AppColors.success.withValues(alpha: 0.2)
                        : AppColors.error.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trade.direction == 'BUY'
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 16,
                        color: trade.direction == 'BUY'
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${trade.direction} ${trade.type.toUpperCase()}',
                        style: AppTypography.labelMedium.copyWith(
                          color: trade.direction == 'BUY'
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStatusText(trade.status),
                    style: AppTypography.labelMedium.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Entry & Exit
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        'Entry',
                        '\$${trade.entryPrice.toStringAsFixed(2)}',
                        AppColors.textPrimary,
                      ),
                    ),
                    if (trade.exitPrice != null)
                      Expanded(
                        child: _buildInfoItem(
                          'Exit',
                          '\$${trade.exitPrice!.toStringAsFixed(2)}',
                          statusColor,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // SL & TP
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        'Stop Loss',
                        '\$${trade.stopLoss.toStringAsFixed(2)}',
                        AppColors.error,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        'Take Profit',
                        trade.takeProfit
                            .map((tp) => '\$${tp.toStringAsFixed(2)}')
                            .join(' | '),
                        AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // P/L
                if (trade.profitLoss != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isProfit
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isProfit ? Icons.trending_up : Icons.trending_down,
                          color: isProfit ? AppColors.success : AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${isProfit ? '+' : ''}\$${trade.profitLoss!.toStringAsFixed(2)}',
                          style: AppTypography.titleMedium.copyWith(
                            color:
                                isProfit ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${isProfit ? '+' : ''}${(trade.profitLossPercent ?? 0.0).toStringAsFixed(2)}%)',
                          style: AppTypography.bodyMedium.copyWith(
                            color:
                                isProfit ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Time & Duration
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        'Entry Time',
                        DateFormat('dd/MM HH:mm').format(trade.entryTime),
                        AppColors.textSecondary,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        'Duration',
                        '${trade.durationHours.toStringAsFixed(1)}h',
                        AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Engine & Strictness
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        'Engine',
                        trade.engine,
                        AppColors.royalGold,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        'Strictness',
                        trade.strictness,
                        AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                // Notes
                if (trade.notes != null && trade.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundPrimary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notes',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          trade.notes!,
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],

                // Actions (for open trades)
                if (trade.status == 'open') ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showCloseDialog(context),
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('إغلاق'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.success,
                            side: const BorderSide(color: AppColors.success),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showCancelDialog(context),
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text('إلغاء'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Delete action (for all trades)
                if (trade.status != 'open') ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _showDeleteDialog(context),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('حذف'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildInfoItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'open':
        return 'مفتوحة';
      case 'closed':
        return 'مغلقة';
      case 'cancelled':
        return 'ملغاة';
      default:
        return status;
    }
  }

  void _showCloseDialog(BuildContext context) {
    final controller = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إغلاق الصفقة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'سعر الخروج',
                hintText: '2650.00',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'ملاحظات (اختياري)',
                hintText: 'TP1 hit',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final exitPrice = double.tryParse(controller.text);
              if (exitPrice != null && onClose != null) {
                onClose!(
                  exitPrice,
                  notesController.text.isEmpty ? null : notesController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الصفقة'),
        content: TextField(
          controller: notesController,
          decoration: const InputDecoration(
            labelText: 'سبب الإلغاء (اختياري)',
            hintText: 'تغير ظروف السوق',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('رجوع'),
          ),
          ElevatedButton(
            onPressed: () {
              if (onCancel != null) {
                onCancel!(
                  notesController.text.isEmpty ? null : notesController.text,
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('إلغاء الصفقة'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الصفقة'),
        content: const Text(
            'هل أنت متأكد من حذف هذه الصفقة؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (onDelete != null) {
                onDelete!();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
