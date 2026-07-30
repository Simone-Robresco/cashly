// Smoke test di base per la nuova home page (non più il contatore di
// default generato da Flutter).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cashly/main.dart';

void main() {
  testWidgets('La home si carica e mostra il pulsante +', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseTrackerApp());
    await tester.pumpAndSettle();

    // Il tasto per aggiungere una spesa deve essere presente.
    expect(find.byIcon(Icons.add), findsOneWidget);

    // Lo storico del mese deve essere visibile.
    expect(find.text('Storico del mese'), findsOneWidget);
  });
}
