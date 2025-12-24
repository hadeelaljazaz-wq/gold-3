import 'package:hive/hive.dart';
import '../core/utils/type_converter.dart';

part 'trade_record.g.dart';

/// 📊 Trade Record Model
///
/// نموذج سجل الصفقة مع دعم Hive للحفظ المحلي
@HiveType(typeId: 11)
class TradeRecord extends HiveObject {
  /// Unique ID
  @HiveField(0)
  final String id;

  /// Trade type (scalp or swing)
  @HiveField(1)
  final String type;

  /// Signal direction (BUY or SELL)
  @HiveField(2)
  final String direction;

  /// Entry price
  @HiveField(3)
  final double entryPrice;

  /// Stop loss
  @HiveField(4)
  final double stopLoss;

  /// Take profit targets
  @HiveField(5)
  final List<double> takeProfit;

  /// Entry timestamp
  @HiveField(6)
  final DateTime entryTime;

  /// Exit timestamp (null if still open)
  @HiveField(7)
  final DateTime? exitTime;

  /// Exit price (null if still open)
  @HiveField(8)
  final double? exitPrice;

  /// Status (open, closed, cancelled)
  @HiveField(9)
  final String status;

  /// Profit/Loss in USD
  @HiveField(10)
  final double? profitLoss;

  /// Profit/Loss percentage
  @HiveField(11)
  final double? profitLossPercent;

  /// Notes
  @HiveField(12)
  final String? notes;

  /// Engine used (golden_nightmare, scalping_v2, swing_v2)
  @HiveField(13)
  final String engine;

  /// Strictness level
  @HiveField(14)
  final String strictness;

  TradeRecord({
    required this.id,
    required this.type,
    required this.direction,
    required this.entryPrice,
    required this.stopLoss,
    required this.takeProfit,
    required this.entryTime,
    this.exitTime,
    this.exitPrice,
    this.status = 'open',
    this.profitLoss,
    this.profitLossPercent,
    this.notes,
    required this.engine,
    required this.strictness,
  });

  /// Create from signal
  factory TradeRecord.fromSignal({
    required String type,
    required String direction,
    required double entryPrice,
    required double stopLoss,
    required List<double> takeProfit,
    required String engine,
    required String strictness,
  }) {
    return TradeRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      direction: direction,
      entryPrice: entryPrice,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
      entryTime: DateTime.now(),
      engine: engine,
      strictness: strictness,
    );
  }

  /// Close trade
  TradeRecord close({
    required double exitPrice,
    String? notes,
  }) {
    final pl = _calculateProfitLoss(exitPrice);
    final plPercent = _calculateProfitLossPercent(exitPrice);

    return TradeRecord(
      id: id,
      type: type,
      direction: direction,
      entryPrice: entryPrice,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
      entryTime: entryTime,
      exitTime: DateTime.now(),
      exitPrice: exitPrice,
      status: 'closed',
      profitLoss: pl,
      profitLossPercent: plPercent,
      notes: notes ?? this.notes,
      engine: engine,
      strictness: strictness,
    );
  }

  /// Cancel trade
  TradeRecord cancel({String? notes}) {
    return TradeRecord(
      id: id,
      type: type,
      direction: direction,
      entryPrice: entryPrice,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
      entryTime: entryTime,
      exitTime: DateTime.now(),
      exitPrice: entryPrice,
      status: 'cancelled',
      profitLoss: 0,
      profitLossPercent: 0,
      notes: notes ?? this.notes,
      engine: engine,
      strictness: strictness,
    );
  }

  /// Calculate profit/loss
  double _calculateProfitLoss(double exitPrice) {
    if (direction == 'BUY') {
      return exitPrice - entryPrice;
    } else {
      return entryPrice - exitPrice;
    }
  }

  /// Calculate profit/loss percentage
  double _calculateProfitLossPercent(double exitPrice) {
    final pl = _calculateProfitLoss(exitPrice);
    return (pl / entryPrice) * 100;
  }

  /// Is profitable
  bool get isProfitable => (profitLoss ?? 0) > 0;

  /// Is open
  bool get isOpen => status == 'open';

  /// Duration in hours
  double get durationHours {
    final end = exitTime ?? DateTime.now();
    return end.difference(entryTime).inMinutes / 60;
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'direction': direction,
      'entryPrice': entryPrice,
      'stopLoss': stopLoss,
      'takeProfit': takeProfit,
      'entryTime': entryTime.toIso8601String(),
      'exitTime': exitTime?.toIso8601String(),
      'exitPrice': exitPrice,
      'status': status,
      'profitLoss': profitLoss,
      'profitLossPercent': profitLossPercent,
      'notes': notes,
      'engine': engine,
      'strictness': strictness,
    };
  }

  /// From JSON
  factory TradeRecord.fromJson(Map<String, dynamic> json) {
    return TradeRecord(
      id: json['id'],
      type: json['type'],
      direction: json['direction'],
      entryPrice: TypeConverter.safeToDouble(json['entryPrice']) ?? 0.0,
      stopLoss: TypeConverter.safeToDouble(json['stopLoss']) ?? 0.0,
      takeProfit: TypeConverter.safeToListOfDoubles(json['takeProfit'] as List? ?? []),
      entryTime: DateTime.parse(json['entryTime']),
      exitTime:
          json['exitTime'] != null ? DateTime.parse(json['exitTime']) : null,
      exitPrice: TypeConverter.safeToDouble(json['exitPrice']),
      status: json['status'] ?? 'open',
      profitLoss: TypeConverter.safeToDouble(json['profitLoss']),
      profitLossPercent: TypeConverter.safeToDouble(json['profitLossPercent']),
      notes: json['notes'],
      engine: json['engine'],
      strictness: json['strictness'],
    );
  }

  @override
  String toString() {
    return 'TradeRecord(id: $id, type: $type, direction: $direction, status: $status, P/L: $profitLoss)';
  }
}
