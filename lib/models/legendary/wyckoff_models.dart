/// 📈 Wyckoff Method Models
///
/// موديلات Wyckoff - المراحل الخمس
library;

import 'package:flutter/foundation.dart';

/// Wyckoff Phase - مرحلة Wyckoff
enum WyckoffPhase {
  phaseA, // Selling/Buying Climax
  phaseB, // Building Cause
  phaseC, // Spring/Upthrust (الأهم!)
  phaseD, // Sign of Strength
  phaseE, // Markup/Markdown
}

/// Wyckoff Event - حدث Wyckoff
@immutable
class WyckoffEvent {
  final WyckoffEventType type;
  final double price;
  final DateTime timestamp;
  final String description;

  WyckoffEvent({
    required this.type,
    required this.price,
    required this.timestamp,
    required this.description,
  });
}

enum WyckoffEventType {
  preliminarySupport, // PS
  sellingClimax, // SC
  automaticRally, // AR
  secondaryTest, // ST
  spring, // Spring (فرصة شراء)
  upthrust, // Upthrust (فرصة بيع)
  signOfStrength, // SOS
  lastPointOfSupport, // LPS
  signOfWeakness, // SOW
}

/// Wyckoff Accumulation/Distribution
class WyckoffSchematic {
  final WyckoffSchematicType type;
  final WyckoffPhase currentPhase;
  final List<WyckoffEvent> events;
  final double confidence;

  WyckoffSchematic({
    required this.type,
    required this.currentPhase,
    required this.events,
    required this.confidence,
  });

  bool get isAccumulation => type == WyckoffSchematicType.accumulation;
  bool get isDistribution => type == WyckoffSchematicType.distribution;
  bool get isInSpringPhase => currentPhase == WyckoffPhase.phaseC;
}

enum WyckoffSchematicType {
  accumulation, // تجميع (صعودي)
  distribution, // توزيع (هبوطي)
  reAccumulation, // إعادة تجميع
  reDistribution, // إعادة توزيع
}

/// Volume Spread Analysis (VSA)
class VolumeSpreadAnalysis {
  final double volume;
  final double spread; // الشمعة
  final VSASignal signal;
  final String interpretation;

  VolumeSpreadAnalysis({
    required this.volume,
    required this.spread,
    required this.signal,
    required this.interpretation,
  });
}

enum VSASignal {
  strength, // قوة
  weakness, // ضعف
  noSupply, // لا عرض (صعودي)
  noDemand, // لا طلب (هبوطي)
  effortVsResult, // جهد vs نتيجة
}

/// Wyckoff Analysis Result - نتيجة تحليل Wyckoff
class WyckoffAnalysisResult {
  final WyckoffSchematic? schematic;
  final WyckoffPhase currentPhase;
  final List<WyckoffEvent> recentEvents;
  final VolumeSpreadAnalysis? vsa;
  final String bias;
  final double confidence;
  final bool hasSpring;
  final bool hasUpthrust;

  WyckoffAnalysisResult({
    this.schematic,
    required this.currentPhase,
    required this.recentEvents,
    this.vsa,
    required this.bias,
    required this.confidence,
    required this.hasSpring,
    required this.hasUpthrust,
  });

  Map<String, dynamic> toJson() => {
    'hasSchematic': schematic != null,
    'schematicType': schematic?.type.name,
    'currentPhase': currentPhase.name,
    'recentEventsCount': recentEvents.length,
    'hasVSA': vsa != null,
    'vsaSignal': vsa?.signal.name,
    'bias': bias,
    'confidence': confidence,
    'hasSpring': hasSpring,
    'hasUpthrust': hasUpthrust,
  };
}
