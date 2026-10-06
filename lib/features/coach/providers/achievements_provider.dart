import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../academy/domain/lesson.dart';
import '../../academy/providers/academy_progress.dart';
import '../../rebalance/domain/rebalance_settings.dart';
import '../../rebalance/providers/rebalance_providers.dart';
import '../../transactions/providers/transactions_providers.dart';
import '../domain/achievements.dart';

typedef AchievementsState = ({List<Achievement> list, int streak, int unlocked});

final achievementsProvider = Provider<AchievementsState>((ref) {
  final txs =
      ref.watch(transactionsControllerProvider).asData?.value ?? const [];
  final done = ref.watch(academyProgressProvider).asData?.value ?? const {};
  final settings = ref.watch(rebalanceSettingsControllerProvider).asData?.value;
  final hasCadence =
      settings != null && settings.frequency != RebalanceFrequency.none;

  final list = Achievements.compute(
    transactions: txs,
    lessonsCompleted: done.length,
    lessonsTotal: academyLessons.length,
    hasRebalanceCadence: hasCadence,
  );
  return (
    list: list,
    streak: Achievements.pacStreakMonths(txs),
    unlocked: list.where((a) => a.unlocked).length,
  );
});
