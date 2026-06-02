import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../domain/investment_plan.dart';

/// Il piano attivo dell'utente (null se non ancora creato).
final planControllerProvider =
    AsyncNotifierProvider<PlanController, InvestmentPlan?>(PlanController.new);

class PlanController extends AsyncNotifier<InvestmentPlan?> {
  @override
  Future<InvestmentPlan?> build() async {
    return ref.watch(planRepositoryProvider).fetchPlan();
  }

  Future<void> save(InvestmentPlan plan) async {
    state = const AsyncValue.loading();
    await ref.read(planRepositoryProvider).savePlan(plan);
    ref.invalidateSelf();
    await future;
  }
}

/// Vero se l'utente ha già un piano attivo.
final hasPlanProvider = Provider<bool>((ref) {
  return ref.watch(planControllerProvider).asData?.value != null;
});
