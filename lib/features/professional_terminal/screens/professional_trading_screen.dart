import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/order_book_entry.dart';

// Professional Trading Color Scheme - Inspired by Bloomberg/Reuters
class ProColors {
  // Core Dark Theme
  static const Color backgroundPrimary = Color(0xFF000000);
  static const Color backgroundSecondary = Color(0xFF0A0A0A);
  static const Color backgroundTertiary = Color(0xFF141414);
  static const Color surfaceCard = Color(0xFF1A1A1A);
  static const Color borderSubtle = Color(0xFF2A2A2A);
  static const Color borderStrong = Color(0xFF3A3A3A);

  // Data Colors (High Contrast for Trading)
  static const Color priceUp = Color(0xFF00FF41); // Bright Green
  static const Color priceDown = Color(0xFFFF0040); // Bright Red
  static const Color priceNeutral = Color(0xFFFFB800); // Amber
  static const Color goldPrice = Color(0xFFFFD700); // Gold
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF808080);

  // Accent Colors
  static const Color accentBlue = Color(0xFF0080FF);
  static const Color accentOrange = Color(0xFFFF6B00);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentCyan = Color(0xFF00D9FF);
}

class ProfessionalTradingScreen extends StatefulWidget {
  const ProfessionalTradingScreen({Key? key}) : super(key: key);

  @override
  _ProfessionalTradingScreenState createState() =>
      _ProfessionalTradingScreenState();
}

