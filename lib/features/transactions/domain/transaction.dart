import '../../portfolio/domain/holding.dart';

enum TxSide {
  buy('Acquisto'),
  sell('Vendita');

  const TxSide(this.label);
  final String label;

  static TxSide fromName(String? n) =>
      TxSide.values.firstWhere((e) => e.name == n, orElse: () => TxSide.buy);
}

/// Tipo di operazione: distingue il PAC dai versamenti extra (buy-the-dip),
/// dalla quota iniziale (maxi-canone) e dagli inserimenti manuali.
enum TxKind {
  pac('PAC'),
  oneOff('Extra / buy-the-dip'),
  initial('Versamento iniziale'),
  manual('Manuale');

  const TxKind(this.label);
  final String label;

  static TxKind fromName(String? n) =>
      TxKind.values.firstWhere((e) => e.name == n, orElse: () => TxKind.manual);
}

/// Comparto del PAC: alcuni piani alternano una parte "core" (l'ossatura, es.
/// all-world) e una "satellite" (scommesse tematiche) nel tempo.
enum TxSleeve {
  none('—'),
  core('Core'),
  satellite('Satellite');

  const TxSleeve(this.label);
  final String label;

  static TxSleeve fromName(String? n) => TxSleeve.values
      .firstWhere((e) => e.name == n, orElse: () => TxSleeve.none);
}

/// Una singola operazione del registro (ledger): acquisto/vendita di uno
/// strumento in una data, con prezzo e quantità. Le posizioni correnti
/// (`holdings`) sono l'aggregato di queste operazioni.
class Transaction {
  const Transaction({
    this.id,
    required this.symbol,
    required this.name,
    required this.side,
    required this.kind,
    required this.date,
    required this.quantity,
    required this.price,
    this.assetClass = AssetClass.etf,
    this.currency = 'EUR',
    this.ter = 0,
    this.distribution = DistributionPolicy.none,
    this.leverage = 1,
    this.portfolioId,
    this.sleeve = TxSleeve.none,
  });

  final String? id;
  final String symbol;
  final String name;
  final TxSide side;
  final TxKind kind;
  final DateTime date;
  final double quantity;
  final double price;
  final AssetClass assetClass;
  final String currency;
  final double ter;
  final DistributionPolicy distribution;
  final int leverage;
  final String? portfolioId;
  final TxSleeve sleeve;

  /// Controvalore dell'operazione.
  double get amount => quantity * price;

  Transaction copyWith({String? portfolioId}) {
    return Transaction(
      id: id,
      symbol: symbol,
      name: name,
      side: side,
      kind: kind,
      date: date,
      quantity: quantity,
      price: price,
      assetClass: assetClass,
      currency: currency,
      ter: ter,
      distribution: distribution,
      leverage: leverage,
      portfolioId: portfolioId ?? this.portfolioId,
      sleeve: sleeve,
    );
  }

  factory Transaction.fromMap(Map<String, dynamic> m) {
    return Transaction(
      id: m['id']?.toString(),
      symbol: (m['symbol'] as String).toUpperCase(),
      name: (m['name'] as String?) ?? m['symbol'] as String,
      side: TxSide.fromName(m['side'] as String?),
      kind: TxKind.fromName(m['kind'] as String?),
      date: DateTime.parse(m['tx_date'] as String),
      quantity: (m['quantity'] as num).toDouble(),
      price: (m['price'] as num).toDouble(),
      assetClass: AssetClass.fromName(m['asset_class'] as String?),
      currency: (m['currency'] as String?) ?? 'EUR',
      ter: (m['ter'] as num?)?.toDouble() ?? 0,
      distribution: DistributionPolicy.fromName(m['distribution'] as String?),
      leverage: (m['leverage'] as num?)?.toInt() ?? 1,
      portfolioId: m['portfolio_id']?.toString(),
      sleeve: TxSleeve.fromName(m['sleeve'] as String?),
    );
  }

  Map<String, dynamic> toInsert(String userId) {
    return {
      'user_id': userId,
      'symbol': symbol.toUpperCase(),
      'name': name,
      'side': side.name,
      'kind': kind.name,
      'tx_date':
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'quantity': quantity,
      'price': price,
      'asset_class': assetClass.name,
      'currency': currency,
      'ter': ter,
      'distribution': distribution.name,
      'leverage': leverage,
      if (portfolioId != null) 'portfolio_id': portfolioId,
      'sleeve': sleeve.name,
    };
  }
}
