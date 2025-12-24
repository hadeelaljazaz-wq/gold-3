/// 👑 Legendary Mode Toggle
///
/// زر التبديل للوضع الأسطوري
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/legendary_design_system.dart';
import '../providers/analysis_provider.dart';

class LegendaryModeToggle extends ConsumerWidget {
  const LegendaryModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analysisProvider);
    final isLegendaryMode = state.useLegendaryMode;

    return GestureDetector(
      onTap: () {
        ref.read(analysisProvider.notifier).toggleLegendaryMode();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isLegendaryMode
              ? LegendaryDesignSystem.royalGoldGradient
              : null,
          color: isLegendaryMode ? null : LegendaryDesignSystem.cardBackground,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isLegendaryMode
                ? LegendaryDesignSystem.royalGold
                : LegendaryDesignSystem.royalGold.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: isLegendaryMode
              ? [
                  BoxShadow(
                    color: LegendaryDesignSystem.royalGold.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              color: isLegendaryMode
                  ? Colors.black
                  : LegendaryDesignSystem.royalGold,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              isLegendaryMode ? 'الوضع الأسطوري 👑' : 'الوضع العادي',
              style: TextStyle(
                color: isLegendaryMode ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
