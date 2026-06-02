/// Profilo di rischio espresso in linguaggio "friendly" (mai "rischioso").
/// I rendimenti attesi sono **stime nominali indicative**, non garanzie.
enum RiskProfile {
  prudent(
    'Prudente',
    'Preferisci dormire sonni tranquilli: oscillazioni piccole, crescita più lenta.',
    expectedReturn: 0.03,
    worstYearText: 'In un anno difficile potresti vedere circa -5% / -10%.',
  ),
  balanced(
    'Equilibrato',
    'Un buon compromesso tra crescita e stabilità: la scelta di molti.',
    expectedReturn: 0.05,
    worstYearText: 'In un anno difficile potresti vedere circa -15% / -20%.',
  ),
  aggressive(
    'Aggressivo',
    'Punti alla crescita massima nel lungo periodo e accetti forti oscillazioni.',
    expectedReturn: 0.07,
    worstYearText: 'In un anno difficile potresti vedere anche -30% / -40%.',
  );

  const RiskProfile(
    this.label,
    this.description, {
    required this.expectedReturn,
    required this.worstYearText,
  });

  /// Etichetta friendly.
  final String label;

  /// Spiegazione in linguaggio umano.
  final String description;

  /// Rendimento medio annuo atteso (nominale, stima indicativa).
  final double expectedReturn;

  /// Scenario di anno negativo, spiegato con concretezza.
  final String worstYearText;

  static RiskProfile fromName(String? name) => RiskProfile.values.firstWhere(
        (r) => r.name == name,
        orElse: () => RiskProfile.balanced,
      );
}
