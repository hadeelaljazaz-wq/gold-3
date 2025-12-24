import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_initialization_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// 🚀 App Initialization Screen
///
/// Displays loading progress while app features are being initialized
class AppInitializationScreen extends ConsumerStatefulWidget {
  final Widget child;

  const AppInitializationScreen({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AppInitializationScreen> createState() =>
      _AppInitializationScreenState();
}

class _AppInitializationScreenState
    extends ConsumerState<AppInitializationScreen> {
  @override
  void initState() {
    super.initState();
    // Start initialization
    Future.microtask(() {
      ref.read(appInitProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final initState = ref.watch(appInitProvider);

    // Show loading screen while initializing
    if (!initState.isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: Scaffold(
          backgroundColor: AppColors.background,
          body: _buildLoadingScreen(initState),
        ),
      );
    }

    // Show error screen if initialization failed critically
    if (initState.error != null && !initState.allCriticalFeaturesLoaded) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: Scaffold(
          backgroundColor: AppColors.background,
          body: _buildErrorScreen(initState),
        ),
      );
    }

    // Initialization complete - show main app
    return widget.child;
  }

  /// Build loading screen
  Widget _buildLoadingScreen(AppInitState state) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo/Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.royalGold.withValues(alpha: 0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_graph,
                size: 60,
                color: AppColors.background,
              ),
            ),

            const SizedBox(height: 40),

            // App Name
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.goldGradient.createShader(bounds),
              child: const Text(
                'الكابوس الملكي',
                style: AppTypography.displaySmall,
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'منصة التحليل الذهبي الاحترافية',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 60),

            // Progress Bar
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: state.progress,
                      minHeight: 6,
                      backgroundColor: AppColors.backgroundSecondary,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.royalGold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${(state.progress * 100).toInt()}%',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Loading Status
            _buildLoadingStatus(state),
          ],
        ),
      ),
    );
  }

  /// Build loading status indicators
  Widget _buildLoadingStatus(AppInitState state) {
    return Column(
      children: state.features.entries.map((entry) {
        final featureName = _getFeatureName(entry.key);
        final isLoaded = entry.value;
        final isLoading = !isLoaded && state.isLoading;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status Icon
              if (isLoaded)
                const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppColors.success,
                )
              else if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.royalGold,
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.circle_outlined,
                  size: 16,
                  color: AppColors.textTertiary,
                ),

              const SizedBox(width: 8),

              // Feature Name
              Text(
                featureName,
                style: AppTypography.bodySmall.copyWith(
                  color:
                      isLoaded ? AppColors.textPrimary : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Build error screen
  Widget _buildErrorScreen(AppInitState state) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 50,
                color: AppColors.error,
              ),
            ),

            const SizedBox(height: 24),

            // Error Title
            Text(
              'Initialization Failed',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Error Message
            Text(
              state.error ?? 'Unknown error occurred',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Retry Button
            ElevatedButton.icon(
              onPressed: () {
                ref.read(appInitProvider.notifier).reset();
                ref.read(appInitProvider.notifier).initialize();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.royalGold,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get user-friendly feature name
  String _getFeatureName(String key) {
    switch (key) {
      case 'dotenv':
        return 'Environment Configuration';
      case 'localization':
        return 'Localization';
      case 'hive':
        return 'Local Storage';
      case 'notifications':
        return 'Notifications';
      default:
        return key;
    }
  }
}
