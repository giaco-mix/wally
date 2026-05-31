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
