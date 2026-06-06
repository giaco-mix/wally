import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/format.dart';
import '../../portfolio/domain/position.dart';
import '../../portfolio/providers/portfolio_providers.dart';
import '../../rebalance/providers/rebalance_providers.dart';
import 'widgets/allocation_pie.dart';
import 'widgets/coach_card.dart';
import 'widgets/costs_card.dart';
import 'widgets/performance_chart.dart';
import 'widgets/plan_card.dart';
import 'widgets/rebalance_alert.dart';
import 'widgets/summary_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positions = ref.watch(positionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          _NotificationBell(count: ref.watch(notificationsProvider).length),
          IconButton(
            tooltip: 'Aggiorna',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(quotesProvider),
          ),
        ],
      ),
      body: positions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Errore: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Aggiungi posizioni nella sezione Portafoglio per vedere '
                  'qui la tua dashboard.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return _DashboardBody(positions: list);
        },
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final icon = IconButton(
      tooltip: 'Avvisi',
      icon: const Icon(Icons.notifications_outlined),
      onPressed: () => context.go('/notifications'),
    );
    if (count == 0) return icon;
    return Badge.count(count: count, child: icon);
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.positions});
  final List<Position> positions;

  @override
  Widget build(BuildContext context) {
    final totalValue = positions.fold<double>(0, (a, p) => a + p.marketValue);
    final totalCost = positions.fold<double>(0, (a, p) => a + p.costBasis);
    final gain = totalValue - totalCost;
    final gainPct = totalCost == 0 ? 0.0 : (gain / totalCost) * 100;

    final byClass = <String, double>{};
    final bySector = <String, double>{};
    for (final p in positions) {
      byClass.update(p.holding.assetClass.label, (v) => v + p.marketValue,
          ifAbsent: () => p.marketValue);
      final sector = p.holding.sector?.trim();
      bySector.update(
        (sector == null || sector.isEmpty) ? 'N/D' : sector,
        (v) => v + p.marketValue,
        ifAbsent: () => p.marketValue,
      );
    }

    final wide = MediaQuery.sizeOf(context).width >= 760;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const PlanCard(),
        const SizedBox(height: 8),
        const CoachCard(),
        const SizedBox(height: 8),
        const RebalanceAlert(),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SummaryCard(
              label: 'Valore totale',
              value: Fmt.money(totalValue),
              icon: Icons.account_balance,
            ),
            SummaryCard(
              label: 'Guadagno / Perdita',
              value: '${Fmt.signed(gain)}  (${Fmt.signedPct(gainPct)})',
              icon: gain >= 0 ? Icons.trending_up : Icons.trending_down,
              color: gain >= 0 ? AppTheme.positive : AppTheme.negative,
            ),
            SummaryCard(
              label: 'Posizioni',
              value: positions.length.toString(),
              icon: Icons.layers_outlined,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Flex(
          direction: wide ? Axis.horizontal : Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: wide ? 1 : 0,
              child: AllocationPie(
                title: 'Allocazione per asset class',
                data: byClass,
                total: totalValue,
              ),
            ),
            SizedBox(width: wide ? 16 : 0, height: wide ? 0 : 16),
            Expanded(
              flex: wide ? 1 : 0,
              child: AllocationPie(
                title: 'Allocazione per settore',
                data: bySector,
                total: totalValue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        PerformanceChart(currentValue: totalValue),
        const SizedBox(height: 16),
        const CostsCard(),
      ],
    );
  }
}
