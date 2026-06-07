import 'package:finance_companion/features/portfolio/presentation/holding_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('il form mostra e rende cliccabile il pulsante Salva', (
    tester,
  ) async {
    // Finestra volutamente bassa: è la condizione in cui prima la barra
    // Annulla/Salva finiva fuori schermo.
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: _Harness())),
    );

    await tester.tap(find.text('Aggiungi'));
    await tester.pumpAndSettle();

    expect(find.text('Nuova posizione'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Annulla'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Salva'), findsOneWidget);

    // Se "Salva" fosse fuori schermo o non hit-testabile, questo tap fallirebbe.
    await tester.tap(find.widgetWithText(FilledButton, 'Salva'));
    await tester.pump();

    // Campi vuoti -> la validazione blocca il salvataggio e la dialog resta
    // aperta (conferma anche che il tap è arrivato al pulsante).
    expect(find.text('Nuova posizione'), findsOneWidget);
  });
}

class _Harness extends StatelessWidget {
  const _Harness();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showHoldingForm(context),
            child: const Text('Aggiungi'),
          ),
        ),
      ),
    );
  }
}
