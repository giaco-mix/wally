import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../../portfolio/providers/portfolio_providers.dart';
import '../domain/news_item.dart';

/// Notizie relative ai titoli in portafoglio. Chiama l'edge function `yahoo`
/// con azione `news` per i primi simboli; in modalità demo usa dati finti.
final portfolioNewsProvider = FutureProvider<List<NewsItem>>((ref) async {
  final positions = ref.watch(positionsProvider).asData?.value ?? const [];
  final symbols = positions.map((p) => p.holding.symbol).take(4).toList();

  if (!AppConfig.isConfigured) {
    return _demoNews(symbols);
  }
  if (symbols.isEmpty) return const [];

  final client = http.Client();
  final out = <NewsItem>[];
  try {
    for (final s in symbols) {
      final uri = Uri.parse(AppConfig.yahooFunctionUrl)
          .replace(queryParameters: {'action': 'news', 'symbol': s});
      final res = await client.get(uri, headers: {
        'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
        'apikey': AppConfig.supabaseAnonKey,
      });
      if (res.statusCode != 200) continue;
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final news = (json['news'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map((m) => NewsItem.fromYahoo(m, symbol: s));
      out.addAll(news);
    }
  } finally {
    client.close();
  }
  // Dedup per titolo + ordina per data desc.
  final seen = <String>{};
  final deduped = out.where((n) => seen.add(n.title)).toList()
    ..sort((a, b) => (b.providerPublishTime ?? DateTime(2000))
        .compareTo(a.providerPublishTime ?? DateTime(2000)));
  return deduped;
});

List<NewsItem> _demoNews(List<String> symbols) {
  final s = symbols.isEmpty ? 'AAPL' : symbols.first;
  return [
    NewsItem(
      title: '(Demo) $s: i mercati restano volatili, gli analisti invitano alla calma',
      publisher: 'Wally Demo',
      link: '',
      relatedSymbol: s,
    ),
    const NewsItem(
      title: '(Demo) Inflazione in calo: cosa significa per i tuoi ETF',
      publisher: 'Wally Demo',
      link: '',
    ),
  ];
}
