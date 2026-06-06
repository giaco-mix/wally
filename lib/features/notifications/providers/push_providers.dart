import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/providers.dart';
import '../data/push_client.dart';
import '../data/push_repository.dart';

final pushClientProvider = Provider<PushClient>((_) => const PushClient());

final pushRepositoryProvider = Provider<PushRepository>((ref) {
  return PushRepository(ref.watch(supabaseClientProvider));
});

/// Vero se le notifiche push sono mostrabili nell'UI: backend + chiave VAPID
/// configurati e browser compatibile.
final pushAvailableProvider = Provider<bool>((ref) {
  if (!AppConfig.isPushConfigured) return false;
  return ref.watch(pushClientProvider).isSupported;
});

/// Stato (attivo/non attivo) della sottoscrizione push dell'utente.
final pushEnabledProvider =
    AsyncNotifierProvider<PushController, bool>(PushController.new);

class PushController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    if (!ref.watch(pushAvailableProvider)) return false;
    return ref.watch(pushRepositoryProvider).hasSubscription();
  }

  /// Attiva le notifiche: sottoscrive il browser e salva su Supabase.
  /// Rilancia [PushException] con messaggio pronto per la UI.
  Future<void> enable() async {
    state = const AsyncValue.loading();
    try {
      final sub = await ref
          .read(pushClientProvider)
          .enable(AppConfig.vapidPublicKey);
      await ref.read(pushRepositoryProvider).saveSubscription(sub);
      state = const AsyncValue.data(true);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Disattiva le notifiche: annulla la sottoscrizione e la rimuove da Supabase.
  Future<void> disable() async {
    state = const AsyncValue.loading();
    try {
      final endpoint = await ref.read(pushClientProvider).disable();
      if (endpoint != null) {
        await ref.read(pushRepositoryProvider).deleteSubscription(endpoint);
      }
      state = const AsyncValue.data(false);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
