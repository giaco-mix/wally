import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/format.dart';
import '../../../portfolio/domain/portfolio_snapshot.dart';
import '../../../portfolio/providers/portfolio_providers.dart';

/// Mostra la curva del valore del portafoglio nel tempo e registra lo
/// snapshot del giorno corrente.
class PerformanceChart extends ConsumerStatefulWidget {
  const PerformanceChart({super.key, required this.currentValue});
  final double currentValue;

  @override
  ConsumerState<PerformanceChart> createState() => _PerformanceChartState();
}

class _PerformanceChartState extends ConsumerState<PerformanceChart> {
  @override
  void initState() {
    super.initState();
    _record();
  }

  @override
  void didUpdateWidget(PerformanceChart old) {
    super.didUpdateWidget(old);
    if (old.currentValue != widget.currentValue) _record();
  }

  void _record() {
    final value = widget.currentValue;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(performanceControllerProvider.notifier).recordToday(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final snapshots = ref.watch(performanceControllerProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Performance nel tempo',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: snapshots.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Storico non disponibile: $e')),
                data: (list) => list.length < 2
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'Serve almeno qualche giorno di dati: la curva si '
                            'popolerà man mano che apri l\'app.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : _Chart(snapshots: list),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  const _Chart({required this.snapshots});
  final List<PortfolioSnapshot> snapshots;

  @override
  Widget build(BuildContext context) {
    final first = snapshots.first.totalValue;
    final last = snapshots.last.totalValue;
    final changePct = first == 0 ? 0.0 : (last - first) / first * 100;
    final up = changePct >= 0;
    final color = up ? AppTheme.positive : AppTheme.negative;

    final spots = <FlSpot>[
      for (var i = 0; i < snapshots.length; i++)
        FlSpot(i.toDouble(), snapshots[i].totalValue),
    ];
    final values = snapshots.map((s) => s.totalValue);
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final pad = (maxY - minY) * 0.1 + 1;

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '${Fmt.signedPct(changePct)} dall\'inizio del periodo',
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          // Il canvas del grafico non è leggibile dagli screen reader: forniamo
          // un riepilogo testuale equivalente.
          child: Semantics(
            label: 'Andamento del valore del portafoglio da '
                '${Fmt.money(first)} a ${Fmt.money(last)}, '
                '${Fmt.signedPct(changePct)} dall\'inizio del periodo.',
            excludeSemantics: true,
            child: LineChart(
            LineChartData(
              minY: minY - pad,
              maxY: maxY + pad,
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (items) => items
                      .map((s) => LineTooltipItem(
                            Fmt.money(s.y),
                            const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ))
                      .toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: color,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: color.withValues(alpha: 0.12),
                  ),
                ),
              ],
            ),
          ),
          ),
        ),
      ],
    );
  }
}
