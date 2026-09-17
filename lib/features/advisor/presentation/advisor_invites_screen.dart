import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/advisor_providers.dart';

/// Lato cliente: inviti dei consulenti da accettare (concede la sola lettura
/// del proprio portafoglio al consulente).
class AdvisorInvitesScreen extends ConsumerWidget {
  const AdvisorInvitesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invites = ref.watch(pendingInvitesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Inviti consulente')),
      body: invites.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Errore: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Nessun invito in attesa.',
                    textAlign: TextAlign.center),
              ),
            );
          }
          return ListView(
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
              for (final inv in list)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.handshake_outlined),
                    title: const Text('Invito da un consulente'),
                    subtitle: Text('Per l\'email ${inv.email}'),
                    trailing: FilledButton(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          await ref
                              .read(advisorRepositoryProvider)
                              .acceptInvite(inv.id);
                          ref.invalidate(pendingInvitesProvider);
                          messenger.showSnackBar(const SnackBar(
                              content: Text('Invito accettato.')));
                        } catch (e) {
                          messenger.showSnackBar(
                              SnackBar(content: Text('Errore: $e')));
                        }
                      },
                      child: const Text('Accetta'),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
