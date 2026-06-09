import 'package:finance_companion/shared/widgets/sparkline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Sparkline si disegna senza errori con >=2 valori', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Sparkline(values: [1, 2, 3, 2, 4, 3.5], color: Colors.green),
        ),
      ),
    );
    expect(find.byType(Sparkline), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('con meno di 2 valori non lancia eccezioni', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Sparkline(values: [42], color: Colors.red)),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
