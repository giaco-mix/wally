import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/format.dart';
import '../../../rebalance/providers/rebalance_providers.dart';

class RebalanceAlert extends ConsumerWidget {
  const RebalanceAlert({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(rebalanceAlertsProvider);
    if (alerts.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: scheme.onErrorContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Portafoglio sbilanciato',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: scheme.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Queste asset class si discostano di oltre '
              '${kRebalanceThresholdPct.round()} punti dal target:',
              style: TextStyle(color: scheme.onErrorContainer),
            ),
            const SizedBox(height: 8),
            ...alerts.map((r) {
              final over = r.deviationPct > 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '• ${r.assetClass.label}: ${Fmt.pct(r.currentPct)} '
                  'su target ${Fmt.pct(r.targetPct)} '
                  '(${over ? 'sovrappeso' : 'sottopeso'} '
                  '${Fmt.signedPct(r.deviationPct)})',
                  style: TextStyle(color: scheme.onErrorContainer),
                ),
              );
            }),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => context.go('/rebalance'),
                icon: const Icon(Icons.balance),
                label: const Text('Vai al ribilanciamento'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
