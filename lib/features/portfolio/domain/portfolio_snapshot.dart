/// Valore del portafoglio in un dato giorno.
class PortfolioSnapshot {
  const PortfolioSnapshot({required this.date, required this.totalValue});

  final DateTime date;
  final double totalValue;

  factory PortfolioSnapshot.fromMap(Map<String, dynamic> map) {
    return PortfolioSnapshot(
      date: DateTime.parse(map['snapshot_date'] as String),
      totalValue: (map['total_value'] as num).toDouble(),
    );
  }
}
