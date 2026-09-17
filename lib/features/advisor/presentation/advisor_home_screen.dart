import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/format.dart';
import '../providers/advisor_providers.dart';
import 'advisor_client_screen.dart';

/// Home del consulente: elenco dei clienti seguiti (prototipo, dati demo).
class AdvisorHomeScreen extends ConsumerWidget {
  const AdvisorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(advisorClientsProvider);
    final scheme = Theme.of(context).colorScheme;
    final totalAum = clients.fold<double>(0, (a, c) => a + c.totalValue);

    return Scaffold(
      appBar: AppBar(title: const Text('Consulente')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Nell\'anteprima l\'invito è disattivato: arriverà con il backend reale.'),
          ),
        ),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Invita cliente'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
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
                      'Anteprima con dati dimostrativi. La versione reale collega '
                      'i clienti veri (in sola lettura) via inviti e permessi.',
                      style: TextStyle(
                          color: scheme.onTertiaryContainer, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              '${clients.length} clienti · patrimonio seguito ${Fmt.money(totalAum)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          for (final c in clients)
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(c.name.characters.first)),
                title: Text(c.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(c.note ?? '',
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(Fmt.money(c.totalValue),
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      Fmt.signedPct(c.gainPercent),
                      style: TextStyle(
                        fontSize: 12,
                        color: c.gain >= 0
                            ? AppTheme.positive
                            : AppTheme.negative,
                      ),
                    ),
                  ],
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AdvisorClientScreen(client: c),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
