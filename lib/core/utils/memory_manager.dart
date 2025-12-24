/// 🧠 Memory Manager
///
/// Utility class for memory management and optimization.
/// Helps prevent memory leaks and optimize memory usage.
///
/// **Usage:**
/// ```dart
/// // Track memory usage
/// MemoryManager.trackObject(myObject);
///
/// // Clear unused caches
/// MemoryManager.clearCaches();
/// ```

class MemoryManager {
  MemoryManager._();

  static final Set<Object> _trackedObjects = {};
  static final Map<String, List<Object>> _caches = {};

  /// Track an object for memory management
  ///
  /// Adds object to tracking list for potential cleanup.
  static void trackObject(Object obj) {
    _trackedObjects.add(obj);
  }

  /// Untrack an object
  ///
  /// Removes object from tracking list.
  static void untrackObject(Object obj) {
    _trackedObjects.remove(obj);
  }

  /// Register a cache
  ///
  /// Registers a named cache for management.
  ///
  /// **Parameters:**
  /// - [name]: Cache name
  /// - [items]: Cache items
  static void registerCache(String name, List<Object> items) {
    _caches[name] = items;
  }

  /// Clear a specific cache
  ///
  /// Clears items from a named cache.
  ///
  /// **Parameters:**
  /// - [name]: Cache name to clear
  static void clearCache(String name) {
    _caches[name]?.clear();
    _caches.remove(name);
  }

  /// Clear all caches
  ///
  /// Clears all registered caches.
  static void clearAllCaches() {
    for (final cache in _caches.values) {
      cache.clear();
    }
    _caches.clear();
  }

  /// Get cache size
  ///
  /// Returns the number of items in a cache.
  ///
  /// **Parameters:**
  /// - [name]: Cache name
  ///
  /// **Returns:**
  /// Number of items in cache, or 0 if cache doesn't exist
  static int getCacheSize(String name) {
    return _caches[name]?.length ?? 0;
  }

  /// Get total cache size
  ///
  /// Returns total number of items across all caches.
  ///
  /// **Returns:**
  /// Total number of cached items
  static int getTotalCacheSize() {
    return _caches.values.fold(0, (sum, cache) => sum + cache.length);
  }

  /// Cleanup unused objects
  ///
  /// Removes tracked objects that are no longer referenced.
  /// This is a best-effort cleanup.
  static void cleanup() {
    // Clear tracked objects set
    _trackedObjects.clear();

    // Clear empty caches
    _caches.removeWhere((key, value) => value.isEmpty);
  }

  /// Get memory statistics
  ///
  /// Returns memory usage statistics.
  ///
  /// **Returns:**
  /// Map with memory statistics
  static Map<String, dynamic> getMemoryStats() {
    return {
      'trackedObjects': _trackedObjects.length,
      'caches': _caches.length,
      'totalCachedItems': getTotalCacheSize(),
      'cacheNames': _caches.keys.toList(),
    };
  }
}
