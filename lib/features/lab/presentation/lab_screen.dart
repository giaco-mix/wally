import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/disclaimer_banner.dart';
import '../../instruments/domain/instrument_pick.dart';
import '../../market/domain/price_point.dart';
import '../../market/providers/market_providers.dart';
import '../domain/backtest.dart';

const _benchmarks = <(String, String)>[
  ('S&P 500', '^GSPC'),
  ('Nasdaq 100', '^NDX'),
  ('MSCI World (ETF)', 'SWDA.MI'),
  ('Euro Stoxx 50', '^STOXX50E'),
  ('FTSE MIB', 'FTSEMIB.MI'),
];

/// Laboratorio: costruisci un portafoglio e confrontalo con un benchmark
/// (backtest storico). Sandbox educativa, non tocca il portafoglio reale.
class LabScreen extends ConsumerStatefulWidget {
  const LabScreen({super.key});

  @override
  ConsumerState<LabScreen> createState() => _LabScreenState();
}

class _LabScreenState extends ConsumerState<LabScreen> {
  String _benchmark = '^GSPC';
  HistoryRange _range = HistoryRange.fiveYears;
  final List<String> _symbols = [];
  final Map<String, TextEditingController> _weights = {};
  bool _loading = false;
  String? _error;
  BacktestResult? _result;

  @override
  void dispose() {
    for (final c in _weights.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _addSymbol(String symbol) {
    final s = symbol.trim().toUpperCase();
    if (s.isEmpty || _symbols.contains(s)) return;
    setState(() {
      _symbols.add(s);
      _weights[s] = TextEditingController(text: '25');
    });
  }

  void _removeSymbol(String s) {
    setState(() {
      _symbols.remove(s);
      _weights.remove(s)?.dispose();
    });
  }

  double get _weightSum => _symbols.fold(
      0, (a, s) => a + (double.tryParse(_weights[s]!.text.replaceAll(',', '.')) ?? 0));

  Future<void> _run() async {
    if (_symbols.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final want = {_benchmark, ..._symbols};
      final entries = await Future.wait(want.map((s) async {
        final h = await ref.read(
            priceHistoryProvider((symbol: s, range: _range)).future);
        return MapEntry(s, h.points);
      }));
      final histories = {for (final e in entries) e.key: e.value};

      final bench = histories[_benchmark] ?? const <PricePoint>[];
      final comps = {
        for (final s in _symbols) s: histories[s] ?? const <PricePoint>[],
      };
      final weights = {
        for (final s in _symbols)
          s: double.tryParse(_weights[s]!.text.replaceAll(',', '.')) ?? 0,
      };

      final res = Backtest.run(
        components: comps,
        weights: weights,
        benchmark: bench,
        periodsPerYear: _range.periodsPerYear,
      );
      setState(() {
        _result = res;
        if (res == null) {
          _error =
              'Dati insufficienti o non sovrapponibili (controlla i ticker e '
              'che abbiano storico comune).';
        }
      });
    } catch (e) {
      setState(() => _error = 'Errore nel recupero dati: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sum = _weightSum;
    return Scaffold(
      appBar: AppBar(title: const Text('Laboratorio')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Costruisci un portafoglio e vedi come si sarebbe comportato nel '
            'passato rispetto a un indice di riferimento. È una simulazione '
            'storica (backtest): il passato non garantisce il futuro.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _benchmark,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Benchmark'),
                  items: [
                    for (final b in _benchmarks)
                      DropdownMenuItem(value: b.$2, child: Text(b.$1)),
                  ],
                  onChanged: (v) => setState(() => _benchmark = v ?? _benchmark),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<HistoryRange>(
                value: _range,
                items: const [
                  DropdownMenuItem(
                      value: HistoryRange.oneYear, child: Text('1 anno')),
                  DropdownMenuItem(
                      value: HistoryRange.fiveYears, child: Text('5 anni')),
                ],
                onChanged: (v) => setState(() => _range = v ?? _range),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Il tuo portafoglio',
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              TextButton.icon(
                onPressed: _pickInstrument,
                icon: const Icon(Icons.add),
                label: const Text('Aggiungi'),
              ),
            ],
          ),
          if (_symbols.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('Aggiungi qualche strumento e imposta i pesi (%).'),
            ),
          for (final s in _symbols)
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    Expanded(child: Text(s)),
                    SizedBox(
                      width: 70,
                      child: TextField(
                        controller: _weights[s],
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        decoration: const InputDecoration(suffixText: '%'),
                        textAlign: TextAlign.end,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _removeSymbol(s),
                    ),
                  ],
                ),
              ),
            ),
          if (_symbols.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Somma pesi: ${Fmt.pct(sum, decimals: 0)} '
                '${(sum - 100).abs() < 0.5 ? '' : '(verrà normalizzata a 100%)'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: (_loading || _symbols.isEmpty) ? null : _run,
            icon: _loading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.play_arrow),
            label: const Text('Esegui backtest'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          if (_result != null) ...[
            const SizedBox(height: 16),
            _Chart(result: _result!),
            const SizedBox(height: 12),
            _MetricsTable(result: _result!),
          ],
          const DisclaimerBanner(margin: EdgeInsets.only(top: 16)),
        ],
      ),
    );
  }

  Future<void> _pickInstrument() async {
    final custom = TextEditingController();
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: custom,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Ticker (o scegli sotto)',
                    hintText: 'es. SWDA.MI, ^GSPC',
                    suffixIcon: Icon(Icons.check),
                  ),
                  onSubmitted: (v) => Navigator.pop(ctx, v),
                ),
              ),
              const Divider(),
              for (final p in instrumentCatalog)
                ListTile(
                  dense: true,
                  title: Text(p.ticker),
                  subtitle: Text(p.name,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  onTap: () => Navigator.pop(ctx, p.ticker),
                ),
            ],
          ),
        ),
      ),
    );
    custom.dispose();
    if (picked != null) _addSymbol(picked);
  }
}

