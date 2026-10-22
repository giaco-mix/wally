import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/format.dart';
import '../../../shared/widgets/disclaimer_banner.dart';
import '../../portfolio/domain/holding.dart';
import '../../portfolio/domain/position.dart';
import '../../portfolio/presentation/holdings_by_class_screen.dart';
import '../../portfolio/providers/portfolio_providers.dart';
import '../../rebalance/providers/rebalance_providers.dart';
import '../providers/home_hint.dart';
import 'widgets/allocation_pie.dart';
import 'widgets/coach_card.dart';
import 'widgets/costs_card.dart';
import 'widgets/news_card.dart';
import 'widgets/performance_chart.dart';
import 'widgets/plan_card.dart';
import 'widgets/rebalance_alert.dart';
import 'widgets/summary_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positions = ref.watch(positionsProvider);

    // Registra il momento dell'ultimo aggiornamento riuscito delle quotazioni.
    ref.listen(quotesProvider, (_, next) {
      if (next.hasValue) {
        ref.read(lastQuotesRefreshProvider.notifier).stampNow();
      }
    });

    Future<void> refresh() async {
      ref.invalidate(quotesProvider);
      try {
        await ref.read(quotesProvider.future);
      } catch (_) {
        // L'errore è già gestito dallo stato del provider.
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          const _PortfolioMenu(),
          _NotificationBell(count: ref.watch(notificationsProvider).length),
          IconButton(
            tooltip: 'Aggiorna',
            icon: const Icon(Icons.refresh),
            onPressed: refresh,
          ),
        ],
      ),
      body: positions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Errore: $e')),
        data: (list) {
          if (list.isEmpty) return const _EmptyDashboard();
          return RefreshIndicator(
            onRefresh: refresh,
            child: _DashboardBody(positions: list),
          );
        },
      ),
    );
  }
}

class _PortfolioMenu extends ConsumerWidget {
  const _PortfolioMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolios =
        ref.watch(portfoliosControllerProvider).asData?.value ?? const [];
    if (portfolios.length < 2) {
      // Un solo portafoglio: mostra solo l'azione "nuovo".
      return IconButton(
        tooltip: 'Nuovo portafoglio',
        icon: const Icon(Icons.create_new_folder_outlined),
        onPressed: () => _createDialog(context, ref),
      );
    }
    final current = ref.watch(currentPortfolioIdProvider);
    return PopupMenuButton<String>(
      tooltip: 'Cambia portafoglio',
      icon: const Icon(Icons.folder_outlined),
      onSelected: (v) {
        if (v == '__new__') {
          _createDialog(context, ref);
        } else {
          ref.read(selectedPortfolioIdProvider.notifier).select(v);
        }
      },
      itemBuilder: (_) => [
        for (final p in portfolios)
          CheckedPopupMenuItem(
            value: p.id,
            checked: p.id == current,
            child: Text(p.name),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem(value: '__new__', child: Text('Nuovo portafoglio…')),
      ],
    );
  }

  Future<void> _createDialog(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    // Usa il context del dialog (non quello esterno della dashboard) per il
    // pop: altrimenti chiuderebbe la pagina dello shell -> schermata bianca.
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nuovo portafoglio'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nome (es. Pensione)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(ctrl.text.trim()),
            child: const Text('Crea'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (name == null || name.isEmpty) return;
    await ref.read(portfoliosControllerProvider.notifier).create(name);
    final list = ref.read(portfoliosControllerProvider).asData?.value ?? const [];
    final created = list.where((p) => p.name == name).toList();
    if (created.isNotEmpty) {
      ref.read(selectedPortfolioIdProvider.notifier).select(created.last.id);
    }
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

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.positions});
  final List<Position> positions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updatedAt = ref.watch(lastQuotesRefreshProvider);
    final hintDismissed =
        ref.watch(homeHintDismissedProvider).asData?.value ?? false;
    final totalValue = positions.fold<double>(0, (a, p) => a + p.marketValue);
    final totalCost = positions.fold<double>(0, (a, p) => a + p.costBasis);
    final gain = totalValue - totalCost;
    final gainPct = totalCost == 0 ? 0.0 : (gain / totalCost) * 100;

