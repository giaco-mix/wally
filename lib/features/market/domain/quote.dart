/// Quotazione corrente di un titolo.
class Quote {
  const Quote({
    required this.symbol,
    required this.price,
    required this.previousClose,
    this.currency = 'USD',
    this.shortName,
  });

  final String symbol;
  final double price;
  final double previousClose;
  final String currency;
  final String? shortName;

  double get dayChange => price - previousClose;
  double get dayChangePercent =>
      previousClose == 0 ? 0 : (dayChange / previousClose) * 100;

  factory Quote.fromYahooChart(Map<String, dynamic> json) {
    final result =
        (json['chart']['result'] as List).first as Map<String, dynamic>;
    final meta = result['meta'] as Map<String, dynamic>;
    return Quote(
      symbol: meta['symbol'] as String,
      price: (meta['regularMarketPrice'] as num?)?.toDouble() ?? 0,
      previousClose:
          (meta['chartPreviousClose'] as num?)?.toDouble() ??
          (meta['previousClose'] as num?)?.toDouble() ??
          0,
      currency: (meta['currency'] as String?) ?? 'USD',
      shortName: meta['shortName'] as String?,
    );
  }
}
