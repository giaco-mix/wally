import 'package:csv/csv.dart';

import '../domain/holding.dart';

/// Campi mappabili dall'header del CSV verso un [Holding].
enum ImportField { symbol, name, quantity, avgPrice, assetClass }

/// Alias di intestazione riconosciuti (lowercase, senza spazi ai bordi) per
/// ciascun campo. Coprono i formati più comuni dei broker IT/EN.
const Map<ImportField, List<String>> _headerAliases = {
  ImportField.symbol: [
    'symbol', 'ticker', 'simbolo', 'sigla', 'codice',
  ],
  ImportField.name: [
    'name', 'nome', 'descrizione', 'description', 'strumento', 'titolo',
  ],
  ImportField.quantity: [
    'quantity', 'qty', 'quantità', 'quantita', 'shares', 'numero', 'pezzi',
    'q.tà', 'q.ta',
  ],
  ImportField.avgPrice: [
    'avg_price', 'avgprice', 'price', 'prezzo', 'prezzo medio', 'prezzo_medio',
    'pmc', 'carico', 'prezzo di carico', 'cost', 'costo',
  ],
  ImportField.assetClass: [
    'asset_class', 'asset class', 'assetclass', 'tipo', 'classe', 'categoria',
  ],
};

/// Parole-chiave per dedurre l'[AssetClass] dal valore di una cella.
/// ORDINE IMPORTANTE:
/// - le obbligazioni vanno PRIMA di `stock` perché "obbligazi**oni**" contiene
///   la sottostringa "azion" (keyword di stock) → altrimenti finirebbe in stock;
/// - le durate (breve/medio/lungo) vanno PRIMA della generica `bond`.
/// I valori esatti tipo "Azioni"/"ETF" passano comunque dal match esatto in
/// [CsvImporter._parseAssetClass], quindi non sono toccati da quest'ordine.
const Map<AssetClass, List<String>> _assetClassKeywords = {
  AssetClass.bondShort: ['brev', 'short'],
  AssetClass.bondMid: ['medi', 'mid', 'intermedi'],
  AssetClass.bondLong: ['lung', 'long'],
  AssetClass.bond: ['obblig', 'bond'],
  AssetClass.stock: ['azion', 'stock', 'equity'],
  AssetClass.etf: ['etf', 'fondo', 'fund'],
  AssetClass.crypto: ['crypto', 'cripto', 'btc', 'eth'],
  AssetClass.cash: ['liquid', 'cash', 'contant', 'conto'],
};

/// Una riga del CSV dopo il parsing: o un [Holding] valido o un [error].
class CsvImportRow {
  const CsvImportRow({required this.lineNumber, this.holding, this.error});

  /// Numero di riga nel file (1-based, header escluso).
  final int lineNumber;
  final Holding? holding;
  final String? error;

  bool get isValid => holding != null;
}

/// Esito completo del parsing di un CSV.
class CsvImportResult {
  const CsvImportResult({
    required this.headers,
    required this.mapping,
    required this.rows,
    required this.delimiter,
  });

  final List<String> headers;
  final Map<ImportField, int> mapping;
  final List<CsvImportRow> rows;
  final String delimiter;

  List<CsvImportRow> get validRows =>
      rows.where((r) => r.isValid).toList(growable: false);
  List<CsvImportRow> get errorRows =>
      rows.where((r) => !r.isValid).toList(growable: false);

  bool get hasRequiredColumns =>
      mapping.containsKey(ImportField.symbol) &&
      mapping.containsKey(ImportField.quantity) &&
      mapping.containsKey(ImportField.avgPrice);
}

/// Eccezione per problemi strutturali del file (non di singole righe).
class CsvImportException implements Exception {
  CsvImportException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Importer CSV flessibile: rileva delimitatore e colonne, e converte le righe
/// in [Holding]. Nessuna dipendenza dall'UI o dalla rete: facilmente testabile.
class CsvImporter {
  const CsvImporter._();

