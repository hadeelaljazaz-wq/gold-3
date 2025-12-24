import 'package:hive/hive.dart';

part 'app_settings.g.dart';

/// ⚙️ App Settings Model
///
/// نموذج إعدادات التطبيق مع دعم Hive للحفظ المحلي
@HiveType(typeId: 10)
class AppSettings extends HiveObject {
  /// Theme mode (original or royal)
  @HiveField(0)
  final String themeMode; // 'original' or 'royal'

  /// Strictness level (relaxed, balanced, strict)
  @HiveField(1)
  final String strictnessLevel;

  /// Auto-refresh enabled
  @HiveField(2)
  final bool autoRefreshEnabled;

  /// Auto-refresh interval in seconds
  @HiveField(3)
  final int autoRefreshInterval;

  /// Notifications enabled
  @HiveField(4)
  final bool notificationsEnabled;

  /// Signal notifications enabled
  @HiveField(5)
  final bool signalNotificationsEnabled;

  /// Price alerts enabled
  @HiveField(6)
  final bool priceAlertsEnabled;

  /// Language (en or ar)
  @HiveField(7)
  final String language;

  /// Show AI Analysis by default
  @HiveField(8)
  final bool showAIAnalysisByDefault;

  /// Sound effects enabled
  @HiveField(9)
  final bool soundEffectsEnabled;

  /// Vibration enabled
  @HiveField(10)
  final bool vibrationEnabled;

  AppSettings({
    this.themeMode = 'original',
    this.strictnessLevel = 'balanced',
    this.autoRefreshEnabled = false,
    this.autoRefreshInterval = 300, // 5 minutes
    this.notificationsEnabled = true,
    this.signalNotificationsEnabled = true,
    this.priceAlertsEnabled = true,
    this.language = 'ar',
    this.showAIAnalysisByDefault = false,
    this.soundEffectsEnabled = true,
    this.vibrationEnabled = true,
  });

  /// Create default settings
  factory AppSettings.defaults() => AppSettings();

  /// Copy with
  AppSettings copyWith({
    String? themeMode,
    String? strictnessLevel,
    bool? autoRefreshEnabled,
    int? autoRefreshInterval,
    bool? notificationsEnabled,
    bool? signalNotificationsEnabled,
    bool? priceAlertsEnabled,
    String? language,
    bool? showAIAnalysisByDefault,
    bool? soundEffectsEnabled,
    bool? vibrationEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      strictnessLevel: strictnessLevel ?? this.strictnessLevel,
      autoRefreshEnabled: autoRefreshEnabled ?? this.autoRefreshEnabled,
      autoRefreshInterval: autoRefreshInterval ?? this.autoRefreshInterval,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      signalNotificationsEnabled:
          signalNotificationsEnabled ?? this.signalNotificationsEnabled,
      priceAlertsEnabled: priceAlertsEnabled ?? this.priceAlertsEnabled,
      language: language ?? this.language,
      showAIAnalysisByDefault:
          showAIAnalysisByDefault ?? this.showAIAnalysisByDefault,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode,
      'strictnessLevel': strictnessLevel,
      'autoRefreshEnabled': autoRefreshEnabled,
      'autoRefreshInterval': autoRefreshInterval,
      'notificationsEnabled': notificationsEnabled,
      'signalNotificationsEnabled': signalNotificationsEnabled,
      'priceAlertsEnabled': priceAlertsEnabled,
      'language': language,
      'showAIAnalysisByDefault': showAIAnalysisByDefault,
      'soundEffectsEnabled': soundEffectsEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  /// From JSON
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: json['themeMode'] ?? 'original',
      strictnessLevel: json['strictnessLevel'] ?? 'balanced',
      autoRefreshEnabled: json['autoRefreshEnabled'] ?? false,
      autoRefreshInterval: json['autoRefreshInterval'] ?? 300,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      signalNotificationsEnabled: json['signalNotificationsEnabled'] ?? true,
      priceAlertsEnabled: json['priceAlertsEnabled'] ?? true,
      language: json['language'] ?? 'ar',
      showAIAnalysisByDefault: json['showAIAnalysisByDefault'] ?? false,
      soundEffectsEnabled: json['soundEffectsEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
    );
  }

  @override
  String toString() {
    return 'AppSettings(theme: $themeMode, strictness: $strictnessLevel, autoRefresh: $autoRefreshEnabled, language: $language)';
  }
}
