import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../domain/fundamentals.dart';
import '../domain/price_point.dart';
import '../domain/quote.dart';
import '../domain/symbol_search_result.dart';

abstract class MarketRepository {
  Future<Quote> quote(String symbol);
  Future<Map<String, Quote>> quotes(List<String> symbols);
  Future<Fundamentals> fundamentals(String symbol);
  Future<List<SymbolSearchResult>> search(String query);
  Future<PriceHistory> history(String symbol, HistoryRange range);
}

/// Repository reale: chiama l'edge function Supabase che fa da proxy a Yahoo.
class YahooMarketRepository implements MarketRepository {
  YahooMarketRepository({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String action, Map<String, String> params) {
    return Uri.parse(AppConfig.yahooFunctionUrl).replace(
      queryParameters: {'action': action, ...params},
    );
  }

  Future<Map<String, dynamic>> _get(String action, Map<String, String> p) async {
    final res = await _client.get(
      _uri(action, p),
      headers: {
        'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
        'apikey': AppConfig.supabaseAnonKey,
      },
    );
    if (res.statusCode != 200) {
      throw MarketException(
        'Errore ${res.statusCode} per "$action": ${res.body}',
      );
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  @override
  Future<Quote> quote(String symbol) async {
    final json = await _get('chart', {'symbol': symbol});
    return Quote.fromYahooChart(json);
  }

  @override
  Future<Map<String, Quote>> quotes(List<String> symbols) async {
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
    final json = await _get('summary', {'symbol': symbol});
    return Fundamentals.fromYahooSummary(symbol, json);
  }

  @override
  Future<PriceHistory> history(String symbol, HistoryRange range) async {
    final json = await _get('chart', {
      'symbol': symbol,
      'range': range.range,
      'interval': range.interval,
    });
    return PriceHistory.fromYahooChart(symbol, json);
  }

  @override
  Future<List<SymbolSearchResult>> search(String query) async {
    final json = await _get('search', {'q': query});
    final quotes = (json['quotes'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .where((q) => q['symbol'] != null)
        .map(SymbolSearchResult.fromYahoo)
        .toList();
    return quotes;
  }
}

class MarketException implements Exception {
  MarketException(this.message);
  final String message;
  @override
  String toString() => message;
}
