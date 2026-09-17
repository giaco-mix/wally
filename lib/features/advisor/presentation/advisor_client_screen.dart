import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/disclaimer_banner.dart';
import '../../dashboard/presentation/widgets/allocation_pie.dart';
import '../domain/advisor_client.dart';

/// Dettaglio del portafoglio di un cliente, in **sola lettura** (prototipo).
class AdvisorClientScreen extends StatelessWidget {
  const AdvisorClientScreen({super.key, required this.client});
  final AdvisorClient client;

  @override
  Widget build(BuildContext context) {
    final gainColor =
        client.gain >= 0 ? AppTheme.positive : AppTheme.negative;
    final dayColor =
        client.dayChange >= 0 ? AppTheme.positive : AppTheme.negative;

    return Scaffold(
      appBar: AppBar(
        title: Text(client.name),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(24),
          child: Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Text('Sola lettura', style: TextStyle(fontSize: 12)),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (client.note != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(client.note!,
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Valore totale',
                      style: Theme.of(context).textTheme.bodyMedium),
                  Text(Fmt.money(client.totalValue),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(
                    '${Fmt.signed(client.gain)} (${Fmt.signedPct(client.gainPercent)})',
                    style: TextStyle(
                        color: gainColor, fontWeight: FontWeight.w600),
                  ),
                  Text('Oggi ${Fmt.signedPct(client.dayChangePercent)}',
                      style: TextStyle(color: dayColor, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          AllocationPie(
            title: 'Allocazione per asset class',
            data: client.byAssetClass,
            total: client.totalValue,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Posizioni',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  for (final p in client.positions)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.holding.symbol,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                Text(p.holding.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(Fmt.money(p.marketValue),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              Text(Fmt.signedPct(p.gainPercent),
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: p.gain >= 0
                                          ? AppTheme.positive
                                          : AppTheme.negative)),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.self_improvement),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Messaggio Wally al cliente (esempio): "Il piano è in '
                      'linea. Nelle giornate storte ricorda perché sei partito: '
                      'il tempo lavora per te." Nella versione reale lo scrive/'
                      'abilita il consulente.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const DisclaimerBanner(margin: EdgeInsets.only(top: 12)),
        ],
      ),
    );
  }
}
