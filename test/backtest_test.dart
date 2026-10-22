import 'package:finance_companion/features/lab/domain/backtest.dart';
import 'package:finance_companion/features/market/domain/price_point.dart';
import 'package:flutter_test/flutter_test.dart';

List<PricePoint> _series(List<double> closes) => [
      for (var i = 0; i < closes.length; i++)
        PricePoint(date: DateTime(2026, 1, 1).add(Duration(days: i)), close: closes[i]),
    ];

void main() {
  group('Backtest.run', () {
    test('un componente uguale al benchmark lo replica (corr 1)', () {
      final s = _series([100, 110, 121]);
      final r = Backtest.run(
        components: {'X': s},
        weights: {'X': 1},
        benchmark: _series([100, 110, 121]),
        periodsPerYear: 52,
      )!;
      expect(r.portfolioMetrics.totalReturnPct, closeTo(21, 1e-6));
      expect(r.benchmarkMetrics.totalReturnPct, closeTo(21, 1e-6));
      expect(r.correlation, closeTo(1, 1e-6));
      expect(r.portfolioMetrics.maxDrawdownPct, closeTo(0, 1e-9));
    });

    test('calcola il max drawdown', () {
      final r = Backtest.run(
        components: {'X': _series([100, 120, 60, 90])},
        weights: {'X': 1},
        benchmark: _series([100, 100, 100, 100]),
        periodsPerYear: 52,
      )!;
      // picco 120 -> minimo 60 = -50%
      expect(r.portfolioMetrics.maxDrawdownPct, closeTo(-50, 1e-6));
    });

    test('i pesi vengono normalizzati (0.5/0.5 == 1/1)', () {
      final a = _series([100, 110, 120]);
      final b = _series([100, 90, 80]);
      final bench = _series([100, 100, 100]);
      final r1 = Backtest.run(
          components: {'A': a, 'B': b},
          weights: {'A': 0.5, 'B': 0.5},
          benchmark: bench,
          periodsPerYear: 52)!;
      final r2 = Backtest.run(
          components: {'A': a, 'B': b},
          weights: {'A': 1, 'B': 1},
          benchmark: bench,
          periodsPerYear: 52)!;
      expect(r1.portfolioMetrics.totalReturnPct,
          closeTo(r2.portfolioMetrics.totalReturnPct, 1e-9));
      // 50/50 di +20% e -20% ≈ 0%
      expect(r1.portfolioMetrics.totalReturnPct, closeTo(0, 1e-6));
    });

    test('serie troppo corta o pesi nulli -> null', () {
      expect(
          Backtest.run(
              components: {'X': _series([100])},
              weights: {'X': 1},
              benchmark: _series([100]),
              periodsPerYear: 52),
          isNull);
      expect(
          Backtest.run(
              components: {'X': _series([100, 110, 120])},
              weights: {'X': 0},
              benchmark: _series([100, 110, 120]),
              periodsPerYear: 52),
          isNull);
    });
  });
}
