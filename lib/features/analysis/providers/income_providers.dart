import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../market/providers/market_providers.dart';
import '../../portfolio/providers/portfolio_providers.dart';

class IncomeItem {
  const IncomeItem({
    required this.symbol,
    required this.value,
    required this.yieldFraction,
  });
  final String symbol;
  final double value;
  final double yieldFraction; // 0..1
  double get income => value * yieldFraction;
}

class IncomeReport {
  const IncomeReport({required this.items});
  final List<IncomeItem> items;
  double get total => items.fold(0, (a, e) => a + e.income);
  double get totalValue => items.fold(0, (a, e) => a + e.value);
  double get avgYield => totalValue == 0 ? 0 : total / totalValue;
}

/// Stima della rendita annua da dividendi/cedole del portafoglio.
final annualIncomeProvider = FutureProvider<IncomeReport>((ref) async {
  final positions = ref.watch(positionsProvider).asData?.value ?? const [];
  final items = <IncomeItem>[];
  for (final p in positions) {
    if (p.marketValue <= 0) continue;
    double y = 0;
    try {
      final f = await ref.watch(fundamentalsProvider(p.holding.symbol).future);
      y = f.fundYield ?? f.dividendYield ?? 0;
    } catch (_) {
      y = 0;
    }
    items.add(IncomeItem(
      symbol: p.holding.symbol,
      value: p.marketValue,
      yieldFraction: y,
    ));
  }
  items.sort((a, b) => b.income.compareTo(a.income));
  return IncomeReport(items: items);
});
