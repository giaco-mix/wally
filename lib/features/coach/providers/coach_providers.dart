import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../portfolio/providers/portfolio_providers.dart';
import '../domain/mood.dart';
import '../domain/mood_checkin.dart';

/// Variazione del portafoglio "oggi" (in € e %), dalle quotazioni correnti.
typedef DayChange = ({double amount, double pct});

final portfolioDayChangeProvider = Provider<DayChange?>((ref) {
  final positions = ref.watch(positionsProvider).asData?.value ?? const [];
  var today = 0.0;
  var prev = 0.0;
  for (final p in positions) {
    final q = p.quote;
    if (q == null) continue;
    today += q.price * p.holding.quantity;
    prev += q.previousClose * p.holding.quantity;
  }
  if (prev <= 0) return null;
  final amount = today - prev;
  return (amount: amount, pct: amount / prev * 100);
});

/// Soglia di calo giornaliero oltre la quale scatta l'intervento anti panic-sell.
const double kRedDayThresholdPct = -3;

final isRedDayProvider = Provider<bool>((ref) {
  final dc = ref.watch(portfolioDayChangeProvider);
  return dc != null && dc.pct <= kRedDayThresholdPct;
});

/// Check-in dello stato d'animo (storico + registrazione).
final moodCheckinsControllerProvider =
    AsyncNotifierProvider<MoodCheckinsController, List<MoodCheckin>>(
        MoodCheckinsController.new);

class MoodCheckinsController extends AsyncNotifier<List<MoodCheckin>> {
  @override
  Future<List<MoodCheckin>> build() async {
    return ref.watch(portfolioRepositoryProvider).fetchMoodCheckins();
  }

  Future<void> record(Mood mood) async {
    await ref.read(portfolioRepositoryProvider).recordMood(mood);
    ref.invalidateSelf();
    await future;
  }
}

/// Ultimo check-in registrato (o null).
final lastMoodProvider = Provider<MoodCheckin?>((ref) {
  final list = ref.watch(moodCheckinsControllerProvider).asData?.value;
  return (list == null || list.isEmpty) ? null : list.first;
});

/// Quante volte l'utente era nervoso/tentato ma è rimasto (metrica not-quitter).
final resistedCountProvider = Provider<int>((ref) {
  final list = ref.watch(moodCheckinsControllerProvider).asData?.value ?? const [];
  return list.where((c) => c.mood.isAtRisk).length;
});

/// Vero quando mostrare l'intervento anti panic-sell: giornata molto rossa
/// oppure ultimo check-in (di oggi) a rischio.
final showPanicInterventionProvider = Provider<bool>((ref) {
  if (ref.watch(isRedDayProvider)) return true;
  final last = ref.watch(lastMoodProvider);
  if (last == null) return false;
  final isToday = DateTime.now().difference(last.createdAt).inHours < 24;
  return isToday && last.mood.isAtRisk;
});
