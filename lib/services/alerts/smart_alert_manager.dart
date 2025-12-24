import 'dart:async';
import '../../models/advanced/alert_models.dart';

/// SmartAlertManager - إدارة التنبيهات الذكية
class SmartAlertManager {
  static final SmartAlertManager _instance = SmartAlertManager._internal();

  final List<PriceAlert> _alerts = [];
  final _alertController = StreamController<Alert>.broadcast();

  SmartAlertManager._internal();

  factory SmartAlertManager() => _instance;

  Stream<Alert> get alertStream => _alertController.stream;

  /// إضافة تنبيه سعر
  void addPriceAlert({
    required double price,
    required AlertType type,
    required String label,
  }) {
    _alerts.add(PriceAlert(
      price: price,
      type: type,
      label: label,
      createdAt: DateTime.now(),
    ));

    print('➕ Price alert added: $label at $price');
  }

  /// فحص التنبيهات
  void checkAlerts(double currentPrice) {
    for (final alert in _alerts) {
      bool triggered = false;

      switch (alert.type) {
        case AlertType.priceAbove:
          triggered = currentPrice >= alert.price;
          break;
        case AlertType.priceBelow:
          triggered = currentPrice <= alert.price;
          break;
        case AlertType.priceBreakAbove:
          triggered = currentPrice > alert.price;
          break;
        case AlertType.priceBreakBelow:
          triggered = currentPrice < alert.price;
          break;
      }

      if (triggered && !alert.triggered) {
        alert.triggered = true;

        final alertEvent = Alert(
          title: alert.label,
          message: 'السعر الحالي: \$${currentPrice.toStringAsFixed(2)}',
          type: alert.type,
          timestamp: DateTime.now(),
          priority: AlertPriority.high,
        );

        _alertController.add(alertEvent);
        _sendNotification(alertEvent);
        print('🔔 Alert triggered: ${alert.label}');
      }
    }
  }

  void _sendNotification(Alert alert) {
    // سيتم التطبيق الفعلي لاحقاً مع Push Notifications
    print('📢 Notification: ${alert.title} - ${alert.message}');
  }

  /// إزالة تنبيه
  void removeAlert(PriceAlert alert) {
    _alerts.remove(alert);
    print('❌ Alert removed: ${alert.label}');
  }

  /// احصل على جميع التنبيهات
  List<PriceAlert> get alerts => List.unmodifiable(_alerts);

  /// احصل على التنبيهات النشطة
  List<PriceAlert> get activeAlerts =>
      _alerts.where((a) => !a.triggered).toList();

  /// مسح جميع التنبيهات
  void clearAllAlerts() {
    _alerts.clear();
    print('🗑️ All alerts cleared');
  }

  void dispose() {
    _alertController.close();
  }
}

