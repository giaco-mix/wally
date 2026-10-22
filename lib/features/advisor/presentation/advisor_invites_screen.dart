import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../admin/providers/admin_providers.dart';
import '../data/advisor_repository.dart';
import '../providers/advisor_providers.dart';

/// Lato cliente — "Il mio consulente": inviti da accettare + consulenti che
/// seguono il portafoglio in sola lettura, con possibilità di **revoca**.
class AdvisorInvitesScreen extends ConsumerWidget {
  const AdvisorInvitesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invites = ref.watch(pendingInvitesProvider);
    final advisors = ref.watch(activeAdvisorsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Il mio consulente')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(pendingInvitesProvider);
          ref.invalidate(activeAdvisorsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Un consulente può seguire il tuo portafoglio in SOLA LETTURA. '
                'Puoi revocare l\'accesso quando vuoi.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),

            // ── Inviti in attesa ───────────────────────────────────────────
            _SectionTitle('Inviti in attesa'),
            invites.when(
              loading: () => const _Loading(),
              error: (e, _) => _Error('$e'),
              data: (list) {
                if (list.isEmpty) {
                  return const _Hint('Nessun invito in attesa.');
                }
                return Column(
                  children: [for (final inv in list) _InviteCard(invite: inv)],
                );
              },
            ),

            const SizedBox(height: 8),

            // ── Consulenti attivi ──────────────────────────────────────────
            _SectionTitle('Consulenti collegati'),
            advisors.when(
              loading: () => const _Loading(),
              error: (e, _) => _Error('$e'),
              data: (list) {
                if (list.isEmpty) {
                  return const _Hint(
                      'Nessun consulente ti sta seguendo al momento.');
                }
                return Column(
                  children: [for (final a in list) _AdvisorCard(link: a)],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InviteCard extends ConsumerWidget {
  const _InviteCard({required this.invite});
  final AdvisorClientLink invite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.handshake_outlined),
        title: const Text('Invito da un consulente'),
        subtitle: Text('Per l\'email ${invite.email}'),
        trailing: FilledButton(
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            try {
              await ref.read(advisorRepositoryProvider).acceptInvite(invite.id);
              ref.invalidate(pendingInvitesProvider);
              ref.invalidate(activeAdvisorsProvider);
              ref.invalidate(currentUserRoleProvider);
              messenger.showSnackBar(const SnackBar(
                content: Text('Invito accettato. Puoi revocare l\'accesso '
                    'quando vuoi da questa pagina.'),
              ));
            } catch (e) {
              messenger.showSnackBar(SnackBar(content: Text('Errore: $e')));
            }
          },
          child: const Text('Accetta'),
        ),
      ),
    );
  }
}

class _AdvisorCard extends ConsumerWidget {
  const _AdvisorCard({required this.link});
  final AdvisorClientLink link;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.verified_user_outlined),
        title: Text(link.label ?? 'Consulente collegato'),
        subtitle: const Text('Vede il tuo portafoglio in sola lettura'),
        trailing: OutlinedButton(
          onPressed: () => _confirmRevoke(context, ref),
          child: const Text('Revoca'),
        ),
      ),
    );
  }

  Future<void> _confirmRevoke(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dctx) => AlertDialog(
        title: const Text('Revocare l\'accesso?'),
        content: const Text(
          'Il consulente non vedrà più il tuo portafoglio. Potrà seguirti di '
          'nuovo solo con un nuovo invito accettato da te.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dctx, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dctx, true),
            child: const Text('Revoca'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(advisorRepositoryProvider).revoke(link.id);
      ref.invalidate(activeAdvisorsProvider);
      messenger
          .showSnackBar(const SnackBar(content: Text('Accesso revocato.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Errore: $e')));
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
      child: Text(text,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w700)),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
}

class _Error extends StatelessWidget {
  const _Error(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(12),
        child: Text('Errore: $message'),
      );
}
