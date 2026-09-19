import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/app_user.dart';
import '../providers/admin_providers.dart';

String _date(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

/// Pannello amministratore: elenco utenti e gestione ruoli.
/// (Non espone i dati finanziari dei singoli utenti.)
class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(adminUsersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Amministrazione')),
      body: users.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Errore: $e\n\nServe il ruolo admin e lo schema aggiornato '
              '(apply_all.sql).',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (list) {
          final byRole = <String, int>{};
          for (final u in list) {
            byRole.update(u.role, (v) => v + 1, ifAbsent: () => 1);
          }
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${list.length} utenti',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final r in kUserRoles)
                            Chip(label: Text('$r: ${byRole[r] ?? 0}')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              for (final u in list) _UserTile(user: u),
            ],
          );
        },
      ),
    );
  }
}

class _UserTile extends ConsumerWidget {
  const _UserTile({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
            child: Text(user.displayName.characters.first.toUpperCase())),
        title: Text(user.displayName,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: user.createdAt == null
            ? null
            : Text('Iscritto ${_date(user.createdAt!)}'),
        trailing: DropdownButton<String>(
          value: kUserRoles.contains(user.role) ? user.role : 'retail',
          underline: const SizedBox.shrink(),
          items: [
            for (final r in kUserRoles)
              DropdownMenuItem(value: r, child: Text(r)),
          ],
          onChanged: (r) async {
            if (r == null || r == user.role) return;
            final messenger = ScaffoldMessenger.of(context);
            try {
              await setUserRole(ref, user.id, r);
              messenger.showSnackBar(
                  SnackBar(content: Text('${user.displayName} → $r')));
            } catch (e) {
              messenger.showSnackBar(SnackBar(content: Text('Errore: $e')));
            }
          },
        ),
      ),
    );
  }
}
