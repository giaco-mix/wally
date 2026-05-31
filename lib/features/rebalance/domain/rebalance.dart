import '../../portfolio/domain/holding.dart';
import '../../portfolio/domain/position.dart';

/// Riga del piano di ribilanciamento per una singola asset class.
class RebalanceRow {
  const RebalanceRow({
    required this.assetClass,
    required this.currentValue,
    required this.currentPct,
    required this.targetPct,
    required this.targetValue,
  });

  final AssetClass assetClass;
  final double currentValue;
  final double currentPct;
  final double targetPct;
  final double targetValue;

  /// Importo da movimentare: positivo = comprare, negativo = vendere.
  double get delta => targetValue - currentValue;
  double get deviationPct => currentPct - targetPct;
  bool get isBuy => delta > 0;
}

class RebalancePlan {
  const RebalancePlan({required this.rows, required this.total});

  final List<RebalanceRow> rows;
  final double total;

  bool get isEmpty => total == 0 || rows.isEmpty;

  /// Calcola il piano dato lo stato attuale e le percentuali target.
  factory RebalancePlan.compute({
    required List<Position> positions,
    required Map<String, double> targets,
  }) {
    final byClass = <AssetClass, double>{};
    for (final p in positions) {
      byClass.update(
        p.holding.assetClass,
        (v) => v + p.marketValue,
        ifAbsent: () => p.marketValue,
      );
    }

    final total = byClass.values.fold<double>(0, (a, b) => a + b);

    final classes = <AssetClass>{
      ...byClass.keys,
      ...targets.keys.map(AssetClass.fromName),
    };

    final rows = classes.map((ac) {
      final current = byClass[ac] ?? 0;
      final targetPct = targets[ac.name] ?? 0;
      return RebalanceRow(
        assetClass: ac,
        currentValue: current,
        currentPct: total == 0 ? 0 : (current / total) * 100,
        targetPct: targetPct,
        targetValue: total * (targetPct / 100),
      );
    }).toList()
      ..sort((a, b) => b.targetPct.compareTo(a.targetPct));

    return RebalancePlan(rows: rows, total: total);
  }
}
