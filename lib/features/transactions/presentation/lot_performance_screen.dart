import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/disclaimer_banner.dart';
import '../domain/lot_performance.dart';
import '../providers/transactions_providers.dart';

/// "Rendimento accumuli": per ogni titolo mostra come sta andando **ogni
/// singolo accumulo** (lotto) rispetto al suo prezzo d'ingresso, più
/// l'aggregato per titolo e per portafoglio.
class LotPerformanceScreen extends ConsumerWidget {
  const LotPerformanceScreen({super.key});

  static String _d(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perf = ref.watch(lotPerformanceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Rendimento accumuli')),
      body: perf.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Errore: $e')),
        data: (symbols) {
          if (symbols.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Registra le operazioni del tuo PAC (in Transazioni) per '
                  'vedere come sta andando ogni singolo accumulo.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _PortfolioSummary(symbols: symbols),
              const SizedBox(height: 8),
              for (final s in symbols) _SymbolCard(perf: s),
              const DisclaimerBanner(margin: EdgeInsets.only(top: 8)),
            ],
          );
        },
      ),
    );
  }
}

Color _gainColor(double? pct) =>
    (pct ?? 0) >= 0 ? AppTheme.positive : AppTheme.negative;

class _PortfolioSummary extends StatelessWidget {
  const _PortfolioSummary({required this.symbols});
  final List<SymbolPerformance> symbols;

  @override
  Widget build(BuildContext context) {
    final invested = symbols.fold<double>(0, (a, s) => a + s.invested);
    final current = symbols.fold<double>(
        0, (a, s) => a + (s.currentValue ?? s.invested));
    final dividends =
        symbols.fold<double>(0, (a, s) => a + s.dividendsReceived);
    final gain = current - invested + dividends;
    final gainPct = invested == 0 ? 0.0 : gain / invested * 100;
    final scheme = Theme.of(context).colorScheme;

    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Totale investito ${Fmt.money(invested)}',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(Fmt.money(current),
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(
              '${Fmt.signed(gain)}  (${Fmt.signedPct(gainPct)})',
              style: TextStyle(
                  color: _gainColor(gainPct), fontWeight: FontWeight.w600),
            ),
            if (dividends > 0)
              Text('di cui dividendi ${Fmt.money(dividends)}',
                  style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _SymbolCard extends StatelessWidget {
  const _SymbolCard({required this.perf});
  final SymbolPerformance perf;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        title: Row(
          children: [
            Expanded(
              child: Text(perf.symbol,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Text(
              perf.gainPercent == null
                  ? '—'
                  : Fmt.signedPct(perf.gainPercent!),
              style: TextStyle(
                color: _gainColor(perf.gainPercent),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        subtitle: Text(
          '${perf.lots.length} accumuli · investito ${Fmt.money(perf.invested)}'
          '${perf.currentValue != null ? ' → ${Fmt.money(perf.currentValue)}' : ''}'
          '${perf.dividendsReceived > 0 ? ' · dividendi ${Fmt.money(perf.dividendsReceived)} (tot ${perf.totalReturnPercent == null ? '—' : Fmt.signedPct(perf.totalReturnPercent!)})' : ''}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        children: [
          for (final lp in perf.lots) _LotRow(lp: lp),
        ],
      ),
    );
  }
}

class _LotRow extends StatelessWidget {
  const _LotRow({required this.lp});
  final LotPerformance lp;

  @override
  Widget build(BuildContext context) {
    final lot = lp.lot;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(LotPerformanceScreen._d(lot.date),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  '${lot.kind.label} · '
                  '${Fmt.ratio(lot.quantity, decimals: lot.quantity % 1 == 0 ? 0 : 4)} '
                  '× ${Fmt.money(lot.price)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                lp.gainPercent == null ? '—' : Fmt.signedPct(lp.gainPercent!),
                style: TextStyle(
                    color: _gainColor(lp.gainPercent),
                    fontWeight: FontWeight.w600),
              ),
              if (lp.gain != null)
                Text(Fmt.signed(lp.gain!),
                    style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
