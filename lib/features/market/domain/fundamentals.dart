/// Metriche fondamentali di un titolo, derivate dai moduli quoteSummary di Yahoo.
class Fundamentals {
  const Fundamentals({
    required this.symbol,
    this.name,
    this.sector,
    this.industry,
    this.marketCap,
    this.trailingPe,
    this.forwardPe,
    this.priceToBook,
    this.returnOnEquity,
    this.profitMargins,
    this.debtToEquity,
    this.dividendYield,
    this.beta,
    this.currentRatio,
    this.revenueGrowth,
    this.summary,
  });

  final String symbol;
  final String? name;
  final String? sector;
  final String? industry;
  final double? marketCap;
  final double? trailingPe;
  final double? forwardPe;
  final double? priceToBook;
  final double? returnOnEquity; // 0..1
  final double? profitMargins; // 0..1
  final double? debtToEquity;
  final double? dividendYield; // 0..1
  final double? beta;
  final double? currentRatio;
  final double? revenueGrowth; // 0..1
  final String? summary;

  static double? _raw(Map<String, dynamic>? m, String key) {
    final v = m?[key];
    if (v is Map && v['raw'] is num) return (v['raw'] as num).toDouble();
    if (v is num) return v.toDouble();
    return null;
  }

  static String? _str(Map<String, dynamic>? m, String key) {
    final v = m?[key];
    return v is String ? v : null;
  }

  factory Fundamentals.fromYahooSummary(
    String symbol,
    Map<String, dynamic> json,
  ) {
    final result =
        (json['quoteSummary']['result'] as List).first as Map<String, dynamic>;
    final summaryDetail =
        result['summaryDetail'] as Map<String, dynamic>?;
    final keyStats =
        result['defaultKeyStatistics'] as Map<String, dynamic>?;
    final financial =
        result['financialData'] as Map<String, dynamic>?;
    final profile =
        result['assetProfile'] as Map<String, dynamic>?;
    final price = result['price'] as Map<String, dynamic>?;

    return Fundamentals(
      symbol: symbol.toUpperCase(),
      name: _str(price, 'longName') ?? _str(price, 'shortName'),
      sector: _str(profile, 'sector'),
      industry: _str(profile, 'industry'),
      marketCap: _raw(summaryDetail, 'marketCap') ?? _raw(price, 'marketCap'),
      trailingPe: _raw(summaryDetail, 'trailingPE'),
      forwardPe: _raw(summaryDetail, 'forwardPE') ?? _raw(keyStats, 'forwardPE'),
      priceToBook: _raw(keyStats, 'priceToBook'),
      returnOnEquity: _raw(financial, 'returnOnEquity'),
      profitMargins:
          _raw(financial, 'profitMargins') ?? _raw(keyStats, 'profitMargins'),
      debtToEquity: _raw(financial, 'debtToEquity'),
      dividendYield: _raw(summaryDetail, 'dividendYield'),
      beta: _raw(summaryDetail, 'beta') ?? _raw(keyStats, 'beta'),
      currentRatio: _raw(financial, 'currentRatio'),
      revenueGrowth: _raw(financial, 'revenueGrowth'),
      summary: _str(profile, 'longBusinessSummary'),
    );
  }
}
