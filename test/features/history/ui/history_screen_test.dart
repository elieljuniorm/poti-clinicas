import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/features/history/application/history_controller.dart';
import 'package:poti_5f/src/features/history/ui/pages/history_screen.dart';
import 'package:poti_5f/src/features/home/ui/widgets/financial_entry_card.dart';

import '../application/fake_history_repository.dart';

void main() {
  Future<void> abrir(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 5000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          historyRepositoryProvider.overrideWithValue(FakeHistoryRepository()),
        ],
        child: const MaterialApp(home: HistoryScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('abre em "Atendimentos" com data, status e profissional', (
    tester,
  ) async {
    await abrir(tester);

    expect(find.text('Histórico'), findsOneWidget);
    expect(find.text('Jorge Silva'), findsOneWidget);
    expect(find.text('Confirmada'), findsOneWidget);
    expect(find.text('Cancelada'), findsOneWidget);
    expect(find.text('Lucas Meireles'), findsNWidgets(2));
    expect(find.text('TOTAL A RECEBER'), findsNothing);
  });

  testWidgets('"Lançamentos": totais, recentes e "Ver Todos"', (tester) async {
    await abrir(tester);

    await tester.tap(find.text('Lançamentos'));
    await tester.pumpAndSettle();

    expect(find.text('TOTAL A RECEBER'), findsOneWidget);
    expect(find.text('R\$ 500,00'), findsOneWidget); // total
    expect(find.text('R\$ 300,00'), findsOneWidget); // recebido
    expect(find.text('R\$ 200,00'), findsOneWidget); // pendente
    expect(find.text('LANÇAMENTOS RECENTES'), findsOneWidget);
    expect(find.byType(FinancialEntryCard), findsNWidgets(3));
    expect(find.text('Jorge Silva'), findsNothing);

    await tester.tap(find.text('Ver Todos'));
    await tester.pumpAndSettle();
    expect(find.byType(FinancialEntryCard), findsNWidgets(5));
    expect(find.text('TODOS OS LANÇAMENTOS'), findsOneWidget);

    await tester.tap(find.text('Ver Menos'));
    await tester.pumpAndSettle();
    expect(find.byType(FinancialEntryCard), findsNWidgets(3));
  });
}
