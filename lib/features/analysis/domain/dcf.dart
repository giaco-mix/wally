import 'dart:math' as math;

/// Parametri per la stima del valore intrinseco con i flussi di cassa
/// attualizzati (DCF). Sono **assunzioni**: cambiando i tassi cambia il risultato.
class DcfInputs {
  const DcfInputs({
    required this.freeCashflow,
    required this.growthRate,
    required this.discountRate,
    required this.terminalGrowth,
    required this.years,
    required this.sharesOutstanding,
    this.netDebt = 0,
  });

  final double freeCashflow; // FCF di partenza (annuo)
  final double growthRate; // crescita FCF nei primi anni (0..1)
  final double discountRate; // tasso di sconto / rendimento richiesto (0..1)
  final double terminalGrowth; // crescita perpetua finale (0..1)
  final int years; // anni di proiezione esplicita
  final double sharesOutstanding;
  final double netDebt; // debiti - cassa (può essere negativo)
}

class DcfResult {
  const DcfResult({required this.intrinsicPerShare, required this.equityValue});

  final double intrinsicPerShare;
  final double equityValue;

  /// Prezzo d'acquisto lasciando un margine di sicurezza (in %).
  double priceWithMargin(double marginPercent) =>
      intrinsicPerShare * (1 - marginPercent / 100);
}

class Dcf {
  const Dcf._();

  /// Valido solo se `discountRate > terminalGrowth` (altrimenti il valore
  /// terminale esplode) e ci sono flussi/azioni positivi.
  static bool isValid(DcfInputs i) =>
      i.freeCashflow > 0 &&
      i.sharesOutstanding > 0 &&
      i.discountRate > i.terminalGrowth;

  static DcfResult compute(DcfInputs i) {
    var pvSum = 0.0;
    var fcf = i.freeCashflow;
    for (var t = 1; t <= i.years; t++) {
      fcf = fcf * (1 + i.growthRate);
      pvSum += fcf / math.pow(1 + i.discountRate, t);
    }
    // Valore terminale (Gordon) sull'ultimo flusso proiettato.
    final tv =
        (fcf * (1 + i.terminalGrowth)) / (i.discountRate - i.terminalGrowth);
    final pvTv = tv / math.pow(1 + i.discountRate, i.years);
    final enterprise = pvSum + pvTv;
    final equity = enterprise - i.netDebt;
    final perShare =
        i.sharesOutstanding > 0 ? equity / i.sharesOutstanding : 0.0;
    return DcfResult(intrinsicPerShare: perShare, equityValue: equity);
  }
}
