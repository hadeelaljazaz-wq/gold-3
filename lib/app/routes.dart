import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/unified_analysis/screens/royal_analysis_screen.dart';
import '../features/analytics/screens/gold_analytics_dashboard.dart';
import '../features/analytics/screens/ai_analytics_screen.dart';
import '../core/theme/app_colors.dart';

// Router Provider - Unified Analysis ONLY
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/unified_analysis',
    debugLogDiagnostics: false,
    routes: [
      // Unified Analysis - الشاشة الوحيدة (الحديثة والكاملة)
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const RoyalAnalysisScreen(),
      ),
      
      GoRoute(
        path: '/unified_analysis',
        name: 'unified_analysis',
        builder: (context, state) => const RoyalAnalysisScreen(),
      ),

      // Analytics Dashboard - التحليلات المتقدمة
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return GoldAnalyticsDashboard(
            currentPrice: extra?['currentPrice'] ?? 2150.0,
            candles: extra?['candles'] ?? [],
            indicators: extra?['indicators'] ?? {},
          );
        },
      ),

      // 🧠 AI Analytics - تحليل الذكاء الاصطناعي
      GoRoute(
        path: '/ai-analytics',
        name: 'ai_analytics',
        builder: (context, state) => const AIAnalyticsScreen(),
      ),

    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'الصفحة غير موجودة',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('العودة للرئيسية'),
            ),
          ],
        ),
      ),
    ),
  );
});
