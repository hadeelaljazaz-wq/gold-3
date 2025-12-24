import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes.dart';
import 'theme.dart';
import '../services/unified_activation_service.dart';
import '../features/activation/screens/activation_screen.dart';
import '../features/splash/splash_screen.dart';

/// Provider للتحقق من حالة الترخيص
final licenseStatusProvider = FutureProvider<bool>((ref) async {
  final status = await UnifiedActivationService.checkActivationStatus();
  return status.isActivated;
});

class GoldenNightmareApp extends ConsumerWidget {
  const GoldenNightmareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'كابوس ذهبي برو',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // Localization - Arabic with proper delegates
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'), // Fallback
      ],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,

      // Home with license check
      home: const LicenseChecker(),
    );
  }
}

/// Widget للتحقق من الترخيص قبل عرض التطبيق
class LicenseChecker extends ConsumerStatefulWidget {
  const LicenseChecker({super.key});

  @override
  ConsumerState<LicenseChecker> createState() => _LicenseCheckerState();
}

class _LicenseCheckerState extends ConsumerState<LicenseChecker> {
  bool _isLicensed = false;
  bool _isChecking = true;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _checkLicense();
  }

  Future<void> _checkLicense() async {
    final status = await UnifiedActivationService.checkActivationStatus();
    setState(() {
      _isLicensed = status.isActivated;
      _isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // شاشة البداية الأسطورية
    if (_showSplash) {
      return LegendarySplashScreen(
        onComplete: () {
          setState(() {
            _showSplash = false;
          });
        },
      );
    }

    if (_isChecking) {
      // شاشة التحميل
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isLicensed) {
      // شاشة التفعيل مع callback للتفعيل الناجح
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) {
            await _checkLicense();
          }
        },
        child: ActivationScreenWrapper(
          onActivationSuccess: () {
            setState(() {
              _isChecking = true;
            });
            _checkLicense();
          },
        ),
      );
    }

    // التطبيق الرئيسي
    return const MainAppWithRouting();
  }
}

/// التطبيق الرئيسي مع الـ Routing
class MainAppWithRouting extends ConsumerWidget {
  const MainAppWithRouting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'كابوس ذهبي برو',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // Routing
      routerConfig: router,

      // Localization - Arabic with proper delegates
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'), // Fallback
      ],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
    );
  }
}

/// Wrapper لشاشة التفعيل مع callback
class ActivationScreenWrapper extends StatelessWidget {
  final VoidCallback onActivationSuccess;

  const ActivationScreenWrapper({
    super.key,
    required this.onActivationSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onDidRemovePage: (page) {
        // يتم استدعاء onActivationSuccess عند نجاح التفعيل
        onActivationSuccess();
      },
      pages: const [
        MaterialPage(child: ActivationScreen()),
      ],
    );
  }
}
