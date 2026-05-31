enum AssetClass {
  stock('Azioni'),
  etf('ETF'),
  bond('Obbligazioni'),
  crypto('Crypto'),
  cash('Liquidità'),
  other('Altro');

  const AssetClass(this.label);
  final String label;

  static AssetClass fromName(String? name) =>
      AssetClass.values.firstWhere(
        (e) => e.name == name,
        orElse: () => AssetClass.other,
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
  });

  final String id;
  final String symbol;
  final String name;
  final double quantity;
  final double avgPrice;
  final AssetClass assetClass;
  final String? sector;

  double get costBasis => quantity * avgPrice;

  Holding copyWith({
    String? symbol,
    String? name,
    double? quantity,
    double? avgPrice,
    AssetClass? assetClass,
    String? sector,
  }) {
    return Holding(
      id: id,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      avgPrice: avgPrice ?? this.avgPrice,
      assetClass: assetClass ?? this.assetClass,
      sector: sector ?? this.sector,
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
    };
  }
}
