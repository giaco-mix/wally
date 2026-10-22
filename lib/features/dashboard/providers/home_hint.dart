import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stato "card di benvenuto già chiusa" (persistito in locale, per device).
/// Usato per la guida al primo impatto in Dashboard ("Da dove comincio?").
final homeHintDismissedProvider =
    AsyncNotifierProvider<HomeHintDismissed, bool>(HomeHintDismissed.new);

class HomeHintDismissed extends AsyncNotifier<bool> {
  static const _key = 'home_hint_dismissed';

  @override
  Future<bool> build() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_key) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> dismiss() async {
    state = const AsyncData(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, true);
    } catch (_) {
      // best-effort
    }
  }
}
