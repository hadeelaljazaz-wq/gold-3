import 'package:flutter_test/flutter_test.dart';
import 'package:golden_nightmare_pro/core/utils/execution_guard.dart';

void main() {
  group('ExecutionGuard Unit Tests', () {
    late ExecutionGuard guard;

    setUp(() {
      guard = ExecutionGuard();
    });

    test('should acquire lock on first attempt', () {
      final acquired = guard.tryAcquire('test_key');
      expect(acquired, isTrue);
      expect(guard.isLocked('test_key'), isTrue);
    });

    test('should block concurrent acquisition', () {
      final first = guard.tryAcquire('test_key');
      final second = guard.tryAcquire('test_key');

      expect(first, isTrue);
      expect(second, isFalse);
      expect(guard.isLocked('test_key'), isTrue);
    });

    test('should allow acquisition after release', () {
      guard.tryAcquire('test_key');
      guard.release('test_key');

      final acquired = guard.tryAcquire('test_key');
      expect(acquired, isTrue);
    });

    test('should handle multiple keys independently', () {
      final key1 = guard.tryAcquire('key1');
      final key2 = guard.tryAcquire('key2');

      expect(key1, isTrue);
      expect(key2, isTrue);
      expect(guard.isLocked('key1'), isTrue);
      expect(guard.isLocked('key2'), isTrue);
    });

    test('waitForRelease should complete after release', () async {
      guard.tryAcquire('test_key');

      // Release after 100ms
      Future.delayed(const Duration(milliseconds: 100), () {
        guard.release('test_key');
      });

      final startTime = DateTime.now();
      await guard.waitForRelease('test_key');
      final elapsed = DateTime.now().difference(startTime);

      expect(elapsed.inMilliseconds, greaterThanOrEqualTo(100));
    });
  });
}
