import '../../portfolio/domain/position.dart';

/// Un cliente seguito da un consulente (prototipo). Nella fase reale arriverà
/// da Supabase via `advisor_clients` + RLS; qui è alimentato da dati demo.
class AdvisorClient {
  const AdvisorClient({
    required this.id,
    required this.name,
    this.note,
    this.positions = const [],
  });

  final String id;
  final String name;
  final String? note;
  final List<Position> positions;

  double get totalValue => positions.fold(0, (a, p) => a + p.marketValue);
  double get totalCost => positions.fold(0, (a, p) => a + p.costBasis);
  double get gain => totalValue - totalCost;
  double get gainPercent => totalCost == 0 ? 0 : gain / totalCost * 100;

  double get dayChange => positions.fold(0, (a, p) => a + (p.dayChange ?? 0));
  double get dayChangePercent {
    final prev = totalValue - dayChange;
    return prev == 0 ? 0 : dayChange / prev * 100;
  }

  /// Allocazione per asset class (label → valore), per i grafici.
  Map<String, double> get byAssetClass {
    final m = <String, double>{};
    for (final p in positions) {
      m.update(p.holding.assetClass.label, (v) => v + p.marketValue,
          ifAbsent: () => p.marketValue);
    }
    return m;
  }
}
