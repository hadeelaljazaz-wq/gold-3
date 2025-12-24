import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/settings_provider.dart';

class StrictnessSelectorSettings extends ConsumerWidget {
  const StrictnessSelectorSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final currentStrictness = settingsState.settings.strictnessLevel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مستوى الصرامة',
          style: AppTypography.bodyMedium,
        ),
        Text(
          'Strictness Level',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildOption(
                context,
                ref,
                'مرن',
                'Relaxed',
                'relaxed',
                Colors.green,
                currentStrictness == 'relaxed',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildOption(
                context,
                ref,
                'متوازن',
                'Balanced',
                'balanced',
                Colors.orange,
                currentStrictness == 'balanced',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildOption(
                context,
                ref,
                'صارم',
                'Strict',
                'strict',
                Colors.red,
                currentStrictness == 'strict',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOption(
    BuildContext context,
    WidgetRef ref,
    String titleAr,
    String titleEn,
    String value,
    Color color,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        ref.read(settingsProvider.notifier).updateStrictness(value);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.borderColor,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              titleAr,
              style: AppTypography.bodySmall.copyWith(
                color: isSelected ? color : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              titleEn,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected
                    ? color.withValues(alpha: 0.8)
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
