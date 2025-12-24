import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/settings_provider.dart';
import '../widgets/theme_switcher.dart';
import '../widgets/strictness_selector_settings.dart';
import '../../../widgets/animations/slide_in_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final settings = settingsState.settings;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.goldGradient.createShader(bounds),
              child: const Text(
                'الإعدادات',
                style: AppTypography.titleLarge,
              ),
            ),
            Text(
              'Settings',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Theme Section
            SlideInCard(
              delay: const Duration(milliseconds: 100),
              child: _buildSection(
                context,
                title: 'المظهر',
                subtitle: 'Theme',
                icon: Icons.palette_outlined,
                child: const ThemeSwitcher(),
              ),
            ),
            const SizedBox(height: 16),

            // Analysis Settings
            SlideInCard(
              delay: const Duration(milliseconds: 200),
              child: _buildSection(
                context,
                title: 'إعدادات التحليل',
                subtitle: 'Analysis Settings',
                icon: Icons.analytics_outlined,
                child: Column(
                  children: [
                    const StrictnessSelectorSettings(),
                    const SizedBox(height: 16),
                    _buildSwitch(
                      context,
                      title: 'عرض تحليل AI تلقائياً',
                      subtitle: 'Show AI Analysis by default',
                      value: settings.showAIAnalysisByDefault,
                      onChanged: (value) {
                        ref
                            .read(settingsProvider.notifier)
                            .toggleAIAnalysisByDefault();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Auto-Refresh Settings
            SlideInCard(
              delay: const Duration(milliseconds: 300),
              child: _buildSection(
                context,
                title: 'التحديث التلقائي',
                subtitle: 'Auto-Refresh',
                icon: Icons.refresh,
                child: Column(
                  children: [
                    _buildSwitch(
                      context,
                      title: 'تفعيل التحديث التلقائي',
                      subtitle: 'Enable auto-refresh',
                      value: settings.autoRefreshEnabled,
                      onChanged: (value) {
                        ref.read(settingsProvider.notifier).toggleAutoRefresh();
                      },
                    ),
                    if (settings.autoRefreshEnabled) ...[
                      const SizedBox(height: 16),
                      _buildSlider(
                        context,
                        title: 'فترة التحديث (ثواني)',
                        subtitle: 'Refresh interval (seconds)',
                        value: settings.autoRefreshInterval.toDouble(),
                        min: 60,
                        max: 600,
                        divisions: 9,
                        label: '${settings.autoRefreshInterval}s',
                        onChanged: (value) {
                          ref
                              .read(settingsProvider.notifier)
                              .updateAutoRefreshInterval(value.toInt());
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notifications Settings
            SlideInCard(
              delay: const Duration(milliseconds: 400),
              child: _buildSection(
                context,
                title: 'الإشعارات',
                subtitle: 'Notifications',
                icon: Icons.notifications_outlined,
                child: Column(
                  children: [
                    _buildSwitch(
                      context,
                      title: 'تفعيل الإشعارات',
                      subtitle: 'Enable notifications',
                      value: settings.notificationsEnabled,
                      onChanged: (value) {
                        ref
                            .read(settingsProvider.notifier)
                            .toggleNotifications();
                      },
                    ),
                    if (settings.notificationsEnabled) ...[
                      const SizedBox(height: 12),
                      _buildSwitch(
                        context,
                        title: 'إشعارات الإشارات',
                        subtitle: 'Signal notifications',
                        value: settings.signalNotificationsEnabled,
                        onChanged: (value) {
                          ref
                              .read(settingsProvider.notifier)
                              .toggleSignalNotifications();
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildSwitch(
                        context,
                        title: 'تنبيهات الأسعار',
                        subtitle: 'Price alerts',
                        value: settings.priceAlertsEnabled,
                        onChanged: (value) {
                          ref
                              .read(settingsProvider.notifier)
                              .togglePriceAlerts();
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sound & Vibration
            SlideInCard(
              delay: const Duration(milliseconds: 500),
              child: _buildSection(
                context,
                title: 'الصوت والاهتزاز',
                subtitle: 'Sound & Vibration',
                icon: Icons.volume_up_outlined,
                child: Column(
                  children: [
                    _buildSwitch(
                      context,
                      title: 'المؤثرات الصوتية',
                      subtitle: 'Sound effects',
                      value: settings.soundEffectsEnabled,
                      onChanged: (value) {
                        ref
                            .read(settingsProvider.notifier)
                            .toggleSoundEffects();
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildSwitch(
                      context,
                      title: 'الاهتزاز',
                      subtitle: 'Vibration',
                      value: settings.vibrationEnabled,
                      onChanged: (value) {
                        ref.read(settingsProvider.notifier).toggleVibration();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Language Settings
            SlideInCard(
              delay: const Duration(milliseconds: 600),
              child: _buildSection(
                context,
                title: 'اللغة',
                subtitle: 'Language',
                icon: Icons.language_outlined,
                child: _buildLanguageSelector(context, ref, settings.language),
              ),
            ),
            const SizedBox(height: 16),

            // About Section
            SlideInCard(
              delay: const Duration(milliseconds: 700),
              child: _buildSection(
                context,
                title: 'حول التطبيق',
                subtitle: 'About',
                icon: Icons.info_outline,
                child: Column(
                  children: [
                    _buildInfoRow('الإصدار', 'v2.5.0'),
                    const SizedBox(height: 8),
                    _buildInfoRow('المطور', 'KABOUS Team'),
                    const SizedBox(height: 8),
                    _buildInfoRow('البناء', 'Production'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Reset Button
            SlideInCard(
              delay: const Duration(milliseconds: 800),
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('إعادة تعيين الإعدادات'),
                      content: const Text(
                          'هل أنت متأكد من إعادة تعيين جميع الإعدادات إلى القيم الافتراضية؟'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('إلغاء'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('إعادة تعيين'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await ref.read(settingsProvider.notifier).resetToDefaults();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم إعادة تعيين الإعدادات بنجاح'),
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.restore),
                label: const Text('إعادة تعيين الإعدادات'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
                  foregroundColor: AppColors.error,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.royalGold, size: 24),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.titleMedium),
                  Text(
                    subtitle,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSwitch(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.bodyMedium),
              Text(
                subtitle,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppColors.royalGold,
        ),
      ],
    );
  }

  Widget _buildSlider(
    BuildContext context, {
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.bodyMedium),
        Text(
          subtitle,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: label,
          onChanged: onChanged,
          activeColor: AppColors.royalGold,
        ),
      ],
    );
  }

  Widget _buildLanguageSelector(
      BuildContext context, WidgetRef ref, String currentLanguage) {
    return Row(
      children: [
        Expanded(
          child: _buildLanguageOption(
            context,
            ref,
            'العربية',
            'ar',
            currentLanguage == 'ar',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildLanguageOption(
            context,
            ref,
            'English',
            'en',
            currentLanguage == 'en',
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    WidgetRef ref,
    String label,
    String code,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        ref.read(settingsProvider.notifier).updateLanguage(code);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.royalGold.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.royalGold : AppColors.borderColor,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: isSelected ? AppColors.royalGold : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMedium),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
