import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// 🎯 Clean Trading Screen
/// شاشة احترافية نظيفة تطبق كل القواعد
class CleanTradingScreen extends StatefulWidget {
  const CleanTradingScreen({Key? key}) : super(key: key);

  @override
  State<CleanTradingScreen> createState() => _CleanTradingScreenState();
}

class _CleanTradingScreenState extends State<CleanTradingScreen> {
  // Market Data
  final double currentPrice = 2146.23;
  final String signal = 'SELL'; // or 'BUY'
  final double successRate = 85.0;
  final double entryPrice = 2146.23;
  final double stopLoss = 2155.00;
  final double takeProfit = 2135.00;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary, // #0B0E11 - ثابتة
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildPriceSection(),
                    const SizedBox(height: 20),
                    _buildSignalCard(),
                    const SizedBox(height: 16),
                    _buildTargetsCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header بسيط
  Widget _buildHeader() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary, // #12161C
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Logo بسيط
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.goldMain,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'G',
                style: GoogleFonts.poppins(
                  color: AppColors.bgPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // عنوان - ذهبي
          Text(
            'GOLD TRADING',
            style: GoogleFonts.poppins(
              color: AppColors.goldMain, // ذهبي للعنوان
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),

          const Spacer(),

          // نسبة النجاح - ذهبي
          Text(
            '${successRate.toInt()}%',
            style: GoogleFonts.poppins(
              color: AppColors.goldMain, // ذهبي للنسبة
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// قسم السعر - ملك الشاشة
  Widget _buildPriceSection() {
    return Column(
      children: [
        // XAUUSD
        Text(
          'XAUUSD',
          style: GoogleFonts.poppins(
            color: AppColors.textMuted, // خافت
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: 8),

        // السعر الكبير - ذهبي
        Text(
          currentPrice.toStringAsFixed(2),
          style: GoogleFonts.poppins(
            color: AppColors.goldMain, // ذهبي للسعر
            fontSize: 40, // الأكبر
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 12),

        // SELL Badge - هادئ
        _buildSignalBadge(),
      ],
    );
  }

  /// SELL/BUY Badge - هادئ
  Widget _buildSignalBadge() {
    final isSell = signal == 'SELL';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSell ? AppColors.sellBadgeBg : AppColors.buyBadgeBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        signal,
        style: GoogleFonts.poppins(
          color: isSell ? AppColors.sellBadgeText : AppColors.buyBadgeText,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// كرت الإشارة - موحد
  Widget _buildSignalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard, // #161B22
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border, // #232A32
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ], // Shadow ناعم
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Text(
            'Active Signal',
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary, // أبيض
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          // التفاصيل
          _buildDetailRow('Entry', entryPrice.toStringAsFixed(2)),
          const SizedBox(height: 12),
          _buildDetailRow('Stop Loss', stopLoss.toStringAsFixed(2)),
          const SizedBox(height: 12),
          _buildDetailRow('Take Profit', takeProfit.toStringAsFixed(2)),

          const SizedBox(height: 16),

          // ملاحظة
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgHover, // #1E2329
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Strong resistance at 2155. Expect bearish momentum.',
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary, // خافت
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// صف التفاصيل
  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppColors.textMuted, // خافت جداً
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary, // أبيض
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// كرت الأهداف - موحد
  Widget _buildTargetsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Targets',
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildTargetRow('TP1', '2135.00', AppColors.profit),
          const SizedBox(height: 12),
          _buildTargetRow('TP2', '2125.00', AppColors.profit),
          const SizedBox(height: 12),
          _buildTargetRow('TP3', '2115.00', AppColors.profit),
        ],
      ),
    );
  }

  /// صف الهدف
  Widget _buildTargetRow(String label, String price, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppColors.textMuted,
            fontSize: 12,
          ),
        ),
        Text(
          price,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
