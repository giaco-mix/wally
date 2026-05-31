import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../domain/fundamentals.dart';
import '../domain/price_point.dart';
import '../domain/symbol_search_result.dart';

final fundamentalsProvider =
    FutureProvider.family<Fundamentals, String>((ref, symbol) async {
  return ref.watch(marketRepositoryProvider).fundamentals(symbol);
});

final symbolSearchProvider =
    FutureProvider.family<List<SymbolSearchResult>, String>((ref, query) async {
  if (query.trim().length < 2) return const [];
  return ref.watch(marketRepositoryProvider).search(query.trim());
});

typedef HistoryArgs = ({String symbol, HistoryRange range});

final priceHistoryProvider =
    FutureProvider.family<PriceHistory, HistoryArgs>((ref, args) async {
  return ref.watch(marketRepositoryProvider).history(args.symbol, args.range);
});
