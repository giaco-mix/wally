import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/format.dart';
import '../../../market/domain/price_point.dart';
import '../../../market/providers/market_providers.dart';

class PriceHistoryChart extends ConsumerStatefulWidget {
  const PriceHistoryChart({super.key, required this.symbol});
  final String symbol;

  @override
  ConsumerState<PriceHistoryChart> createState() => _PriceHistoryChartState();
}

class _PriceHistoryChartState extends ConsumerState<PriceHistoryChart> {
  HistoryRange _range = HistoryRange.sixMonths;

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(
      priceHistoryProvider((symbol: widget.symbol, range: _range)),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Andamento prezzo',
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                SegmentedButton<HistoryRange>(
                  showSelectedIcon: false,
                  segments: [
                    for (final r in HistoryRange.values)
                      ButtonSegment(value: r, label: Text(r.label)),
                  ],
                  selected: {_range},
                  onSelectionChanged: (s) => setState(() => _range = s.first),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: history.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text('Storico non disponibile: $e')),
                data: (h) => h.isEmpty
                    ? const Center(child: Text('Nessun dato storico'))
                    : _Chart(history: h),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  const _Chart({required this.history});
  final PriceHistory history;

  @override
  Widget build(BuildContext context) {
    final pts = history.points;
    final up = (history.changePercent ?? 0) >= 0;
    final color = up ? AppTheme.positive : AppTheme.negative;

    final spots = <FlSpot>[
      for (var i = 0; i < pts.length; i++) FlSpot(i.toDouble(), pts[i].close),
    ];
    final minY = pts.map((p) => p.close).reduce((a, b) => a < b ? a : b);
    final maxY = pts.map((p) => p.close).reduce((a, b) => a > b ? a : b);
    final pad = (maxY - minY) * 0.08;

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '${Fmt.signedPct(history.changePercent ?? 0)} nel periodo',
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: LineChart(
            LineChartData(
              minY: minY - pad,
              maxY: maxY + pad,
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) => spots.map((s) {
                    return LineTooltipItem(
                      Fmt.money(s.y),
                      const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  }).toList(),
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
      ],
    );
  }
}
