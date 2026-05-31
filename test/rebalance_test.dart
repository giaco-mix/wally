import 'package:finance_companion/features/portfolio/domain/holding.dart';
import 'package:finance_companion/features/portfolio/domain/position.dart';
import 'package:finance_companion/features/market/domain/quote.dart';
import 'package:finance_companion/features/rebalance/domain/rebalance.dart';
import 'package:flutter_test/flutter_test.dart';

Position pos(String symbol, AssetClass ac, double qty, double price) {
  return Position(
    holding: Holding(
      id: symbol,
      symbol: symbol,
      name: symbol,
      quantity: qty,
      avgPrice: price,
      assetClass: ac,
    ),
    quote: Quote(symbol: symbol, price: price, previousClose: price),
  );
}

void main() {
  group('RebalancePlan.compute', () {
    test('calcola percentuali e delta verso il target', () {
      final positions = [
        pos('AAPL', AssetClass.stock, 10, 100), // 1000 (stock)
        pos('VWCE', AssetClass.etf, 10, 100), // 1000 (etf)
      ];
      final plan = RebalancePlan.compute(
        positions: positions,
        targets: {AssetClass.stock.name: 25, AssetClass.etf.name: 75},
      );

      expect(plan.total, 2000);

      final stock =
          plan.rows.firstWhere((r) => r.assetClass == AssetClass.stock);
      final etf = plan.rows.firstWhere((r) => r.assetClass == AssetClass.etf);

      expect(stock.currentPct, 50);
      expect(stock.targetPct, 25);
      // target 25% di 2000 = 500, attuale 1000 -> vendere 500
      expect(stock.delta, -500);
      expect(stock.isBuy, isFalse);

      expect(etf.targetPct, 75);
      // target 75% di 2000 = 1500, attuale 1000 -> comprare 500
      expect(etf.delta, 500);
      expect(etf.isBuy, isTrue);
    });

    test('portafoglio vuoto produce un piano vuoto', () {
      final plan = RebalancePlan.compute(positions: [], targets: {});
      expect(plan.isEmpty, isTrue);
    });
  });
}
