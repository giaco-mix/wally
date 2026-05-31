import 'dart:math';

import '../domain/fundamentals.dart';
import '../domain/quote.dart';
import '../domain/symbol_search_result.dart';
import 'market_repository.dart';

/// Implementazione di fallback usata quando Supabase/edge function non sono
/// configurati: restituisce dati realistici ma sintetici, così la UI è
/// pienamente navigabile in modalità demo.
class MockMarketRepository implements MarketRepository {
  final _rnd = Random(7);

  static final Map<String, _Seed> _seeds = {
    'AAPL': _Seed('Apple Inc.', 195.0, 'Technology', 'Consumer Electronics',
        marketCap: 3.0e12, pe: 31.2, roe: 1.47, margin: 0.25, debt: 1.4,
        dividend: 0.005, beta: 1.28),
    'MSFT': _Seed('Microsoft Corp.', 415.0, 'Technology', 'Software',
        marketCap: 3.1e12, pe: 36.0, roe: 0.39, margin: 0.36, debt: 0.35,
        dividend: 0.0075, beta: 0.9),
    'GOOGL': _Seed('Alphabet Inc.', 175.0, 'Communication Services',
        'Internet Content',
        marketCap: 2.1e12, pe: 26.5, roe: 0.30, margin: 0.27, debt: 0.10,
        dividend: 0.0, beta: 1.05),
    'AMZN': _Seed('Amazon.com Inc.', 185.0, 'Consumer Cyclical',
        'Internet Retail',
        marketCap: 1.9e12, pe: 43.0, roe: 0.21, margin: 0.07, debt: 0.55,
        dividend: 0.0, beta: 1.15),
    'VWCE.DE': _Seed('Vanguard FTSE All-World UCITS ETF', 118.0, 'ETF',
        'Global Equity',
        marketCap: 2.0e10, dividend: 0.015, beta: 1.0),
    'TSLA': _Seed('Tesla Inc.', 250.0, 'Consumer Cyclical', 'Auto Manufacturers',
        marketCap: 8.0e11, pe: 65.0, roe: 0.18, margin: 0.10, debt: 0.08,
        dividend: 0.0, beta: 2.0),
  };

  _Seed _seedFor(String symbol) =>
      _seeds[symbol.toUpperCase()] ??
      _Seed(symbol.toUpperCase(), 50 + _rnd.nextDouble() * 200, 'Other',
          'Unknown',
          marketCap: 1e9, pe: 18, roe: 0.12, margin: 0.10, debt: 0.5,
          dividend: 0.01, beta: 1.0);

  @override
  Future<Quote> quote(String symbol) async {
    await Future.delayed(const Duration(milliseconds: 120));
    final s = _seedFor(symbol);
    final prev = s.price * (1 + (_rnd.nextDouble() - 0.5) * 0.02);
    return Quote(
      symbol: symbol.toUpperCase(),
      price: s.price,
      previousClose: prev,
      currency: 'USD',
      shortName: s.name,
    );
  }

  @override
  Future<Map<String, Quote>> quotes(List<String> symbols) async {
    final out = <String, Quote>{};
    for (final s in symbols) {
      out[s.toUpperCase()] = await quote(s);
    }
    return out;
  }

  @override
  Future<Fundamentals> fundamentals(String symbol) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final s = _seedFor(symbol);
    return Fundamentals(
      symbol: symbol.toUpperCase(),
      name: s.name,
      sector: s.sector,
      industry: s.industry,
      marketCap: s.marketCap,
      trailingPe: s.pe,
      forwardPe: s.pe == null ? null : s.pe! * 0.9,
      priceToBook: s.pe == null ? null : s.pe! / 8,
      returnOnEquity: s.roe,
      profitMargins: s.margin,
      debtToEquity: s.debt,
      dividendYield: s.dividend,
      beta: s.beta,
      currentRatio: 1.5,
      revenueGrowth: 0.08,
      summary:
          '${s.name} — dati dimostrativi generati localmente (modalità demo, '
          'nessuna connessione a Yahoo Finance).',
    );
  }

  @override
  Future<List<SymbolSearchResult>> search(String query) async {
    await Future.delayed(const Duration(milliseconds: 120));
    final q = query.toUpperCase();
    final matches = _seeds.entries
        .where((e) => e.key.contains(q) || e.value.name.toUpperCase().contains(q))
        .map((e) => SymbolSearchResult(
              symbol: e.key,
              name: e.value.name,
              exchange: 'DEMO',
              type: e.value.sector == 'ETF' ? 'ETF' : 'Equity',
            ))
        .toList();
    if (matches.isEmpty && query.trim().isNotEmpty) {
      matches.add(SymbolSearchResult(
        symbol: q,
        name: '$q (demo)',
        exchange: 'DEMO',
        type: 'Equity',
      ));
    }
    return matches;
  }
}

class _Seed {
  _Seed(
    this.name,
    this.price,
    this.sector,
    this.industry, {
    this.marketCap,
    this.pe,
    this.roe,
    this.margin,
    this.debt,
    this.dividend,
    this.beta,
  });

  final String name;
  final double price;
  final String sector;
  final String industry;
  final double? marketCap;
  final double? pe;
  final double? roe;
  final double? margin;
  final double? debt;
  final double? dividend;
  final double? beta;
}
