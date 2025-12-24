/// KABOUS PRO - Backend Service
/// ============================
/// HTTP client للاتصال بالـ Python backend

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'kabous_models.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/type_converter.dart';

class KabousBackendService {
  // Backend URL - يمكن تغييره من settings
  static String _baseUrl = 'http://localhost:8000';
  
  static void setBaseUrl(String url) {
    _baseUrl = url;
    AppLogger.info('KABOUS Backend URL set to: $url');
  }

  /// Health Check
  static Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      AppLogger.error('KABOUS Backend health check failed', e);
      return false;
    }
  }

  /// Get Current Price
  static Future<double> getCurrentPrice({String? goldApiKey}) async {
    try {
      final uri = goldApiKey != null
          ? Uri.parse('$_baseUrl/api/price').replace(
              queryParameters: {'gold_api_key': goldApiKey},
            )
          : Uri.parse('$_baseUrl/api/price');

      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TypeConverter.safeToDouble(data['price']) ?? 2000.0;
      } else {
        throw Exception('Failed to get price: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('KABOUS get current price failed', e);
      rethrow;
    }
  }

  /// Full Analysis
  static Future<KabousAnalysisResult> analyze({
    String? goldApiKey,
    String? claudeApiKey,
    String timeframe = '5m',
    double accountBalance = 10000,
  }) async {
    try {
      final body = {
        if (goldApiKey != null) 'gold_api_key': goldApiKey,
        if (claudeApiKey != null) 'claude_api_key': claudeApiKey,
        'timeframe': timeframe,
        'account_balance': accountBalance,
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/analyze'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return KabousAnalysisResult.fromJson(data);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'Analysis failed');
      }
    } catch (e) {
      AppLogger.error('KABOUS analysis failed', e);
      rethrow;
    }
  }

  /// Quick Scalp
  static Future<Map<String, dynamic>> quickScalp({
    String? goldApiKey,
    String timeframe = '1m',
  }) async {
    try {
      final body = {
        if (goldApiKey != null) 'gold_api_key': goldApiKey,
        'timeframe': timeframe,
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/quick-scalp'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Quick scalp failed');
      }
    } catch (e) {
      AppLogger.error('KABOUS quick scalp failed', e);
      rethrow;
    }
  }

  /// Get Indicators
  static Future<Map<String, dynamic>> getIndicators({
    String? goldApiKey,
    String timeframe = '5m',
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/indicators').replace(
        queryParameters: {
          if (goldApiKey != null) 'gold_api_key': goldApiKey,
          'timeframe': timeframe,
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Get indicators failed');
      }
    } catch (e) {
      AppLogger.error('KABOUS get indicators failed', e);
      rethrow;
    }
  }
}


