import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/format.dart';
import '../../../shared/widgets/disclaimer_banner.dart';
import '../domain/investment_plan.dart';
import '../providers/plan_providers.dart';
import 'widgets/projection_chart.dart';

class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(planControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Il tuo piano'),
        actions: [
          IconButton(
            tooltip: 'Modifica',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.go('/onboarding'),
          ),
        ],
      ),
      body: planAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Errore: $e')),
        data: (plan) =>
            plan == null ? const _NoPlan() : _PlanView(plan: plan),
      ),
    );
  }
}

class _NoPlan extends StatelessWidget {
  const _NoPlan();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.flag_outlined, size: 56),
            const SizedBox(height: 16),
            Text('Non hai ancora un piano',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Bastano due minuti: definiamo un obiettivo e un piano di '
              'accumulo su misura per te.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => context.go('/onboarding'),
              icon: const Icon(Icons.add),
              label: const Text('Crea il tuo piano'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanView extends StatelessWidget {
  const _PlanView({required this.plan});
  final InvestmentPlan plan;

  @override
  Widget build(BuildContext context) {
    final lazy = plan.lazyPortfolio;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header obiettivo
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(plan.goalType.icon, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan.goalLabel ?? plan.goalType.label,
                          style: Theme.of(context).textTheme.titleLarge),
                      Text('Profilo ${plan.riskProfile.label} · '
                          '${plan.horizonYears} anni'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Numeri chiave
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _kv(context, 'Versamento mensile',
                    Fmt.money(plan.monthlyContribution)),
                const Divider(),
                _kv(context, 'Valore atteso a ${plan.horizonYears} anni',
                    Fmt.money(plan.projectedValue), highlight: true),
                const Divider(),
                _kv(context, 'Totale versato', Fmt.money(plan.totalContributed)),
                const Divider(),
                _kv(context, 'Crescita attesa',
                    Fmt.money(plan.projectedValue - plan.totalContributed)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Proiezione
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Proiezione',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Stima al ${Fmt.pct(plan.riskProfile.expectedReturn * 100)} medio annuo. '
                  'È un\'ipotesi, non una garanzia.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                ProjectionChart(points: plan.projection),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Lazy portfolio
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Portafoglio: ${lazy.name}',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(lazy.description,
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 12),
                ...lazy.allocations.entries.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(width: 110, child: Text(e.key.label)),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: e.value / 100,
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${e.value.toStringAsFixed(0)}%'),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => context.go('/onboarding'),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Modifica il piano'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => context.go('/strategie'),
          icon: const Icon(Icons.school_outlined),
          label: const Text('Scopri le strategie'),
        ),
        const DisclaimerBanner(margin: EdgeInsets.only(top: 16)),
      ],
    );
  }

  Widget _kv(BuildContext context, String k, String v,
      {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(k)),
          Text(v,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: highlight ? 18 : 14,
                color: highlight ? Theme.of(context).colorScheme.primary : null,
              )),
        ],
      ),
    );
  }
}
