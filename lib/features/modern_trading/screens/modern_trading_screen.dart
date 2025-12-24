import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

// Clean Professional Color Palette
class CleanColors {
  // Base
  static const Color bgPrimary = Color(0xFF0D0D0D);
  static const Color bgSecondary = Color(0xFF1A1A1A);
  static const Color bgCard = Color(0xFF242424);
  static const Color bgHover = Color(0xFF2A2A2A);

  // Text
  static const Color textPrimary = Color(0xFFE5E5E5);
  static const Color textSecondary = Color(0xFF999999);
  static const Color textMuted = Color(0xFF666666);

  // Accents
  static const Color profit = Color(0xFF10B981); // Green
  static const Color loss = Color(0xFFEF4444); // Red
  static const Color gold = Color(0xFFF59E0B); // Gold
  static const Color info = Color(0xFF3B82F6); // Blue
  static const Color warning = Color(0xFFF97316); // Orange

  // Borders
  static const Color borderDefault = Color(0xFF2D2D2D);
  static const Color borderLight = Color(0xFF363636);
}

class ModernTradingScreen extends StatefulWidget {
  const ModernTradingScreen({Key? key}) : super(key: key);

  @override
  _ModernTradingScreenState createState() => _ModernTradingScreenState();
}

class _ModernTradingScreenState extends State<ModernTradingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Timer _timer;

  // Market Data
  double goldPrice = 2146.23;
  double priceChange = -2.18;
  double changePercent = -0.10;
  String trend = 'BEARISH';
  int signalStrength = 85;

  // Recommendations
  String currentSignal = 'SELL';
  double entryPrice = 2146.23;
  double stopLoss = 2155.00;
  double takeProfit1 = 2135.00;
  double takeProfit2 = 2125.00;
  double takeProfit3 = 2115.00;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Simulate real-time updates
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        double change = (math.Random().nextDouble() - 0.5) * 1;
        goldPrice += change;
        priceChange = goldPrice - 2148.41;
        changePercent = (priceChange / 2148.41) * 100;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CleanColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildMainPriceCard(),
            _buildQuickStats(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSignalsTab(),
                  _buildAnalysisTab(),
                  _buildIndicatorsTab(),
                  _buildSettingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: CleanColors.bgSecondary,
        border: Border(
          bottom: BorderSide(color: CleanColors.borderDefault, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [CleanColors.gold, CleanColors.warning],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'G',
                style: GoogleFonts.poppins(
                  color: CleanColors.bgPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Title
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GOLD TRADING PRO',
                style: GoogleFonts.poppins(
                  color: CleanColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Real-time Analysis System',
                style: GoogleFonts.poppins(
                  color: CleanColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Connection Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: CleanColors.profit.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: CleanColors.profit.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: CleanColors.profit,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'LIVE',
                  style: GoogleFonts.poppins(
                    color: CleanColors.profit,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Menu Button
          IconButton(
            icon: const Icon(Icons.more_vert, color: CleanColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMainPriceCard() {
    bool isProfit = priceChange >= 0;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CleanColors.bgCard,
            CleanColors.bgSecondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CleanColors.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'XAUUSD',
                    style: GoogleFonts.poppins(
                      color: CleanColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    goldPrice.toStringAsFixed(2),
                    style: GoogleFonts.poppins(
                      color: CleanColors.textPrimary,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        isProfit ? Icons.trending_up : Icons.trending_down,
                        color: isProfit ? CleanColors.profit : CleanColors.loss,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${isProfit ? '+' : ''}${priceChange.toStringAsFixed(2)} (${changePercent.toStringAsFixed(2)}%)',
                        style: GoogleFonts.poppins(
                          color:
                              isProfit ? CleanColors.profit : CleanColors.loss,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Signal Indicator
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: currentSignal == 'BUY'
                      ? CleanColors.profit.withValues(alpha: 0.15)
                      : CleanColors.loss.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: currentSignal == 'BUY'
                        ? CleanColors.profit.withValues(alpha: 0.3)
                        : CleanColors.loss.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      currentSignal,
                      style: GoogleFonts.poppins(
                        color: currentSignal == 'BUY'
                            ? CleanColors.profit
                            : CleanColors.loss,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Signal',
                      style: GoogleFonts.poppins(
                        color: CleanColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Signal Strength',
                    style: GoogleFonts.poppins(
                      color: CleanColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '$signalStrength%',
                    style: GoogleFonts.poppins(
                      color: CleanColors.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: CleanColors.bgHover,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: signalStrength / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [CleanColors.gold, CleanColors.warning],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildStatCard('24H High', '2155.00', CleanColors.profit),
          const SizedBox(width: 12),
          _buildStatCard('24H Low', '2135.00', CleanColors.loss),
          const SizedBox(width: 12),
          _buildStatCard('Volume', '125.4K', CleanColors.info),
          const SizedBox(width: 12),
          _buildStatCard('Trend', trend, CleanColors.warning),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CleanColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CleanColors.borderDefault,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                color: CleanColors.textMuted,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: CleanColors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [CleanColors.gold, CleanColors.warning],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: CleanColors.bgPrimary,
        unselectedLabelColor: CleanColors.textSecondary,
        labelStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'إشارات'),
          Tab(text: 'تحليل'),
          Tab(text: 'مؤشرات'),
          Tab(text: 'إعدادات'),
        ],
      ),
    );
  }

  Widget _buildSignalsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildSignalCard(),
          const SizedBox(height: 16),
          _buildTargetsCard(),
          const SizedBox(height: 16),
          _buildRiskManagementCard(),
          const SizedBox(height: 16),
          _buildRecentSignalsCard(),
        ],
      ),
    );
  }

  Widget _buildSignalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CleanColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CleanColors.loss.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Signal',
                style: GoogleFonts.poppins(
                  color: CleanColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: CleanColors.loss.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: CleanColors.loss.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sell, color: CleanColors.loss, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'SELL',
                      style: GoogleFonts.poppins(
                        color: CleanColors.loss,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSignalRow(
              'Entry Price', entryPrice.toStringAsFixed(2), CleanColors.gold),
          const SizedBox(height: 12),
          _buildSignalRow(
              'Stop Loss', stopLoss.toStringAsFixed(2), CleanColors.loss),
          const SizedBox(height: 12),
          _buildSignalRow('Risk/Reward', '1:3.2', CleanColors.profit),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CleanColors.bgHover,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analysis Note',
                  style: GoogleFonts.poppins(
                    color: CleanColors.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Strong resistance at 2155. RSI showing oversold conditions. Expect short-term bearish momentum.',
                  style: GoogleFonts.poppins(
                    color: CleanColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: CleanColors.textSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTargetsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CleanColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CleanColors.borderDefault,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Take Profit Targets',
            style: GoogleFonts.poppins(
              color: CleanColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildTargetRow('Target 1', takeProfit1.toStringAsFixed(2), 0.7,
              CleanColors.profit),
          const SizedBox(height: 12),
          _buildTargetRow('Target 2', takeProfit2.toStringAsFixed(2), 0.5,
              CleanColors.profit),
          const SizedBox(height: 12),
          _buildTargetRow('Target 3', takeProfit3.toStringAsFixed(2), 0.3,
              CleanColors.profit),
        ],
      ),
    );
  }

  Widget _buildTargetRow(
      String label, String price, double probability, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                color: CleanColors.textSecondary,
                fontSize: 13,
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
        ),
        const SizedBox(height: 6),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: CleanColors.bgHover,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: probability,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRiskManagementCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            CleanColors.bgCard,
            CleanColors.bgSecondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CleanColors.borderDefault,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Risk Management',
                style: GoogleFonts.poppins(
                  color: CleanColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(Icons.shield_outlined, color: CleanColors.warning),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRiskItem('Risk Per Trade', '2%', CleanColors.info),
              _buildRiskItem('Lot Size', '0.05', CleanColors.gold),
              _buildRiskItem('Max Loss', '\$100', CleanColors.loss),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: CleanColors.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSignalsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CleanColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CleanColors.borderDefault,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Signals',
            style: GoogleFonts.poppins(
              color: CleanColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecentSignalRow('14:32', 'SELL', 2148.50, 2145.00, true),
          _buildRecentSignalRow('12:15', 'BUY', 2142.30, 2146.00, true),
          _buildRecentSignalRow('10:45', 'SELL', 2150.00, 2151.00, false),
          _buildRecentSignalRow('09:20', 'BUY', 2138.00, 2144.00, true),
        ],
      ),
    );
  }

  Widget _buildRecentSignalRow(
      String time, String type, double entry, double close, bool profit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CleanColors.bgHover,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            time,
            style: GoogleFonts.poppins(
              color: CleanColors.textMuted,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: type == 'BUY'
                  ? CleanColors.profit.withValues(alpha: 0.15)
                  : CleanColors.loss.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              type,
              style: GoogleFonts.poppins(
                color: type == 'BUY' ? CleanColors.profit : CleanColors.loss,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '@${entry.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              color: CleanColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Icon(
            profit ? Icons.check_circle : Icons.cancel,
            color: profit ? CleanColors.profit : CleanColors.loss,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            profit
                ? '+${(close - entry).toStringAsFixed(2)}'
                : '${(close - entry).toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              color: profit ? CleanColors.profit : CleanColors.loss,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab() {
    return Center(
      child: Text(
        'Technical Analysis',
        style: GoogleFonts.poppins(color: CleanColors.textPrimary),
      ),
    );
  }

  Widget _buildIndicatorsTab() {
    return Center(
      child: Text(
        'Market Indicators',
        style: GoogleFonts.poppins(color: CleanColors.textPrimary),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Center(
      child: Text(
        'Settings',
        style: GoogleFonts.poppins(color: CleanColors.textPrimary),
      ),
    );
  }
}
