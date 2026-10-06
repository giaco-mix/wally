import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lezioni completate (persistite in locale con SharedPreferences, per device).
final academyProgressProvider =
    AsyncNotifierProvider<AcademyProgress, Set<String>>(AcademyProgress.new);

class AcademyProgress extends AsyncNotifier<Set<String>> {
  static const _key = 'academy_completed_lessons';

  @override
  Future<Set<String>> build() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (prefs.getStringList(_key) ?? const <String>[]).toSet();
    } catch (_) {
      return <String>{};
    }
  }

  bool isCompleted(String lessonId) =>
      state.asData?.value.contains(lessonId) ?? false;

  Future<void> markCompleted(String lessonId) async {
    final current = {...(state.asData?.value ?? <String>{})};
    if (current.contains(lessonId)) return;
    current.add(lessonId);
    state = AsyncData(current);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, current.toList());
    } catch (_) {
      // Persistenza best-effort: in memoria resta comunque aggiornato.
    }
  }
}
