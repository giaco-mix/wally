/// Uno strumento (ETF) del catalogo curato, con gli attributi che contano nella
/// scelta. Dati **indicativi**: il valore autoritativo è il KIID/sito emittente.
class InstrumentPick {
  const InstrumentPick({
    required this.role,
    required this.name,
    required this.ticker,
    required this.isin,
    required this.ter,
    required this.distribution, // 'ACC' | 'DIST'
    required this.currency,
    this.note,
  });

  final String role;
  final String name;
  final String ticker;
  final String isin;
  final double ter; // % annua, indicativa
  final String distribution;
  final String currency;
  final String? note;
}

/// Ruoli = le "fette" con cui si costruisce un portafoglio (lazy o All Weather).
const instrumentRoles = <String>[
  'Azionario mondiale',
  'Azionario USA (S&P 500)',
  'Azionario Europa',
  'Mercati emergenti',
  'Obbligazionario globale',
  'Obbligazionario breve termine',
  'Oro',
];

/// Catalogo curato dei più diffusi (dati indicativi — verifica sempre il KIID).
const instrumentCatalog = <InstrumentPick>[
  // Azionario mondiale
  InstrumentPick(
      role: 'Azionario mondiale',
      name: 'iShares Core MSCI World',
      ticker: 'SWDA.MI',
      isin: 'IE00B4L5Y983',
      ter: 0.20,
      distribution: 'ACC',
      currency: 'USD',
      note: 'Grande e liquidissimo; ~1500 titoli paesi sviluppati.'),
  InstrumentPick(
      role: 'Azionario mondiale',
      name: 'Vanguard FTSE All-World',
      ticker: 'VWCE.DE',
      isin: 'IE00BK5BQT80',
      ter: 0.22,
      distribution: 'ACC',
      currency: 'USD',
      note: 'Include anche i mercati emergenti (all-world).'),
  // Azionario USA
  InstrumentPick(
      role: 'Azionario USA (S&P 500)',
      name: 'iShares Core S&P 500',
      ticker: 'CSPX.MI',
      isin: 'IE00B5BMR087',
      ter: 0.07,
      distribution: 'ACC',
      currency: 'USD'),
  InstrumentPick(
      role: 'Azionario USA (S&P 500)',
      name: 'Vanguard S&P 500',
      ticker: 'VUAA.DE',
      isin: 'IE00BFMXXD54',
      ter: 0.07,
      distribution: 'ACC',
      currency: 'USD'),
  // Azionario Europa
  InstrumentPick(
      role: 'Azionario Europa',
      name: 'iShares Core MSCI Europe',
      ticker: 'IMEU.MI',
      isin: 'IE00B4K48X80',
      ter: 0.12,
      distribution: 'ACC',
      currency: 'EUR'),
  // Emergenti
  InstrumentPick(
      role: 'Mercati emergenti',
      name: 'iShares Core MSCI EM IMI',
      ticker: 'EIMI.MI',
      isin: 'IE00BKM4GZ66',
      ter: 0.18,
      distribution: 'ACC',
      currency: 'USD'),
  // Obbligazionario globale
  InstrumentPick(
      role: 'Obbligazionario globale',
      name: 'iShares Core Global Aggregate Bond (EUR Hedged)',
      ticker: 'AGGH.MI',
      isin: 'IE00BDBRDM35',
      ter: 0.10,
      distribution: 'ACC',
      currency: 'EUR',
      note: 'Copertura in euro: riduce il rischio cambio.'),
  // Obbligazionario breve
  InstrumentPick(
      role: 'Obbligazionario breve termine',
      name: 'iShares \$ Treasury Bond 0-1yr',
      ticker: 'IB01.MI',
      isin: 'IE00BGSF1X88',
      ter: 0.07,
      distribution: 'ACC',
      currency: 'USD',
      note: 'Molto stabile; usato come parcheggio/cuscinetto.'),
  // Oro
  InstrumentPick(
      role: 'Oro',
      name: 'Invesco Physical Gold',
      ticker: 'SGLD.MI',
      isin: 'IE00B579F325',
      ter: 0.12,
      distribution: 'ACC',
      currency: 'USD',
      note: 'Oro fisico; copertura contro inflazione/crisi.'),
  InstrumentPick(
      role: 'Oro',
      name: 'iShares Physical Gold',
      ticker: 'SGLN.MI',
      isin: 'IE00B4ND3602',
      ter: 0.12,
      distribution: 'ACC',
      currency: 'USD'),
];
