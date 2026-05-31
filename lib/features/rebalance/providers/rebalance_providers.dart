import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../portfolio/providers/portfolio_providers.dart';
import '../domain/rebalance.dart';

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
