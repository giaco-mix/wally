import 'fundamentals.dart';

/// Valutazione qualitativa di un singolo fattore (0-100).
class HealthFactor {
  const HealthFactor({
    required this.label,
    required this.score,
    required this.detail,
  });

  final String label;
  final int score; // 0-100
  final String detail;
}

/// Punteggio sintetico di "salute fondamentale" (0-100), derivato da metriche
/// fondamentali. È un'euristica informativa, non un consiglio di investimento.
class HealthScore {
  const HealthScore({required this.overall, required this.factors});

  final int overall;
  final List<HealthFactor> factors;

  bool get hasData => factors.isNotEmpty;

  String get rating {
    if (overall >= 75) return 'Ottimo';
    if (overall >= 60) return 'Buono';
    if (overall >= 45) return 'Discreto';
    if (overall >= 30) return 'Debole';
    return 'Critico';
  }

  /// Interpola linearmente un valore su una scala a "scalini" (soglia → punti).
  /// `stops` ordinati per valore crescente. `higherIsBetter` inverte la scala.
  static int _scale(
    double value,
    List<(double, int)> stops, {
    bool higherIsBetter = true,
  }) {
    final v = value;
    if (v <= stops.first.$1) return higherIsBetter ? stops.first.$2 : stops.last.$2;
    if (v >= stops.last.$1) return higherIsBetter ? stops.last.$2 : stops.first.$2;
    for (var i = 0; i < stops.length - 1; i++) {
      final (x0, y0) = stops[i];
      final (x1, y1) = stops[i + 1];
      if (v >= x0 && v <= x1) {
        final t = (v - x0) / (x1 - x0);
        final score = y0 + (y1 - y0) * t;
        return score.round().clamp(0, 100);
      }
    }
    return 50;
  }

  factory HealthScore.from(Fundamentals f) {
    final factors = <HealthFactor>[];
    final weighted = <(int score, double weight)>[];

    // Valutazione (P/E): più basso è meglio (entro limiti ragionevoli).
    if (f.trailingPe != null && f.trailingPe! > 0) {
      final s = _scale(
        f.trailingPe!,
        [(8, 100), (15, 80), (25, 60), (35, 40), (50, 20)],
        higherIsBetter: false,
      );
      factors.add(HealthFactor(
        label: 'Valutazione (P/E)',
        score: s,
        detail: 'P/E ${f.trailingPe!.toStringAsFixed(1)} — '
            '${s >= 60 ? 'prezzo ragionevole' : 'valutazione elevata'}',
      ));
      weighted.add((s, 0.25));
    }

    // Redditività (ROE + margine netto).
    final profScores = <int>[];
    if (f.returnOnEquity != null) {
      profScores.add(_scale(
        f.returnOnEquity!,
        [(0, 10), (0.05, 45), (0.10, 65), (0.15, 85), (0.20, 100)],
      ));
    }
    if (f.profitMargins != null) {
      profScores.add(_scale(
        f.profitMargins!,
        [(0, 10), (0.05, 50), (0.10, 70), (0.20, 90), (0.30, 100)],
      ));
    }
    if (profScores.isNotEmpty) {
      final s = (profScores.reduce((a, b) => a + b) / profScores.length).round();
      factors.add(HealthFactor(
        label: 'Redditività',
        score: s,
        detail: [
          if (f.returnOnEquity != null)
            'ROE ${(f.returnOnEquity! * 100).toStringAsFixed(1)}%',
          if (f.profitMargins != null)
            'margine ${(f.profitMargins! * 100).toStringAsFixed(1)}%',
        ].join(' · '),
      ));
      weighted.add((s, 0.30));
    }

    // Solidità finanziaria (debito/equity + current ratio).
    final healthScores = <int>[];
    if (f.debtToEquity != null) {
      // Yahoo a volte esprime D/E in percentuale (es. 140 = 1.4x).
      final de = f.debtToEquity! > 10 ? f.debtToEquity! / 100 : f.debtToEquity!;
      healthScores.add(_scale(
        de,
        [(0.3, 100), (0.5, 85), (1.0, 65), (2.0, 40), (3.0, 15)],
        higherIsBetter: false,
      ));
    }
    if (f.currentRatio != null) {
      healthScores.add(_scale(
        f.currentRatio!,
        [(0.5, 20), (1.0, 55), (1.5, 80), (2.0, 100)],
      ));
    }
    if (healthScores.isNotEmpty) {
      final s =
          (healthScores.reduce((a, b) => a + b) / healthScores.length).round();
      factors.add(HealthFactor(
        label: 'Solidità finanziaria',
        score: s,
        detail: [
          if (f.debtToEquity != null) 'D/E ${f.debtToEquity!.toStringAsFixed(2)}',
          if (f.currentRatio != null)
            'current ratio ${f.currentRatio!.toStringAsFixed(2)}',
        ].join(' · '),
      ));
      weighted.add((s, 0.25));
    }

    // Crescita (ricavi).
    if (f.revenueGrowth != null) {
      final s = _scale(
        f.revenueGrowth!,
        [(-0.10, 15), (0, 40), (0.05, 60), (0.10, 80), (0.20, 100)],
      );
      factors.add(HealthFactor(
        label: 'Crescita',
        score: s,
        detail: 'ricavi ${(f.revenueGrowth! * 100).toStringAsFixed(1)}% a/a',
      ));
      weighted.add((s, 0.20));
    }

    if (weighted.isEmpty) {
      return const HealthScore(overall: 0, factors: []);
    }
    final totalWeight = weighted.fold<double>(0, (a, w) => a + w.$2);
    final overall =
        (weighted.fold<double>(0, (a, w) => a + w.$1 * w.$2) / totalWeight)
            .round();

    return HealthScore(overall: overall, factors: factors);
  }
}
