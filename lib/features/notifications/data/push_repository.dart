import 'package:supabase_flutter/supabase_flutter.dart';

import 'push_client.dart';

/// Persistenza delle sottoscrizioni push su Supabase (tabella
/// `push_subscriptions`, protetta da RLS: ogni utente vede solo le proprie).
class PushRepository {
  PushRepository(this._client);
  final SupabaseClient _client;

  String? get _userId => _client.auth.currentUser?.id;

  /// Salva (o aggiorna) la sottoscrizione per l'utente corrente.
  Future<void> saveSubscription(PushSubscriptionData sub) async {
    final userId = _userId;
    if (userId == null) return;
    await _client.from('push_subscriptions').upsert({
      'endpoint': sub.endpoint,
      'user_id': userId,
      'p256dh': sub.p256dh,
      'auth': sub.auth,
    }, onConflict: 'endpoint');
  }

  /// Rimuove una sottoscrizione dato l'endpoint.
  Future<void> deleteSubscription(String endpoint) async {
    await _client.from('push_subscriptions').delete().eq('endpoint', endpoint);
  }

  /// Vero se l'utente ha almeno una sottoscrizione registrata.
  Future<bool> hasSubscription() async {
    final userId = _userId;
    if (userId == null) return false;
    final rows = await _client
        .from('push_subscriptions')
        .select('endpoint')
        .eq('user_id', userId)
        .limit(1);
    return (rows as List).isNotEmpty;
  }
}
