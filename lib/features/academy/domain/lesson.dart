/// Una "lezione" dell'area educativa. Contenuto **descrittivo, non
/// prescrittivo**: spiega come funzionano le cose, non dice cosa comprare.
class Lesson {
  const Lesson({
    required this.id,
    required this.category,
    required this.title,
    required this.summary,
    required this.body,
    this.minutes = 3,
  });

  final String id;
  final String category;
  final String title;
  final String summary;
  final String body; // paragrafi separati da doppio a-capo
  final int minutes;
}

/// Categorie in ordine di percorso.
const academyCategories = <String>[
  'Le basi',
  'Gli approcci',
  'Dalla strategia allo strumento',
  'Comportamento',
  'Fiscalità (Italia)',
];

/// Catalogo delle lezioni. Ogni testo si chiude ricordando che è educativo.
const academyLessons = <Lesson>[
  // ── Le basi ────────────────────────────────────────────────────────────
  Lesson(
    id: 'compound',
    category: 'Le basi',
    title: 'Il tempo è il tuo alleato',
    summary: 'Interesse composto e orizzonte: perché iniziare presto conta più di quanto versi.',
    body:
        'L\'interesse composto è il meccanismo per cui i rendimenti generano a '
        'loro volta rendimenti. Su orizzonti lunghi diventa la forza più potente '
        'a disposizione dell\'investitore.\n\n'
        'Un esempio: 100€ al mese per 30 anni sono 36.000€ versati; con un '
        'rendimento medio ipotetico del 6% annuo potrebbero diventare molto di '
        'più, perché ogni anno cresce anche ciò che gli anni prima hanno reso.\n\n'
        'La conseguenza pratica: iniziare **presto** e restare investito conta '
        'spesso più di quanto riesci a versare. È anche il motivo per cui '
        'interrompere il piano nei momenti difficili è così costoso.\n\n'
        'A scopo educativo: le percentuali sono ipotesi, non garanzie.',
  ),
  Lesson(
    id: 'asset-classes',
    category: 'Le basi',
    title: 'Azioni, obbligazioni, ETF: chi fa cosa',
    summary: 'Il ruolo di ciascun mattoncino del portafoglio.',
    body:
        '**Azioni**: quote di proprietà di aziende. Sono il motore di crescita '
        'nel lungo periodo, ma oscillano molto.\n\n'
        '**Obbligazioni**: prestiti a stati o aziende che pagano interessi. Più '
        'stabili delle azioni, rendono meno; si distinguono per durata (breve/'
        'media/lunga) e rischio dell\'emittente.\n\n'
        '**ETF**: fondi che replicano un indice (es. l\'MSCI World). Con un solo '
        'strumento compri centinaia o migliaia di titoli: diversificazione '
        'immediata, costi bassi. Sono il mattone più usato dagli investitori '
        'passivi.\n\n'
        '**Liquidità/oro/altro**: cuscinetti o coperture. Nessuno di questi è '
        '"giusto" o "sbagliato": dipende dall\'obiettivo. (Contenuto educativo.)',
  ),
  Lesson(
    id: 'diversify',
    category: 'Le basi',
    title: 'Diversificare: non mettere tutto in un posto',
    summary: 'Perché mescolare riduce il rischio senza rinunciare troppo al rendimento.',
    body:
        'Diversificare significa distribuire i soldi su strumenti che non si '
        'muovono tutti insieme. Quando uno scende, un altro può reggere: il '
        'risultato è un percorso più liscio, con meno sobbalzi.\n\n'
        'Non elimina il rischio (in una crisi globale scende quasi tutto), ma ne '
        'riduce l\'intensità e soprattutto la probabilità di errori gravi legati '
        'a una singola scommessa andata male.\n\n'
        'Un ETF azionario globale è già molto diversificato al suo interno; '
        'aggiungere obbligazioni o altre classi serve a modulare quanto il '
        'portafoglio oscilla. A scopo educativo.',
  ),

  // ── Gli approcci ─────────────────────────────────────────────────────────
  Lesson(
    id: 'passive',
    category: 'Gli approcci',
    title: 'Investire passivo: PAC + lazy portfolio',
    summary: 'La via semplice e robusta: versamenti costanti su portafogli-modello.',
    body:
        'L\'approccio passivo non cerca di battere il mercato: cerca di '
        '**seguirlo** a basso costo, con disciplina. Due ingredienti:\n\n'
        '1. **PAC (Piano di Accumulo)**: versare una cifra fissa a intervalli '
        'regolari. Compri sempre, un po\' alla volta, senza dover indovinare il '
        'momento giusto.\n\n'
        '2. **Lazy portfolio**: un\'allocazione semplice e diversificata (es. '
        '3-fund, 60/40, all-world) da mantenere nel tempo, ribilanciando ogni '
        'tanto.\n\n'
        'È l\'approccio più adatto a chi non vuole (o non può) analizzare singole '
        'aziende. Poco lavoro, pochi errori. Non è "meno serio": è la scelta di '
        'moltissimi investitori competenti. (Educativo, non un consiglio.)',
  ),
  Lesson(
    id: 'value',
    category: 'Gli approcci',
    title: 'Value investing: comprare sotto il valore',
    summary: 'L\'approccio di Graham e Buffett: valore intrinseco e margine di sicurezza.',
    body:
        'Il value investing (Benjamin Graham, poi Warren Buffett) parte da '
        'un\'idea: un\'azienda ha un **valore intrinseco** — quanto vale davvero, '
        'stimato dai suoi flussi di cassa futuri — che può differire dal '
        '**prezzo** di mercato.\n\n'
        'Il value investor stima quel valore, e compra solo quando il prezzo è '
        '**sensibilmente sotto**, lasciando un **margine di sicurezza** (una '
        'distanza di sicurezza contro gli errori di stima: spesso ~30%). Poi '
        'attende, senza farsi guidare dalle oscillazioni di breve.\n\n'
        'È un approccio potente ma **impegnativo**: richiede analisi dei bilanci '
        'e pazienza. È adatto a chi fa selezione di singoli titoli, non a chi fa '
        'PAC su ETF. In Wally trovi uno **strumento per stimare il valore '
        'intrinseco** (con assunzioni tue) nella scheda del titolo. (Educativo, '
        'non un consiglio di acquisto.)',
  ),
  Lesson(
    id: 'all-weather',
    category: 'Gli approcci',
    title: 'All Weather: un portafoglio per ogni stagione',
    summary: 'L\'idea di Ray Dalio: bilanciare il rischio tra scenari economici.',
    body:
        'L\'All Weather (Ray Dalio) nasce da una domanda: come costruire un '
        'portafoglio che regga in **qualunque scenario** economico (crescita, '
        'recessione, inflazione, deflazione)?\n\n'
        'La risposta: bilanciare non i soldi ma il **rischio** tra classi che '
        'reagiscono in modo diverso — tipicamente molte obbligazioni (brevi e '
        'lunghe), una parte di azioni, oro e materie prime.\n\n'
        'L\'obiettivo non è il massimo rendimento, ma un percorso **stabile** con '
        'poche scosse. È un esempio di come "la strategia giusta" dipenda da cosa '
        'cerchi: serenità o crescita massima. Sapere cosa vuoi viene prima di '
        'scegliere gli strumenti. (Contenuto educativo.)',
  ),

  // ── Dalla strategia allo strumento ───────────────────────────────────────
  Lesson(
    id: 'pick-etf',
    category: 'Dalla strategia allo strumento',
    title: 'Stesso indice, ETF diversi: cosa guardare',
    summary: 'Deciso "cosa" comprare, come scegli il fondo concreto?',
    body:
        'Hai deciso l\'allocazione (es. 60% azionario mondiale): ma di ETF '
        'sull\'MSCI World ce ne sono decine. La differenza la fanno pochi '
        'fattori chiave:\n\n'
        '• **TER** (costo annuo): più basso è, meglio è, a parità di indice.\n'
        '• **ACC vs DIST**: ad accumulazione (reinveste i dividendi da solo) o a '
        'distribuzione (te li paga). ACC è comodo per far crescere; DIST se vuoi '
        'una rendita.\n'
        '• **Valuta** del fondo e copertura (hedge sì/no).\n'
        '• **Replica** (fisica/sintetica) e **dimensione/liquidità** (fondi '
        'grandi e liquidi costano meno da comprare/vendere).\n\n'
        'In Wally usa il **confronto** per mettere due strumenti fianco a fianco. '
        'A parità di indice, il tuo compito è scegliere il "contenitore" migliore, '
        'non indovinare il mercato. (Educativo.)',
  ),

  // ── Comportamento ────────────────────────────────────────────────────────
  Lesson(
    id: 'behavior-gap',
    category: 'Comportamento',
    title: 'Il nemico sei tu: il behavior gap',
    summary: 'Perché l\'investitore medio guadagna meno del mercato in cui investe.',
    body:
        'Studi come "Mind the Gap" (Morningstar) mostrano un fatto scomodo: '
        'l\'investitore medio ottiene **meno** del rendimento del fondo in cui '
        'investe. La differenza (il *behavior gap*) nasce dai comportamenti: si '
        'compra dopo che è salito, si vende nel panico dei ribassi, si interrompe '
        'il PAC quando il mercato scende (cioè quando conviene di più).\n\n'
        'La buona notizia: è la parte su cui hai **più controllo**. Un piano '
        'scritto, versamenti automatici e un freno gentile nei momenti di paura '
        'valgono, sul lungo periodo, più di qualsiasi selezione di titoli.\n\n'
        'È esattamente il lavoro di Wally Coach: tenerti nel piano. (Educativo.)',
  ),

  // ── Fiscalità ────────────────────────────────────────────────────────────
  Lesson(
    id: 'tax-it',
    category: 'Fiscalità (Italia)',
    title: 'Tasse in breve (Italia)',
    summary: 'Le nozioni base: aliquote, bollo, minus/plusvalenze. Non è consulenza fiscale.',
    body:
        'Alcune nozioni generali sulla fiscalità degli investimenti in Italia '
        '(possono cambiare nel tempo — verifica sempre le regole aggiornate):\n\n'
        '• **Capital gain**: le plusvalenze su azioni/ETF sono tassate in genere '
        'al **26%** (i titoli di Stato italiani e assimilati al **12,5%**).\n'
        '• **Imposta di bollo**: circa **0,20%** annuo sul valore del deposito '
        'titoli.\n'
        '• **Minusvalenze**: le perdite realizzate creano un "credito" che puoi '
        'compensare con plusvalenze **della stessa natura** entro alcuni anni. '
        'Attenzione: con molti ETF (armonizzati) le plusvalenze da ETF **non** '
        'compensano le minus da altri ETF — una regola che spiazza molti.\n'
        '• **Regime**: amministrato (fa tutto la banca) o dichiarativo (te ne '
        'occupi tu).\n\n'
        'Questo è materiale **educativo**, non consulenza fiscale: per il tuo caso '
        'specifico rivolgiti a un commercialista.',
  ),
];
