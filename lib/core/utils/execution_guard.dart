import 'dart:async';
import 'logger.dart';

/// 🔒 Execution Guard - يمنع تشغيل متزامن للعمليات الثقيلة
class ExecutionGuard {
  final Map<String, Completer<void>> _locks = {};

  /// محاولة الحصول على القفل؛ يعيد false إذا كان محجوز
  bool tryAcquire(String key) {
    if (_locks.containsKey(key)) {
      AppLogger.warn('🔒 Execution blocked: $key already running');
      return false;
    }

    _locks[key] = Completer<void>();
    AppLogger.info('🔓 Execution lock acquired: $key');
    return true;
  }

  /// تحرير القفل
  void release(String key) {
    final completer = _locks.remove(key);
    if (completer != null && !completer.isCompleted) {
      completer.complete();
      AppLogger.info('🔓 Execution lock released: $key');
    }
  }

  /// انتظار حتى يتحرر القفل
  Future<void> waitForRelease(String key) async {
    final completer = _locks[key];
    if (completer != null) {
      AppLogger.info('⏳ Waiting for lock release: $key');
      await completer.future;
    }
  }

  /// هل القفل محجوز؟
  bool isLocked(String key) => _locks.containsKey(key);
}
