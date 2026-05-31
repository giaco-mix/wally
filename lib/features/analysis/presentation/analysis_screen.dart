import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../market/providers/market_providers.dart';

class AnalysisScreen extends ConsumerStatefulWidget {
  const AnalysisScreen({super.key});

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(symbolSearchProvider(_query));

    return Scaffold(
      appBar: AppBar(title: const Text('Analisi fondamentale')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Cerca un titolo o ETF',
                hintText: 'es. Apple, AAPL, VWCE',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: _query.trim().length < 2
                ? const _Hint()
                : results.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Errore: $e')),
                    data: (list) {
                      if (list.isEmpty) {
                        return const Center(child: Text('Nessun risultato'));
                      }
                      return ListView.separated(
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final r = list[i];
                          return ListTile(
                            leading: const Icon(Icons.show_chart),
                            title: Text(r.symbol),
                            subtitle: Text(r.name),
                            trailing: Text(
                              [r.type, r.exchange]
                                  .where((e) => e != null && e.isNotEmpty)
                                  .join(' · '),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            onTap: () => context.go('/analysis/${r.symbol}'),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.insights_outlined, size: 64),
            SizedBox(height: 16),
            Text(
              'Cerca un titolo per vedere i suoi indicatori fondamentali: '
              'P/E, ROE, margini, debito, dividendi e altro.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
