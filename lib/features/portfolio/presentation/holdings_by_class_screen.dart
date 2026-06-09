import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/format.dart';
import '../domain/position.dart';
import '../providers/portfolio_providers.dart';

/// Drill-down generico: le posizioni che soddisfano un filtro (per asset class
/// o per settore), aperte dai grafici in dashboard.
class HoldingsFilterScreen extends ConsumerWidget {
  const HoldingsFilterScreen({
    super.key,
    required this.title,
    required this.test,
  });

  final String title;
  final bool Function(Position) test;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positions = ref.watch(positionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: positions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Errore: $e')),
        data: (all) {
          final list = all.where(test).toList()
            ..sort((a, b) => b.marketValue.compareTo(a.marketValue));
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text('Nessuna posizione in $title.',
                    textAlign: TextAlign.center),
              ),
            );
          }
          final total = list.fold<double>(0, (a, p) => a + p.marketValue);
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  '${list.length} posizioni · ${Fmt.money(total)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              for (final p in list) _Tile(position: p),
            ],
          );
        },
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.position});
  final Position position;

  @override
  Widget build(BuildContext context) {
    final h = position.holding;
    final gainColor =
        position.gain >= 0 ? AppTheme.positive : AppTheme.negative;
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(h.symbol.characters.first)),
        title:
            Text(h.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${Fmt.ratio(h.quantity, decimals: h.quantity % 1 == 0 ? 0 : 2)} '
              '× ${Fmt.money(h.avgPrice)}'
              '${position.hasQuote ? '  →  ${Fmt.money(position.currentPrice)}' : ''}',
            ),
            if (position.dayChangePercent != null)
              Text(
                'Oggi ${Fmt.signedPct(position.dayChangePercent!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: position.dayChangePercent! >= 0
                      ? AppTheme.positive
                      : AppTheme.negative,
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(Fmt.money(position.marketValue),
                style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              '${Fmt.signed(position.gain)} (${Fmt.signedPct(position.gainPercent)})',
              style: TextStyle(color: gainColor, fontSize: 12),
            ),
          ],
        ),
        onTap: () => context.go('/analysis/${h.symbol}'),
      ),
    );
  }
}
