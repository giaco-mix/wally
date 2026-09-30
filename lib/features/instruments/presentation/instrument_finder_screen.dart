import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/format.dart';
import '../../../shared/widgets/disclaimer_banner.dart';
import '../domain/instrument_pick.dart';

/// "Trova lo strumento": deciso COSA vuoi (una fetta di allocazione), qui vedi
/// gli ETF più diffusi per quel ruolo e cosa li distingue (TER, ACC/DIST,
/// valuta). Dati indicativi; l'analisi live è in Analisi.
class InstrumentFinderScreen extends StatelessWidget {
  const InstrumentFinderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trova lo strumento')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Hai deciso l\'allocazione? Qui trovi, per ogni "fetta", gli ETF più '
            'diffusi e cosa li distingue: costo (TER), accumulazione/distribuzione, '
            'valuta. A parità di indice, la differenza la fanno questi dettagli.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          for (final role in instrumentRoles) ...[
            Text(role, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final p
                in instrumentCatalog.where((x) => x.role == role))
              _InstrumentCard(pick: p),
            const SizedBox(height: 16),
          ],
          const DisclaimerBanner(
            margin: EdgeInsets.only(top: 4),
          ),
          const SizedBox(height: 8),
          Text(
            'Dati indicativi (TER/ISIN possono cambiare): verifica sempre il '
            'documento informativo (KIID) dello strumento.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _InstrumentCard extends StatelessWidget {
  const _InstrumentCard({required this.pick});
  final InstrumentPick pick;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(pick.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                Text(pick.ticker,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _tag(context, 'TER ${Fmt.pct(pick.ter, decimals: 2)}'),
                _tag(context, pick.distribution),
                _tag(context, pick.currency),
                _tag(context, pick.isin),
              ],
            ),
            if (pick.note != null) ...[
              const SizedBox(height: 6),
              Text(pick.note!, style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => context.go('/analysis/${pick.ticker}'),
                icon: const Icon(Icons.insights, size: 18),
                label: const Text('Analizza (live)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(BuildContext context, String text) => Chip(
        label: Text(text),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
}
