import 'package:finance_companion/features/portfolio/domain/holding.dart';
import 'package:finance_companion/features/transactions/domain/lot_performance.dart';
import 'package:finance_companion/features/transactions/domain/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

Transaction _buy(String sym, DateTime d, double qty, double price,
        {TxKind kind = TxKind.pac}) =>
    Transaction(
      symbol: sym,
      name: sym,
      side: TxSide.buy,
      kind: kind,
      date: d,
      quantity: qty,
      price: price,
    );

void main() {
  group('LotEngine.forSymbol', () {
    test('rendimento per lotto e aggregato money-weighted', () {
      final txs = [
        _buy('SWDA', DateTime(2026, 1, 2), 1, 100),
        _buy('SWDA', DateTime(2026, 2, 2), 1, 120),
      ];
      final perf = LotEngine.forSymbol('SWDA', 'iShares World', txs, 150);

      expect(perf.lots.length, 2);
      // Lotto 1: 100 -> 150 = +50%
      expect(perf.lots[0].gainPercent, closeTo(50, 1e-9));
      // Lotto 2: 120 -> 150 = +25%
      expect(perf.lots[1].gainPercent, closeTo(25, 1e-9));

      // Investito 220, valore 2×150=300, gain 80 -> +36,36%
      expect(perf.invested, 220);
      expect(perf.currentValue, 300);
      expect(perf.gain, 80);
      expect(perf.gainPercent, closeTo(80 / 220 * 100, 1e-9));
      expect(perf.avgPrice, 110);
    });

    test('le vendite consumano i lotti in FIFO', () {
      final txs = [
        _buy('AAA', DateTime(2026, 1, 1), 2, 100),
        _buy('AAA', DateTime(2026, 2, 1), 2, 200),
        Transaction(
          symbol: 'AAA',
          name: 'AAA',
          side: TxSide.sell,
          kind: TxKind.manual,
          date: DateTime(2026, 3, 1),
          quantity: 3, // vende 3: consuma i 2 del primo lotto + 1 del secondo
          price: 250,
        ),
      ];
      final perf = LotEngine.forSymbol('AAA', 'AAA', txs, 300);

      // Resta 1 quota del secondo lotto (prezzo 200).
      expect(perf.quantity, 1);
      expect(perf.lots.length, 1);
      expect(perf.lots.first.lot.price, 200);
      expect(perf.invested, 200);
      expect(perf.currentValue, 300);
    });

    test('senza prezzo corrente i rendimenti sono null (ma investito no)', () {
      final txs = [_buy('X', DateTime(2026, 1, 1), 1, 100)];
      final perf = LotEngine.forSymbol('X', 'X', txs, null);
      expect(perf.invested, 100);
      expect(perf.currentValue, isNull);
      expect(perf.gainPercent, isNull);
      expect(perf.lots.single.gainPercent, isNull);
    });
  });

  test('i dividendi entrano nel rendimento totale ma non nelle quote', () {
    final txs = [
      _buy('VHYL', DateTime(2026, 1, 1), 10, 10), // investito 100
      Transaction(
        symbol: 'VHYL',
        name: 'VHYL',
        side: TxSide.buy, // ignorato per i dividendi
        kind: TxKind.dividend,
        date: DateTime(2026, 6, 1),
        quantity: 1,
        price: 5, // 5€ di dividendo incassato
      ),
    ];
    final perf = LotEngine.forSymbol('VHYL', 'Vanguard High Yield', txs, 11);

    // Le quote restano 10 (il dividendo non aggiunge quote).
    expect(perf.quantity, 10);
    expect(perf.invested, 100);
    expect(perf.dividendsReceived, 5);
    // Solo prezzo: 110 vs 100 = +10%
    expect(perf.gainPercent, closeTo(10, 1e-9));
    // Totale: (110 - 100 + 5)/100 = +15%
    expect(perf.totalReturnPercent, closeTo(15, 1e-9));
  });

  test('il dividendo reinvestito aggiunge quote (a differenza di quello cassa)', () {
    final txs = [
      _buy('SWDA', DateTime(2026, 1, 1), 10, 10), // 100
      Transaction(
        symbol: 'SWDA',
        name: 'SWDA',
        side: TxSide.buy,
        kind: TxKind.dividendReinvest,
        date: DateTime(2026, 6, 1),
        quantity: 1,
        price: 12, // reinveste 12€ comprando 1 quota
      ),
    ];
    final perf = LotEngine.forSymbol('SWDA', 'SWDA', txs, 15);
    expect(perf.quantity, 11); // 10 + 1 (il reinvestito aggiunge quote)
    expect(perf.invested, 112);
    expect(perf.reinvestedInvested, 12);
    expect(perf.dividendsReceived, 0); // non è cassa
  });

  group('LotEngine.forPortfolio', () {
    test('raggruppa per simbolo ed esclude i simboli senza lotti aperti', () {
      final txs = [
        _buy('SWDA', DateTime(2026, 1, 1), 1, 100),
        _buy('AGGH', DateTime(2026, 1, 1), 1, 50),
        Transaction(
          symbol: 'AGGH',
          name: 'AGGH',
          side: TxSide.sell,
          kind: TxKind.manual,
          date: DateTime(2026, 2, 1),
          quantity: 1,
          price: 55,
        ),
      ];
      final out = LotEngine.forPortfolio(txs, {'SWDA': 120});
      // AGGH è stato venduto del tutto -> escluso.
      expect(out.map((s) => s.symbol), ['SWDA']);
      expect(out.single.gainPercent, closeTo(20, 1e-9));
    });
  });

  test('AssetClass usata dal ledger resta valida', () {
    // guardia: il default TxKind è pac
    expect(AssetClass.etf.label, 'ETF');
  });
}
