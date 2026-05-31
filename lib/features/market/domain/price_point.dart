/// Un punto della serie storica dei prezzi (data + chiusura).
class PricePoint {
  const PricePoint({required this.date, required this.close});

  final DateTime date;
  final double close;
}

/// Serie storica dei prezzi di un titolo per un dato periodo.
class PriceHistory {
  const PriceHistory({required this.symbol, required this.points});

  final String symbol;
  final List<PricePoint> points;

  bool get isEmpty => points.isEmpty;
  double? get first => points.isEmpty ? null : points.first.close;
  double? get last => points.isEmpty ? null : points.last.close;

  /// Variazione percentuale sull'intero periodo.
  double? get changePercent {
    final f = first;
    final l = last;
    if (f == null || l == null || f == 0) return null;
    return (l - f) / f * 100;
  }

  factory PriceHistory.fromYahooChart(String symbol, Map<String, dynamic> json) {
    final result =
        (json['chart']['result'] as List).first as Map<String, dynamic>;
    final timestamps = (result['timestamp'] as List?)?.cast<num>() ?? const [];
    final quote = ((result['indicators']?['quote'] as List?)?.first
            as Map<String, dynamic>?) ??
        const {};
    final closes = (quote['close'] as List?) ?? const [];

    final points = <PricePoint>[];
    for (var i = 0; i < timestamps.length && i < closes.length; i++) {
      final c = closes[i];
      if (c == null) continue; // Yahoo può avere buchi (null) nei dati.
      points.add(PricePoint(
        date: DateTime.fromMillisecondsSinceEpoch(timestamps[i].toInt() * 1000),
        close: (c as num).toDouble(),
      ));
    }
    return PriceHistory(symbol: symbol.toUpperCase(), points: points);
  }
}

/// Periodi selezionabili per il grafico storico.
enum HistoryRange {
  oneMonth('1M', '1mo', '1d'),
  sixMonths('6M', '6mo', '1d'),
  oneYear('1A', '1y', '1wk');

  const HistoryRange(this.label, this.range, this.interval);
  final String label;
  final String range;
  final String interval;
}
