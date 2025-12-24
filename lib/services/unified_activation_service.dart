import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/utils/logger.dart';

/// 🔐 Unified Activation Service
/// خدمة موحدة لإدارة أكواد التفعيل - تجمع بين النظامين القديمين
///
/// Features:
/// - Loads codes from unified JSON file
/// - Tracks used codes globally
/// - Calculates expiry from activation date (not from file)
/// - Supports 3-day, 5-day, 30-day, and lifetime codes
class UnifiedActivationService {
  static const String _activatedCodeKey = 'unified_activated_code';
  static const String _activationDateKey = 'unified_activation_date';
  static const String _expiryDateKey = 'unified_expiry_date';
  static const String _usedCodesKey = 'unified_used_codes_list';
  static const String _isLifetimeKey = 'unified_is_lifetime';

  /// تحميل جميع الأكواد الصالحة من الملف الموحد
  static Future<List<ActivationCode>> loadAllValidCodes() async {
    try {
      AppLogger.info('📂 Loading unified activation codes...');

      final jsonString = await rootBundle.loadString(
        'assets/activation_codes/all_valid_codes.json',
      );

      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> codesList = data['codes'] ?? [];

      final codes =
          codesList.map((json) => ActivationCode.fromJson(json)).toList();

      AppLogger.info('✅ Loaded ${codes.length} activation codes');
      AppLogger.info('   - Total codes: ${data['total_codes']}');

      return codes;
    } catch (e, stack) {
      AppLogger.error('❌ Failed to load activation codes', e, stack);
      return [];
    }
  }

  /// تفعيل كود
  static Future<ActivationResult> activateCode(String code) async {
    try {
      // تنظيف الكود
      final cleanCode = code.trim().toUpperCase();

      AppLogger.info('🔐 Attempting activation with code: $cleanCode');

      final prefs = await SharedPreferences.getInstance();

      // 🔍 التحقق من أن الكود لم يُستخدم من قبل
      final usedCodes = prefs.getStringList(_usedCodesKey) ?? [];
      if (usedCodes.contains(cleanCode)) {
        AppLogger.warn('⚠️ Code already used: $cleanCode');
        return ActivationResult(
          success: false,
          message: 'هذا الكود مستخدم من قبل',
        );
      }

      // تحميل جميع الأكواد الصالحة
      final validCodes = await loadAllValidCodes();

      if (validCodes.isEmpty) {
        AppLogger.error('❌ No valid codes loaded from file');
        return ActivationResult(
          success: false,
          message: 'خطأ في تحميل الأكواد',
        );
      }

      // البحث عن الكود
      final matchingCode = validCodes.firstWhere(
        (c) => c.code == cleanCode && c.status == 'active',
        orElse: () => ActivationCode.invalid(),
      );

      if (!matchingCode.isValid) {
        AppLogger.warn('⚠️ Invalid or inactive code: $cleanCode');
        return ActivationResult(
          success: false,
          message: 'كود غير صالح',
        );
      }

      // حساب تاريخ الانتهاء من تاريخ التفعيل الحالي (وليس من الملف!)
      final now = DateTime.now();
      final expiryDate = now.add(Duration(days: matchingCode.days));
      final isLifetime = matchingCode.isLifetime;

      // حفظ بيانات التفعيل
      await prefs.setString(_activatedCodeKey, cleanCode);
      await prefs.setString(_activationDateKey, now.toIso8601String());
      await prefs.setString(_expiryDateKey, expiryDate.toIso8601String());
      await prefs.setBool(_isLifetimeKey, isLifetime);

      // 🔑 إضافة الكود لقائمة الأكواد المستخدمة
      usedCodes.add(cleanCode);
      await prefs.setStringList(_usedCodesKey, usedCodes);

      AppLogger.success('✅ Code activated successfully: $cleanCode');
      AppLogger.info('   Type: ${matchingCode.type}');
      AppLogger.info('   Days: ${matchingCode.days}');
      AppLogger.info('   Expiry: ${expiryDate.toIso8601String()}');

      String daysText;
      if (isLifetime) {
        daysText = 'مدى الحياة';
      } else {
        daysText = '${matchingCode.days} يوم';
      }

      return ActivationResult(
        success: true,
        message: 'تم تفعيل التطبيق بنجاح لمدة $daysText!',
        expiryDate: expiryDate,
        code: cleanCode,
        isLifetime: isLifetime,
        daysRemaining: isLifetime ? 999999 : matchingCode.days,
      );
    } catch (e, stack) {
      AppLogger.error('❌ Activation failed', e, stack);
      return ActivationResult(
        success: false,
        message: 'حدث خطأ أثناء التفعيل',
      );
    }
  }

  /// التحقق من حالة التفعيل
  static Future<ActivationStatus> checkActivationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final activatedCode = prefs.getString(_activatedCodeKey);
      final expiryDateStr = prefs.getString(_expiryDateKey);
      final isLifetime = prefs.getBool(_isLifetimeKey) ?? false;

      // إذا لم يتم التفعيل بعد
      if (activatedCode == null || expiryDateStr == null) {
        return ActivationStatus(
          isActivated: false,
          message: 'التطبيق غير مفعل - يمكنك استخدامه مجاناً',
        );
      }

