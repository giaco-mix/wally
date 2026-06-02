import '../../portfolio/domain/holding.dart';
import 'risk_profile.dart';

/// Portafoglio "pigro": un'allocazione semplice e diversificata, pronta da usare
/// come punto di partenza. Allocazioni espresse per asset class (somma = 100).
class LazyPortfolio {
  const LazyPortfolio({
    required this.id,
    required this.name,
    required this.description,
    required this.riskProfile,
    required this.allocations,
  });

  final String id;
  final String name;
  final String description;
  final RiskProfile riskProfile;
  final Map<AssetClass, double> allocations;

  /// Catalogo iniziale dei lazy portfolio.
  static const List<LazyPortfolio> catalog = [
    LazyPortfolio(
      id: 'conservative_30_70',
      name: 'Conservativo 30/70',
      description:
          '30% azioni, 70% tra obbligazioni e liquidità. Cresce piano ma con poche scosse.',
      riskProfile: RiskProfile.prudent,
      allocations: {
        AssetClass.stock: 30,
        AssetClass.bond: 60,
        AssetClass.cash: 10,
      },
    ),
    LazyPortfolio(
      id: 'balanced_60_40',
      name: 'Bilanciato 60/40',
      description:
          'Il classico 60% azioni / 40% obbligazioni: il compromesso più diffuso al mondo.',
      riskProfile: RiskProfile.balanced,
      allocations: {
        AssetClass.stock: 60,
        AssetClass.bond: 40,
      },
    ),
    LazyPortfolio(
      id: 'growth_90_10',
      name: 'Crescita 90/10',
      description:
          '90% azioni, 10% obbligazioni. Massima crescita attesa nel lungo periodo, oscillazioni forti.',
      riskProfile: RiskProfile.aggressive,
      allocations: {
        AssetClass.stock: 90,
        AssetClass.bond: 10,
      },
    ),
  ];

  static LazyPortfolio forProfile(RiskProfile profile) {
    return catalog.firstWhere(
      (p) => p.riskProfile == profile,
      orElse: () => catalog[1],
    );
  }

  static LazyPortfolio? byId(String? id) {
    if (id == null) return null;
    for (final p in catalog) {
      if (p.id == id) return p;
    }
    return null;
  }
}
