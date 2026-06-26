/// Un portafoglio/obiettivo dell'utente (multi-portafoglio).
class Portfolio {
  const Portfolio({required this.id, required this.name});

  final String id;
  final String name;

  factory Portfolio.fromMap(Map<String, dynamic> m) => Portfolio(
        id: m['id'].toString(),
        name: (m['name'] as String?) ?? 'Portafoglio',
      );
}
