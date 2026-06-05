import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/format.dart';
import '../../../portfolio/providers/portfolio_providers.dart';

/// Card "Costi & Netto": stima del costo annuo (TER + canoni broker) e valore
/// netto del portafoglio.
class CostsCard extends ConsumerWidget {
  const CostsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final costsAsync = ref.watch(portfolioCostsProvider);
    return costsAsync.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (c) {
        if (c.portfolioValue <= 0) return const SizedBox.shrink();
        final scheme = Theme.of(context).colorScheme;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.percent, color: scheme.primary),
                    const SizedBox(width: 8),
                    Text('Costi & Netto',
                        style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.go('/brokers'),
                      child: const Text('Piattaforme'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _row(context, 'Costo annuo stimato',
                    '${Fmt.money(c.totalAnnual)}  (${Fmt.pct(c.totalAnnualPct, decimals: 2)})'),
                _row(context, '· di cui TER fondi', Fmt.money(c.terAnnual)),
                _row(context, '· di cui canoni broker',
                    Fmt.money(c.brokerFeesAnnual)),
                const Divider(),
                _row(
                  context,
                  'Valore netto stimato a 1 anno',
                  Fmt.money(c.netValueOneYear),
                  highlight: true,
                ),
                const SizedBox(height: 6),
                Text(
                  'A parità di prezzi: è quanto resterebbe dopo un anno di costi. '
                  'Imposta il TER nelle posizioni e i canoni in Piattaforme.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _row(BuildContext context, String k, String v,
      {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(k)),
          Text(v,
              style: TextStyle(
                fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
                color: highlight ? Theme.of(context).colorScheme.primary : null,
              )),
        ],
      ),
    );
  }
}
