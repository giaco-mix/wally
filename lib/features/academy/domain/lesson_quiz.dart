/// Un quiz a fine lezione: una domanda, opzioni, indice della risposta giusta.
class LessonQuiz {
  const LessonQuiz({
    required this.question,
    required this.options,
    required this.answer,
    this.explanation,
  });

  final String question;
  final List<String> options;
  final int answer;
  final String? explanation;
}

/// Quiz associati alle lezioni per id (vedi academyLessons).
const academyQuizzes = <String, LessonQuiz>{
  'compound': LessonQuiz(
    question: 'Perché l\'interesse composto è così potente nel lungo periodo?',
    options: [
      'Perché garantisce un rendimento fisso',
      'Perché i rendimenti generano a loro volta rendimenti',
      'Perché elimina il rischio di mercato',
    ],
    answer: 1,
    explanation:
        'Ogni anno cresce anche ciò che gli anni precedenti hanno reso: l\'effetto si accumula nel tempo.',
  ),
  'asset-classes': LessonQuiz(
    question: 'Qual è tipicamente il "motore di crescita" di un portafoglio?',
    options: ['Le obbligazioni', 'La liquidità', 'Le azioni'],
    answer: 2,
    explanation:
        'Le azioni rendono di più nel lungo periodo, ma oscillano di più.',
  ),
  'diversify': LessonQuiz(
    question: 'Cosa fa (soprattutto) la diversificazione?',
    options: [
      'Elimina del tutto il rischio',
      'Riduce l\'intensità delle oscillazioni e il rischio di errori gravi',
      'Garantisce un guadagno',
    ],
    answer: 1,
    explanation:
        'In una crisi globale scende quasi tutto: diversificare attenua, non azzera.',
  ),
  'passive': LessonQuiz(
    question: 'A cosa serve soprattutto il PAC?',
    options: [
      'A battere il mercato',
      'A non dover indovinare il momento giusto per entrare',
      'A evitare le tasse',
    ],
    answer: 1,
    explanation: 'Versando a intervalli regolari compri un po\' alla volta.',
  ),
  'value': LessonQuiz(
    question: 'Nel value investing, il "margine di sicurezza" serve a…',
    options: [
      'Coprire gli errori di stima comprando sotto il valore',
      'Garantire un rendimento minimo',
      'Ridurre le tasse sulla plusvalenza',
    ],
    answer: 0,
    explanation:
        'Si compra a un prezzo sensibilmente sotto il valore intrinseco stimato.',
  ),
  'all-weather': LessonQuiz(
    question: 'Qual è l\'obiettivo principale dell\'All Weather?',
    options: [
      'Il massimo rendimento possibile',
      'Reggere in ogni scenario economico con poche scosse',
      'Investire solo in azioni USA',
    ],
    answer: 1,
    explanation: 'Bilancia il rischio tra classi che reagiscono in modo diverso.',
  ),
  'pick-etf': LessonQuiz(
    question: 'A parità di indice, cosa distingue soprattutto due ETF?',
    options: [
      'Il nome dell\'emittente',
      'TER, accumulazione/distribuzione, valuta, liquidità',
      'Il colore del logo',
    ],
    answer: 1,
  ),
  'behavior-gap': LessonQuiz(
    question: 'Il "behavior gap" nasce principalmente da…',
    options: [
      'Costi troppo alti dei fondi',
      'Errori comportamentali (vendere nel panico, inseguire le mode)',
      'Tasse elevate',
    ],
    answer: 1,
    explanation:
        'È la parte su cui l\'investitore ha più controllo: restare nel piano.',
  ),
  'tax-it': LessonQuiz(
    question: 'In Italia, l\'aliquota tipica sul capital gain di azioni/ETF è…',
    options: ['12,5%', '26%', '43%'],
    answer: 1,
    explanation:
        'I titoli di Stato italiani e assimilati sono invece al 12,5%. (Educativo.)',
  ),
};
