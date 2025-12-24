import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/analysis_strictness.dart';

/// Provider for analysis strictness level
///
/// يدير مستوى صرامة التحليل ويحفظه في SharedPreferences
class StrictnessNotifier extends StateNotifier<AnalysisStrictness> {
  StrictnessNotifier() : super(AnalysisStrictness.flexible) {
    _loadStrictness();
  }

  /// Load saved strictness from SharedPreferences
  Future<void> _loadStrictness() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('analysis_strictness');

    if (saved != null) {
      switch (saved) {
        case 'strict':
          state = AnalysisStrictness.strict;
          break;
        case 'moderate':
          state = AnalysisStrictness.moderate;
          break;
        case 'flexible':
          state = AnalysisStrictness.flexible;
          break;
      }
    }
  }

  /// Change strictness level
  Future<void> setStrictness(AnalysisStrictness newLevel) async {
    state = newLevel;

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('analysis_strictness', newLevel.name);
  }
}

/// Provider instance
final strictnessProvider =
    StateNotifierProvider<StrictnessNotifier, AnalysisStrictness>(
  (ref) => StrictnessNotifier(),
);

/// Provider for current settings based on strictness
final strictnessSettingsProvider = Provider<StrictnessSettings>((ref) {
  final strictness = ref.watch(strictnessProvider);
  return StrictnessSettings.forLevel(strictness);
});
