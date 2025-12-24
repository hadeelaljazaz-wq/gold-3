/// 🔐 API Keys Configuration
///
/// ✅ SECURITY: This file now reads from environment variables
/// - API keys are loaded from .env file using flutter_dotenv
/// - No hardcoded secrets in source code
/// - Safe for version control

import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/logger.dart';

class ApiKeys {
  static bool get _envReady => dotenv.isInitialized;

  /// Track if keys are valid
  static bool _keysValid = false;
  static List<String> _missingKeys = [];

  /// Check if API keys are valid
  static bool get hasValidKeys => _keysValid;

  /// Get list of missing keys
  static List<String> get missingKeys => _missingKeys;

  // 🤖 Claude AI (Anthropic) - For Advanced Analysis
  static String get anthropicApiKey {
    const envKey =
        String.fromEnvironment('ANTHROPIC_API_KEY', defaultValue: '');
    if (envKey.isNotEmpty) return envKey;

    if (_envReady) return dotenv.env['ANTHROPIC_API_KEY'] ?? '';

    // For production: Set ANTHROPIC_API_KEY in Render environment variables
    return '';
  }

  static String get anthropicModel {
    const envModel =
        String.fromEnvironment('ANTHROPIC_MODEL', defaultValue: '');
    if (envModel.isNotEmpty) return envModel;

    if (_envReady)
      return dotenv.env['ANTHROPIC_MODEL'] ?? 'claude-sonnet-4-20250514';

    return 'claude-sonnet-4-20250514';
  }

  static String get anthropicBaseUrl {
    const envUrl =
        String.fromEnvironment('ANTHROPIC_BASE_URL', defaultValue: '');
    if (envUrl.isNotEmpty) return envUrl;

    if (_envReady)
      return dotenv.env['ANTHROPIC_BASE_URL'] ?? 'https://api.anthropic.com/v1';

    return 'https://api.anthropic.com/v1';
  }

  // 🌐 OpenRouter API Configuration
  static String get openRouterBaseUrl => _envReady
      ? (dotenv.env['OPENROUTER_BASE_URL'] ?? 'https://openrouter.ai/api/v1')
      : 'https://openrouter.ai/api/v1';

  // 💰 Gold Price API - For Real-time XAUUSD Data
  static String get goldPriceApiKey {
    // Priority 1: Compile-time environment variable (for Render deployment)
    const envKey = String.fromEnvironment('GOLD_PRICE_API_KEY', defaultValue: '');
    if (envKey.isNotEmpty) return envKey;

    // Priority 2: Runtime dotenv (for local development)
    if (_envReady) {
      final dotenvKey = dotenv.env['GOLD_PRICE_API_KEY'];
      if (dotenvKey != null && dotenvKey.isNotEmpty) return dotenvKey;
    }

    // ⚠️ SECURITY: No fallback - force use of environment variables
    // If you see "missing API key" error, add GOLD_PRICE_API_KEY to project.env
    return '';
  }

  static String get goldPriceBaseUrl {
    const envUrl =
        String.fromEnvironment('GOLD_PRICE_BASE_URL', defaultValue: '');
    if (envUrl.isNotEmpty) return envUrl;

    if (_envReady)
      return dotenv.env['GOLD_PRICE_BASE_URL'] ?? 'https://www.goldapi.io/api';

    return 'https://www.goldapi.io/api';
  }

  // 📰 News API (Optional - add your key if needed)
  static String get newsApiKey =>
      _envReady ? (dotenv.env['NEWS_API_KEY'] ?? '') : '';

  // 📅 Economic Calendar API (Optional)
  static String get tradingEconomicsApiKey =>
      _envReady ? (dotenv.env['TRADING_ECONOMICS_API_KEY'] ?? '') : '';

  // 📊 Twelve Data API (Alternative for Gold Price)
  static String get twelveDataApiKey {
    // Priority 1: Compile-time environment variable
    const envKey = String.fromEnvironment('TWELVE_DATA_API_KEY', defaultValue: '');
    if (envKey.isNotEmpty) return envKey;

    // Priority 2: Runtime dotenv
    if (_envReady) {
      final key = dotenv.env['TWELVE_DATA_API_KEY'];
      if (key != null && key.isNotEmpty) return key;
    }

    // ⚠️ SECURITY: No hardcoded key - use environment variables
    return '';
  }

  // 🔥 Firebase Configuration (if using)
  static bool get useFirebase =>
      _envReady && dotenv.env['USE_FIREBASE']?.toLowerCase() == 'true';

  /// Validate that all required API keys are present
  /// Returns true if all keys are valid, false otherwise (non-blocking)
  static bool validateKeys() {
    _missingKeys = <String>[];

    if (anthropicApiKey.isEmpty) _missingKeys.add('ANTHROPIC_API_KEY');
    if (goldPriceApiKey.isEmpty) _missingKeys.add('GOLD_PRICE_API_KEY');

    if (_missingKeys.isNotEmpty) {
      // Log warning instead of throwing exception
      AppLogger.warn(
          '⚠️ WARNING: Missing API keys: ${_missingKeys.join(", ")}');
      AppLogger.warn('⚠️ Some features may not work properly.');
      AppLogger.warn('⚠️ Please check your project.env file.');
      _keysValid = false;
      return false;
    }

    _keysValid = true;
    AppLogger.success('✅ All API keys validated successfully');
    return true;
  }
}

/// Environment Configuration
class Environment {
  /// Safe production flag: defaults to false if dotenv not loaded
  static bool get isProduction {
    try {
      if (!dotenv.isInitialized) return false;
      return dotenv.env['IS_PRODUCTION']?.toLowerCase() == 'true';
    } catch (_) {
      return false;
    }
  }

  static bool get enableLogging {
    try {
      if (!dotenv.isInitialized) return true;
      return dotenv.env['ENABLE_LOGGING']?.toLowerCase() != 'false';
    } catch (_) {
      return true;
    }
  }

  static bool get enableAnalytics {
    try {
      if (!dotenv.isInitialized) return false;
      return dotenv.env['ENABLE_ANALYTICS']?.toLowerCase() == 'true';
    } catch (_) {
      return false;
    }
  }
}
