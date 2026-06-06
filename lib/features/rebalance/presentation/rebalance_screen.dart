import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/disclaimer_banner.dart';
import '../../portfolio/domain/holding.dart';
import '../../portfolio/providers/portfolio_providers.dart';
import '../domain/rebalance.dart';
import '../domain/rebalance_settings.dart';
import '../providers/rebalance_providers.dart';

class RebalanceScreen extends ConsumerWidget {
  const RebalanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(rebalancePlanProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ribilanciamento')),
      body: plan.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Errore: $e')),
        data: (p) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _ScheduleCard(),
            const SizedBox(height: 16),
            const _TargetEditor(),
            const SizedBox(height: 16),
            _PlanCard(plan: p),
            const DisclaimerBanner(margin: EdgeInsets.only(top: 16)),
          ],
        ),
      ),
    );
  }
}

class _ScheduleCard extends ConsumerWidget {
  const _ScheduleCard();

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(rebalanceSettingsControllerProvider);
    return async.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => Card(
          child: Padding(padding: const EdgeInsets.all(16), child: Text('Errore: $e'))),
      data: (s) {
        final scheme = Theme.of(context).colorScheme;
        final notifier = ref.read(rebalanceSettingsControllerProvider.notifier);
        return Card(
          color: s.isDue ? scheme.errorContainer : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.event_repeat, color: scheme.primary),
                    const SizedBox(width: 8),
                    Text('Ribilanciamento periodico',
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Ribilanciare a intervalli regolari aiuta a mantenere la rotta '
                  'senza farsi guidare dall\'emotività.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final f in RebalanceFrequency.values)
                      ChoiceChip(
                        label: Text(f.label),
                        selected: s.frequency == f,
                        onSelected: (_) => notifier.setFrequency(f),
                      ),
                  ],
                ),
                if (s.frequency != RebalanceFrequency.none) ...[
                  const SizedBox(height: 12),
                  Text(
                    s.isDue
                        ? '⏰ È ora di ribilanciare!'
                        : 'Prossimo controllo: ${s.nextDate != null ? _fmtDate(s.nextDate!) : '—'}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: s.isDue ? scheme.onErrorContainer : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => notifier.markRebalanced(),
                    icon: const Icon(Icons.check),
                    label: const Text('Segna come ribilanciato oggi'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TargetEditor extends ConsumerStatefulWidget {
  const _TargetEditor();

  @override
  ConsumerState<_TargetEditor> createState() => _TargetEditorState();
}

class _TargetEditorState extends ConsumerState<_TargetEditor> {
  Map<String, double>? _draft;
  bool _saving = false;

  Map<String, double> _ensure(Map<String, double> fromRepo) {
    return _draft ??= {
      for (final ac in AssetClass.values) ac.name: fromRepo[ac.name] ?? 0,
    };
  }

  double get _sum => (_draft ?? const {}).values.fold(0, (a, b) => a + b);

  Future<void> _save() async {
    setState(() => _saving = true);
    final cleaned = {
      for (final e in _draft!.entries)
        if (e.value > 0) e.key: e.value,
    };
    try {
      await ref.read(targetsControllerProvider.notifier).save(cleaned);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Allocazione target salvata')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final targets = ref.watch(targetsControllerProvider);
    return targets.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('Errore: $e'))),
      data: (repoTargets) {
        final draft = _ensure(repoTargets);
        final sum = _sum;
        final sumOk = (sum - 100).abs() < 0.01;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Allocazione target',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Imposta la percentuale obiettivo per ciascuna asset class.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                for (final ac in AssetClass.values)
                  _TargetRow(
                    label: ac.label,
                    value: draft[ac.name] ?? 0,
                    onChanged: (v) =>
                        setState(() => draft[ac.name] = v.roundToDouble()),
                  ),
                const Divider(),
                Row(
                  children: [
                    Text('Totale: ${Fmt.pct(sum, decimals: 0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: sumOk
                              ? AppTheme.positive
                              : Theme.of(context).colorScheme.error,
                        )),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: (_saving || !sumOk) ? null : _save,
                      icon: const Icon(Icons.save_outlined),
                      label: Text(sumOk ? 'Salva' : 'Deve fare 100%'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TargetRow extends StatelessWidget {
  const _TargetRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 110, child: Text(label)),
        Expanded(
          // Associa lo slider all'asset class: lo screen reader annuncia
          // "<asset class>: N%" invece del solo valore.
          child: Semantics(
            label: 'Allocazione target $label',
            child: Slider(
              value: value.clamp(0, 100),
              max: 100,
              divisions: 100,
              label: '${value.round()}%',
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 48,
          child: Text('${value.round()}%', textAlign: TextAlign.end),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan});
  final RebalancePlan plan;

  @override
  Widget build(BuildContext context) {
    if (plan.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Aggiungi posizioni e imposta un\'allocazione target per vedere '
            'il piano di ribilanciamento.',
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Piano di ribilanciamento',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Valore totale: ${Fmt.money(plan.total)}',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 24,
                columns: const [
                  DataColumn(label: Text('Asset class')),
                  DataColumn(label: Text('Attuale'), numeric: true),
                  DataColumn(label: Text('Target'), numeric: true),
                  DataColumn(label: Text('Scostam.'), numeric: true),
                  DataColumn(label: Text('Azione'), numeric: true),
                ],
                rows: [
                  for (final r in plan.rows)
                    DataRow(cells: [
                      DataCell(Text(r.assetClass.label)),
                      DataCell(Text(Fmt.pct(r.currentPct))),
                      DataCell(Text(Fmt.pct(r.targetPct))),
                      DataCell(Text(Fmt.signedPct(r.deviationPct))),
                      DataCell(_ActionCell(row: r)),
                    ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCell extends StatelessWidget {
  const _ActionCell({required this.row});
  final RebalanceRow row;

  @override
  Widget build(BuildContext context) {
    if (row.delta.abs() < 1) {
      return const Text('In linea');
    }
    final color = row.isBuy ? AppTheme.positive : AppTheme.negative;
    final verb = row.isBuy ? 'Compra' : 'Vendi';
    return Text(
      '$verb ${Fmt.money(row.delta.abs())}',
      style: TextStyle(color: color, fontWeight: FontWeight.w600),
    );
  }
}
