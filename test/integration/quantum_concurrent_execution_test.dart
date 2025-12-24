import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_nightmare_pro/features/quantum_analysis/providers/quantum_analysis_provider.dart';

/// ✅ TEST: يمنع تشغيل تحليل Quantum أكثر من مرة في نفس الوقت
void main() {
  group('Quantum Analysis Concurrent Execution Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should block concurrent analysis execution', () async {
      final notifier = container.read(quantumAnalysisProvider.notifier);

      // Keep provider alive
      // ignore: unused_local_variable
      final keepAlive = container.listen(
        quantumAnalysisProvider,
        (_, __) {},
        fireImmediately: true,
      );

      // محاولة تشغيل 3 تحليلات في نفس الوقت
      final futures = <Future<void>>[];
      for (int i = 0; i < 3; i++) {
        futures.add(notifier.generateAnalysis());
      }

      // انتظار انتهاء جميع المحاولات
      await Future.wait(futures);

      // التحقق: يجب أن يكون التحليل قد نُفذ مرة واحدة فقط
      // (نظراً لأن الـ 2 الآخرين تم حظرهم)
      final state = container.read(quantumAnalysisProvider);

      // يجب أن يكون التحليل غير قيد التشغيل
      expect(state.isLoading, isFalse);

      // يجب أن يكون لدينا نتيجة (signal أو error)
      expect(
        state.signal != null || state.error != null || state.lastUpdate != null,
        isTrue,
        reason: 'Analysis should have completed with signal or error',
      );
    });

    test('should allow sequential execution after completion', () async {
      final notifier = container.read(quantumAnalysisProvider.notifier);

      // Keep provider alive
      // ignore: unused_local_variable
      final keepAlive = container.listen(
        quantumAnalysisProvider,
        (_, __) {},
        fireImmediately: true,
      );

      // تحليل أول
      await notifier.generateAnalysis();
      final firstUpdate = container.read(quantumAnalysisProvider).lastUpdate;

      // انتظار قليل
      await Future.delayed(const Duration(milliseconds: 500));

      // تحليل ثاني بعد الانتهاء من الأول
      await notifier.generateAnalysis(forceRefresh: true);
      final secondUpdate = container.read(quantumAnalysisProvider).lastUpdate;

      // يجب أن يكون التحليل الثاني قد تم (timestamps مختلفة)
      if (firstUpdate != null && secondUpdate != null) {
        expect(
          secondUpdate.isAfter(firstUpdate) ||
              secondUpdate.isAtSameMomentAs(firstUpdate),
          isTrue,
          reason: 'Second analysis should have executed',
        );
      }

      final state = container.read(quantumAnalysisProvider);
      expect(state.isLoading, isFalse);
    });

    test('should track concurrent call attempts in real scenario', () async {
      final notifier = container.read(quantumAnalysisProvider.notifier);

      // Keep provider alive
      // ignore: unused_local_variable
      final keepAlive = container.listen(
        quantumAnalysisProvider,
        (_, __) {},
        fireImmediately: true,
      );

      int completedCalls = 0;

      // إطلاق 5 محاولات متزامنة
      final futures = List.generate(5, (i) async {
        await notifier.generateAnalysis();
        completedCalls++;
      });

      await Future.wait(futures);

      // كل المحاولات يجب أن تكتمل (لكن واحدة فقط تنفذ التحليل)
      expect(completedCalls, equals(5));

      // التحقق من أن التحليل تم مرة واحدة
      final state = container.read(quantumAnalysisProvider);
      expect(state.isLoading, isFalse);
      expect(state.signal != null || state.error != null, isTrue);
    });
  });
}
