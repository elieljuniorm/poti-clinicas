import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:poti_5f/src/features/finance/application/finance_controller.dart';
import 'package:poti_5f/src/features/finance/domain/models/new_invoice_model.dart';
import 'package:poti_5f/src/features/finance/domain/models/pre_invoice_model.dart';
import 'package:poti_5f/src/features/finance/ui/pages/new_invoice_screen.dart';
import 'package:poti_5f/src/features/users/application/users_controller.dart';

import '../../users/application/fake_users_repository.dart';
import '../application/fake_finance_repository.dart';

void main() {
  late FakeFinanceRepository financeiro;

  final preFatura = PreInvoiceModel(
    id: '7',
    patientId: '9',
    patientName: 'Juliana Mendes Souza',
    professionalId: '1',
    professionalName: 'Arnaldo Ribeiro',
    sessions: 3,
    createdAt: DateTime(2026, 7, 15),
  );

  Future<void> abrir(
    WidgetTester tester, {
    String inicio = '/financeiro/novo',
    Map<String, int> creditos = const {},
  }) async {
    // Tela alta: tudo cabe sem rolar.
    tester.view.physicalSize = const Size(1000, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    financeiro = FakeFinanceRepository(
      preFaturas: [preFatura],
      creditos: {...creditos},
    );
    final router = GoRouter(
      initialLocation: inicio,
      routes: [
        GoRoute(
          path: '/financeiro',
          name: 'financeiro',
          builder: (context, state) => const Scaffold(body: Text('FINANCEIRO')),
          routes: [
            GoRoute(
              path: 'novo',
              name: 'financeiro-novo',
              builder: (context, state) => const NewInvoiceScreen(),
            ),
            GoRoute(
              path: 'pre-fatura/:preInvoiceId',
              name: 'financeiro-pre-fatura',
              builder: (context, state) => NewInvoiceScreen(
                preInvoiceId: state.pathParameters['preInvoiceId'],
              ),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          usersRepositoryProvider.overrideWithValue(FakeUsersRepository()),
          financeRepositoryProvider.overrideWithValue(financeiro),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder campo(String rotulo) => find.descendant(
    of: find
        .ancestor(of: find.text(rotulo), matching: find.byType(Column))
        .first,
    matching: find.byType(TextFormField),
  );

  Future<void> escolher(
    WidgetTester tester,
    String rotulo,
    String opcao,
  ) async {
    final bloco = find
        .ancestor(of: find.text(rotulo), matching: find.byType(Column))
        .first;
    await tester.tap(
      find.descendant(of: bloco, matching: find.byType(InkWell)).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(opcao).last);
    await tester.pumpAndSettle();
  }

  /// Um toque por frame, como na tela real.
  Future<void> aumentar(WidgetTester tester, int vezes) async {
    for (var i = 0; i < vezes; i++) {
      await tester.tap(find.byTooltip('Aumentar'));
      await tester.pump();
    }
  }

  Future<void> lancar(WidgetTester tester) async {
    await tester.tap(find.textContaining('FATURA').last);
    await tester.pumpAndSettle();
  }

  group('Novo Lançamento (sem atendimento)', () {
    testWidgets('salvar vazio mostra o que falta', (tester) async {
      await abrir(tester);

      await lancar(tester);

      expect(find.text('Selecione um paciente'), findsOneWidget);
      expect(find.text('Selecione o tipo de atendimento'), findsOneWidget);
      expect(find.text('Informe o valor'), findsOneWidget);
      // Profissional e pagamento.
      expect(find.text('Selecione uma opção'), findsNWidgets(2));
      expect(financeiro.lancadas, isEmpty);
    });

    testWidgets('máscara de moeda e total = valor × sessões', (tester) async {
      await abrir(tester);

      await tester.enterText(campo('VALOR SESSÃO (R\$)'), '15000');
      await tester.pump();
      expect(find.text('R\$ 150,00'), findsNWidgets(2)); // valor e total

      await aumentar(tester, 2);
      await tester.pump();
      expect(find.text('R\$ 450,00'), findsOneWidget);
    });

    testWidgets('lança a fatura e o paciente ganha os créditos', (
      tester,
    ) async {
      await abrir(tester);

      await tester.enterText(find.byType(TextField).first, 'anto');
      await tester.pump();
      await tester.tap(find.text('Antônio Araújo'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Sem atendimento agendado: as sessões viram créditos de '
          'agendamento do paciente.',
        ),
        findsOneWidget,
      );

      await escolher(tester, 'PROFISSIONAL', 'Arnaldo Ribeiro');
      await tester.tap(find.text('Pacote Domiciliar'));
      await aumentar(tester, 2);
      await tester.enterText(campo('VALOR SESSÃO (R\$)'), '18000');
      await escolher(tester, 'PAGAMENTO', 'Pix');
      await tester.enterText(campo('PERCENTUAL'), '40');
      await tester.enterText(campo('OBSERVAÇÕES'), 'Pago à vista');
      await lancar(tester);

      final fatura = financeiro.lancadas.single;
      expect(fatura.preInvoiceId, isNull);
      expect(fatura.patientId, '2');
      expect(fatura.patientName, 'Antônio Araújo');
      expect(fatura.professionalName, 'Arnaldo Ribeiro');
      expect(fatura.type, InvoiceType.homePackage);
      expect(fatura.sessions, 3);
      expect(fatura.sessionValue, 180);
      expect(fatura.total, 540);
      expect(fatura.paymentMethod, PaymentMethod.pix);
      expect(fatura.percentage, 40);
      expect(fatura.notes, 'Pago à vista');

      expect(find.text('FINANCEIRO'), findsOneWidget);
      expect(
        find.text(
          'Fatura de Antônio Araújo lançada. '
          '3 créditos de agendamento gerados',
        ),
        findsOneWidget,
      );
    });

    testWidgets('percentual acima de 100 é recusado', (tester) async {
      await abrir(tester);

      await tester.enterText(campo('PERCENTUAL'), '150');
      await lancar(tester);

      expect(find.text('Máximo 100%'), findsOneWidget);
    });

    testWidgets('mostra os créditos que o paciente já tem', (tester) async {
      await abrir(tester, creditos: {'2': 2});

      await tester.enterText(find.byType(TextField).first, 'anto');
      await tester.pump();
      await tester.tap(find.text('Antônio Araújo'));
      await tester.pumpAndSettle();

      expect(
        find.text('O paciente já tem 2 créditos de agendamento para usar.'),
        findsOneWidget,
      );
    });
  });

  group('Finalizar pré-fatura', () {
    testWidgets('vem preenchida com paciente, profissional e sessões', (
      tester,
    ) async {
      await abrir(tester, inicio: '/financeiro/pre-fatura/7');

      expect(find.text('Finalizar Pré-fatura'), findsOneWidget);
      expect(find.text('Juliana Mendes Souza'), findsOneWidget);
      expect(find.text('Arnaldo Ribeiro'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      // Paciente travado: sem busca.
      expect(find.text('Buscar paciente por nome'), findsNothing);
      expect(
        find.text(
          '3 sessões agendadas. Aumente para gerar créditos de '
          'agendamento.',
        ),
        findsOneWidget,
      );

      // Não dá para faturar menos do que o agendado.
      await tester.tap(find.byTooltip('Diminuir'));
      await tester.pump();
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('sessões a mais viram créditos; a pré-fatura é finalizada', (
      tester,
    ) async {
      await abrir(tester, inicio: '/financeiro/pre-fatura/7');

      await tester.tap(find.text('Pacote Clínica'));
      await tester.tap(find.byTooltip('Aumentar'));
      await tester.pump();
      expect(
        find.text('3 sessões agendadas + 1 crédito de agendamento.'),
        findsOneWidget,
      );
      await tester.enterText(campo('VALOR SESSÃO (R\$)'), '10000');
      await escolher(tester, 'PAGAMENTO', 'Boleto');
      await lancar(tester);

      final fatura = financeiro.lancadas.single;
      expect(fatura.preInvoiceId, '7');
      expect(fatura.patientId, '9');
      expect(fatura.professionalId, '1');
      expect(fatura.sessions, 4);
      expect(fatura.total, 400);
      expect(fatura.paymentMethod, PaymentMethod.bankSlip);
      expect(financeiro.preFaturas, isEmpty);

      expect(find.text('FINANCEIRO'), findsOneWidget);
      expect(
        find.text(
          'Fatura de Juliana Mendes Souza lançada. '
          '1 crédito de agendamento gerado',
        ),
        findsOneWidget,
      );
    });

    testWidgets('pré-fatura inexistente mostra o aviso', (tester) async {
      await abrir(tester, inicio: '/financeiro/pre-fatura/999');

      expect(find.textContaining('Pré-fatura não encontrada'), findsOneWidget);
      expect(find.byType(TextFormField), findsNothing);
    });
  });
}
