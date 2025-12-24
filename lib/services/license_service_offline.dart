import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

/// 🔐 نظام التراخيص Offline - بدون سيرفر خارجي
///
/// المميزات:
/// - 100 كود محفوظ داخل التطبيق
/// - صلاحية 30 يوم لكل كود
/// - يعمل بدون إنترنت
/// - ربط الكود بجهاز واحد فقط

class LicenseService {
  static const String _localLicenseKey = 'app_license_data';
  static const String _deviceIdKey = 'device_unique_id';
  static const String _usedCodesKey = 'used_codes';

  static SharedPreferences? _prefs;
  static List<Map<String, dynamic>>? _validCodes;

  /// تهيئة الخدمة
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadValidCodes();
  }

  /// تحميل الأكواد الصالحة من assets
  static Future<void> _loadValidCodes() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/valid_codes.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _validCodes = jsonList.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      print('Error loading valid codes: $e');
      _validCodes = [];
    }
  }

  /// الحصول على معرف الجهاز الفريد
  static Future<String> getDeviceId() async {
    // تحقق من وجود ID محفوظ
    final savedId = _prefs?.getString(_deviceIdKey);
    if (savedId != null) return savedId;

    // توليد ID جديد
    final deviceInfo = DeviceInfoPlugin();
    String deviceId;

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id; // Android ID
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? 'unknown';
    } else {
      deviceId = 'unknown';
    }

    // حفظ ال ID
    await _prefs?.setString(_deviceIdKey, deviceId);
    return deviceId;
  }

  /// تفعيل الترخيص
  static Future<LicenseResult> activateLicense(String code) async {
    code = code.trim().toUpperCase();

    // التحقق من أن الكود لم يستخدم من قبل
    final usedCodes = _prefs?.getStringList(_usedCodesKey) ?? [];
    if (usedCodes.contains(code)) {
      return LicenseResult(
        isValid: false,
        message: 'هذا الكود تم استخدامه من قبل ❌',
        daysRemaining: 0,
      );
    }

    // البحث عن الكود في القائمة
    final codeData = _validCodes?.firstWhere(
      (c) => c['code'] == code && c['status'] == 'active',
      orElse: () => {},
    );

    if (codeData == null || codeData.isEmpty) {
      return LicenseResult(
        isValid: false,
        message: 'كود غير صحيح أو منتهي الصلاحية ❌',
        daysRemaining: 0,
      );
    }

    // التحقق من تاريخ انتهاء الصلاحية
    final expiryDate = DateTime.parse(codeData['expiry_date']);
    if (DateTime.now().isAfter(expiryDate)) {
      return LicenseResult(
        isValid: false,
        message:
            'الكود منتهي الصلاحية ❌\nانتهى في: ${expiryDate.toString().split(' ')[0]}',
        daysRemaining: 0,
      );
    }

    // حساب الأيام المتبقية
    final daysRemaining = expiryDate.difference(DateTime.now()).inDays;

    // حفظ بيانات الترخيص محلياً
    final deviceId = await getDeviceId();
    final licenseData = LicenseData(
      code: code,
      deviceId: deviceId,
      activatedAt: DateTime.now(),
      expiresAt: expiryDate,
      isActive: true,
      daysRemaining: daysRemaining,
    );

    await _saveLicense(licenseData);

    // إضافة الكود إلى قائمة المستخدمة
    usedCodes.add(code);
    await _prefs?.setStringList(_usedCodesKey, usedCodes);

    return LicenseResult(
      isValid: true,
      message: 'تم التفعيل بنجاح! ✅',
      daysRemaining: daysRemaining,
    );
  }

  /// التحقق من صلاحية الترخيص
  static Future<LicenseResult> verifyLicense() async {
    final licenseData = await _loadLicense();

    if (licenseData == null) {
      return LicenseResult(
        isValid: false,
        message: 'لم يتم تفعيل التطبيق',
        daysRemaining: 0,
      );
    }

    // التحقق من تاريخ الانتهاء
    final now = DateTime.now();
    if (now.isAfter(licenseData.expiresAt)) {
      return LicenseResult(
        isValid: false,
        message: 'انتهت صلاحية الترخيص',
        daysRemaining: 0,
      );
    }

    // التحقق من الجهاز
    final currentDeviceId = await getDeviceId();
    if (currentDeviceId != licenseData.deviceId) {
      return LicenseResult(
        isValid: false,
        message: 'الترخيص مرتبط بجهاز آخر',
        daysRemaining: 0,
      );
    }

    final daysRemaining = licenseData.expiresAt.difference(now).inDays;

    return LicenseResult(
      isValid: true,
      message: 'الترخيص نشط',
      daysRemaining: daysRemaining,
    );
  }

  /// حفظ بيانات الترخيص
  static Future<void> _saveLicense(LicenseData data) async {
    final jsonString = json.encode(data.toJson());
    await _prefs?.setString(_localLicenseKey, jsonString);
  }

  /// تحميل بيانات الترخيص
  static Future<LicenseData?> _loadLicense() async {
    final jsonString = _prefs?.getString(_localLicenseKey);
    if (jsonString == null) return null;

    try {
      final jsonData = json.decode(jsonString);
      return LicenseData.fromJson(jsonData);
    } catch (e) {
      return null;
    }
  }

  /// مسح الترخيص
  static Future<void> clearLicense() async {
    await _prefs?.remove(_localLicenseKey);
  }
}

/// بيانات الترخيص
class LicenseData {
  final String code;
  final String deviceId;
  final DateTime activatedAt;
  final DateTime expiresAt;
  final bool isActive;
  final int daysRemaining;

  LicenseData({
    required this.code,
    required this.deviceId,
    required this.activatedAt,
    required this.expiresAt,
    required this.isActive,
    required this.daysRemaining,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'device_id': deviceId,
        'activated_at': activatedAt.toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
        'is_active': isActive,
        'days_remaining': daysRemaining,
      };

  factory LicenseData.fromJson(Map<String, dynamic> json) => LicenseData(
        code: json['code'],
        deviceId: json['device_id'],
        activatedAt: DateTime.parse(json['activated_at']),
        expiresAt: DateTime.parse(json['expires_at']),
        isActive: json['is_active'] ?? true,
        daysRemaining: json['days_remaining'] ?? 0,
      );
}

/// نتيجة عملية التحقق
class LicenseResult {
  final bool isValid;
  final String message;
  final int daysRemaining;

  LicenseResult({
    required this.isValid,
    required this.message,
    required this.daysRemaining,
  });
}

/// منشئ أكواد التفعيل
class LicenseCodeGenerator {
  static bool isValidFormat(String code) {
    // التحقق من صيغة: GNP-XXXX-XXXX-XXXX
    final pattern = RegExp(r'^GNP-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$');
    return pattern.hasMatch(code);
  }
}
