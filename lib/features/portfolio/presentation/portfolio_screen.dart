import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/format.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/position.dart';
import '../providers/portfolio_providers.dart';
import 'holding_form.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positions = ref.watch(positionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portafoglio'),
        actions: [
          IconButton(
            tooltip: 'Aggiorna quotazioni',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(quotesProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showHoldingForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Aggiungi'),
      ),
      body: positions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Errore: $e')),
        data: (list) {
          if (list.isEmpty) return const _EmptyState();
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(holdingsControllerProvider);
              ref.invalidate(quotesProvider);
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _PositionTile(position: list[i]),
            ),
          );
        },
      ),
    );
  }
}

class _PositionTile extends ConsumerWidget {
  const _PositionTile({required this.position});
  final Position position;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final h = position.holding;
    final gainColor =
        position.gain >= 0 ? AppTheme.positive : AppTheme.negative;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(child: Text(h.symbol.characters.first)),
        title: Row(
          children: [
            Text(h.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Chip(
              label: Text(h.assetClass.label),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            ),
          ],
        ),
        subtitle: Text(
          '${Fmt.ratio(h.quantity, decimals: h.quantity % 1 == 0 ? 0 : 2)} '
          '× ${Fmt.money(h.avgPrice)}'
          '${position.hasQuote ? '  →  ${Fmt.money(position.currentPrice)}' : ''}',
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
        onTap: () => _showActions(context, ref),
      ),
    );
  }

  void _showActions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.insights),
              title: const Text('Analisi fondamentale'),
              onTap: () {
                Navigator.pop(context);
                context.go('/analysis/${position.holding.symbol}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifica'),
              onTap: () {
                Navigator.pop(context);
                showHoldingForm(context, existing: position.holding);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Elimina'),
              onTap: () async {
                Navigator.pop(context);
                await ref
                    .read(holdingsControllerProvider.notifier)
                    .delete(position.holding.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_balance_wallet_outlined, size: 64),
            const SizedBox(height: 16),
            Text('Nessuna posizione',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              'Aggiungi i tuoi titoli, ETF o liquidità per iniziare a '
              'monitorare e ribilanciare il portafoglio.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
