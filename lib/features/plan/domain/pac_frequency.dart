/// Frequenza dei versamenti del PAC.
enum PacFrequency {
  weekly('Settimanale', 52),
  biweekly('Bisettimanale', 26),
  monthly('Mensile', 12),
  quarterly('Trimestrale', 4),
  semiannual('Semestrale', 2),
  annual('Annuale', 1);

  const PacFrequency(this.label, this.perYear);
  final String label;
  final int perYear;

  /// Converte un importo per-versamento nell'equivalente mensile.
  double monthlyEquivalent(double perInstallment) =>
      perInstallment * perYear / 12;

  /// Converte un equivalente mensile nell'importo per-versamento.
  double perInstallment(double monthlyEquivalent) =>
      monthlyEquivalent * 12 / perYear;

  static PacFrequency fromName(String? n) => PacFrequency.values
      .firstWhere((e) => e.name == n, orElse: () => PacFrequency.monthly);
}