class _Chart extends StatelessWidget {
  const _Chart({required this.result});
  final BacktestResult result;

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots(List<SeriesPoint> s) => [
          for (var i = 0; i < s.length; i++) FlSpot(i.toDouble(), s[i].value),
        ];
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _legend(context, 'Tuo portafoglio', scheme.primary),
                const SizedBox(width: 16),
                _legend(context, 'Benchmark', AppTheme.negative),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots(result.portfolio),
                      isCurved: false,
                      color: scheme.primary,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: spots(result.benchmark),
                      isCurved: false,
                      color: AppTheme.negative,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text('Base 100 all\'inizio del periodo.',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _legend(BuildContext context, String label, Color color) => Row(
        children: [
          Container(width: 12, height: 12, color: color),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      );
}

class _MetricsTable extends StatelessWidget {
  const _MetricsTable({required this.result});
  final BacktestResult result;

  @override
  Widget build(BuildContext context) {
    final p = result.portfolioMetrics;
    final b = result.benchmarkMetrics;
    Widget row(String label, String port, String bench) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(flex: 2, child: Text(label)),
              Expanded(
                  child: Text(port,
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontWeight: FontWeight.w600))),
              Expanded(
                  child: Text(bench,
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.bodySmall)),
            ],
          ),
        );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(flex: 2, child: Text('Metrica')),
                const Expanded(
                    child: Text('Tuo',
                        textAlign: TextAlign.end,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('Bench',
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.bodySmall)),
              ],
            ),
            const Divider(),
            row('Rendimento totale', Fmt.signedPct(p.totalReturnPct),
                Fmt.signedPct(b.totalReturnPct)),
            row('Rendimento annuo', Fmt.signedPct(p.annualReturnPct),
                Fmt.signedPct(b.annualReturnPct)),
            row('Volatilità (ann.)', Fmt.pct(p.volatilityPct),
                Fmt.pct(b.volatilityPct)),
            row('Max drawdown', Fmt.pct(p.maxDrawdownPct),
                Fmt.pct(b.maxDrawdownPct)),
            row('Sharpe', Fmt.ratio(p.sharpe), Fmt.ratio(b.sharpe)),
            const Divider(),
            row('Correlazione col benchmark', Fmt.ratio(result.correlation), ''),
            const SizedBox(height: 8),
            Text(
              'Sharpe = rendimento per unità di rischio (più alto è meglio). '
              'Max drawdown = la caduta peggiore dal picco. Backtest semplificato '
              'senza ribilanciamento, dividendi o commissioni.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
