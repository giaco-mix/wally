import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/format.dart';
import '../../../shared/widgets/disclaimer_banner.dart';
import '../../plan/domain/lazy_portfolio.dart';

/// Sezione educativa: come strutturare un piano + le strategie (lazy portfolio)
/// pronte, spiegate. Contenuto "model/educational", non consulenza personalizzata.
class StrategiesScreen extends StatelessWidget {
  const StrategiesScreen({super.key});

  static const _steps = [
    (
      '1. Parti dall\'obiettivo',
      'Comprare casa, pensione, indipendenza… L\'obiettivo decide l\'orizzonte '
          '(quanti anni) e quindi quanto rischio puoi permetterti.',
    ),
    (
      '2. Scegli un profilo onesto',
      'Prudente, equilibrato o aggressivo: non quello che vorresti, ma quello '
          'che ti fa dormire la notte quando il mercato scende.',
    ),
    (
      '3. Automatizza con un PAC',
      'Versare una cifra fissa ogni mese (Piano di Accumulo) ti toglie '
          'l\'ansia di indovinare il momento giusto: compri sempre, un po\' '
          'alla volta.',
    ),
    (
      '4. Diversifica con una strategia',
      'Un lazy portfolio mescola azioni, obbligazioni e liquidità in modo '
          'semplice e robusto. Meno titoli da seguire, meno errori.',
    ),
    (
      '5. Ribilancia con calma',
      'Ogni tanto le percentuali si spostano: riportale a posto, meglio se '
          'con i nuovi versamenti invece di vendere.',
    ),
    (
      '6. Non mollare nei cali',
      'I ribassi fanno parte del gioco: chi resta nel piano raccoglie i frutti '
          'del lungo periodo. È qui che Wally ti tiene per mano.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Strategie')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Come strutturare un piano',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Sei passi semplici per partire con metodo e restare nel piano.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          for (final s in _steps) _StepCard(title: s.$1, body: s.$2),
          const SizedBox(height: 24),
          Text('Strategie pronte',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Portafogli-modello diversificati, da usare come punto di partenza. '
            'Sono esempi generici, non consigli sul tuo caso specifico.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          for (final p in LazyPortfolio.catalog) _StrategyCard(portfolio: p),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: () => context.go('/onboarding'),
            icon: const Icon(Icons.rocket_launch_outlined),
            label: const Text('Costruisci il tuo piano'),
          ),
          const DisclaimerBanner(margin: EdgeInsets.only(top: 16)),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(body, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _StrategyCard extends StatelessWidget {
  const _StrategyCard({required this.portfolio});
  final LazyPortfolio portfolio;

  @override
  Widget build(BuildContext context) {
    final p = portfolio;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(p.name,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                Chip(
                  label: Text(p.riskProfile.label),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(p.description, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            ...p.allocations.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      SizedBox(width: 150, child: Text(e.key.label)),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: e.value / 100,
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${e.value.toStringAsFixed(0)}%'),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            Text(
              'Rendimento medio atteso ~'
              '${Fmt.pct(p.riskProfile.expectedReturn * 100)}/anno · '
              '${p.riskProfile.worstYearText}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
