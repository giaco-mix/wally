import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/format.dart';
import '../providers/income_providers.dart';

class IncomeScreen extends ConsumerWidget {
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(annualIncomeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Dividendi & rendita')),
      body: report.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Errore: $e')),
        data: (r) {
          if (r.items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aggiungi posizioni per stimare la rendita annua da dividendi '
                  'e cedole.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rendita annua stimata',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(Fmt.money(r.total),
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Text('Rendimento medio ${Fmt.pctFromFraction(r.avgYield)} · '
                          '~${Fmt.money(r.total / 12)} al mese'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text('Per posizione',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              ...r.items.map((i) => Card(
                    child: ListTile(
                      title: Text(i.symbol),
                      subtitle: Text(
                          'Rendimento ${Fmt.pctFromFraction(i.yieldFraction)} su ${Fmt.money(i.value)}'),
                      trailing: Text(Fmt.money(i.income),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )),
              const SizedBox(height: 12),
              Text(
                'Stima basata sul rendimento da dividendi/cedole corrente dei tuoi '
                'strumenti. Le distribuzioni reali possono variare. Solo a scopo '
                'informativo.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }
}
