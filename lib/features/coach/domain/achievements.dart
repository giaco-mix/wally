import '../../transactions/domain/transaction.dart';

/// Un traguardo (badge) sbloccabile col comportamento virtuoso.
class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.unlocked,
    this.progress,
  });

  final String id;
  final String title;
  final String description;
  final bool unlocked;
  final double? progress; // 0..1 per i badge "a soglia"
}

/// Calcola i traguardi dai dati già disponibili (ledger + academy + ribilancio).
class Achievements {
  const Achievements._();

  /// Mesi consecutivi (fino al più recente) con almeno un versamento PAC.
  static int pacStreakMonths(List<Transaction> txs) {
    final months = <String>{};
    for (final t in txs) {
      if (t.kind == TxKind.pac && t.side == TxSide.buy) {
        months.add('${t.date.year}-${t.date.month.toString().padLeft(2, '0')}');
      }
    }
    if (months.isEmpty) return 0;
    // Parte dal mese più recente presente e torna indietro finché continua.
    final sorted = months.toList()..sort();
    final last = sorted.last.split('-');
    var y = int.parse(last[0]);
    var m = int.parse(last[1]);
    var streak = 0;
    while (months.contains('$y-${m.toString().padLeft(2, '0')}')) {
      streak++;
      m--;
      if (m == 0) {
        m = 12;
        y--;
      }
    }
    return streak;
  }

  static List<Achievement> compute({
    required List<Transaction> transactions,
    required int lessonsCompleted,
    required int lessonsTotal,
    required bool hasRebalanceCadence,
  }) {
    final pac = transactions
        .where((t) => t.kind == TxKind.pac && t.side == TxSide.buy)
        .length;
    final anyBuy = transactions.any((t) => t.side == TxSide.buy);
    final streak = pacStreakMonths(transactions);

    Achievement a(String id, String title, String desc, bool done,
            [double? progress]) =>
        Achievement(
            id: id,
            title: title,
            description: desc,
            unlocked: done,
            progress: progress);

    return [
      a('first-step', 'Primo passo', 'Hai registrato il tuo primo acquisto',
          anyBuy),
      a('constant', 'Costante', '3 versamenti PAC', pac >= 3,
          (pac / 3).clamp(0, 1)),
      a('disciplined', 'Disciplinato', '6 versamenti PAC', pac >= 6,
          (pac / 6).clamp(0, 1)),
      a('veteran', 'Veterano', '12 versamenti PAC', pac >= 12,
          (pac / 12).clamp(0, 1)),
      a('not-quitter', 'Not-quitter', '6 mesi consecutivi di PAC', streak >= 6,
          (streak / 6).clamp(0, 1)),
      a('student', 'Studioso', '3 lezioni completate', lessonsCompleted >= 3,
          (lessonsCompleted / 3).clamp(0, 1)),
      a(
          'graduate',
          'Dottore in Wally',
          'Tutte le lezioni completate',
          lessonsTotal > 0 && lessonsCompleted >= lessonsTotal,
          lessonsTotal == 0 ? 0 : (lessonsCompleted / lessonsTotal).clamp(0, 1)),
      a('rebalancer', 'Ribilanciatore',
          'Hai impostato la cadenza di ribilanciamento', hasRebalanceCadence),
    ];
  }
}