  static CsvImportResult parse(String content) {
    final normalized = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final firstLine = normalized
        .split('\n')
        .firstWhere((l) => l.trim().isNotEmpty, orElse: () => '');
    if (firstLine.isEmpty) {
      throw CsvImportException('Il file è vuoto.');
    }

    final delimiter = _detectDelimiter(firstLine);
    final table = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
        .convert(normalized, fieldDelimiter: delimiter);
    if (table.isEmpty) {
      throw CsvImportException('Nessuna riga leggibile nel file.');
    }

    final headers =
        table.first.map((c) => c.toString().trim()).toList(growable: false);
    final mapping = _detectMapping(headers);

    final rows = <CsvImportRow>[];
    for (var i = 1; i < table.length; i++) {
      final raw = table[i];
      if (raw.every((c) => c.toString().trim().isEmpty)) continue; // riga vuota
      rows.add(_parseRow(raw, mapping, i));
    }

    return CsvImportResult(
      headers: headers,
      mapping: mapping,
      rows: rows,
      delimiter: delimiter,
    );
  }

  static String _detectDelimiter(String headerLine) {
    const candidates = [';', '\t', ','];
    var best = ',';
    var bestCount = -1;
    for (final c in candidates) {
      final count = c.allMatches(headerLine).length;
      if (count > bestCount) {
        bestCount = count;
        best = c;
      }
    }
    return best;
  }

  static Map<ImportField, int> _detectMapping(List<String> headers) {
    final lower =
        headers.map((h) => h.toLowerCase().trim()).toList(growable: false);
    final mapping = <ImportField, int>{};
    for (final entry in _headerAliases.entries) {
      for (var i = 0; i < lower.length; i++) {
        if (entry.value.contains(lower[i])) {
          mapping[entry.key] = i;
          break;
        }
      }
    }
    return mapping;
  }

  static CsvImportRow _parseRow(
    List<dynamic> raw,
    Map<ImportField, int> mapping,
    int lineNumber,
  ) {
    String cell(ImportField f) {
      final idx = mapping[f];
      if (idx == null || idx >= raw.length) return '';
      return raw[idx].toString().trim();
    }

    final symbol = cell(ImportField.symbol);
    if (symbol.isEmpty) {
      return CsvImportRow(lineNumber: lineNumber, error: 'Simbolo mancante');
    }

    final quantity = _parseNumber(cell(ImportField.quantity));
    if (quantity == null || quantity <= 0) {
      return CsvImportRow(
          lineNumber: lineNumber,
          error: 'Quantità non valida ("${cell(ImportField.quantity)}")');
    }

    final price = _parseNumber(cell(ImportField.avgPrice));
    if (price == null || price < 0) {
      return CsvImportRow(
          lineNumber: lineNumber,
          error: 'Prezzo non valido ("${cell(ImportField.avgPrice)}")');
    }

    final name = cell(ImportField.name);
    final holding = Holding(
      id: '',
      symbol: symbol.toUpperCase(),
      name: name.isEmpty ? symbol.toUpperCase() : name,
      quantity: quantity,
      avgPrice: price,
      assetClass: _parseAssetClass(cell(ImportField.assetClass)),
    );
    return CsvImportRow(lineNumber: lineNumber, holding: holding);
  }

  /// Converte una stringa numerica gestendo decimale `,` o `.`, separatori di
  /// migliaia, simboli di valuta e spazi. Ritorna null se non parsabile.
  static double? _parseNumber(String input) {
    var s = input.trim();
    if (s.isEmpty) return null;
    // Rimuove valuta, spazi e separatori non numerici ai bordi.
    s = s.replaceAll(RegExp(r'[^\d,.\-]'), '');
    if (s.isEmpty) return null;

    final hasComma = s.contains(',');
    final hasDot = s.contains('.');
    if (hasComma && hasDot) {
      // Il separatore decimale è l'ultimo che compare; l'altro è le migliaia.
      if (s.lastIndexOf(',') > s.lastIndexOf('.')) {
        s = s.replaceAll('.', '').replaceAll(',', '.'); // 1.234,56 -> 1234.56
      } else {
        s = s.replaceAll(',', ''); // 1,234.56 -> 1234.56
      }
    } else if (hasComma) {
      s = s.replaceAll(',', '.'); // 1234,56 -> 1234.56
    }
    return double.tryParse(s);
  }

  static AssetClass _parseAssetClass(String value) {
    final v = value.toLowerCase().trim();
    if (v.isEmpty) return AssetClass.stock;
    // Prima prova un match esatto col nome enum (stock, etf, ...).
    for (final ac in AssetClass.values) {
      if (ac.name == v || ac.label.toLowerCase() == v) return ac;
    }
    // Poi per parola-chiave contenuta.
    for (final entry in _assetClassKeywords.entries) {
      if (entry.value.any((kw) => v.contains(kw))) return entry.key;
    }
    return AssetClass.other;
  }
}
