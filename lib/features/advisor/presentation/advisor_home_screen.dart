import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/format.dart';
import '../domain/advisor_client.dart';
import '../providers/advisor_providers.dart';
import 'advisor_client_screen.dart';

/// Home del consulente: elenco dei clienti seguiti. Reale (Supabase) quando
/// configurato, altrimenti dati dimostrativi.
class AdvisorHomeScreen extends ConsumerWidget {
  const AdvisorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(advisorClientsProvider);
    final backendReady = ref.watch(advisorBackendReadyProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Consulente')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => backendReady
            ? _inviteDialog(context, ref)
            : ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'In anteprima demo l\'invito è disattivato: serve il backend reale.'),
                ),
              ),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Invita cliente'),
      ),
      body: clientsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Errore: $e', textAlign: TextAlign.center),
          ),
        ),
        data: (clients) {
          final totalAum =
              clients.fold<double>(0, (a, c) => a + c.totalValue);
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              if (!backendReady)
                Card(
                  color: scheme.tertiaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.science_outlined,
                            size: 18, color: scheme.onTertiaryContainer),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Anteprima con dati dimostrativi. Con il backend reale '
                            'inviti i clienti veri e vedi i loro portafogli in sola lettura.',
                            style: TextStyle(
                                color: scheme.onTertiaryContainer, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (clients.isEmpty && backendReady)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Nessun cliente collegato. Tocca "Invita cliente" e inserisci '
                    'la sua email: comparirà qui quando accetta l\'invito.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              if (clients.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    '${clients.length} clienti · patrimonio seguito ${Fmt.money(totalAum)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              for (final c in clients) _ClientTile(client: c),
            ],
          );
        },
      ),
    );
  }

  Future<void> _inviteDialog(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final email = TextEditingController();
    final label = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dctx) => AlertDialog(
        title: const Text('Invita un cliente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: email,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              decoration:
                  const InputDecoration(labelText: 'Email del cliente'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: label,
              decoration:
                  const InputDecoration(labelText: 'Nome/nota (opzionale)'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dctx, false),
              child: const Text('Annulla')),
          FilledButton(
              onPressed: () => Navigator.pop(dctx, true),
              child: const Text('Invita')),
        ],
      ),
    );
    if (ok != true || email.text.trim().isEmpty) return;
    try {
      await ref
          .read(advisorRepositoryProvider)
          .invite(email.text, label.text);
      ref.invalidate(advisorClientsProvider);
      messenger.showSnackBar(const SnackBar(
          content: Text('Invito inviato. Comparirà quando il cliente accetta.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Errore: $e')));
    }
  }
}

class _ClientTile extends StatelessWidget {
  const _ClientTile({required this.client});
  final AdvisorClient client;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(client.name.characters.first)),
        title: Text(client.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(client.note ?? '',
            maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(Fmt.money(client.totalValue),
                style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              Fmt.signedPct(client.gainPercent),
              style: TextStyle(
                fontSize: 12,
                color:
                    client.gain >= 0 ? AppTheme.positive : AppTheme.negative,
              ),
            ),
          ],
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AdvisorClientScreen(client: client),
          ),
        ),
      ),
    );
  }
}
