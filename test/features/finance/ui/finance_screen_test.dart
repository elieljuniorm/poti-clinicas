import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:poti_5f/src/core/ui/widgets/app_area_chart.dart';
import 'package:poti_5f/src/features/finance/application/finance_controller.dart';
import 'package:poti_5f/src/features/finance/ui/pages/finance_screen.dart';
import 'package:poti_5f/src/features/finance/ui/widgets/professional_payout_card.dart';

import '../application/fake_finance_repository.dart';

void main() {
  Future<void> abrir(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 5000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: '/financeiro',
      routes: [
        GoRoute(
          path: '/financeiro',
          name: 'financeiro',
          builder: (context, state) => const FinanceScreen(),
          routes: [
            GoRoute(
              path: 'novo',
              name: 'financeiro-novo',
              builder: (context, state) => const Text('NOVO LANÇAMENTO'),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          financeRepositoryProvider.overrideWithValue(FakeFinanceRepository()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('mostra card de ação, faturamento, gráfico e profissionais', (
    tester,
  ) async {
    await abrir(tester);

    expect(find.text('Financeiro'), findsOneWidget);
    expect(find.text('Novo Lançamento'), findsOneWidget);
    expect(find.text('FATURAMENTO DO MÊS'), findsOneWidget);
    expect(find.text('R\$ 1.500,00'), findsOneWidget); // total
    expect(find.text('R\$ 1.000,00'), findsWidgets); // recebido e a pagar
    expect(find.byType(AppAreaChart), findsOneWidget);
    expect(find.text('PROFISSIONAIS'), findsOneWidget);
    expect(find.byType(ProfessionalPayoutCard), findsNWidgets(3));
    // Sem foto: iniciais.
    expect(find.text('P1'), findsOneWidget);
    expect(find.text('Fisioterapeuta - 1 atendimento'), findsOneWidget);
    expect(find.text('Fisioterapeuta - 2 atendimentos'), findsOneWidget);
  });

  testWidgets('"Ver Todos" mostra todos os profissionais e volta', (
    tester,
  ) async {
    await abrir(tester);

    await tester.tap(find.text('Ver Todos'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfessionalPayoutCard), findsNWidgets(5));

    await tester.tap(find.text('Ver Menos'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfessionalPayoutCard), findsNWidgets(3));
  });

  testWidgets('"Novo Lançamento" abre a tela de lançamento', (tester) async {
    await abrir(tester);

    await tester.tap(find.text('Novo Lançamento'));
    await tester.pumpAndSettle();

    expect(find.text('NOVO LANÇAMENTO'), findsOneWidget);
  });
}
