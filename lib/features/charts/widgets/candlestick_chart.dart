import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../providers/chart_data_provider.dart';
import '../../../core/theme/app_colors.dart';

class CandlestickChart extends StatelessWidget {
  final List<PricePoint> data;
  final String title;
  final List<SupportResistanceLevel>? supportResistanceLevels;

  // Maximum data points for optimal performance
  static const int _maxDataPoints = 1000;

  const CandlestickChart({
    super.key,
    required this.data,
    this.title = 'XAUUSD',
    this.supportResistanceLevels,
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
      return const Center(
        child: Text('لا توجد بيانات للعرض'),
      );
    }

    final optimizedData = _optimizedData;

    return SfCartesianChart(
      title: ChartTitle(
        text: title,
        textStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.backgroundSecondary,
      plotAreaBackgroundColor: AppColors.backgroundPrimary,
      borderColor: AppColors.borderColor,
      borderWidth: 1,

      // Zoom & Pan
      zoomPanBehavior: ZoomPanBehavior(
        enablePinching: true,
        enablePanning: true,
        enableDoubleTapZooming: true,
        enableSelectionZooming: true,
        zoomMode: ZoomMode.x,
      ),

      // Crosshair
      crosshairBehavior: CrosshairBehavior(
        enable: true,
        activationMode: ActivationMode.longPress,
        lineColor: AppColors.royalGold,
        lineWidth: 1,
        lineDashArray: const [5, 5],
      ),

      // Trackball
      trackballBehavior: TrackballBehavior(
        enable: true,
        activationMode: ActivationMode.singleTap,
        tooltipSettings: const InteractiveTooltip(
          enable: true,
          color: AppColors.backgroundSecondary,
          textStyle: TextStyle(color: AppColors.textPrimary),
        ),
      ),

      // Primary X Axis (Time)
      primaryXAxis: DateTimeAxis(
        dateFormat: optimizedData.length > 24
            ? DateFormat('dd/MM')
            : DateFormat('HH:mm'),
        intervalType: optimizedData.length > 24
            ? DateTimeIntervalType.days
            : DateTimeIntervalType.hours,
        majorGridLines: const MajorGridLines(
          color: AppColors.borderColor,
          width: 0.5,
          dashArray: [5, 5],
        ),
        axisLine: const AxisLine(
          color: AppColors.borderColor,
          width: 1,
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
        ),
      ),

      // Primary Y Axis (Price)
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat('\$#,##0.00'),
        opposedPosition: true,
        majorGridLines: const MajorGridLines(
          color: AppColors.borderColor,
          width: 0.5,
          dashArray: [5, 5],
        ),
        axisLine: const AxisLine(
          color: AppColors.borderColor,
          width: 1,
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
        ),
      ),

      // Series
      series: <CartesianSeries>[
        // Candlestick Series
        CandleSeries<PricePoint, DateTime>(
          dataSource: optimizedData,
          xValueMapper: (PricePoint point, _) => point.timestamp,
          lowValueMapper: (PricePoint point, _) => point.low,
          highValueMapper: (PricePoint point, _) => point.high,
          openValueMapper: (PricePoint point, _) => point.open,
          closeValueMapper: (PricePoint point, _) => point.close,
          name: 'XAUUSD',
          bearColor: AppColors.error,
          bullColor: AppColors.success,
          enableSolidCandles: true,
          borderWidth: 1,
          // Performance optimizations
          animationDuration: 0, // Disable animation for better performance
          enableTooltip: true,
        ),
        // Support/Resistance Lines
        if (supportResistanceLevels != null)
          ...supportResistanceLevels!.map((level) {
            return LineSeries<_HorizontalLinePoint, DateTime>(
              dataSource: [
                _HorizontalLinePoint(
                    optimizedData.first.timestamp, level.price),
                _HorizontalLinePoint(optimizedData.last.timestamp, level.price),
              ],
              xValueMapper: (_HorizontalLinePoint point, _) => point.timestamp,
              yValueMapper: (_HorizontalLinePoint point, _) => point.price,
              color: level.isSupport ? AppColors.success : AppColors.error,
              width: 2,
              dashArray: [5, 5],
              name: level.label,
              enableTooltip: true,
              animationDuration: 0,
            );
          }).toList(),
      ],

      // Legend
      legend: Legend(
        isVisible: supportResistanceLevels != null &&
            supportResistanceLevels!.isNotEmpty,
        position: LegendPosition.bottom,
        textStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
        ),
        iconHeight: 10,
        iconWidth: 10,
      ),
    );
  }
}

/// 📊 Support/Resistance Level Model
class SupportResistanceLevel {
  final double price;
  final bool isSupport;
  final String label;
  final double strength; // 0-1

  const SupportResistanceLevel({
    required this.price,
    required this.isSupport,
    required this.label,
    this.strength = 0.5,
  });
}

/// Internal class for horizontal line rendering
class _HorizontalLinePoint {
  final DateTime timestamp;
  final double price;

  _HorizontalLinePoint(this.timestamp, this.price);
}
