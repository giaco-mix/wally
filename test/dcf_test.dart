import 'package:finance_companion/features/analysis/domain/dcf.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Dcf', () {
    test('valore intrinseco positivo e coerente per input ragionevoli', () {
      const i = DcfInputs(
        freeCashflow: 100,
        growthRate: 0.05,
        discountRate: 0.09,
        terminalGrowth: 0.025,
        years: 10,
        sharesOutstanding: 100,
        netDebt: 0,
      );
      expect(Dcf.isValid(i), isTrue);
      final r = Dcf.compute(i);
      expect(r.equityValue, greaterThan(0));
      expect(r.intrinsicPerShare, closeTo(r.equityValue / 100, 1e-9));
      // Margine di sicurezza 30% => prezzo = 70% del valore.
      expect(r.priceWithMargin(30),
          closeTo(r.intrinsicPerShare * 0.7, 1e-9));
    });

    test('più sconto = valore più basso; più crescita = valore più alto', () {
      DcfResult run(double g, double r) => Dcf.compute(DcfInputs(
            freeCashflow: 100,
            growthRate: g,
            discountRate: r,
            terminalGrowth: 0.025,
            years: 10,
            sharesOutstanding: 100,
          ));
      expect(run(0.05, 0.12).intrinsicPerShare,
          lessThan(run(0.05, 0.08).intrinsicPerShare));
      expect(run(0.02, 0.09).intrinsicPerShare,
          lessThan(run(0.08, 0.09).intrinsicPerShare));
    });

    test('non valido se sconto <= crescita perpetua o flussi non positivi', () {
      expect(
          Dcf.isValid(const DcfInputs(
              freeCashflow: 100,
              growthRate: 0.05,
              discountRate: 0.02,
              terminalGrowth: 0.025,
              years: 10,
              sharesOutstanding: 100)),
          isFalse);
      expect(
          Dcf.isValid(const DcfInputs(
              freeCashflow: -5,
              growthRate: 0.05,
              discountRate: 0.09,
              terminalGrowth: 0.025,
              years: 10,
              sharesOutstanding: 100)),
          isFalse);
    });
  });
}
