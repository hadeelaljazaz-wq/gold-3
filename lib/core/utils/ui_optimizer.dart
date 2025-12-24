/// 🎨 UI Optimizer
///
/// Utility class for optimizing UI performance and responsiveness.
/// Provides lazy loading, image optimization, and widget caching.
///
/// **Usage:**
/// ```dart
/// // Lazy load widget
/// final lazyWidget = UIOptimizer.lazyLoad(() => ExpensiveWidget());
///
/// // Optimize image
/// final optimizedImage = UIOptimizer.optimizeImage(url, width: 200);
/// ```

import 'package:flutter/material.dart';
import '../utils/logger.dart';

class UIOptimizer {
  UIOptimizer._();

  /// Lazy load widget
  ///
  /// Creates a widget that loads lazily to improve initial render time.
  ///
  /// **Parameters:**
  /// - [builder]: Widget builder function
  ///
  /// **Returns:**
  /// Lazy-loaded widget
  static Widget lazyLoad(Widget Function() builder) {
    return Builder(
      builder: (context) {
        // Use FutureBuilder for lazy loading
        return FutureBuilder<Widget>(
          future: Future.microtask(builder),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return snapshot.data!;
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  /// Optimize image loading
  ///
  /// Returns optimized image widget with caching and error handling.
  ///
  /// **Parameters:**
  /// - [url]: Image URL
  /// - [width]: Desired width (optional)
  /// - [height]: Desired height (optional)
  /// - [fit]: BoxFit (default: BoxFit.cover)
  ///
  /// **Returns:**
  /// Optimized image widget
  static Widget optimizeImage(
    String url, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        AppLogger.warn('Failed to load image: $url');
        return const Icon(Icons.error);
      },
    );
  }

  /// Create cached widget
  ///
  /// Creates a widget with automatic caching for better performance.
  ///
  /// **Parameters:**
  /// - [key]: Cache key
  /// - [builder]: Widget builder function
  ///
  /// **Returns:**
  /// Cached widget
  static Widget cachedWidget(
    String key,
    Widget Function() builder,
  ) {
    // Use AutomaticKeepAliveClientMixin for caching
    return _CachedWidgetWrapper(
      cacheKey: key,
      builder: builder,
    );
  }

  /// Debounce widget rebuilds
  ///
  /// Prevents excessive widget rebuilds by debouncing updates.
  ///
  /// **Parameters:**
  /// - [child]: Child widget
  /// - [delay]: Debounce delay (default: 100ms)
  ///
  /// **Returns:**
  /// Debounced widget
  static Widget debounceRebuild(
    Widget child, {
    Duration delay = const Duration(milliseconds: 100),
  }) {
    return _DebouncedWidget(
      delay: delay,
      child: child,
    );
  }

  /// Optimize list rendering
  ///
  /// Creates an optimized list view with lazy loading and item caching.
  ///
  /// **Parameters:**
  /// - [items]: List of items
  /// - [itemBuilder]: Item builder function
  /// - [separatorBuilder]: Separator builder (optional)
  ///
  /// **Returns:**
  /// Optimized list view
  static Widget optimizeList<T>({
    required List<T> items,
    required Widget Function(BuildContext, int, T) itemBuilder,
    Widget Function(BuildContext, int)? separatorBuilder,
  }) {
    return ListView.separated(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return itemBuilder(context, index, items[index]);
      },
      separatorBuilder:
          separatorBuilder ?? (context, index) => const SizedBox(height: 8),
      cacheExtent: 500, // Cache 500 pixels worth of items
    );
  }

  /// Create shimmer loading widget
  ///
  /// Creates a shimmer effect for loading states.
  ///
  /// **Parameters:**
  /// - [width]: Width (optional)
  /// - [height]: Height (optional)
  /// - [borderRadius]: Border radius (default: 8)
  ///
  /// **Returns:**
  /// Shimmer loading widget
  static Widget shimmerLoading({
    double? width,
    double? height,
    double borderRadius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Cached widget wrapper
class _CachedWidgetWrapper extends StatefulWidget {
  final String cacheKey;
  final Widget Function() builder;

  const _CachedWidgetWrapper({
    required this.cacheKey,
    required this.builder,
  });

  @override
  State<_CachedWidgetWrapper> createState() => _CachedWidgetWrapperState();
}

class _CachedWidgetWrapperState extends State<_CachedWidgetWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.builder();
  }
}

/// Debounced widget
class _DebouncedWidget extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _DebouncedWidget({
    required this.child,
    required this.delay,
  });

  @override
  State<_DebouncedWidget> createState() => _DebouncedWidgetState();
}

class _DebouncedWidgetState extends State<_DebouncedWidget> {
  Widget? _cachedChild;

  @override
  void initState() {
    super.initState();
    _cachedChild = widget.child;
  }

  @override
  void didUpdateWidget(_DebouncedWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.child != oldWidget.child) {
      Future.delayed(widget.delay, () {
        if (mounted) {
          setState(() {
            _cachedChild = widget.child;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _cachedChild ?? widget.child;
  }
}
