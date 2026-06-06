import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../shared/format.dart';

class AllocationPie extends StatelessWidget {
  const AllocationPie({
    super.key,
    required this.title,
    required this.data,
    required this.total,
  });

  final String title;
  final Map<String, double> data;
  final double total;

  static const _palette = [
    Color(0xFF1565C0),
    Color(0xFF2E7D32),
    Color(0xFFEF6C00),
    Color(0xFF6A1B9A),
    Color(0xFF00838F),
    Color(0xFFC62828),
    Color(0xFF558B2F),
    Color(0xFF4527A0),
  ];

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            // Il grafico è puramente visivo: la legenda sotto espone gli stessi
            // dati in forma testuale e accessibile.
            ExcludeSemantics(
              child: SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 44,
                  sections: [
                    for (var i = 0; i < entries.length; i++)
                      PieChartSectionData(
                        value: entries[i].value,
                        color: _palette[i % _palette.length],
                        title: total == 0
                            ? ''
                            : '${(entries[i].value / total * 100).round()}%',
                        radius: 48,
                        titleStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            ),
            const SizedBox(height: 16),
            ...[
              for (var i = 0; i < entries.length; i++)
                Builder(builder: (context) {
                  final pct = total == 0
                      ? '0'
                      : (entries[i].value / total * 100).toStringAsFixed(1);
                  final valueLabel = '${Fmt.money(entries[i].value)}  ($pct%)';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Semantics(
                      label: '${entries[i].key}: $valueLabel',
                      excludeSemantics: true,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _palette[i % _palette.length],
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(entries[i].key,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                          Text(
                            valueLabel,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ],
        ),
      ),
    );
  }
}
