import 'package:finance_companion/features/plan/presentation/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Avanti è sempre visibile; guida se manca la scelta, poi avanza', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: OnboardingScreen()),
      ),
    );

    // Step 0: il pulsante Avanti c'è.
    expect(find.widgetWithText(FilledButton, 'Avanti'), findsOneWidget);
    expect(find.text('Qual è il tuo obiettivo?'), findsOneWidget);

    // Tap senza scegliere un obiettivo -> messaggio guida, resta sullo step 0.
    await tester.tap(find.widgetWithText(FilledButton, 'Avanti'));
    await tester.pump();
    expect(find.text('Scegli un obiettivo per continuare.'), findsOneWidget);
    expect(find.text('Qual è il tuo obiettivo?'), findsOneWidget);

    // Scelgo un obiettivo (prima card) e avanzo.
    await tester.tap(find.byType(ListTile).first);
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Avanti'));
    await tester.pumpAndSettle();

    // Ora sono sullo step del profilo di rischio.
    expect(find.text('Che tipo di investitore sei?'), findsOneWidget);
  });
}
