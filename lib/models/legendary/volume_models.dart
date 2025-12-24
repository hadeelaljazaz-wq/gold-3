/// 📊 Volume Profile Models
///
/// موديلات Volume Profile - POC, VAH, VAL, Volume Nodes
library;

import 'package:flutter/foundation.dart';

/// Volume Profile - ملف الحجم
@immutable
class VolumeProfile {
  final double poc; // Point of Control
  final double vah; // Value Area High
  final double val; // Value Area Low
  final List<VolumeNode> highVolumeNodes;
  final List<VolumeNode> lowVolumeNodes;
  final double totalVolume;

  VolumeProfile({
    required this.poc,
    required this.vah,
    required this.val,
    required this.highVolumeNodes,
    required this.lowVolumeNodes,
    required this.totalVolume,
  });

  double get valueAreaRange => vah - val;
  bool isPriceInValueArea(double price) => price >= val && price <= vah;
  bool isPriceAtPOC(double price, double threshold) =>
      (price - poc).abs() <= threshold;
}

/// Volume Node - نقطة حجم
class VolumeNode {
  final double priceLevel;
  final double volume;
  final VolumeNodeType type;

  VolumeNode({
    required this.priceLevel,
    required this.volume,
    required this.type,
  });
}

enum VolumeNodeType {
  high, // حجم عالي (دعم/مقاومة قوية)
  low, // حجم منخفض (حركة سريعة متوقعة)
  poc, // نقطة التحكم
}

/// Volume Delta - فرق الحجم
class VolumeDelta {
  final double buyVolume;
  final double sellVolume;
  final double delta;
  final DeltaSignal signal;

  VolumeDelta({required this.buyVolume, required this.sellVolume})
    : delta = buyVolume - sellVolume,
      signal = buyVolume > sellVolume
          ? DeltaSignal.bullish
          : buyVolume < sellVolume
          ? DeltaSignal.bearish
          : DeltaSignal.neutral;

  bool get isBullish => signal == DeltaSignal.bullish;
  bool get isBearish => signal == DeltaSignal.bearish;
}

enum DeltaSignal { bullish, bearish, neutral }

/// Volume Cluster - تجمع الحجم
class VolumeCluster {
  final double highPrice;
  final double lowPrice;
  final double totalVolume;
  final ClusterType type;

  VolumeCluster({
    required this.highPrice,
    required this.lowPrice,
    required this.totalVolume,
    required this.type,
  });

  double get range => highPrice - lowPrice;
}

enum ClusterType {
  resistance, // مقاومة (حجم بيع عالي)
  support, // دعم (حجم شراء عالي)
  congestion, // احتقان (حجم متساوي)
}

/// Volume Trend - اتجاه الحجم
class VolumeTrend {
  final bool isIncreasing;
  final double averageVolume;
  final double currentVolume;
  final double volumeChange;

  VolumeTrend({
    required this.isIncreasing,
    required this.averageVolume,
    required this.currentVolume,
  }) : volumeChange = ((currentVolume - averageVolume) / averageVolume * 100);

  bool get isAboveAverage => currentVolume > averageVolume;
  bool get isSignificantIncrease => volumeChange > 50;
}

/// Volume Analysis Result - نتيجة تحليل الحجم
class VolumeAnalysisResult {
  final VolumeProfile profile;
  final VolumeDelta? delta;
  final List<VolumeCluster> clusters;
  final VolumeTrend trend;
  final String interpretation;
  final double confidence;
  final String bias;

  VolumeAnalysisResult({
    required this.profile,
    this.delta,
    required this.clusters,
    required this.trend,
    required this.interpretation,
    required this.confidence,
    required this.bias,
  });

  Map<String, dynamic> toJson() => {
    'poc': profile.poc,
    'vah': profile.vah,
    'val': profile.val,
    'highVolumeNodesCount': profile.highVolumeNodes.length,
    'lowVolumeNodesCount': profile.lowVolumeNodes.length,
    'hasDelta': delta != null,
    'deltaSignal': delta?.signal.name,
    'clustersCount': clusters.length,
    'volumeIsIncreasing': trend.isIncreasing,
    'volumeChange': trend.volumeChange,
    'interpretation': interpretation,
    'confidence': confidence,
    'bias': bias,
  };
}
