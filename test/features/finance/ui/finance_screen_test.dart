import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:multiclinica_app/src/core/ui/widgets/app_area_chart.dart';
import 'package:multiclinica_app/src/features/finance/application/finance_controller.dart';
import 'package:multiclinica_app/src/features/finance/domain/models/pre_invoice_model.dart';
import 'package:multiclinica_app/src/features/finance/ui/pages/finance_screen.dart';
import 'package:multiclinica_app/src/features/finance/ui/widgets/pre_invoice_card.dart';
import 'package:multiclinica_app/src/features/finance/ui/widgets/professional_payout_card.dart';

import '../application/fake_finance_repository.dart';

void main() {
  final preFaturas = [
    PreInvoiceModel(
      id: '7',
      patientId: '2',
      patientName: 'Juliana Mendes Souza',
      professionalId: '1',
      professionalName: 'Arnaldo Ribeiro',
      sessions: 3,
      createdAt: DateTime(2026, 7, 14),
    ),
    PreInvoiceModel(
      id: '8',
      patientId: '8',
      patientName: 'Lucas Freitas',
      professionalId: '3',
      professionalName: 'Beatriz Nogueira',
      sessions: 1,
      createdAt: DateTime(2026, 7, 15),
    ),
  ];

  Future<void> abrir(
    WidgetTester tester, {
    List<PreInvoiceModel> preFaturas = const [],
  }) async {
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
            GoRoute(
              path: 'pre-fatura/:preInvoiceId',
              name: 'financeiro-pre-fatura',
              builder: (context, state) =>
                  Text('PRÉ-FATURA ${state.pathParameters['preInvoiceId']}'),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          financeRepositoryProvider.overrideWithValue(
            FakeFinanceRepository(preFaturas: preFaturas),
          ),
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

  testWidgets('pré-faturas abaixo dos profissionais: paciente, '
      'profissional e sessões', (tester) async {
    await abrir(tester, preFaturas: preFaturas);

    expect(find.text('PRÉ-FATURAS'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('PRÉ-FATURAS')).dy,
      greaterThan(tester.getTopLeft(find.text('PROFISSIONAIS')).dy),
    );
    expect(find.byType(PreInvoiceCard), findsNWidgets(2));
    expect(find.text('Juliana Mendes Souza'), findsOneWidget);
    expect(find.text('Arnaldo Ribeiro'), findsOneWidget);
    expect(find.text('3 sessões'), findsOneWidget);
    expect(find.text('1 sessão'), findsOneWidget);
  });

  testWidgets('tocar na pré-fatura abre a finalização dela', (tester) async {
    await abrir(tester, preFaturas: preFaturas);

    await tester.tap(find.text('Lucas Freitas'));
    await tester.pumpAndSettle();

    expect(find.text('PRÉ-FATURA 8'), findsOneWidget);
  });

  testWidgets('sem pré-faturas mostra o aviso', (tester) async {
    await abrir(tester);

    expect(find.text('Nenhuma pré-fatura pendente'), findsOneWidget);
    expect(find.byType(PreInvoiceCard), findsNothing);
  });
}
