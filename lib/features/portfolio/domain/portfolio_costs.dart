import 'broker.dart';
import 'position.dart';

/// Stima dei costi annui del portafoglio: TER dei fondi + canoni dei broker.
class PortfolioCosts {
  const PortfolioCosts({
    required this.portfolioValue,
    required this.terAnnual,
    required this.brokerFeesAnnual,
  });

  final double portfolioValue;

  /// Costo annuo derivante dal TER dei fondi/ETF (€).
  final double terAnnual;

  /// Canoni annui dei broker (€).
  final double brokerFeesAnnual;

  double get totalAnnual => terAnnual + brokerFeesAnnual;

  /// Costo annuo totale in percentuale del portafoglio.
  double get totalAnnualPct =>
      portfolioValue == 0 ? 0 : totalAnnual / portfolioValue * 100;

  /// Valore stimato fra un anno al netto dei soli costi (a parità di prezzi).
  double get netValueOneYear => portfolioValue - totalAnnual;

  static PortfolioCosts compute({
    required List<Position> positions,
    required List<Broker> brokers,
  }) {
    var value = 0.0;
    var ter = 0.0;
    for (final p in positions) {
      final mv = p.marketValue;
      value += mv;
      ter += mv * p.holding.ter / 100;
    }
    final brokerFees =
        brokers.fold<double>(0, (a, b) => a + b.accountFeeAnnual);
    return PortfolioCosts(
      portfolioValue: value,
      terAnnual: ter,
      brokerFeesAnnual: brokerFees,
    );
  }
}
