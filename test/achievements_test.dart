import 'package:finance_companion/features/coach/domain/achievements.dart';
import 'package:finance_companion/features/transactions/domain/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

Transaction _pac(DateTime d) => Transaction(
      symbol: 'SWDA',
      name: 'SWDA',
      side: TxSide.buy,
      kind: TxKind.pac,
      date: d,
      quantity: 1,
      price: 100,
    );

void main() {
  group('Achievements.pacStreakMonths', () {
    test('conta i mesi consecutivi fino al più recente', () {
      final txs = [
        _pac(DateTime(2026, 6, 2)),
        _pac(DateTime(2026, 7, 2)),
        _pac(DateTime(2026, 8, 2)),
      ];
      expect(Achievements.pacStreakMonths(txs), 3);
    });

    test('un buco interrompe la serie (conta solo dal più recente)', () {
      final txs = [
        _pac(DateTime(2026, 1, 2)), // vecchio
        _pac(DateTime(2026, 7, 2)),
        _pac(DateTime(2026, 8, 2)), // più recenti: 2 di fila
      ];
      expect(Achievements.pacStreakMonths(txs), 2);
    });

    test('nessun PAC = 0', () {
      expect(Achievements.pacStreakMonths(const []), 0);
    });
  });

  test('compute sblocca i badge giusti', () {
    final txs = [
      for (var m = 3; m <= 8; m++) _pac(DateTime(2026, m, 2)), // 6 PAC, 6 mesi
    ];
    final list = Achievements.compute(
      transactions: txs,
      lessonsCompleted: 3,
      lessonsTotal: 9,
      hasRebalanceCadence: true,
    );
    bool un(String id) => list.firstWhere((a) => a.id == id).unlocked;
    expect(un('first-step'), isTrue);
    expect(un('constant'), isTrue); // >=3
    expect(un('disciplined'), isTrue); // >=6
    expect(un('veteran'), isFalse); // <12
    expect(un('not-quitter'), isTrue); // streak 6
    expect(un('student'), isTrue); // 3 lezioni
    expect(un('graduate'), isFalse); // 3<9
    expect(un('rebalancer'), isTrue);
  });
}
