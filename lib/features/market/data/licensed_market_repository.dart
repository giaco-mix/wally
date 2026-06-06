import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../domain/fundamentals.dart';
import '../domain/price_point.dart';
import '../domain/quote.dart';
import '../domain/symbol_search_result.dart';
import 'market_repository.dart';

/// **SCAFFOLD** per un provider dati di mercato **licenziato** (es. Twelve Data,
/// EODHD, Financial Modeling Prep, Finnhub, Marketstack…).
///
/// L'astrazione [MarketRepository] è già il punto di sostituzione: per passare a
/// un provider licenziato basta completare i 5 metodi qui sotto con il parsing
/// della sua risposta e selezionarlo con `--dart-define=MARKET_PROVIDER=licensed`
/// (più `MARKET_API_BASE_URL` e `MARKET_API_KEY`). Nessuna modifica alla UI.
///
/// Lo scheletro HTTP (base URL, API key, gestione errori) è già pronto; restano
/// da implementare le mappature `*_fromX` verso i modelli di dominio
/// ([Quote], [Fundamentals], [PriceHistory], [SymbolSearchResult]). Finché non
/// sono completate, i metodi lanciano [UnimplementedError] di proposito.
///
/// Vedi `docs/market-data-providers.md` per il confronto e la scelta.
class LicensedMarketRepository implements MarketRepository {
  LicensedMarketRepository({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  /// GET generico verso il provider, con API key come query param.
  /// Se il provider usa un header (es. `Authorization`/`X-API-KEY`), spostare
  /// la chiave da `queryParameters` agli `headers`.
  // ignore: unused_element  // helper del template, usato quando si completano i metodi
  Future<Map<String, dynamic>> _get(
    String path,
    Map<String, String> params,
  ) async {
    final uri = Uri.parse('${AppConfig.marketApiBaseUrl}$path').replace(
      queryParameters: {...params, 'apikey': AppConfig.marketApiKey},
    );
    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw MarketException(
        'Errore ${res.statusCode} da provider licenziato: ${res.body}',
      );
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  @override
  Future<Quote> quote(String symbol) async {
    // TODO(provider): chiamare l'endpoint quote e mappare su Quote.
    // final json = await _get('/quote', {'symbol': symbol});
    // return Quote.fromLicensed(json);
    throw UnimplementedError('quote(): completa il mapping del provider scelto.');
  }

  @override
  Future<Map<String, Quote>> quotes(List<String> symbols) async {
    // Molti provider supportano batch (es. symbol=AAPL,MSFT): usalo se possibile.
    final result = <String, Quote>{};
    await Future.wait(symbols.map((s) async {
      try {
        result[s.toUpperCase()] = await quote(s);
      } catch (_) {
        // Un simbolo non risolvibile non deve far fallire l'intero batch.
      }
    }));
    return result;
  }

  @override
  Future<Fundamentals> fundamentals(String symbol) async {
    // TODO(provider): endpoint fondamentali -> Fundamentals.
    throw UnimplementedError(
        'fundamentals(): completa il mapping del provider scelto.');
  }

  @override
  Future<PriceHistory> history(String symbol, HistoryRange range) async {
    // TODO(provider): endpoint serie storica -> PriceHistory. Tradurre
    // range.range/range.interval nei parametri del provider.
    throw UnimplementedError(
        'history(): completa il mapping del provider scelto.');
  }

  @override
  Future<List<SymbolSearchResult>> search(String query) async {
    // TODO(provider): endpoint ricerca simboli -> List<SymbolSearchResult>.
    throw UnimplementedError(
        'search(): completa il mapping del provider scelto.');
  }
}