      // Lifetime activation
      if (isLifetime) {
        return ActivationStatus(
          isActivated: true,
          message: 'التطبيق مفعل مدى الحياة',
          expiryDate: null,
          daysRemaining: 999999,
          activatedCode: activatedCode,
          isLifetime: true,
        );
      }

      // محاولة قراءة تاريخ انتهاء الصلاحية
      DateTime? expiryDate;
      try {
        expiryDate = DateTime.parse(expiryDateStr);
      } catch (e) {
        // إذا كان التاريخ غير صالح، نمسح البيانات ونعتبر التطبيق غير مفعل
        AppLogger.error('❌ Invalid expiry date format', e);
        await clearActivation();
        return ActivationStatus(
          isActivated: false,
          message: 'التطبيق غير مفعل - يمكنك استخدامه مجاناً',
        );
      }

      final now = DateTime.now();

      // التحقق من انتهاء الصلاحية
      if (now.isAfter(expiryDate)) {
        await clearActivation();
        return ActivationStatus(
          isActivated: false,
          message: 'انتهت صلاحية التفعيل - يمكنك استخدام التطبيق مجاناً',
        );
      }

      // التطبيق مفعل
      final daysRemaining = expiryDate.difference(now).inDays;
      return ActivationStatus(
        isActivated: true,
        message: 'التطبيق مفعل',
        expiryDate: expiryDate,
        daysRemaining: daysRemaining,
        activatedCode: activatedCode,
      );
    } catch (e, stack) {
      // في حالة أي خطأ، نسمح باستخدام التطبيق
      AppLogger.error('❌ Error checking activation status', e, stack);
      return ActivationStatus(
        isActivated: false,
        message: 'يمكنك استخدام التطبيق',
      );
    }
  }

  /// مسح بيانات التفعيل (لا تمسح قائمة الأكواد المستخدمة!)
  static Future<void> clearActivation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activatedCodeKey);
    await prefs.remove(_activationDateKey);
    await prefs.remove(_expiryDateKey);
    await prefs.remove(_isLifetimeKey);
    // ⚠️ لا نمسح _usedCodesKey لمنع إعادة استخدام الأكواد!
    AppLogger.info('🔄 Activation data cleared (used codes preserved)');
  }

  /// الحصول على إحصائيات الأكواد
  static Future<Map<String, int>> getCodesStatistics() async {
    final codes = await loadAllValidCodes();

    final codes3Days = codes.where((c) => c.days == 3).length;
    final codes5Days = codes.where((c) => c.days == 5).length;
    final codes30Days = codes.where((c) => c.days == 30).length;
    final codesLifetime = codes.where((c) => c.isLifetime).length;

    return {
      '3_days': codes3Days,
      '5_days': codes5Days,
      '30_days': codes30Days,
      'lifetime': codesLifetime,
      'total': codes.length,
    };
  }

  /// حذف قائمة الأكواد المستخدمة (للاختبار فقط!)
  static Future<void> resetUsedCodes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usedCodesKey);
    AppLogger.warn('⚠️ Used codes list has been reset!');
  }

  /// مسح كامل للبيانات (للاختبار فقط!)
  static Future<void> resetAll() async {
    await clearActivation();
    await resetUsedCodes();
    AppLogger.warn('⚠️ All activation data has been reset!');
  }
}

/// نموذج كود التفعيل
class ActivationCode {
  final String code;
  final int days;
  final String type; // 'standard' or 'lifetime'
  final String status;

  ActivationCode({
    required this.code,
    required this.days,
    required this.type,
    required this.status,
  });

  factory ActivationCode.fromJson(Map<String, dynamic> json) {
    return ActivationCode(
      code: json['code'] as String,
      days: json['days'] as int,
      type: json['type'] as String? ?? 'standard',
      status: json['status'] as String? ?? 'active',
    );
  }

  factory ActivationCode.invalid() {
    return ActivationCode(
      code: '',
      days: 0,
      type: 'invalid',
      status: 'invalid',
    );
  }

  bool get isValid => code.isNotEmpty && status == 'active';
  bool get isLifetime => type == 'lifetime' || days >= 36500;
}

/// نتيجة التفعيل
class ActivationResult {
  final bool success;
  final String message;
  final DateTime? expiryDate;
  final String? code;
  final bool isLifetime;
  final int daysRemaining;

  ActivationResult({
    required this.success,
    required this.message,
    this.expiryDate,
    this.code,
    this.isLifetime = false,
    this.daysRemaining = 0,
  });
}

/// حالة التفعيل
class ActivationStatus {
  final bool isActivated;
  final String message;
  final DateTime? expiryDate;
  final int? daysRemaining;
  final String? activatedCode;
  final bool isLifetime;

  ActivationStatus({
    required this.isActivated,
    required this.message,
    this.expiryDate,
    this.daysRemaining,
    this.activatedCode,
    this.isLifetime = false,
  });

  String get formattedExpiryDate {
    if (expiryDate == null) return '';
    return '${expiryDate!.year}-${expiryDate!.month.toString().padLeft(2, '0')}-${expiryDate!.day.toString().padLeft(2, '0')}';
  }
}