class _ProfessionalTradingScreenState extends State<ProfessionalTradingScreen>
    with TickerProviderStateMixin {
  late Timer _priceUpdateTimer;
  late AnimationController _blinkController;

  // Market Data
  double currentPrice = 2146.23;
  double previousClose = 2148.41;
  double dayHigh = 2155.00;
  double dayLow = 2135.00;
  double bid = 2146.20;
  double ask = 2146.26;
  double spread = 0.06;
  int volume = 125478;
  double changeAmount = -2.18;
  double changePercent = -0.10;

  // Technical Indicators
  double rsi = 31.3;
  double macd = -2.45;
  double stochastic = 18.5;

  // Order Book Data
  List<OrderBookEntry> bids = [];
  List<OrderBookEntry> asks = [];

  // Price History for Chart
  List<double> priceHistory = [];

  @override
  void initState() {
    super.initState();

    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Initialize fake order book
    _generateOrderBook();

    // Initialize price history
    _generatePriceHistory();

    // Start real-time price updates
    _priceUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updatePrice();
    });
  }

  void _generateOrderBook() {
    bids = List.generate(
        10,
        (i) => OrderBookEntry(
              price: currentPrice - (i * 0.10),
              volume: (math.Random().nextDouble() * 10000 + 1000).round(),
              total: 0,
            ));

    asks = List.generate(
        10,
        (i) => OrderBookEntry(
              price: currentPrice + (i * 0.10),
              volume: (math.Random().nextDouble() * 10000 + 1000).round(),
              total: 0,
            ));

    // Calculate totals
    double bidTotal = 0;
    for (var bid in bids) {
      bidTotal += bid.volume;
      bid.total = bidTotal;
    }

    double askTotal = 0;
    for (var ask in asks) {
      askTotal += ask.volume;
      ask.total = askTotal;
    }
  }

  void _generatePriceHistory() {
    final random = math.Random();
    double basePrice = currentPrice;
    priceHistory = List.generate(50, (i) {
      basePrice += (random.nextDouble() - 0.5) * 2;
      return basePrice;
    });
  }

  void _updatePrice() {
    setState(() {
      // Simulate price movement
      double change = (math.Random().nextDouble() - 0.5) * 0.5;
      currentPrice += change;

      if (priceHistory.length > 50) {
        priceHistory.removeAt(0);
      }
      priceHistory.add(currentPrice);

      changeAmount = currentPrice - previousClose;
      changePercent = (changeAmount / previousClose) * 100;

      // Update order book
      _generateOrderBook();

      // Trigger blink animation
      _blinkController.forward().then((_) {
        _blinkController.reverse();
      });
    });
  }

  @override
  void dispose() {
    _priceUpdateTimer.cancel();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProColors.backgroundPrimary,
      body: Column(
        children: [
          // Professional Header Bar
          _buildProfessionalHeader(),

          // Main Trading Layout
          Expanded(
            child: Row(
              children: [
                // Left Panel - Order Book & Market Depth
                Container(
                  width: 320,
                  color: ProColors.backgroundSecondary,
                  child: Column(
                    children: [
                      _buildMarketDepthHeader(),
                      Expanded(child: _buildOrderBook()),
                      _buildOrderEntry(),
                    ],
                  ),
                ),

                // Center Panel - Chart & Price
                Expanded(
                  child: Column(
                    children: [
                      _buildMainPriceDisplay(),
                      Expanded(child: _buildProfessionalChart()),
                      _buildTechnicalIndicators(),
                    ],
                  ),
                ),

                // Right Panel - Positions & Analysis
                Container(
                  width: 350,
                  color: ProColors.backgroundSecondary,
                  child: Column(
                    children: [
                      _buildPositionsHeader(),
                      _buildActivePositions(),
                      _buildMarketAnalysis(),
                      Expanded(child: _buildNewsAndAlerts()),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Status Bar
          _buildStatusBar(),
        ],
      ),
    );
  }

  Widget _buildProfessionalHeader() {
    return Container(
      height: 40,
      color: ProColors.backgroundTertiary,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Logo and Title
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: ProColors.goldPrice,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'G',
                    style: GoogleFonts.robotoMono(
                      color: ProColors.backgroundPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'GOLD PROFESSIONAL TERMINAL',
                style: GoogleFonts.robotoMono(
                  color: ProColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Market Status Indicators
          Row(
            children: [
              _buildStatusIndicator('MARKET', 'OPEN', ProColors.priceUp),
              const SizedBox(width: 16),
              _buildStatusIndicator('CONNECTION', 'LIVE', ProColors.priceUp),
              const SizedBox(width: 16),
              _buildStatusIndicator('DATA', 'REAL-TIME', ProColors.accentCyan),
            ],
          ),

          const Spacer(),

          // Time Display
          StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context, snapshot) {
              return Text(
                DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
                style: GoogleFonts.robotoMono(
                  color: ProColors.textSecondary,
                  fontSize: 12,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String label, String status, Color color) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $status',
          style: GoogleFonts.robotoMono(
            color: ProColors.textTertiary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildMainPriceDisplay() {
    Color priceColor =
        changeAmount >= 0 ? ProColors.priceUp : ProColors.priceDown;

    return Container(
      height: 100,
      color: ProColors.backgroundTertiary,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Symbol and Price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'XAUUSD - GOLD SPOT',
                  style: GoogleFonts.robotoMono(
                    color: ProColors.textSecondary,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedBuilder(
                  animation: _blinkController,
                  builder: (context, child) {
                    return Container(
                      color: _blinkController.value > 0.5
                          ? priceColor.withValues(alpha: 0.2)
                          : Colors.transparent,
                      child: Text(
                        currentPrice.toStringAsFixed(2),
                        style: GoogleFonts.robotoMono(
                          color: priceColor,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      changeAmount >= 0
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: priceColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${changeAmount >= 0 ? '+' : ''}${changeAmount.toStringAsFixed(2)} (${changePercent.toStringAsFixed(2)}%)',
                      style: GoogleFonts.robotoMono(
                        color: priceColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Market Statistics Grid
          SizedBox(
            width: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    _buildStatItem(
                        'BID', bid.toStringAsFixed(2), ProColors.priceUp),
                    const SizedBox(width: 16),
                    _buildStatItem(
                        'ASK', ask.toStringAsFixed(2), ProColors.priceDown),
                    const SizedBox(width: 16),
                    _buildStatItem('SPREAD', spread.toStringAsFixed(3),
                        ProColors.priceNeutral),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatItem('HIGH', dayHigh.toStringAsFixed(2),
                        ProColors.textSecondary),
                    const SizedBox(width: 16),
                    _buildStatItem('LOW', dayLow.toStringAsFixed(2),
                        ProColors.textSecondary),
                    const SizedBox(width: 16),
                    _buildStatItem(
                        'VOLUME',
                        NumberFormat.compact().format(volume),
                        ProColors.textSecondary),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.robotoMono(
              color: ProColors.textTertiary,
              fontSize: 9,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.robotoMono(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalChart() {
    return Container(
      color: ProColors.backgroundSecondary,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 1,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return const FlLine(
                color: ProColors.borderSubtle,
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return const FlLine(
                color: ProColors.borderSubtle,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(0),
                    style: GoogleFonts.robotoMono(
                      color: ProColors.textTertiary,
                      fontSize: 10,
                    ),
                  );
                },
                reservedSize: 45,
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: GoogleFonts.robotoMono(
                      color: ProColors.textTertiary,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: ProColors.borderStrong, width: 1),
          ),
          minX: 0,
          maxX: priceHistory.length.toDouble() - 1,
          minY: priceHistory.reduce(math.min) - 5,
          maxY: priceHistory.reduce(math.max) + 5,
          lineBarsData: [
            LineChartBarData(
              spots: priceHistory.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value);
              }).toList(),
              isCurved: true,
              gradient: const LinearGradient(
                colors: [ProColors.goldPrice, ProColors.accentOrange],
              ),
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    ProColors.goldPrice.withValues(alpha: 0.15),
                    ProColors.goldPrice.withValues(alpha: 0.15),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalIndicators() {
    return Container(
      height: 80,
      color: ProColors.backgroundTertiary,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _buildIndicatorCard(
              'RSI',
              rsi.toStringAsFixed(1),
              rsi < 30
                  ? ProColors.priceUp
                  : rsi > 70
                      ? ProColors.priceDown
                      : ProColors.priceNeutral),
          const SizedBox(width: 12),
          _buildIndicatorCard('MACD', macd.toStringAsFixed(2),
              macd > 0 ? ProColors.priceUp : ProColors.priceDown),
          const SizedBox(width: 12),
          _buildIndicatorCard(
              'STOCH',
              stochastic.toStringAsFixed(1),
              stochastic < 20
                  ? ProColors.priceUp
                  : stochastic > 80
                      ? ProColors.priceDown
                      : ProColors.priceNeutral),
          const SizedBox(width: 12),
          _buildIndicatorCard('MA(50)', '2145.80', ProColors.accentBlue),
          const SizedBox(width: 12),
          _buildIndicatorCard('MA(200)', '2142.30', ProColors.accentPurple),
        ],
      ),
    );
  }

  Widget _buildIndicatorCard(String name, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ProColors.surfaceCard,
          border: Border.all(color: ProColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: GoogleFonts.robotoMono(
                color: ProColors.textTertiary,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.robotoMono(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketDepthHeader() {
    return Container(
      height: 40,
      color: ProColors.backgroundTertiary,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Text(
            'عمق السوق',
            style: GoogleFonts.cairo(
              color: ProColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            'LEVEL II',
            style: GoogleFonts.robotoMono(
              color: ProColors.accentCyan,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderBook() {
    return Container(
      color: ProColors.surfaceCard,
      child: Column(
        children: [
          // Header
          Container(
            height: 30,
            color: ProColors.backgroundTertiary,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(child: Text('السعر', style: _headerStyle())),
                Expanded(
                    child: Text('الحجم',
                        style: _headerStyle(), textAlign: TextAlign.center)),
                Expanded(
                    child: Text('الإجمالي',
                        style: _headerStyle(), textAlign: TextAlign.end)),
              ],
            ),
          ),

          // Asks (Sell Orders)
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: asks.length,
              itemBuilder: (context, index) {
                return _buildOrderBookRow(asks[index], false);
              },
            ),
          ),

          // Current Price Divider
          Container(
            height: 40,
            color: ProColors.backgroundPrimary,
            child: Center(
              child: Text(
                currentPrice.toStringAsFixed(2),
                style: GoogleFonts.robotoMono(
                  color: ProColors.goldPrice,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Bids (Buy Orders)
          Expanded(
            child: ListView.builder(
              itemCount: bids.length,
              itemBuilder: (context, index) {
                return _buildOrderBookRow(bids[index], true);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderBookRow(OrderBookEntry entry, bool isBid) {
    Color color = isBid ? ProColors.priceUp : ProColors.priceDown;

    return Container(
      height: 24,
      color: color.withValues(alpha: 0.15),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              entry.price.toStringAsFixed(2),
              style: GoogleFonts.robotoMono(
                color: color,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              NumberFormat.compact().format(entry.volume),
              style: GoogleFonts.robotoMono(
                color: ProColors.textSecondary,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              NumberFormat.compact().format(entry.total),
              style: GoogleFonts.robotoMono(
                color: ProColors.textTertiary,
                fontSize: 11,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderEntry() {
    return Container(
      height: 120,
      color: ProColors.backgroundTertiary,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ProColors.priceUp,
                    foregroundColor: ProColors.backgroundPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  child: Text('شراء',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ProColors.priceDown,
                    foregroundColor: ProColors.textPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  child: Text('بيع',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: ProColors.surfaceCard,
                    border: Border.all(color: ProColors.borderSubtle),
                  ),
                  child: Center(
                    child: Text(
                      'LOT: 0.01',
                      style: GoogleFonts.robotoMono(
                        color: ProColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: ProColors.surfaceCard,
                    border: Border.all(color: ProColors.borderSubtle),
                  ),
                  child: Center(
                    child: Text(
                      'SL: 50',
                      style: GoogleFonts.robotoMono(
                        color: ProColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: ProColors.surfaceCard,
                    border: Border.all(color: ProColors.borderSubtle),
                  ),
                  child: Center(
                    child: Text(
                      'TP: 100',
                      style: GoogleFonts.robotoMono(
                        color: ProColors.textSecondary,
                        fontSize: 12,
                      ),
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

  Widget _buildPositionsHeader() {
    return Container(
      height: 40,
      color: ProColors.backgroundTertiary,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Text(
            'المراكز المفتوحة',
            style: GoogleFonts.cairo(
              color: ProColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            'P&L: +\$1,234.56',
            style: GoogleFonts.robotoMono(
              color: ProColors.priceUp,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePositions() {
    return Container(
      height: 150,
      color: ProColors.surfaceCard,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildPositionRow('SELL', 0.05, 2148.50, 2146.23, 113.50, true),
          _buildPositionRow('BUY', 0.02, 2142.30, 2146.23, 78.60, true),
          _buildPositionRow('SELL', 0.01, 2146.80, 2146.23, 5.70, true),
        ],
      ),
    );
  }

  Widget _buildPositionRow(String type, double lot, double entry,
      double current, double pl, bool isProfit) {
    Color plColor = isProfit ? ProColors.priceUp : ProColors.priceDown;

    return Container(
      height: 36,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: ProColors.backgroundSecondary,
        border: Border.all(color: ProColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: type == 'BUY'
                  ? ProColors.priceUp.withValues(alpha: 0.15)
                  : ProColors.priceDown.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              type,
              style: GoogleFonts.robotoMono(
                color: type == 'BUY' ? ProColors.priceUp : ProColors.priceDown,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            lot.toString(),
            style: GoogleFonts.robotoMono(
                color: ProColors.textSecondary, fontSize: 11),
          ),
          const Spacer(),
          Text(
            '@${entry.toStringAsFixed(2)}',
            style: GoogleFonts.robotoMono(
                color: ProColors.textTertiary, fontSize: 11),
          ),
          const SizedBox(width: 12),
          Text(
            '${isProfit ? '+' : ''}\$${pl.toStringAsFixed(2)}',
            style: GoogleFonts.robotoMono(
              color: plColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketAnalysis() {
    return Container(
      height: 180,
      color: ProColors.backgroundTertiary,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'التحليل الآلي',
            style: GoogleFonts.cairo(
              color: ProColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ProColors.surfaceCard,
              border:
                  Border.all(color: ProColors.priceDown.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: ProColors.priceDown.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        'بيع قوي',
                        style: GoogleFonts.cairo(
                          color: ProColors.priceDown,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'الثقة: 87%',
                      style: GoogleFonts.cairo(
                        color: ProColors.accentOrange,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• السعر تحت المتوسطات المتحركة الرئيسية',
                  style: GoogleFonts.cairo(
                    color: ProColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                Text(
                  '• مؤشر RSI في منطقة ذروة البيع',
                  style: GoogleFonts.cairo(
                    color: ProColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                Text(
                  '• احتمال ارتداد قصير المدى عند 2142.00',
                  style: GoogleFonts.cairo(
                    color: ProColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildTargetChip('TP1: 2135.00', ProColors.priceUp),
                    const SizedBox(width: 8),
                    _buildTargetChip('TP2: 2128.00', ProColors.priceUp),
                    const SizedBox(width: 8),
                    _buildTargetChip('SL: 2155.00', ProColors.priceDown),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label,
        style: GoogleFonts.robotoMono(
          color: color,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildNewsAndAlerts() {
    return Container(
      color: ProColors.surfaceCard,
      child: Column(
        children: [
          Container(
            height: 32,
            color: ProColors.backgroundTertiary,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text(
                  'الأخبار والتنبيهات',
                  style: GoogleFonts.cairo(
                    color: ProColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.notifications_active,
                    color: ProColors.accentOrange, size: 16),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                _buildNewsItem('14:32', 'تصريحات الفيدرالي تدعم الدولار',
                    ProColors.priceDown),
                _buildNewsItem(
                    '14:15', 'ارتفاع مخزونات الذهب في ETF', ProColors.priceUp),
                _buildNewsItem('13:45', 'بيانات التضخم أعلى من المتوقع',
                    ProColors.priceDown),
                _buildNewsItem('13:20', 'توترات جيوسياسية تدعم الملاذات',
                    ProColors.priceUp),
                _buildNewsItem('12:55', 'تنبيه: اختراق مستوى 2145.00',
                    ProColors.accentCyan),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsItem(String time, String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: ProColors.backgroundSecondary,
        border: Border(
          left: BorderSide(color: color, width: 2),
        ),
      ),
      child: Row(
        children: [
          Text(
            time,
            style: GoogleFonts.robotoMono(
              color: ProColors.textTertiary,
              fontSize: 10,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.cairo(
                color: ProColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      height: 24,
      color: ProColors.backgroundTertiary,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            'ACCOUNT: \$50,000.00',
            style: GoogleFonts.robotoMono(
                color: ProColors.textTertiary, fontSize: 10),
          ),
          const SizedBox(width: 16),
          Text(
            'EQUITY: \$51,234.56',
            style:
                GoogleFonts.robotoMono(color: ProColors.priceUp, fontSize: 10),
          ),
          const SizedBox(width: 16),
          Text(
            'MARGIN: \$1,245.00',
            style: GoogleFonts.robotoMono(
                color: ProColors.textTertiary, fontSize: 10),
          ),
          const SizedBox(width: 16),
          Text(
            'FREE: \$48,755.00',
            style: GoogleFonts.robotoMono(
                color: ProColors.textTertiary, fontSize: 10),
          ),
          const Spacer(),
          Text(
            'PING: 12ms',
            style:
                GoogleFonts.robotoMono(color: ProColors.priceUp, fontSize: 10),
          ),
          const SizedBox(width: 16),
          Text(
            'SERVER: LONDON-01',
            style: GoogleFonts.robotoMono(
                color: ProColors.textTertiary, fontSize: 10),
          ),
        ],
      ),
    );
  }

  TextStyle _headerStyle() {
    return GoogleFonts.cairo(
      color: ProColors.textTertiary,
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );
  }
}
