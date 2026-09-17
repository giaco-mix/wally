import 'package:finance_companion/features/advisor/presentation/advisor_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('la home consulente elenca i clienti e apre il dettaglio', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: AdvisorHomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Marco R.'), findsOneWidget);
    expect(find.textContaining('clienti'), findsWidgets);

    await tester.tap(find.text('Marco R.'));
    await tester.pumpAndSettle();

    // Nel dettaglio (elementi in alto, sicuri nel tree): sola lettura + valore.
    expect(find.text('Sola lettura'), findsOneWidget);
    expect(find.text('Valore totale'), findsOneWidget);
  });
}
