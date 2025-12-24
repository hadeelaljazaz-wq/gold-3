import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/home_provider.dart';
import '../widgets/home_widgets.dart';
import '../../../widgets/shared_widgets.dart';
import '../../../widgets/animations/slide_in_card.dart';
import '../../../widgets/animations/shimmer_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goldPriceAsync = ref.watch(goldPriceProvider);
    final marketStatus = ref.watch(marketStatusProvider);
    final performanceStats = ref.watch(performanceStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('كابوس ذهبي برو'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications (can be implemented when notification screen is added)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ميزة الإشعارات قيد الإعداد')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(goldPriceProvider);
          await Future.delayed(const Duration(seconds: 1));
        },
        child: goldPriceAsync.when(
          data: (goldPrice) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card with SlideIn animation
                SlideInCard(
                  delay: const Duration(milliseconds: 0),
                  child: _buildWelcomeCard(context),
                ),
                const SizedBox(height: 16),

                // Price Card with SlideIn animation
                SlideInCard(
                  delay: const Duration(milliseconds: 100),
                  child: PriceCard(goldPrice: goldPrice),
                ),
                const SizedBox(height: 16),

                // Market Status with SlideIn animation
                SlideInCard(
                  delay: const Duration(milliseconds: 200),
                  child: MarketStatusCard(status: marketStatus),
                ),
                const SizedBox(height: 16),

                // Quick Stats with SlideIn animation
                SlideInCard(
                  delay: const Duration(milliseconds: 300),
                  child: QuickStatsCard(stats: performanceStats),
                ),
                const SizedBox(height: 16),

                // Quick Actions with SlideIn animation
                SlideInCard(
                  delay: const Duration(milliseconds: 400),
                  child: const QuickActionButtons(),
                ),
                const SizedBox(height: 24),

                // Latest Recommendations (Placeholder)
                Text(
                  'أحدث توصية',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                _buildLatestRecommendation(context),

                const SizedBox(height: 24),

                // Contact Section
                SlideInCard(
                  delay: const Duration(milliseconds: 500),
                  child: _buildContactSection(context),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          loading: () => Center(
            child: ShimmerWidget(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.royalGold),
                  ),
                  SizedBox(height: 16),
                  Text('جاري تحميل بيانات السوق...'),
                ],
              ),
            ),
          ),
          error: (error, stack) => ErrorStateWidget(
            message: 'فشل تحميل بيانات السوق',
            onRetry: () {
              ref.invalidate(goldPriceProvider);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.backgroundSecondary,
            AppColors.backgroundTertiary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wb_sunny_outlined,
            color: AppColors.royalGold,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً بعودتك!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'جاهز لتحليل السوق؟',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestRecommendation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'No recent recommendations',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              ElevatedButton(
                onPressed: () {
                  context.go('/');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text('Generate Now'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.backgroundSecondary,
            AppColors.backgroundTertiary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderGold.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.contact_support,
                  color: Colors.black,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'تواصل معنا',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.royalGold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'للدعم الفني والاستفسارات',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildContactButton(
                  context: context,
                  icon: Icons.telegram,
                  label: 'Telegram',
                  color: const Color(0xFF0088CC),
                  onTap: () => _launchUrl('https://t.me/Odai_xau'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildContactButton(
                  context: context,
                  icon: Icons.chat,
                  label: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  onTap: () => _launchUrl('https://wa.me/962786275654'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Show error if can't launch
      debugPrint('Could not launch $urlString');
    }
  }
}
