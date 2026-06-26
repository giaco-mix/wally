import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../portfolio/providers/portfolio_providers.dart';
import '../../../shared/format.dart';
import '../domain/rebalance.dart';
import '../domain/rebalance_settings.dart';
import '../domain/wally_notification.dart';

final rebalancePlanProvider = Provider<AsyncValue<RebalancePlan>>((ref) {
  final positions = ref.watch(positionsProvider);
  final targets = ref.watch(targetsControllerProvider);
  if (targets.isLoading || positions.isLoading) {
    return const AsyncValue.loading();
  }
  return positions.whenData((list) {
    return RebalancePlan.compute(
      positions: list,
      targets: targets.asData?.value ?? const {},
    );
  });
});

/// Soglia (in punti percentuali) oltre la quale un'asset class è considerata
/// sbilanciata rispetto al target.
const double kRebalanceThresholdPct = 5;

/// Righe del piano che deviano dal target oltre la soglia. Vuota se non ci
/// sono target impostati o se tutto è in linea.
final rebalanceAlertsProvider = Provider<List<RebalanceRow>>((ref) {
  final plan = ref.watch(rebalancePlanProvider).asData?.value;
  if (plan == null || plan.isEmpty) return const [];
  final hasTargets = plan.rows.any((r) => r.targetPct > 0);
  if (!hasTargets) return const [];
  final out = plan.rows
      .where((r) => r.deviationPct.abs() >= kRebalanceThresholdPct)
      .toList()
    ..sort((a, b) => b.deviationPct.abs().compareTo(a.deviationPct.abs()));
  return out;
});

/// Impostazioni di ribilanciamento schedulato (cadenza + ultima data).
final rebalanceSettingsControllerProvider =
    AsyncNotifierProvider<RebalanceSettingsController, RebalanceSettings>(
        RebalanceSettingsController.new);

class RebalanceSettingsController extends AsyncNotifier<RebalanceSettings> {
  @override
  Future<RebalanceSettings> build() async {
    final pid = ref.watch(currentPortfolioIdProvider);
    return ref.watch(portfolioRepositoryProvider).fetchRebalanceSettings(pid);
  }

  /// Imposta la cadenza; se non c'è ancora una data base, parte da oggi.
  Future<void> setFrequency(RebalanceFrequency freq) async {
    final current = state.asData?.value ?? const RebalanceSettings();
    final next = RebalanceSettings(
      frequency: freq,
      lastRebalancedAt: current.lastRebalancedAt ??
          (freq == RebalanceFrequency.none ? null : DateTime.now()),
    );
    final pid = ref.read(currentPortfolioIdProvider);
    await ref
        .read(portfolioRepositoryProvider)
        .saveRebalanceSettings(next, pid);
    ref.invalidateSelf();
    await future;
  }

  /// Segna il ribilanciamento come effettuato oggi.
  Future<void> markRebalanced() async {
    final current = state.asData?.value ?? const RebalanceSettings();
    final next = current.copyWith(lastRebalancedAt: DateTime.now());
    final pid = ref.read(currentPortfolioIdProvider);
    await ref
        .read(portfolioRepositoryProvider)
        .saveRebalanceSettings(next, pid);
    ref.invalidateSelf();
    await future;
  }
}

/// Notifiche/avvisi in-app generati dallo stato attuale: promemoria di
/// ribilanciamento schedulato + asset class sbilanciate (con titolo trainante).
final notificationsProvider = Provider<List<WallyNotification>>((ref) {
  final notifications = <WallyNotification>[];

  // 1) Promemoria schedulato
  final settings = ref.watch(rebalanceSettingsControllerProvider).asData?.value;
  if (settings != null && settings.isDue) {
    notifications.add(WallyNotification(
      id: 'schedule',
      severity: NotificationSeverity.warning,
      title: 'È ora di ribilanciare',
      body: 'Secondo la tua cadenza ${settings.frequency.label.toLowerCase()} '
          'è il momento di dare un\'occhiata e riportare il piano in equilibrio.',
      route: '/rebalance',
      actionLabel: 'Ribilancia',
    ));
  }

  // 2) Asset class fuori soglia, con il titolo che pesa di più
  final alerts = ref.watch(rebalanceAlertsProvider);
  final positions = ref.watch(positionsProvider).asData?.value ?? const [];
  for (final r in alerts) {
    final inClass = positions
        .where((p) => p.holding.assetClass == r.assetClass)
        .toList()
      ..sort((a, b) => b.marketValue.compareTo(a.marketValue));
    final top = inClass.isEmpty ? null : inClass.first.holding;
    final over = r.deviationPct > 0;
    final String body;
    if (over && top != null) {
      body = '${top.symbol} è cresciuto e la tua quota '
          '${r.assetClass.label} è al ${Fmt.pct(r.currentPct)} '
          '(target ${Fmt.pct(r.targetPct)}). Valuta di alleggerire o di '
          'comprare altro col prossimo versamento.';
    } else {
      body = 'La tua quota ${r.assetClass.label} è al ${Fmt.pct(r.currentPct)} '
          '(target ${Fmt.pct(r.targetPct)}). Valuta di rinforzarla, magari '
          'col prossimo versamento del PAC.';
    }
    notifications.add(WallyNotification(
      id: 'dev_${r.assetClass.name}',
      severity: NotificationSeverity.warning,
      title: over
          ? '${r.assetClass.label} sopra il target'
          : '${r.assetClass.label} sotto il target',
      body: body,
      route: '/rebalance',
      actionLabel: 'Vai al ribilanciamento',
    ));
  }

  return notifications;
});
