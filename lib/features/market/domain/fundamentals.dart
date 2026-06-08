/// Una posizione tra le principali partecipazioni di un fondo/ETF.
class FundHolding {
  const FundHolding({required this.name, required this.weight, this.symbol});

  final String name;
  final double weight; // 0..1
  final String? symbol;
}

/// Metriche fondamentali di un titolo, derivate dai moduli quoteSummary di Yahoo.
/// Distingue tra **azioni** (P/E, ROE, ecc.) e **fondi/ETF** (TER, categoria,
/// rendimento, top holdings): gli ETF non hanno metriche da singola azienda.
class Fundamentals {
  const Fundamentals({
    required this.symbol,
    this.name,
    this.quoteType,
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
    this.category,
    this.expenseRatio,
    this.fundYield,
    this.ytdReturn,
    this.topHoldings = const [],
  });

  final String symbol;
  final String? name;

  /// Tipo Yahoo: EQUITY, ETF, MUTUALFUND, INDEX, CRYPTOCURRENCY…
  final String? quoteType;

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

  // Campi specifici di fondi/ETF.
  final String? category; // es. "Large Blend", "World Equity"
  final double? expenseRatio; // TER, 0..1
  final double? fundYield; // rendimento da distribuzione, 0..1
  final double? ytdReturn; // 0..1
  final List<FundHolding> topHoldings;

  /// Vero se è un fondo/ETF: niente metriche da singola azienda (P/E, ROE…).
  bool get isFund => quoteType == 'ETF' || quoteType == 'MUTUALFUND';

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
    final fundProfile = result['fundProfile'] as Map<String, dynamic>?;
    final topHoldingsMod = result['topHoldings'] as Map<String, dynamic>?;

    final fees =
        fundProfile?['feesExpensesInvestment'] as Map<String, dynamic>?;
    final holdings = <FundHolding>[];
    final rawHoldings = topHoldingsMod?['holdings'];
    if (rawHoldings is List) {
      for (final h in rawHoldings) {
        if (h is! Map) continue;
        final m = h.cast<String, dynamic>();
        final w = _raw(m, 'holdingPercent');
        holdings.add(FundHolding(
          name: _str(m, 'holdingName') ?? _str(m, 'symbol') ?? '—',
          symbol: _str(m, 'symbol'),
          weight: w ?? 0,
        ));
      }
    }

    return Fundamentals(
      symbol: symbol.toUpperCase(),
      name: _str(price, 'longName') ?? _str(price, 'shortName'),
      quoteType: _str(price, 'quoteType'),
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
      category: _str(fundProfile, 'categoryName'),
      expenseRatio: _raw(fees, 'annualReportExpenseRatio') ??
          _raw(keyStats, 'annualReportExpenseRatio'),
      fundYield: _raw(summaryDetail, 'yield'),
      ytdReturn:
          _raw(keyStats, 'ytdReturn') ?? _raw(fundProfile, 'ytdReturn'),
      topHoldings: holdings,
    );
  }
}
