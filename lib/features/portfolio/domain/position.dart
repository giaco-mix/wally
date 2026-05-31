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

  bool get hasQuote => quote != null;
}
