/// 💾 Cache Manager
///
/// Advanced caching system with TTL (Time To Live) and size limits.
/// Provides efficient data caching with automatic expiration.
///
/// **Usage:**
/// ```dart
/// // Set cache with TTL
/// CacheManager.set('key', data, ttl: Duration(minutes: 5));
///
/// // Get from cache
/// final data = CacheManager.get('key');
///
/// // Check if exists and valid
/// if (CacheManager.has('key')) {
///   // Use cached data
/// }
/// ```

class CacheManager {
  CacheManager._();

  static final Map<String, _CacheEntry> _cache = {};
  static int _maxSize = 100; // Maximum number of entries
  static Duration _defaultTTL = const Duration(minutes: 5);

  /// Set cache entry
  ///
  /// Stores data in cache with optional TTL.
  ///
  /// **Parameters:**
  /// - [key]: Cache key
  /// - [value]: Value to cache
  /// - [ttl]: Time to live (default: 5 minutes)
  static void set(String key, dynamic value, {Duration? ttl}) {
    // Remove oldest entries if cache is full
    if (_cache.length >= _maxSize) {
      _evictOldest();
    }

    _cache[key] = _CacheEntry(
      value: value,
      expiresAt: DateTime.now().add(ttl ?? _defaultTTL),
    );
  }

  /// Get cache entry
  ///
  /// Retrieves data from cache if it exists and hasn't expired.
  ///
  /// **Parameters:**
  /// - [key]: Cache key
  ///
  /// **Returns:**
  /// Cached value, or null if not found or expired
  static dynamic get(String key) {
    final entry = _cache[key];
    if (entry == null) {
      return null;
    }

    // Check if expired
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _cache.remove(key);
      return null;
    }

    return entry.value;
  }

  /// Check if cache entry exists and is valid
  ///
  /// **Parameters:**
  /// - [key]: Cache key
  ///
  /// **Returns:**
  /// True if entry exists and hasn't expired
  static bool has(String key) {
    final entry = _cache[key];
    if (entry == null) {
      return false;
    }

    if (DateTime.now().isAfter(entry.expiresAt)) {
      _cache.remove(key);
      return false;
    }

    return true;
  }

  /// Remove cache entry
  ///
  /// **Parameters:**
  /// - [key]: Cache key to remove
  static void remove(String key) {
    _cache.remove(key);
  }

  /// Clear all cache entries
  static void clear() {
    _cache.clear();
  }

  /// Clear expired entries
  ///
  /// Removes all expired entries from cache.
  static void clearExpired() {
    final now = DateTime.now();
    _cache.removeWhere((key, entry) => now.isAfter(entry.expiresAt));
  }

  /// Set maximum cache size
  ///
  /// **Parameters:**
  /// - [size]: Maximum number of entries
  static void setMaxSize(int size) {
    _maxSize = size;
    while (_cache.length > _maxSize) {
      _evictOldest();
    }
  }

  /// Set default TTL
  ///
  /// **Parameters:**
  /// - [ttl]: Default time to live
  static void setDefaultTTL(Duration ttl) {
    _defaultTTL = ttl;
  }

  /// Get cache statistics
  ///
  /// **Returns:**
  /// Map with cache statistics
  static Map<String, dynamic> getStats() {
    clearExpired(); // Clean expired entries first
    return {
      'size': _cache.length,
      'maxSize': _maxSize,
      'defaultTTL': _defaultTTL.inSeconds,
      'keys': _cache.keys.toList(),
    };
  }

  /// Evict oldest entry
  ///
  /// Removes the oldest entry from cache.
  static void _evictOldest() {
    if (_cache.isEmpty) return;

    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _cache.entries) {
      if (oldestTime == null || entry.value.expiresAt.isBefore(oldestTime)) {
        oldestTime = entry.value.expiresAt;
        oldestKey = entry.key;
      }
    }

    if (oldestKey != null) {
      _cache.remove(oldestKey);
    }
  }
}

/// Cache entry with expiration
class _CacheEntry {
  final dynamic value;
  final DateTime expiresAt;

  _CacheEntry({
    required this.value,
    required this.expiresAt,
  });
}
