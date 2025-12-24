import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/chart_data_provider.dart';
import '../../../core/theme/app_colors.dart';

class IndicatorsChart extends StatelessWidget {
  final List<PricePoint> data;
  final String indicator; // 'RSI', 'MACD', 'Volume'

  // Maximum data points for optimal performance
  static const int _maxDataPoints = 500;

  const IndicatorsChart({
    super.key,
    required this.data,
    required this.indicator,
  });

  /// Sample data if too large for better performance
  List<PricePoint> get _optimizedData {
    if (data.length <= _maxDataPoints) {
      return data;
    }

    // Sample data: take every Nth point
    final step = (data.length / _maxDataPoints).ceil();
    return List.generate(
      _maxDataPoints,
      (index) => data[index * step],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('لا توجد بيانات'));
    }

    // Use optimized data for better performance
    // ignore: unused_local_variable
    final chartData = _optimizedData;
    switch (indicator) {
      case 'RSI':
        return _buildRSIChart();
      case 'MACD':
        return _buildMACDChart();
      case 'Volume':
        return _buildVolumeChart();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildRSIChart() {
    // حساب RSI (مبسط)
    final rsiValues = _calculateRSI(_optimizedData);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RSI (14)',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.borderColor.withValues(alpha: 0.3),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  // RSI Line
                  LineChartBarData(
                    spots: rsiValues.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value);
                    }).toList(),
                    isCurved: true,
                    color: AppColors.royalGold,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.royalGold.withValues(alpha: 0.1),
                    ),
                  ),
                ],
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    // Overbought (70)
                    HorizontalLine(
                      y: 70,
                      color: AppColors.error.withValues(alpha: 0.5),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                    // Oversold (30)
                    HorizontalLine(
                      y: 30,
                      color: AppColors.success.withValues(alpha: 0.5),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('Overbought (70)', AppColors.error),
              _buildLegendItem('Oversold (30)', AppColors.success),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMACDChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: const Column(
        children: [
          Text(
            'MACD',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          SizedBox(
            height: 150,
            child: Center(
              child: Text(
                'MACD Chart (قيد التطوير)',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Volume',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: _optimizedData.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.volume,
                        color: entry.value.close > entry.value.open
                            ? AppColors.success.withValues(alpha: 0.5)
                            : AppColors.error.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  /// Calculate RSI (simplified)
  List<double> _calculateRSI(List<PricePoint> data, {int period = 14}) {
    if (data.length < period + 1) {
      return List.filled(data.length, 50.0);
    }

    final rsi = <double>[];

    for (int i = 0; i < data.length; i++) {
      if (i < period) {
        rsi.add(50.0); // Default neutral value
        continue;
      }

      double gains = 0;
      double losses = 0;

      for (int j = i - period + 1; j <= i; j++) {
        final change = data[j].close - data[j - 1].close;
        if (change > 0) {
          gains += change;
        } else {
          losses += change.abs();
        }
      }

      final avgGain = gains / period;
      final avgLoss = losses / period;

      if (avgLoss == 0) {
        rsi.add(100.0);
      } else {
        final rs = avgGain / avgLoss;
        rsi.add(100 - (100 / (1 + rs)));
      }
    }

    return rsi;
  }
}
