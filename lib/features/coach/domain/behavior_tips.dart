/// Pillole di finanza comportamentale mostrate per tenere alta la disciplina.
class BehaviorTips {
  const BehaviorTips._();

  static const List<String> tips = [
    'Il tempo nel mercato batte il tempismo sul mercato: chi resta investito, '
        'storicamente, vince su chi entra ed esce.',
    'Le tue peggiori decisioni le prenderai quando sei emotivo. Il piano serve '
        'proprio a toglierti quella scelta di dosso.',
    'Una discesa è uno sconto: con il PAC compri più quote quando i prezzi sono '
        'bassi.',
    'Dopo ogni grande crisi, il mercato ha sempre recuperato. Chi era uscito, '
        'spesso si è perso proprio il rimbalzo.',
    'Non controllare il portafoglio ogni giorno: più lo guardi, più sei tentato '
        'di fare mosse che non servono.',
    'Vendere nel panico trasforma una perdita "sulla carta" in una perdita vera.',
    'La diversificazione è l\'unico pasto gratis in finanza: non puntare tutto su '
        'una sola carta.',
    'Il rendimento più importante non è quello del fondo, ma quello che riesci '
        'davvero a tenere restando costante.',
  ];

  /// Tip "del giorno", stabile nell'arco della giornata.
  static String ofToday() {
    final day = DateTime.now();
    final seed = day.year * 1000 + day.month * 50 + day.day;
    return tips[seed % tips.length];
  }
}
