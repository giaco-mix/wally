import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/format.dart';
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

  @override
  Widget build(BuildContext context) {
    final metrics = <_Metric>[
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(f.name ?? f.symbol,
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: [
            if (f.sector != null) Chip(label: Text(f.sector!)),
            if (f.industry != null)
              Chip(label: Text(f.industry!), visualDensity: VisualDensity.compact),
          ],
        ),
        const SizedBox(height: 16),
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
        if (f.summary != null) ...[
          const SizedBox(height: 24),
          Text('Profilo', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(f.summary!, style: Theme.of(context).textTheme.bodyMedium),
        ],
        const SizedBox(height: 24),
        Card(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Le informazioni mostrate hanno scopo puramente informativo e '
              'non costituiscono consulenza finanziaria.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
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
