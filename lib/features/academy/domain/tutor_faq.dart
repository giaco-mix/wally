/// Una risposta pre-impostata del tutor demo: parole chiave → risposta.
class TutorAnswer {
  const TutorAnswer({
    required this.keywords,
    required this.answer,
    this.route,
    this.routeLabel,
  });

  final List<String> keywords;
  final String answer;
  final String? route; // es. apri una lezione/sezione correlata
  final String? routeLabel;
}

/// Tutor **in anteprima**: risponde a temi comuni con testi pre-scritti. Nella
/// versione completa qui ci sarà un vero assistente AI.
class TutorDemo {
  const TutorDemo._();

  static const _answers = <TutorAnswer>[
    TutorAnswer(
      keywords: ['pac', 'accumulo', 'versamento', 'versare'],
      answer:
          'Il PAC (Piano di Accumulo) è versare una cifra fissa a intervalli '
          'regolari. Compri un po\' alla volta, senza dover indovinare il momento '
          'giusto: è la difesa numero uno contro il market timing. In Wally lo '
          'registri in Movimenti e vedi il rendimento di ogni versamento.',
      route: '/academy',
      routeLabel: 'Vai a Impara',
    ),
    TutorAnswer(
      keywords: ['etf', 'fondo', 'indice'],
      answer:
          'Un ETF è un fondo quotato che replica un indice (es. l\'MSCI World): '
          'con un solo strumento compri tanti titoli, a basso costo. A parità di '
          'indice, scegli guardando TER, accumulazione/distribuzione, valuta e '
          'liquidità. Usa "Trova lo strumento" per orientarti.',
      route: '/strumenti',
      routeLabel: 'Trova lo strumento',
    ),
    TutorAnswer(
      keywords: ['rischio', 'profilo', 'prudente', 'aggressivo'],
      answer:
          'Il profilo di rischio è quanto sei davvero disposto a vedere oscillare '
          'il portafoglio. Non quello che vorresti, ma quello che ti fa dormire '
          'la notte quando il mercato scende. Da lì discende l\'allocazione '
          '(più o meno azioni).',
      route: '/strategie',
      routeLabel: 'Vedi le strategie',
    ),
    TutorAnswer(
      keywords: ['ribilanci', 'riequilibr', 'soglia'],
      answer:
          'Ribilanciare significa riportare le percentuali del portafoglio ai '
          'valori obiettivo quando si sono spostate. Meglio farlo con i nuovi '
          'versamenti (più efficiente), e con calma secondo una cadenza. In Wally '
          'trovi la sezione Ribilanciamento con la cadenza e gli scostamenti.',
      route: '/rebalance',
      routeLabel: 'Vai al ribilanciamento',
    ),
    TutorAnswer(
      keywords: ['diversific', 'allocazione'],
      answer:
          'Diversificare è distribuire i soldi su strumenti che non si muovono '
          'tutti insieme: quando uno scende, un altro può reggere. Non elimina il '
          'rischio, ma ne riduce l\'intensità e il rischio di errori gravi.',
    ),
    TutorAnswer(
      keywords: ['composto', 'tempo', 'orizzonte'],
      answer:
          'L\'interesse composto fa sì che i rendimenti generino altri '
          'rendimenti. Su orizzonti lunghi è la forza più potente: iniziare '
          'presto e restare investito conta spesso più di quanto riesci a versare.',
    ),
    TutorAnswer(
      keywords: ['tass', 'fiscal', 'imposte', '26', 'bollo', 'minusval'],
      answer:
          'In Italia le plusvalenze su azioni/ETF sono tassate in genere al 26% '
          '(titoli di Stato al 12,5%), c\'è un\'imposta di bollo ~0,20% annuo, e le '
          'minusvalenze si possono compensare (con regole particolari per gli '
          'ETF). È materiale educativo, non consulenza fiscale.',
      route: '/academy',
      routeLabel: 'Leggi la lezione',
    ),
    TutorAnswer(
      keywords: ['intrinseco', 'dcf', 'valore', 'buffett', 'graham', 'margine'],
      answer:
          'Il valore intrinseco è quanto "vale davvero" un\'azienda secondo una '
          'stima dei flussi di cassa futuri attualizzati. Il value investing '
          'compra quando il prezzo è sotto quel valore, lasciando un margine di '
          'sicurezza. In Wally trovi uno strumento DCF nella scheda di un\'azione.',
    ),
    TutorAnswer(
      keywords: ['paura', 'panic', 'crollo', 'scende', 'vendere', 'rosso'],
      answer:
          'È normale avere paura quando il mercato scende. Ma vendere nel panico '
          'cristallizza le perdite ed è uno degli errori più costosi. Il piano è '
          'pensato proprio per questi momenti. Dai un\'occhiata al Coach prima di '
          'decisioni impulsive.',
      route: '/coach',
      routeLabel: 'Apri Wally Coach',
    ),
    TutorAnswer(
      keywords: ['dividend', 'cedola', 'rendita'],
      answer:
          'Il dividendo è la quota di utili che un\'azienda o un ETF distribuisce. '
          'Un ETF ad accumulazione li reinveste da solo; a distribuzione te li '
          'paga. Per una rendita servono strumenti a distribuzione.',
    ),
  ];

  /// Trova la risposta migliore per [question] (match per parola chiave).
  /// Ritorna null se non trova nulla di rilevante.
  static TutorAnswer? answer(String question) {
    final q = question.toLowerCase();
    TutorAnswer? best;
    var bestScore = 0;
    for (final a in _answers) {
      final score = a.keywords.where((k) => q.contains(k)).length;
      if (score > bestScore) {
        bestScore = score;
        best = a;
      }
    }
    return best;
  }

  /// Argomenti suggeriti quando non c'è un match.
  static const suggestions = [
    'Cos\'è un PAC?',
    'Come scelgo un ETF?',
    'Cosa vuol dire ribilanciare?',
    'Come funzionano le tasse?',
    'Il mercato sta scendendo, che faccio?',
  ];
}
