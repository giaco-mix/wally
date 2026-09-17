import 'dart:math' as math;

import 'transaction.dart';

/// Un "lotto" = un singolo accumulo ancora aperto (dopo aver applicato le
/// eventuali vendite in FIFO): quantità residua comprata a un dato prezzo/data.
class Lot {
  const Lot({
    required this.date,
    required this.kind,
    required this.sleeve,
    required this.quantity,
    required this.price,
  });

  final DateTime date;
  final TxKind kind;
  final TxSleeve sleeve;
  final double quantity;
  final double price; // prezzo d'ingresso del lotto
}

/// Rendimento di un singolo lotto rispetto al prezzo corrente.
class LotPerformance {
  const LotPerformance({required this.lot, required this.currentPrice});

  final Lot lot;
  final double? currentPrice;

  double get invested => lot.quantity * lot.price;
  double? get currentValue =>
      currentPrice == null ? null : lot.quantity * currentPrice!;
  double? get gain =>
      currentValue == null ? null : currentValue! - invested;
  double? get gainPercent => (currentPrice == null || lot.price == 0)
      ? null
      : (currentPrice! - lot.price) / lot.price * 100;

  int get daysHeld => DateTime.now().difference(lot.date).inDays;
}

/// Rendimento aggregato di un simbolo: somma dei suoi lotti aperti.
class SymbolPerformance {
  const SymbolPerformance({
    required this.symbol,
    required this.name,
    required this.lots,
    required this.currentPrice,
    this.dividendsReceived = 0,
  });

  final String symbol;
  final String name;
  final List<LotPerformance> lots; // aperti, dal più vecchio al più recente
  final double? currentPrice;

  /// Totale dividendi incassati sul titolo (cassa, non reinvestita qui).
  final double dividendsReceived;

  double get quantity => lots.fold(0, (a, l) => a + l.lot.quantity);
  double get invested => lots.fold(0, (a, l) => a + l.invested);

  /// Prezzo medio di carico dei lotti aperti (media ponderata).
  double get avgPrice => quantity == 0 ? 0 : invested / quantity;

  double? get currentValue =>
      currentPrice == null ? null : quantity * currentPrice!;

  /// Guadagno solo da prezzo (senza dividendi).
  double? get gain => currentValue == null ? null : currentValue! - invested;

  /// Rendimento money-weighted da solo prezzo.
  double? get gainPercent {
    final g = gain;
    if (g == null || invested == 0) return null;
    return g / invested * 100;
  }

  /// Guadagno totale = prezzo + dividendi incassati.
  double? get totalGain =>
      gain == null ? null : gain! + dividendsReceived;

  /// Rendimento totale (prezzo + dividendi) sul capitale investito.
  double? get totalReturnPercent {
    final g = totalGain;
    if (g == null || invested == 0) return null;
    return g / invested * 100;
  }
}

/// Motore di calcolo del rendimento **per singolo accumulo** a partire dal
/// registro delle operazioni. Le vendite consumano i lotti in **FIFO**
/// (prima i più vecchi). Solo basato sul prezzo: non considera ancora
/// dividendi/valute/leva (follow-up).
class LotEngine {
  const LotEngine._();

  static SymbolPerformance forSymbol(
    String symbol,
    String name,
    List<Transaction> txs,
    double? currentPrice,
  ) {
    final sorted = [...txs]..sort((a, b) => a.date.compareTo(b.date));
    final open = <_OpenLot>[];
    var dividends = 0.0;

    for (final tx in sorted) {
      if (tx.kind == TxKind.dividend) {
        // Cassa incassata: non è un movimento di quote.
        dividends += tx.amount;
        continue;
      }
      if (tx.side == TxSide.buy) {
        open.add(_OpenLot(tx.date, tx.kind, tx.sleeve, tx.quantity, tx.price));
      } else {
        var toSell = tx.quantity;
        while (toSell > 1e-9 && open.isNotEmpty) {
          final lot = open.first;
          final take = math.min(lot.quantity, toSell);
          lot.quantity -= take;
          toSell -= take;
          if (lot.quantity <= 1e-9) open.removeAt(0);
        }
      }
    }

    final lots = [
      for (final o in open)
        LotPerformance(
          lot: Lot(
            date: o.date,
            kind: o.kind,
            sleeve: o.sleeve,
            quantity: o.quantity,
            price: o.price,
          ),
          currentPrice: currentPrice,
        ),
    ];
    return SymbolPerformance(
      symbol: symbol.toUpperCase(),
      name: name,
      lots: lots,
      currentPrice: currentPrice,
      dividendsReceived: dividends,
    );
  }

  /// Rendimento per ogni simbolo del portafoglio. `prices` è indicizzato per
  /// simbolo maiuscolo. I simboli senza più lotti aperti vengono esclusi.
  static List<SymbolPerformance> forPortfolio(
    List<Transaction> txs,
    Map<String, double> prices,
  ) {
    final bySymbol = <String, List<Transaction>>{};
    final names = <String, String>{};
    for (final tx in txs) {
      final key = tx.symbol.toUpperCase();
      bySymbol.putIfAbsent(key, () => []).add(tx);
      names[key] = tx.name;
    }

    final out = <SymbolPerformance>[];
    for (final entry in bySymbol.entries) {
      final perf = forSymbol(
        entry.key,
        names[entry.key] ?? entry.key,
        entry.value,
        prices[entry.key],
      );
      if (perf.lots.isNotEmpty || perf.dividendsReceived > 0) out.add(perf);
    }
    out.sort((a, b) => (b.currentValue ?? b.invested)
        .compareTo(a.currentValue ?? a.invested));
    return out;
  }
}

class _OpenLot {
  _OpenLot(this.date, this.kind, this.sleeve, this.quantity, this.price);
  final DateTime date;
  final TxKind kind;
  final TxSleeve sleeve;
  double quantity;
  final double price;
}
