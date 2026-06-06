/// Stato d'animo dell'investitore al momento del check-in.
enum Mood {
  serene('Sereno/a', '😌'),
  nervous('Nervoso/a', '😟'),
  tempted('Tentato/a di vendere', '😰'),
  excited('Entusiasta', '🤩');

  const Mood(this.label, this.emoji);
  final String label;
  final String emoji;

  /// Vero per gli stati a rischio di decisioni impulsive.
  bool get isAtRisk => this == Mood.nervous || this == Mood.tempted;

  /// Risposta empatica e di coaching, in linea col tono di Wally.
  String get coachResponse => switch (this) {
        Mood.serene =>
          'Che bello. La serenità è la migliore alleata dell\'investitore di '
              'lungo periodo: continua così, senza guardare il portafoglio ogni '
              'cinque minuti. 😌',
        Mood.nervous =>
          'È normale sentirsi nervosi quando i mercati ballano. Ma il tuo piano '
              'è costruito proprio per attraversare queste fasi. Respira: non '
              'devi fare nulla. Restare è già la scelta giusta.',
        Mood.tempted =>
          'Fermati un attimo. La voglia di vendere arriva quasi sempre nel '
              'momento peggiore: vendere ora cristallizza la perdita e ti fa '
              'rischiare di perderti il recupero. Storicamente il mercato ha '
              'sempre recuperato. Sei un not-quitter: non mollare adesso. 💪',
        Mood.excited =>
          'Bello l\'entusiasmo! Occhio però a non farti tentare da mosse '
              'impulsive o dal voler "investire di più perché tutto sale". '
              'Mantieni il piano e la disciplina del PAC.',
      };

  static Mood fromName(String? name) => Mood.values.firstWhere(
        (m) => m.name == name,
        orElse: () => Mood.serene,
      );
}
