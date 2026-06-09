import 'package:finance_companion/features/dashboard/presentation/widgets/allocation_pie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('la legenda è cliccabile e passa la chiave (drill-down)', (
    tester,
  ) async {
    String? tapped;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: AllocationPie(
              title: 'Per asset class',
              data: const {'Azioni': 700, 'ETF': 300},
              total: 1000,
              onTap: (k) => tapped = k,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Azioni'), findsOneWidget);
    await tester.tap(find.text('Azioni'));
    await tester.pump();
    expect(tapped, 'Azioni');
  });

  testWidgets('senza onTap la legenda non è un bottone', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: AllocationPie(
              title: 'Per settore',
              data: {'Tech': 500, 'Energy': 500},
              total: 1000,
            ),
          ),
        ),
      ),
    );
    expect(find.byType(InkWell), findsNothing);
  });
}
