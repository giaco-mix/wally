/// Una piattaforma/broker su cui l'utente ha posizioni, con il suo modello di
/// costi. I valori sono modificabili a mano dall'utente.
class Broker {
  const Broker({
    required this.id,
    required this.name,
    this.accountFeeAnnual = 0,
    this.orderFeeFixed = 0,
    this.orderFeePercent = 0,
  });

  final String id;
  final String name;

  /// Canone/commissione di gestione conto annuale (€/anno).
  final double accountFeeAnnual;

  /// Commissione fissa per ordine (€).
  final double orderFeeFixed;

  /// Commissione percentuale per ordine (% dell'importo).
  final double orderFeePercent;

  /// Commissione stimata su un singolo ordine di [amount] euro.
  double orderCost(double amount) =>
      orderFeeFixed + amount * orderFeePercent / 100;

  /// Costo annuo stimato di un PAC mensile da [monthly] euro su questo broker
  /// (12 ordini all'anno) + canone annuo.
  double annualPacCost(double monthly) =>
      accountFeeAnnual + 12 * orderCost(monthly);

  Broker copyWith({
    String? name,
    double? accountFeeAnnual,
    double? orderFeeFixed,
    double? orderFeePercent,
  }) {
    return Broker(
      id: id,
      name: name ?? this.name,
      accountFeeAnnual: accountFeeAnnual ?? this.accountFeeAnnual,
      orderFeeFixed: orderFeeFixed ?? this.orderFeeFixed,
      orderFeePercent: orderFeePercent ?? this.orderFeePercent,
    );
  }

  factory Broker.fromMap(Map<String, dynamic> map) {
    return Broker(
      id: map['id'].toString(),
      name: map['name'] as String,
      accountFeeAnnual: (map['account_fee_annual'] as num?)?.toDouble() ?? 0,
      orderFeeFixed: (map['order_fee_fixed'] as num?)?.toDouble() ?? 0,
      orderFeePercent: (map['order_fee_percent'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toInsert(String userId) {
    return {
      'user_id': userId,
      'name': name,
      'account_fee_annual': accountFeeAnnual,
      'order_fee_fixed': orderFeeFixed,
      'order_fee_percent': orderFeePercent,
    };
  }
}
