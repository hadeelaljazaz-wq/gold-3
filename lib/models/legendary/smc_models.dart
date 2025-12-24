/// 📊 Smart Money Concepts Models
///
/// موديلات SMC - Order Blocks, FVG, BOS, CHoCH
library;

import 'package:flutter/foundation.dart';

enum TrendDirection { bullish, bearish, neutral }

/// Order Block - كتلة الأوامر المؤسسية
@immutable
class OrderBlock {
  final double high;
  final double low;
  final OrderBlockType type;
  final double strength;
  final DateTime timestamp;

  OrderBlock({
    required this.high,
    required this.low,
    required this.type,
    required this.strength,
    required this.timestamp,
  });

  double get size => high - low;
  bool isPriceInside(double price) => price >= low && price <= high;
}

enum OrderBlockType { bullish, bearish }

/// Fair Value Gap - فجوة القيمة العادلة
class FairValueGap {
  final double high;
  final double low;
  final FVGType type;
  final bool isFilled;

  FairValueGap({
    required this.high,
    required this.low,
    required this.type,
    required this.isFilled,
  });

  double get size => high - low;
}

enum FVGType { bullish, bearish }

/// Liquidity Pool - مناطق السيولة
class LiquidityPool {
  final double level;
  final LiquidityType type;
  final int touches;

  LiquidityPool({
    required this.level,
    required this.type,
    required this.touches,
  });
}

enum LiquidityType { buyStop, sellStop }

/// Market Structure - بنية السوق
class MarketStructure {
  final TrendDirection trend;
  final List<double> swingHighs;
  final List<double> swingLows;
  final bool hasHigherHighs;
  final bool hasHigherLows;
  final bool hasLowerHighs;
  final bool hasLowerLows;

  MarketStructure({
    required this.trend,
    required this.swingHighs,
    required this.swingLows,
    required this.hasHigherHighs,
    required this.hasHigherLows,
    required this.hasLowerHighs,
    required this.hasLowerLows,
  });

  bool get isUptrend => hasHigherHighs && hasHigherLows;
  bool get isDowntrend => hasLowerHighs && hasLowerLows;
}

/// SMC Analysis Result - نتيجة تحليل SMC
class SMCAnalysisResult {
  final List<OrderBlock> orderBlocks;
  final List<FairValueGap> fairValueGaps;
  final List<LiquidityPool> liquidityPools;
  final MarketStructure marketStructure;
  final bool hasBOS;
  final bool hasCHOCH;
  final TrendDirection bias;
  final double confidence;

  SMCAnalysisResult({
    required this.orderBlocks,
    required this.fairValueGaps,
    required this.liquidityPools,
    required this.marketStructure,
    required this.hasBOS,
    required this.hasCHOCH,
    required this.bias,
    required this.confidence,
  });

  Map<String, dynamic> toJson() => {
    'orderBlocksCount': orderBlocks.length,
    'fvgCount': fairValueGaps.length,
    'liquidityPoolsCount': liquidityPools.length,
    'trend': marketStructure.trend.name,
    'hasBOS': hasBOS,
    'hasCHOCH': hasCHOCH,
    'bias': bias.name,
    'confidence': confidence,
  };
}
