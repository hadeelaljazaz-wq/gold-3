import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/royal_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/settings_provider.dart';

class ThemeSwitcher extends ConsumerWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final currentTheme = settingsState.settings.themeMode;

    return Row(
      children: [
        Expanded(
          child: _buildThemeOption(
            context,
            ref,
            'Original',
            'original',
            'المظهر الأصلي',
            Icons.diamond_outlined,
            AppColors.goldGradient,
            currentTheme == 'original',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildThemeOption(
            context,
            ref,
            'Royal',
            'royal',
            'المظهر الملكي',
            Icons.auto_awesome_outlined,
            RoyalColors.royalGradient,
            currentTheme == 'royal',
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    String title,
    String themeCode,
    String subtitle,
    IconData icon,
    Gradient gradient,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        ref.read(settingsProvider.notifier).updateTheme(themeCode);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
          color: isSelected ? null : AppColors.backgroundPrimary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.borderColor,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (themeCode == 'royal'
                            ? RoyalColors.royalGold
                            : AppColors.royalGold)
                        .withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTypography.titleSmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.8)
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
