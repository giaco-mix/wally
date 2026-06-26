enum AssetClass {
  stock('Azioni'),
  etf('ETF'),
  bondShort('Obblig. breve termine'),
  bondMid('Obblig. medio termine'),
  bondLong('Obblig. lungo termine'),
  bond('Obblig. generiche'),
  crypto('Crypto'),
  cash('Liquidità'),
  other('Altro');

  const AssetClass(this.label);
  final String label;

  /// Vero per qualunque tipologia obbligazionaria (generica o per durata).
  bool get isBond =>
      this == AssetClass.bond ||
      this == AssetClass.bondShort ||
      this == AssetClass.bondMid ||
      this == AssetClass.bondLong;

  static AssetClass fromName(String? name) =>
      AssetClass.values.firstWhere(
        (e) => e.name == name,
        orElse: () => AssetClass.other,
      );
}

/// Politica dei dividendi di un fondo/ETF.
enum DistributionPolicy {
  none('—', ''),
  accumulating('Accumulazione', 'ACC'),
  distributing('Distribuzione', 'DIST');

  const DistributionPolicy(this.label, this.short);
  final String label;
  final String short;

  static DistributionPolicy fromName(String? name) =>
      DistributionPolicy.values.firstWhere(
        (e) => e.name == name,
        orElse: () => DistributionPolicy.none,
      );
}

/// Una posizione del portafoglio inserita dall'utente.
class Holding {
  const Holding({
    required this.id,
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.avgPrice,
    this.assetClass = AssetClass.stock,
    this.sector,
    this.ter = 0,
    this.distribution = DistributionPolicy.none,
    this.currency = 'EUR',
    this.leverage = 1,
    this.portfolioId,
  });

  final String id;
  final String symbol;
  final String name;
  final double quantity;
  final double avgPrice;
  final AssetClass assetClass;
  final String? sector;

  /// Total Expense Ratio annuo del fondo/ETF, in percentuale (es. 0.20 = 0,20%).
  final double ter;

  /// Politica dei dividendi (ACC/DIST), rilevante per fondi ed ETF.
  final DistributionPolicy distribution;

  /// Valuta dello strumento (per ora EUR o USD, le principali in Italia).
  final String currency;

  /// Fattore di leva (1 = nessuna leva; 2/3 = ETF a leva 2x/3x).
  final int leverage;

  /// Portafoglio di appartenenza (multi-portafoglio). Null = portafoglio
  /// principale / non ancora assegnato.
  final String? portfolioId;

  bool get isLeveraged => leverage > 1;

  double get costBasis => quantity * avgPrice;

  Holding copyWith({
    String? symbol,
    String? name,
    double? quantity,
    double? avgPrice,
    AssetClass? assetClass,
    String? sector,
    double? ter,
    DistributionPolicy? distribution,
    String? currency,
    int? leverage,
    String? portfolioId,
  }) {
    return Holding(
      id: id,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      avgPrice: avgPrice ?? this.avgPrice,
      assetClass: assetClass ?? this.assetClass,
      sector: sector ?? this.sector,
      ter: ter ?? this.ter,
      distribution: distribution ?? this.distribution,
      currency: currency ?? this.currency,
      leverage: leverage ?? this.leverage,
      portfolioId: portfolioId ?? this.portfolioId,
    );
  }

  factory Holding.fromMap(Map<String, dynamic> map) {
    return Holding(
      id: map['id'].toString(),
      symbol: (map['symbol'] as String).toUpperCase(),
      name: (map['name'] as String?) ?? map['symbol'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      avgPrice: (map['avg_price'] as num).toDouble(),
      assetClass: AssetClass.fromName(map['asset_class'] as String?),
      sector: map['sector'] as String?,
      ter: (map['ter'] as num?)?.toDouble() ?? 0,
      distribution: DistributionPolicy.fromName(map['distribution'] as String?),
      currency: (map['currency'] as String?) ?? 'EUR',
      leverage: (map['leverage'] as num?)?.toInt() ?? 1,
      portfolioId: map['portfolio_id']?.toString(),
    );
  }

  /// Mappa per insert/update su Supabase. `id` escluso (gestito dal DB).
  Map<String, dynamic> toInsert(String userId) {
    return {
      'user_id': userId,
      'symbol': symbol.toUpperCase(),
      'name': name,
      'quantity': quantity,
      'avg_price': avgPrice,
      'asset_class': assetClass.name,
      'sector': sector,
      'ter': ter,
      'distribution': distribution.name,
      'currency': currency,
      'leverage': leverage,
      if (portfolioId != null) 'portfolio_id': portfolioId,
    };
  }
}
