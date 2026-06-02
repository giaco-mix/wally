import 'dart:math' as math;

/// Punto annuale della proiezione del piano di accumulo.
class ProjectionPoint {
  const ProjectionPoint({
    required this.year,
    required this.contributed,
    required this.value,
  });

  final int year;
  final double contributed; // totale versato a quel punto
  final double value; // valore atteso (versato + rendimento)

  double get gain => value - contributed;
}

/// Matematica del piano di accumulo (PAC). Capitalizzazione mensile,
/// versamenti a fine mese (annualità ordinaria).
class PacCalculator {
  const PacCalculator._();

  /// Valore futuro di un PAC: versamento [monthly] per [years] anni a
  /// [annualReturn] (es. 0.05 = 5%).
  static double futureValue({
    required double monthly,
    required int years,
    required double annualReturn,
  }) {
    final n = years * 12;
    final r = annualReturn / 12;
    if (r == 0) return monthly * n;
    return monthly * ((math.pow(1 + r, n) - 1) / r);
  }

  /// Versamento mensile necessario per raggiungere [target] in [years] anni.
  static double requiredMonthly({
    required double target,
    required int years,
    required double annualReturn,
  }) {
    final n = years * 12;
    final r = annualReturn / 12;
    if (n == 0) return target;
    if (r == 0) return target / n;
    return target * r / (math.pow(1 + r, n) - 1);
  }

  /// Proiezione anno per anno (incluso l'anno 0).
  static List<ProjectionPoint> projection({
    required double monthly,
    required int years,
    required double annualReturn,
  }) {
    final r = annualReturn / 12;
    final points = <ProjectionPoint>[];
    for (var y = 0; y <= years; y++) {
      final n = y * 12;
      final contributed = monthly * n;
      final value = r == 0
          ? contributed
          : monthly * ((math.pow(1 + r, n) - 1) / r);
      points.add(ProjectionPoint(
        year: y,
        contributed: contributed,
        value: value.toDouble(),
      ));
    }
    return points;
  }
}
