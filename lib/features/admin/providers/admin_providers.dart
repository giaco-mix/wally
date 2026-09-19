import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/providers.dart';
import '../domain/app_user.dart';

/// Ruolo dell'utente corrente (dal profilo). In demo: retail.
final currentUserRoleProvider = FutureProvider<String>((ref) async {
  if (!AppConfig.isConfigured) return 'retail';
  final client = ref.watch(supabaseClientProvider);
  final uid = client.auth.currentUser?.id;
  if (uid == null) return 'retail';
  final row = await client
      .from('profiles')
      .select('role')
      .eq('id', uid)
      .maybeSingle();
  return (row?['role'] as String?) ?? 'retail';
});

/// Vero se l'utente corrente è amministratore.
final isAdminProvider = Provider<bool>(
    (ref) => ref.watch(currentUserRoleProvider).asData?.value == 'admin');

/// Elenco di tutti gli utenti (visibile solo all'admin via RLS).
final adminUsersProvider = FutureProvider<List<AppUser>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final rows = await client
      .from('profiles')
      .select('id, display_name, role, created_at')
      .order('created_at', ascending: false);
  return (rows as List)
      .cast<Map<String, dynamic>>()
      .map(AppUser.fromMap)
      .toList();
});

/// Aggiorna il ruolo di un utente (solo admin, via RLS).
Future<void> setUserRole(WidgetRef ref, String userId, String role) async {
  await ref
      .read(supabaseClientProvider)
      .from('profiles')
      .update({'role': role}).eq('id', userId);
  ref.invalidate(adminUsersProvider);
}
