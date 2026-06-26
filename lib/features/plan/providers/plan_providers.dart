import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../portfolio/providers/portfolio_providers.dart';
import '../domain/investment_plan.dart';

/// Il piano del portafoglio in vista (null se non ancora creato).
final planControllerProvider =
    AsyncNotifierProvider<PlanController, InvestmentPlan?>(PlanController.new);

class PlanController extends AsyncNotifier<InvestmentPlan?> {
  @override
  Future<InvestmentPlan?> build() async {
    final pid = ref.watch(currentPortfolioIdProvider);
    return ref.watch(planRepositoryProvider).fetchPlan(pid);
  }

  Future<void> save(InvestmentPlan plan) async {
    state = const AsyncValue.loading();
    final pid = ref.read(currentPortfolioIdProvider);
    await ref.read(planRepositoryProvider).savePlan(plan, pid);
    ref.invalidateSelf();
    await future;
  }
}

/// Vero se l'utente ha già un piano attivo.
final hasPlanProvider = Provider<bool>((ref) {
  return ref.watch(planControllerProvider).asData?.value != null;
});