    // Variazione di oggi (somma sulle posizioni quotate).
    var dayChange = 0.0;
    var prevValue = 0.0;
    var anyQuote = false;
    for (final p in positions) {
      final dc = p.dayChange;
      if (dc != null) {
        dayChange += dc;
        prevValue += p.marketValue - dc;
        anyQuote = true;
      }
    }
    final dayPct = prevValue == 0 ? 0.0 : (dayChange / prevValue) * 100;

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
        if (!hintDismissed)
          _StartHereCard(
            onClose: () =>
                ref.read(homeHintDismissedProvider.notifier).dismiss(),
          ),
        if (updatedAt != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.schedule,
                    size: 14,
                    color: Theme.of(context).colorScheme.outline),
                const SizedBox(width: 4),
                Text(
                  'Aggiornato alle ${Fmt.time(updatedAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
          ),
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
            if (anyQuote)
              SummaryCard(
                label: 'Oggi',
                value: '${Fmt.signed(dayChange)}  (${Fmt.signedPct(dayPct)})',
                icon: dayChange >= 0 ? Icons.today : Icons.today_outlined,
                color: dayChange >= 0 ? AppTheme.positive : AppTheme.negative,
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
                onTap: (label) {
                  final ac = AssetClass.values.firstWhere(
                    (a) => a.label == label,
                    orElse: () => AssetClass.other,
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => HoldingsFilterScreen(
                        title: ac.label,
                        test: (p) => p.holding.assetClass == ac,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: wide ? 16 : 0, height: wide ? 0 : 16),
            Expanded(
              flex: wide ? 1 : 0,
              child: AllocationPie(
                title: 'Allocazione per settore',
                data: bySector,
                total: totalValue,
                onTap: (sector) {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => HoldingsFilterScreen(
                        title: sector,
                        test: (p) {
                          final s = p.holding.sector?.trim();
                          final key = (s == null || s.isEmpty) ? 'N/D' : s;
                          return key == sector;
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        PerformanceChart(currentValue: totalValue),
        const SizedBox(height: 16),
        const CostsCard(),
        const SizedBox(height: 16),
        const NewsCard(),
        const DisclaimerBanner(margin: EdgeInsets.only(top: 16)),
      ],
    );
  }
}

/// Guida al primo impatto: spiega in poche righe a cosa servono le aree
/// principali. Chiudibile una volta per sempre (stato locale).
class _StartHereCard extends StatelessWidget {
  const _StartHereCard({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.secondaryContainer,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.explore_outlined,
                    size: 20, color: scheme.onSecondaryContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Da dove comincio?',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onSecondaryContainer,
                        ),
                  ),
                ),
                IconButton(
                  tooltip: 'Ho capito',
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onClose,
                ),
              ],
            ),
            Text(
              '• Dashboard: il colpo d\'occhio sul tuo patrimonio.\n'
              '• Portafoglio: cosa possiedi, più movimenti e analisi.\n'
              '• Ribilancia: cosa aggiustare per restare in rotta.\n'
              '• Impara: lezioni, strumenti e laboratorio.\n'
              '• Account: profilo, piano e impostazioni.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSecondaryContainer,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stato vuoto della Dashboard (nessuna posizione): invito all'azione invece
/// di un testo muto.
class _EmptyDashboard extends StatelessWidget {
  const _EmptyDashboard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.rocket_launch_outlined, size: 64),
            const SizedBox(height: 16),
            Text('Benvenuto in Wally',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              'Aggiungi le tue posizioni per vedere qui la tua dashboard, '
              'oppure parti dalle basi con Impara.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: () => context.go('/portfolio'),
                  icon: const Icon(Icons.add),
                  label: const Text('Aggiungi posizioni'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => context.go('/academy'),
                  icon: const Icon(Icons.school_outlined),
                  label: const Text('Scopri Impara'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
