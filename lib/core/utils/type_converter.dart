/// Type Converter Utility
/// Provides safe type conversion methods for handling API responses
class TypeConverter {
  /// Safely converts dynamic value to double
  /// Returns null if conversion fails
  static double? safeToDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  /// Safely converts dynamic value to int
  /// Returns null if conversion fails
  static int? safeToInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  /// Safely converts dynamic value to String
  /// Returns null if value is null
  static String? safeToString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  /// Safely converts dynamic value to bool
  /// Returns null if conversion fails
  static bool? safeToBool(dynamic value) {
    if (value == null) return null;

    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final lowercaseValue = value.toLowerCase();
      if (lowercaseValue == 'true' || lowercaseValue == '1') return true;
      if (lowercaseValue == 'false' || lowercaseValue == '0') return false;
    }

    return null;
  }

  /// Safely converts List to List<double>
  /// Filters out null and invalid values
  static List<double> safeToListOfDoubles(List<dynamic> list) {
    return list
        .map((item) => safeToDouble(item))
        .where((item) => item != null)
        .cast<double>()
        .toList();
  }

  /// Safely converts List to List<int>
  /// Filters out null and invalid values
  static List<int> safeToListOfInts(List<dynamic> list) {
    return list
        .map((item) => safeToInt(item))
        .where((item) => item != null)
        .cast<int>()
        .toList();
  }

  /// Safely converts List to List<String>
  /// Filters out null values
  static List<String> safeToListOfStrings(List<dynamic> list) {
    return list
        .map((item) => safeToString(item))
        .where((item) => item != null)
        .cast<String>()
        .toList();
  }

  /// Safely converts dynamic value to DateTime
  /// Supports String (ISO8601), int (milliseconds since epoch), and DateTime
  static DateTime? safeToDateTime(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) return value;

    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }

    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  /// Safely converts Map to Map<String, dynamic>
  /// Returns empty map if conversion fails
  static Map<String, dynamic> safeToMap(dynamic value) {
    if (value == null) return {};

    if (value is Map<String, dynamic>) return value;

    if (value is Map) {
      try {
        return Map<String, dynamic>.from(value);
      } catch (e) {
        return {};
      }
    }

    return {};
  }

  /// Safely converts List to List<Map<String, dynamic>>
  /// Filters out null and invalid values
  static List<Map<String, dynamic>> safeToListOfMaps(dynamic value) {
    if (value == null) return [];

    if (value is! List) return [];

    return value
        .map((item) => safeToMap(item))
        .where((item) => item.isNotEmpty)
        .toList();
  }
}
