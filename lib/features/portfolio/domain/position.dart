import '../../market/domain/quote.dart';
import 'holding.dart';

/// Una posizione arricchita con la quotazione corrente (se disponibile).
class Position {
  const Position({required this.holding, this.quote});

  final Holding holding;
  final Quote? quote;

  double? get currentPrice => quote?.price;

  double get costBasis => holding.costBasis;

  /// Valore di mercato; se manca la quotazione, ripiega sul costo.
  double get marketValue =>
      (quote?.price ?? holding.avgPrice) * holding.quantity;

  double get gain => marketValue - costBasis;

  double get gainPercent => costBasis == 0 ? 0 : (gain / costBasis) * 100;

  /// Variazione di valore di **oggi** (quantità × variazione giornaliera del
  /// prezzo). Null se manca la quotazione.
  double? get dayChange =>
      quote == null ? null : quote!.dayChange * holding.quantity;

  /// Variazione percentuale di oggi del prezzo (null senza quotazione).
  double? get dayChangePercent => quote?.dayChangePercent;

  bool get hasQuote => quote != null;
}
