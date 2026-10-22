import 'dart:math' as math;

import '../../market/domain/price_point.dart';

/// Un punto della curva di backtest, normalizzato a 100 all'inizio.
class SeriesPoint {
  const SeriesPoint(this.date, this.value);
  final DateTime date;
  final double value;
}

/// Metriche di un portafoglio/benchmark su un periodo storico.
class BacktestMetrics {
  const BacktestMetrics({
    required this.totalReturnPct,
    required this.annualReturnPct,
    required this.volatilityPct,
    required this.maxDrawdownPct,
    required this.sharpe,
  });

  final double totalReturnPct;
  final double annualReturnPct;
  final double volatilityPct; // annualizzata
  final double maxDrawdownPct; // negativo
  final double sharpe; // risk-free = 0
}

class BacktestResult {
  const BacktestResult({
    required this.portfolio,
    required this.benchmark,
    required this.portfolioMetrics,
    required this.benchmarkMetrics,
    required this.correlation,
  });

  final List<SeriesPoint> portfolio;
  final List<SeriesPoint> benchmark;
  final BacktestMetrics portfolioMetrics;
  final BacktestMetrics benchmarkMetrics;
  final double correlation; // dei rendimenti vs benchmark (-1..1)
}

/// Backtest semplificato **buy-and-hold a pesi fissi** di un portafoglio contro
/// un benchmark, allineando le serie sulle date in comune. Educativo: niente
/// ribilanciamento, commissioni o dividendi.
class Backtest {
  const Backtest._();

  static BacktestResult? run({
    required Map<String, List<PricePoint>> components, // symbol -> storico
    required Map<String, double> weights, // symbol -> peso (verrà normalizzato)
    required List<PricePoint> benchmark,
    required double periodsPerYear,
  }) {
    if (components.isEmpty || benchmark.length < 3) return null;

    // Normalizza i pesi a somma 1.
    final totW = weights.values.fold<double>(0, (a, b) => a + b);
    if (totW <= 0) return null;
    final w = {for (final e in weights.entries) e.key: e.value / totW};

    // Mappa date->close per ogni serie (incluso il benchmark).
    Map<DateTime, double> byDate(List<PricePoint> pts) =>
        {for (final p in pts) DateTime(p.date.year, p.date.month, p.date.day): p.close};
    final compMaps = {
      for (final e in components.entries) e.key: byDate(e.value),
    };
    final benchMap = byDate(benchmark);

    // Date in comune a TUTTE le serie.
    Set<DateTime>? common;
    for (final m in [...compMaps.values, benchMap]) {
      common = common == null ? m.keys.toSet() : common.intersection(m.keys.toSet());
    }
    final dates = (common ?? <DateTime>{}).toList()..sort();
    if (dates.length < 3) return null;

    final d0 = dates.first;
    // Prezzi iniziali (base) per ogni componente e benchmark.
    final base = {for (final e in compMaps.entries) e.key: e.value[d0]!};
    final benchBase = benchMap[d0]!;
    if (benchBase == 0 || base.values.any((v) => v == 0)) return null;

    final port = <SeriesPoint>[];
    final bench = <SeriesPoint>[];
    for (final d in dates) {
      var ratio = 0.0;
      for (final e in w.entries) {
        ratio += e.value * (compMaps[e.key]![d]! / base[e.key]!);
      }
      port.add(SeriesPoint(d, ratio * 100));
      bench.add(SeriesPoint(d, benchMap[d]! / benchBase * 100));
    }

    final pr = _returns(port);
    final br = _returns(bench);
    return BacktestResult(
      portfolio: port,
      benchmark: bench,
      portfolioMetrics: _metrics(port, pr, periodsPerYear),
      benchmarkMetrics: _metrics(bench, br, periodsPerYear),
      correlation: _corr(pr, br),
    );
  }

  static List<double> _returns(List<SeriesPoint> s) {
    final r = <double>[];
    for (var i = 1; i < s.length; i++) {
      final prev = s[i - 1].value;
      r.add(prev == 0 ? 0 : s[i].value / prev - 1);
    }
    return r;
  }

  static BacktestMetrics _metrics(
      List<SeriesPoint> s, List<double> r, double ppy) {
    final total = s.first.value == 0 ? 0.0 : s.last.value / s.first.value - 1;
    final n = s.length - 1;
    final cagr = n <= 0 ? 0.0 : math.pow(s.last.value / s.first.value, ppy / n) - 1;
    // Volatilità annualizzata.
    final mean = r.isEmpty ? 0.0 : r.reduce((a, b) => a + b) / r.length;
    final variance = r.length < 2
        ? 0.0
        : r.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) /
            (r.length - 1);
    final vol = math.sqrt(variance) * math.sqrt(ppy);
    // Max drawdown.
    var peak = s.first.value;
    var maxDd = 0.0;
    for (final p in s) {
      if (p.value > peak) peak = p.value;
      final dd = peak == 0 ? 0.0 : p.value / peak - 1;
      if (dd < maxDd) maxDd = dd;
    }
    final sharpe = vol == 0 ? 0.0 : (cagr as double) / vol;
    return BacktestMetrics(
      totalReturnPct: total * 100,
      annualReturnPct: (cagr as double) * 100,
      volatilityPct: vol * 100,
      maxDrawdownPct: maxDd * 100,
      sharpe: sharpe,
    );
  }

  static double _corr(List<double> a, List<double> b) {
    final n = math.min(a.length, b.length);
    if (n < 2) return 0;
    final x = a.sublist(0, n), y = b.sublist(0, n);
    final mx = x.reduce((p, q) => p + q) / n;
    final my = y.reduce((p, q) => p + q) / n;
    var cov = 0.0, vx = 0.0, vy = 0.0;
    for (var i = 0; i < n; i++) {
      cov += (x[i] - mx) * (y[i] - my);
      vx += (x[i] - mx) * (x[i] - mx);
      vy += (y[i] - my) * (y[i] - my);
    }
    final den = math.sqrt(vx * vy);
    return den == 0 ? 0 : cov / den;
  }
}
