/// 🎓 ICT Methodology Models
///
/// موديلات ICT - OTE, Breaker Blocks, Kill Zones
library;

import 'package:flutter/foundation.dart';

/// Optimal Trade Entry - نقطة الدخول المثالية
@immutable
class OptimalTradeEntry {
  final double fibLevel; // 0.618 - 0.786
  final double entryPrice;
  final OTEType type;
  final double confidence;

  OptimalTradeEntry({
    required this.fibLevel,
    required this.entryPrice,
    required this.type,
    required this.confidence,
  });

  bool get isValid => fibLevel >= 0.618 && fibLevel <= 0.786;
}

enum OTEType { bullish, bearish }

/// Breaker Block - كتلة كاسرة
class BreakerBlock {
  final double high;
  final double low;
  final BreakerType type;
  final bool wasResistance;
  final bool wasSupport;

  BreakerBlock({
    required this.high,
    required this.low,
    required this.type,
    required this.wasResistance,
    required this.wasSupport,
  });
}

enum BreakerType { bullish, bearish }

/// Mitigation Block - كتلة التخفيف
class MitigationBlock {
  final double high;
  final double low;
  final MitigationType type;

  MitigationBlock({required this.high, required this.low, required this.type});
}

enum MitigationType { bullish, bearish }

/// Kill Zone Status - حالة المنطقة الزمنية
class KillZoneStatus {
  final KillZone currentZone;
  final bool isActive;
  final String description;

  KillZoneStatus({
    required this.currentZone,
    required this.isActive,
    required this.description,
  });
}

enum KillZone {
  asian, // 00:00-02:00 UTC (ضعيف)
  londonOpen, // 02:00-05:00 UTC (قوي)
  londonClose, // 11:00-12:00 UTC (متوسط)
  nyOpen, // 13:00-16:00 UTC (قوي جداً)
  other, // باقي الأوقات
}

/// Market Maker Model - نموذج صانع السوق
class MarketMakerModel {
  final MMPhase phase;
  final String description;
  final bool isManipulation;

  MarketMakerModel({
    required this.phase,
    required this.description,
    required this.isManipulation,
  });
}

enum MMPhase {
  accumulation, // تجميع
  manipulation, // تلاعب
  distribution, // توزيع
  reAccumulation, // إعادة تجميع
}

/// ICT Analysis Result - نتيجة تحليل ICT
class ICTAnalysisResult {
  final OptimalTradeEntry? ote;
  final List<BreakerBlock> breakerBlocks;
  final List<MitigationBlock> mitigationBlocks;
  final KillZoneStatus killZoneStatus;
  final MarketMakerModel? mmModel;
  final String bias;
  final double confidence;

  ICTAnalysisResult({
    this.ote,
    required this.breakerBlocks,
    required this.mitigationBlocks,
    required this.killZoneStatus,
    this.mmModel,
    required this.bias,
    required this.confidence,
  });

  Map<String, dynamic> toJson() => {
    'hasOTE': ote != null,
    'oteFibLevel': ote?.fibLevel,
    'breakerBlocksCount': breakerBlocks.length,
    'mitigationBlocksCount': mitigationBlocks.length,
    'killZone': killZoneStatus.currentZone.name,
    'isKillZoneActive': killZoneStatus.isActive,
    'hasMMModel': mmModel != null,
    'mmPhase': mmModel?.phase.name,
    'bias': bias,
    'confidence': confidence,
  };
}
