import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/format.dart';
import '../../domain/pac_calculator.dart';

/// Grafico della proiezione: capitale versato vs valore atteso nel tempo.
class ProjectionChart extends StatelessWidget {
  const ProjectionChart({super.key, required this.points});
  final List<ProjectionPoint> points;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxY = points.last.value;

    final valueSpots = [
      for (final p in points) FlSpot(p.year.toDouble(), p.value),
    ];
    final contribSpots = [
      for (final p in points) FlSpot(p.year.toDouble(), p.contributed),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _legend(scheme.primary, 'Valore atteso'),
            const SizedBox(width: 16),
            _legend(scheme.outline, 'Versato'),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: maxY * 1.05,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 46,
                    getTitlesWidget: (v, _) => Text(
                      Fmt.compactMoney(v).replaceAll('\$', ''),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: (points.length / 4).ceilToDouble(),
                    getTitlesWidget: (v, _) => Text('${v.toInt()}a',
                        style: const TextStyle(fontSize: 10)),
                  ),
                ),
              ),
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
                  spots: contribSpots,
                  isCurved: false,
                  color: scheme.outline,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                  dashArray: [6, 4],
                ),
                LineChartBarData(
                  spots: valueSpots,
                  isCurved: true,
                  color: scheme.primary,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppTheme.positive.withValues(alpha: 0.10),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _legend(Color c, String label) => Row(
        children: [
          Container(width: 12, height: 12,
              decoration: BoxDecoration(
                  color: c, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 6),
          Text(label),
        ],
      );
}
