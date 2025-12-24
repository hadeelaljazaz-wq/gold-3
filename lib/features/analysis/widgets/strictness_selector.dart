import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/analysis_strictness.dart';
import '../providers/strictness_provider.dart';

/// Widget to select analysis strictness level
///
/// ويدجت لاختيار مستوى صرامة التحليل
class StrictnessSelector extends ConsumerWidget {
  const StrictnessSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStrictness = ref.watch(strictnessProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.tune,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'مستوى صرامة التحليل',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Current selection description
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                  currentStrictness.icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentStrictness.displayName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentStrictness.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Level buttons
          Row(
            children: [
              Expanded(
                child: _LevelButton(
                  level: AnalysisStrictness.strict,
                  isSelected: currentStrictness == AnalysisStrictness.strict,
                  onTap: () =>
                      ref.read(strictnessProvider.notifier).setStrictness(
                            AnalysisStrictness.strict,
                          ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _LevelButton(
                  level: AnalysisStrictness.moderate,
                  isSelected: currentStrictness == AnalysisStrictness.moderate,
                  onTap: () =>
                      ref.read(strictnessProvider.notifier).setStrictness(
                            AnalysisStrictness.moderate,
                          ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _LevelButton(
                  level: AnalysisStrictness.flexible,
                  isSelected: currentStrictness == AnalysisStrictness.flexible,
                  onTap: () =>
                      ref.read(strictnessProvider.notifier).setStrictness(
                            AnalysisStrictness.flexible,
                          ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Individual level button
class _LevelButton extends StatelessWidget {
  final AnalysisStrictness level;
  final bool isSelected;
  final VoidCallback onTap;

  const _LevelButton({
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              level.icon,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 4),
            Text(
              level.displayName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
