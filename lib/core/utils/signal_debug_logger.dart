/// 🔍 Signal Debug Logger
///
/// أداة لتسجيل وفحص التوصيات بدقة للكشف عن أي تناقضات

import 'logger.dart';

class SignalDebugLogger {
  /// تسجيل إشارة السكالبينج مع فحص شامل
  static void logScalpingSignal({
    required String direction,
    required double entryPrice,
    required double stopLoss,
    required double takeProfit,
    required int confidence,
    String? source,
  }) {
    final isBuy = direction.toUpperCase() == 'BUY';
    final isSell = direction.toUpperCase() == 'SELL';
    
    // ✅ فحص المنطق
    bool isValid = true;
    final errors = <String>[];
    
    // فحص 1: الاتجاه صحيح
    if (!isBuy && !isSell && direction.toUpperCase() != 'NO_TRADE') {
      errors.add('❌ اتجاه غير صحيح: $direction');
      isValid = false;
    }
    
    // فحص 2: للشراء - SL يجب أن يكون أقل من Entry
    if (isBuy && stopLoss >= entryPrice) {
      errors.add('❌ خطأ في توصية الشراء: Stop Loss ($stopLoss) أكبر من أو يساوي Entry ($entryPrice)');
      isValid = false;
    }
    
    // فحص 3: للشراء - TP يجب أن يكون أعلى من Entry
    if (isBuy && takeProfit <= entryPrice) {
      errors.add('❌ خطأ في توصية الشراء: Take Profit ($takeProfit) أقل من أو يساوي Entry ($entryPrice)');
      isValid = false;
    }
    
    // فحص 4: للبيع - SL يجب أن يكون أعلى من Entry
    if (isSell && stopLoss <= entryPrice) {
      errors.add('❌ خطأ في توصية البيع: Stop Loss ($stopLoss) أقل من أو يساوي Entry ($entryPrice)');
      isValid = false;
    }
    
    // فحص 5: للبيع - TP يجب أن يكون أقل من Entry
    if (isSell && takeProfit >= entryPrice) {
      errors.add('❌ خطأ في توصية البيع: Take Profit ($takeProfit) أكبر من أو يساوي Entry ($entryPrice)');
      isValid = false;
    }
    
    // طباعة النتيجة
    final prefix = isValid ? '✅' : '🚨';
    final status = isValid ? 'صحيحة' : 'خاطئة';
    final sourceText = source != null ? ' [$source]' : '';
    
    AppLogger.info('$prefix توصية سكالبينج$sourceText - $status');
    AppLogger.info('   الاتجاه: $direction');
    AppLogger.info('   الدخول: \$$entryPrice');
    AppLogger.info('   وقف الخسارة: \$$stopLoss');
    AppLogger.info('   جني الأرباح: \$$takeProfit');
    AppLogger.info('   الثقة: $confidence%');
    
    if (!isValid) {
      AppLogger.error('🚨 أخطاء مكتشفة في التوصية:', errors.join('\n'));
    }
    
    // حساب R:R
    if (isBuy || isSell) {
      final risk = (entryPrice - stopLoss).abs();
      final reward = (takeProfit - entryPrice).abs();
      final rr = risk > 0 ? reward / risk : 0;
      AppLogger.info('   R:R = 1:${rr.toStringAsFixed(2)}');
    }
  }
  
  /// تسجيل إشارة السوينج مع فحص شامل
  static void logSwingSignal({
    required String direction,
    required double entryPrice,
    required double stopLoss,
    required double takeProfit,
    required int confidence,
    String? source,
  }) {
    // نفس المنطق للسكالبينج
    logScalpingSignal(
      direction: direction,
      entryPrice: entryPrice,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
      confidence: confidence,
      source: source ?? 'Swing',
    );
  }
  
  /// فحص سريع لأي إشارة
  static bool quickValidate({
    required String direction,
    required double entryPrice,
    required double stopLoss,
    required double takeProfit,
  }) {
    final isBuy = direction.toUpperCase() == 'BUY';
    final isSell = direction.toUpperCase() == 'SELL';
    
    if (isBuy) {
      // للشراء: SL < Entry < TP
      return stopLoss < entryPrice && entryPrice < takeProfit;
    } else if (isSell) {
      // للبيع: TP < Entry < SL
      return takeProfit < entryPrice && entryPrice < stopLoss;
    }
    
    return false;
  }
}
