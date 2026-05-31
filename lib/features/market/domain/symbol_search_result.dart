class SymbolSearchResult {
  const SymbolSearchResult({
    required this.symbol,
    required this.name,
    this.exchange,
    this.type,
  });

  final String symbol;
  final String name;
  final String? exchange;
  final String? type;

  factory SymbolSearchResult.fromYahoo(Map<String, dynamic> q) {
    return SymbolSearchResult(
      symbol: q['symbol'] as String,
      name: (q['shortname'] ?? q['longname'] ?? q['symbol']) as String,
      exchange: q['exchDisp'] as String?,
      type: q['typeDisp'] as String?,
    );
  }
}
