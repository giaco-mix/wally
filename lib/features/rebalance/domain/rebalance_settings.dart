/// Cadenza con cui Wally ricorda di ribilanciare.
enum RebalanceFrequency {
  none('Mai', 0),
  monthly('Mensile', 1),
  quarterly('Trimestrale', 3),
  annual('Annuale', 12);

  const RebalanceFrequency(this.label, this.months);
  final String label;
  final int months;

  static RebalanceFrequency fromName(String? name) =>
      RebalanceFrequency.values.firstWhere(
        (f) => f.name == name,
        orElse: () => RebalanceFrequency.none,
      );
}

DateTime _addMonths(DateTime d, int months) {
  final m = d.month - 1 + months;
  final y = d.year + m ~/ 12;
  final nm = m % 12 + 1;
  final lastDay = DateTime(y, nm + 1, 0).day;
  return DateTime(y, nm, d.day > lastDay ? lastDay : d.day);
}

/// Impostazioni di ribilanciamento schedulato dell'utente.
class RebalanceSettings {
  const RebalanceSettings({
    this.frequency = RebalanceFrequency.none,
    this.lastRebalancedAt,
  });

  final RebalanceFrequency frequency;
  final DateTime? lastRebalancedAt;

  /// Data del prossimo ribilanciamento previsto (null se cadenza "Mai").
  DateTime? get nextDate {
    if (frequency == RebalanceFrequency.none) return null;
    final base = lastRebalancedAt ?? DateTime.now();
    return _addMonths(base, frequency.months);
  }

  /// Vero se è arrivato (o passato) il momento di ribilanciare.
  bool get isDue {
    final next = nextDate;
    if (next == null) return false;
    return !DateTime.now().isBefore(next);
  }

  RebalanceSettings copyWith({
    RebalanceFrequency? frequency,
    DateTime? lastRebalancedAt,
  }) {
    return RebalanceSettings(
      frequency: frequency ?? this.frequency,
      lastRebalancedAt: lastRebalancedAt ?? this.lastRebalancedAt,
    );
  }

  factory RebalanceSettings.fromMap(Map<String, dynamic> map) {
    final last = map['last_rebalanced_at'] as String?;
    return RebalanceSettings(
      frequency: RebalanceFrequency.fromName(map['frequency'] as String?),
      lastRebalancedAt: last == null ? null : DateTime.parse(last),
    );
  }
}
