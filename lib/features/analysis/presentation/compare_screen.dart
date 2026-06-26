import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/format.dart';
import '../../market/domain/fundamentals.dart';
import '../../market/providers/market_providers.dart';

class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({super.key});
  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen> {
  final List<String> _symbols = [];
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _add() {
    final s = _input.text.trim().toUpperCase();
    if (s.isEmpty || _symbols.contains(s) || _symbols.length >= 4) return;
    setState(() {
      _symbols.add(s);
      _input.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confronto fondi/ETF')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Aggiungi ticker (es. VWCE.DE)',
                      prefixIcon: Icon(Icons.add),
                    ),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _add, child: const Text('Aggiungi')),
              ],
            ),
          ),
          if (_symbols.isEmpty)
            const Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Aggiungi 2-4 strumenti per confrontarli: stesso indice, '
                    'fondi diversi hanno TER, valuta e distribuzione differenti.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: _table(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _table() {
    return DataTable(
      columnSpacing: 20,
      columns: [
        const DataColumn(label: Text('Metrica')),
        for (final s in _symbols)
          DataColumn(
            label: Row(
              children: [
                Text(s, style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () => setState(() => _symbols.remove(s)),
                ),
              ],
            ),
          ),
      ],
      rows: [
        _row('Nome', (f) => f.name ?? '—'),
        _row('Tipo', (f) => f.isFund ? 'Fondo/ETF' : 'Azione'),
        _row('Categoria/Settore', (f) => f.category ?? f.sector ?? '—'),
        _row('TER', (f) => Fmt.pctFromFraction(f.expenseRatio, decimals: 2)),
        _row('Rendimento', (f) =>
            Fmt.pctFromFraction(f.fundYield ?? f.dividendYield)),
        _row('YTD', (f) => Fmt.pctFromFraction(f.ytdReturn)),
      ],
    );
  }

  DataRow _row(String label, String Function(Fundamentals) value) {
    return DataRow(cells: [
      DataCell(Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
      for (final s in _symbols)
        DataCell(Consumer(builder: (context, ref, _) {
          final f = ref.watch(fundamentalsProvider(s));
          return f.when(
            loading: () => const Text('…'),
            error: (_, _) => const Text('—'),
            data: (data) => Text(value(data)),
          );
        })),
    ]);
  }
}
