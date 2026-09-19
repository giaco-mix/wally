import 'package:supabase_flutter/supabase_flutter.dart';

import '../../portfolio/domain/holding.dart';

/// Collegamento consulente↔cliente (riga di `advisor_clients`).
class AdvisorClientLink {
  const AdvisorClientLink({
    required this.id,
    required this.email,
    required this.status,
    this.clientId,
    this.label,
  });

  final int id;
  final String email;
  final String status; // pending | active | revoked
  final String? clientId;
  final String? label;

  factory AdvisorClientLink.fromMap(Map<String, dynamic> m) => AdvisorClientLink(
        id: (m['id'] as num).toInt(),
        email: m['client_email'] as String,
        status: m['status'] as String? ?? 'pending',
        clientId: m['client_id']?.toString(),
        label: m['client_label'] as String?,
      );
}

abstract class AdvisorRepository {
  /// Clienti collegati e ATTIVI del consulente corrente.
  Future<List<AdvisorClientLink>> fetchActiveClients();

  /// Posizioni (holdings) di un cliente (leggibili grazie alla RLS consulente).
  Future<List<Holding>> clientHoldings(String clientId);

  /// Crea un invito verso l'email di un cliente.
  Future<void> invite(String email, String? label);

  /// Inviti in attesa indirizzati all'utente corrente (lato cliente).
  Future<List<AdvisorClientLink>> pendingInvitesForMe();

  /// Accetta un invito: collega il proprio id e mette 'active'.
  Future<void> acceptInvite(int id);
}

class SupabaseAdvisorRepository implements AdvisorRepository {
  SupabaseAdvisorRepository(this._client);
  final SupabaseClient _client;

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('Utente non autenticato');
    return id;
  }

  String? get _email => _client.auth.currentUser?.email;

  @override
  Future<List<AdvisorClientLink>> fetchActiveClients() async {
    final rows = await _client
        .from('advisor_clients')
        .select()
        .eq('advisor_id', _uid)
        .eq('status', 'active');
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(AdvisorClientLink.fromMap)
        .toList();
  }

  @override
  Future<List<Holding>> clientHoldings(String clientId) async {
    final rows = await _client
        .from('holdings')
        .select()
        .eq('user_id', clientId)
        .order('symbol', ascending: true);
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(Holding.fromMap)
        .toList();
  }

  @override
  Future<void> invite(String email, String? label) async {
    await _client.from('advisor_clients').upsert({
      'advisor_id': _uid,
      'client_email': email.trim().toLowerCase(),
      'client_label': (label == null || label.trim().isEmpty) ? null : label.trim(),
      'status': 'pending',
    }, onConflict: 'advisor_id,client_email');
    // Chi invita diventa 'advisor' (solo se era 'retail': non tocca admin).
    await _client
        .from('profiles')
        .update({'role': 'advisor'})
        .eq('id', _uid)
        .eq('role', 'retail');
  }

  @override
  Future<List<AdvisorClientLink>> pendingInvitesForMe() async {
    final email = _email;
    if (email == null) return const [];
    final rows = await _client
        .from('advisor_clients')
        .select()
        .eq('client_email', email.toLowerCase())
        .eq('status', 'pending');
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(AdvisorClientLink.fromMap)
        .toList();
  }

  @override
  Future<void> acceptInvite(int id) async {
    await _client.from('advisor_clients').update({
      'client_id': _uid,
      'status': 'active',
    }).eq('id', id);
    // Chi accetta diventa 'client' (solo se era 'retail').
    await _client
        .from('profiles')
        .update({'role': 'client'})
        .eq('id', _uid)
        .eq('role', 'retail');
  }
}
