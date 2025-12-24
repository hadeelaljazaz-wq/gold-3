import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/trade_history_provider.dart';
import '../widgets/trade_card.dart';
import '../widgets/statistics_card.dart';
import '../../../widgets/animations/slide_in_card.dart';

class TradeHistoryScreen extends ConsumerWidget {
  const TradeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(tradeHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.goldGradient.createShader(bounds),
              child: const Text(
                'سجل الصفقات',
                style: AppTypography.titleLarge,
              ),
            ),
            Text(
              'Trade History & Analytics',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          // Export to CSV
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () async {
              await _exportToCSV(context, ref);
            },
          ),
          // Clear all
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('مسح جميع الصفقات'),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'clear') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('تأكيد المسح'),
                    content: const Text(
                        'هل أنت متأكد من مسح جميع الصفقات؟ لا يمكن التراجع عن هذا الإجراء.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('إلغاء'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                        child: const Text('مسح'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref
                      .read(tradeHistoryProvider.notifier)
                      .clearAllTrades();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم مسح جميع الصفقات')),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
      body: historyState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Statistics
                  SlideInCard(
                    delay: const Duration(milliseconds: 100),
                    child: StatisticsCard(state: historyState),
                  ),
                  const SizedBox(height: 16),

                  // Filter Tabs
                  SlideInCard(
                    delay: const Duration(milliseconds: 200),
                    child: _buildFilterTabs(ref, historyState.filter),
                  ),
                  const SizedBox(height: 16),

                  // Trades List
                  if (historyState.filteredTrades.isEmpty)
                    SlideInCard(
                      delay: const Duration(milliseconds: 300),
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundSecondary,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'لا توجد صفقات',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...historyState.filteredTrades.asMap().entries.map((entry) {
                      return SlideInCard(
                        delay: Duration(milliseconds: 300 + (entry.key * 50)),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TradeCard(
                            trade: entry.value,
                            onClose: (exitPrice, notes) async {
                              await ref
                                  .read(tradeHistoryProvider.notifier)
                                  .closeTrade(entry.value.id, exitPrice,
                                      notes: notes);
                            },
                            onCancel: (notes) async {
                              await ref
                                  .read(tradeHistoryProvider.notifier)
                                  .cancelTrade(entry.value.id, notes: notes);
                            },
                            onDelete: () async {
                              await ref
                                  .read(tradeHistoryProvider.notifier)
                                  .deleteTrade(entry.value.id);
                            },
                          ),
                        ),
                      );
                    }).toList(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildFilterTabs(WidgetRef ref, String currentFilter) {
    final filters = [
      {'key': 'all', 'label': 'الكل', 'icon': Icons.all_inclusive},
      {'key': 'open', 'label': 'مفتوحة', 'icon': Icons.trending_up},
      {'key': 'closed', 'label': 'مغلقة', 'icon': Icons.done},
      {'key': 'profitable', 'label': 'رابحة', 'icon': Icons.check_circle},
      {'key': 'loss', 'label': 'خاسرة', 'icon': Icons.cancel},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تصفية',
            style: AppTypography.titleSmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filters.map((filter) {
              final isSelected = filter['key'] == currentFilter;
              return InkWell(
                onTap: () {
                  ref
                      .read(tradeHistoryProvider.notifier)
                      .changeFilter(filter['key'] as String);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.royalGold.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.royalGold
                          : AppColors.borderColor,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        filter['icon'] as IconData,
                        size: 16,
                        color: isSelected
                            ? AppColors.royalGold
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        filter['label'] as String,
                        style: AppTypography.bodySmall.copyWith(
                          color: isSelected
                              ? AppColors.royalGold
                              : AppColors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToCSV(BuildContext context, WidgetRef ref) async {
    try {
      final csv = ref.read(tradeHistoryProvider.notifier).exportToCSV();

      // Save to temporary file
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/trade_history.csv');
      await file.writeAsString(csv);

      // Share file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Trade History Export',
        text: 'سجل الصفقات - Gold Nightmare Pro',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تصدير سجل الصفقات')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل التصدير: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
