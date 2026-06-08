import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/format.dart';
import '../../../shared/widgets/disclaimer_banner.dart';
import '../../market/domain/fundamentals.dart';
import '../../market/providers/market_providers.dart';
import 'widgets/health_score_card.dart';
import 'widgets/price_history_chart.dart';

class StockDetailScreen extends ConsumerWidget {
  const StockDetailScreen({super.key, required this.symbol});
  final String symbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(fundamentalsProvider(symbol));

    return Scaffold(
      appBar: AppBar(title: Text(symbol.toUpperCase())),
      body: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Impossibile caricare i dati: $e',
                textAlign: TextAlign.center),
          ),
        ),
        data: (f) => _Body(f: f),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.f});
  final Fundamentals f;

  List<_Metric> _equityMetrics() => [
        _Metric('Capitalizzazione', Fmt.compactMoney(f.marketCap)),
        _Metric('P/E (trailing)', Fmt.ratio(f.trailingPe)),
        _Metric('P/E (forward)', Fmt.ratio(f.forwardPe)),
        _Metric('Prezzo / Valore contabile', Fmt.ratio(f.priceToBook)),
        _Metric('ROE', Fmt.pctFromFraction(f.returnOnEquity)),
        _Metric('Margine netto', Fmt.pctFromFraction(f.profitMargins)),
        _Metric('Debito / Equity', Fmt.ratio(f.debtToEquity)),
        _Metric('Current ratio', Fmt.ratio(f.currentRatio)),
        _Metric('Dividend yield', Fmt.pctFromFraction(f.dividendYield)),
        _Metric('Beta', Fmt.ratio(f.beta)),
        _Metric('Crescita ricavi', Fmt.pctFromFraction(f.revenueGrowth)),
      ];

  /// Metriche rilevanti per un ETF/fondo (no P/E da singola azienda).
  List<_Metric> _fundMetrics() => [
        _Metric('Costo annuo (TER)', Fmt.pctFromFraction(f.expenseRatio)),
        _Metric('Rendimento distribuzione', Fmt.pctFromFraction(f.fundYield)),
        _Metric('Rendimento YTD', Fmt.pctFromFraction(f.ytdReturn)),
        _Metric('Beta', Fmt.ratio(f.beta)),
        _Metric('Patrimonio', Fmt.compactMoney(f.marketCap)),
      ];

  @override
  Widget build(BuildContext context) {
    final isFund = f.isFund;
    final metrics = isFund ? _fundMetrics() : _equityMetrics();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(f.name ?? f.symbol,
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: [
            if (isFund)
              Chip(
                label: Text(f.quoteType == 'MUTUALFUND' ? 'Fondo' : 'ETF'),
                visualDensity: VisualDensity.compact,
              ),
            if (isFund && f.category != null)
              Chip(label: Text(f.category!),
                  visualDensity: VisualDensity.compact),
            if (!isFund && f.sector != null) Chip(label: Text(f.sector!)),
            if (!isFund && f.industry != null)
              Chip(label: Text(f.industry!), visualDensity: VisualDensity.compact),
          ],
        ),
        const SizedBox(height: 16),
        if (isFund)
          const _FundNote()
        else
          HealthScoreCard(fundamentals: f),
        const SizedBox(height: 16),
        PriceHistoryChart(symbol: f.symbol),
        const SizedBox(height: 16),
        LayoutBuilder(builder: (context, c) {
          final cross = c.maxWidth >= 720 ? 3 : (c.maxWidth >= 420 ? 2 : 1);
          return GridView.count(
            crossAxisCount: cross,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [for (final m in metrics) _MetricCard(metric: m)],
          );
        }),
        if (isFund && f.topHoldings.isNotEmpty) ...[
          const SizedBox(height: 24),
          _TopHoldings(holdings: f.topHoldings),
        ],
        if (f.summary != null) ...[
          const SizedBox(height: 24),
          Text('Profilo', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(f.summary!, style: Theme.of(context).textTheme.bodyMedium),
        ],
        const DisclaimerBanner(margin: EdgeInsets.only(top: 24)),
      ],
    );
  }
}

/// Nota esplicativa per ETF/fondi: niente metriche da singola azienda.
class _FundNote extends StatelessWidget {
  const _FundNote();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.account_balance_outlined, color: scheme.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'È un ETF/fondo: raccoglie tanti titoli, quindi non ha metriche '
                'da singola azienda (P/E, ROE…). Quello che conta è il costo '
                'annuo (TER), cosa contiene e quanto è diversificato.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Principali partecipazioni di un ETF/fondo.
class _TopHoldings extends StatelessWidget {
  const _TopHoldings({required this.holdings});
  final List<FundHolding> holdings;

  @override
  Widget build(BuildContext context) {
    final shown = holdings.take(10).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Principali partecipazioni',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final h in shown)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(h.name,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Text(Fmt.pctFromFraction(h.weight),
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Metric {
  const _Metric(this.label, this.value);
  final String label;
  final String value;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});
  final _Metric metric;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(metric.label,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(metric.value,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
