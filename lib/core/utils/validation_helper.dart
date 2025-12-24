/// ✅ Validation Helper
///
/// Utility class for input validation and data sanitization.
///
/// **Usage:**
/// ```dart
/// if (ValidationHelper.isValidPrice(price)) {
///   // Use price
/// }
///
/// final sanitized = ValidationHelper.sanitizeInput(userInput);
/// ```

class ValidationHelper {
  ValidationHelper._();

  /// Validate price value
  ///
  /// Checks if price is within valid range.
  ///
  /// **Parameters:**
  /// - [price]: Price to validate
  /// - [min]: Minimum valid price (default: 1000.0)
  /// - [max]: Maximum valid price (default: 5000.0)
  ///
  /// **Returns:**
  /// True if price is valid
  static bool isValidPrice(
    double price, {
    double min = 1000.0,
    double max = 5000.0,
  }) {
    return price >= min && price <= max && price.isFinite;
  }

  /// Validate percentage value
  ///
  /// Checks if percentage is within valid range (0-100).
  ///
  /// **Parameters:**
  /// - [percentage]: Percentage to validate
  ///
  /// **Returns:**
  /// True if percentage is valid
  static bool isValidPercentage(double percentage) {
    return percentage >= 0 && percentage <= 100 && percentage.isFinite;
  }

  /// Validate risk/reward ratio
  ///
  /// Checks if risk/reward ratio is valid (>= 1.0).
  ///
  /// **Parameters:**
  /// - [ratio]: Risk/reward ratio
  ///
  /// **Returns:**
  /// True if ratio is valid
  static bool isValidRiskReward(double ratio) {
    return ratio >= 1.0 && ratio.isFinite;
  }

  /// Sanitize user input
  ///
  /// Removes potentially dangerous characters from user input.
  ///
  /// **Parameters:**
  /// - [input]: User input string
  ///
  /// **Returns:**
  /// Sanitized string
  static String sanitizeInput(String input) {
    // Remove null bytes and control characters
    return input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
  }

  /// Validate email format
  ///
  /// **Parameters:**
  /// - [email]: Email address to validate
  ///
  /// **Returns:**
  /// True if email format is valid
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate URL format
  ///
  /// **Parameters:**
  /// - [url]: URL to validate
  ///
  /// **Returns:**
  /// True if URL format is valid
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clamp value to range
  ///
  /// Ensures value is within specified range.
  ///
  /// **Parameters:**
  /// - [value]: Value to clamp
  /// - [min]: Minimum value
  /// - [max]: Maximum value
  ///
  /// **Returns:**
  /// Clamped value
  static double clampValue(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  /// Validate list is not empty
  ///
  /// **Parameters:**
  /// - [list]: List to validate
  ///
  /// **Returns:**
  /// True if list is not empty
  static bool isNotEmpty<T>(List<T> list) {
    return list.isNotEmpty;
  }

  /// Validate string is not empty
  ///
  /// **Parameters:**
  /// - [str]: String to validate
  ///
  /// **Returns:**
  /// True if string is not empty
  static bool isNotEmptyString(String str) {
    return str.trim().isNotEmpty;
  }
}
