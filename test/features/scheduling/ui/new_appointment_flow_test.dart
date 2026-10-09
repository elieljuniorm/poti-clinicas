import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:go_router/go_router.dart';
import 'package:multiclinica_app/src/features/finance/application/finance_controller.dart';
import 'package:multiclinica_app/src/features/scheduling/application/scheduling_controller.dart';
import 'package:multiclinica_app/src/features/scheduling/ui/pages/new_appointment_screen.dart';
import 'package:multiclinica_app/src/features/users/application/users_controller.dart';

import '../../finance/application/fake_finance_repository.dart';
import '../../users/application/fake_users_repository.dart';
import '../application/fake_scheduling_repository.dart';

void main() {
  late FakeSchedulingRepository agenda;
  late FakeFinanceRepository financeiro;

  Future<void> abrir(
    WidgetTester tester, {
    Map<String, int> creditos = const {},
  }) async {
    // Tela alta: tudo cabe sem rolar.
    tester.view.physicalSize = const Size(1000, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    agenda = FakeSchedulingRepository();
    financeiro = FakeFinanceRepository(creditos: {...creditos});
    final router = GoRouter(
      initialLocation: '/agenda/novo',
      routes: [
        GoRoute(
          path: '/agenda',
          name: 'agenda',
          builder: (context, state) => const Scaffold(body: Text('AGENDA')),
          routes: [
            GoRoute(
              path: 'novo',
              name: 'agenda-novo',
              builder: (context, state) => const NewAppointmentScreen(),
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
          schedulingRepositoryProvider.overrideWithValue(agenda),
          financeRepositoryProvider.overrideWithValue(financeiro),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> salvar(WidgetTester tester) async {
    await tester.tap(find.text('SALVAR'));
    await tester.pump();
  }

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

  /// Abre o seletor do horário com esse rótulo (a primeira linha que
  /// tiver) e confirma a posição em que ele abriu.
  Future<void> confirmarHorario(WidgetTester tester, String rotulo) async {
    await tester.tap(find.bySemanticsLabel(rotulo).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('CONFIRMAR'));
    await tester.pumpAndSettle();
  }

  /// Datas do mês que vem: todas disponíveis, seja qual for o dia de hoje.
  Future<void> irParaProximoMes(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Próximo mês'));
    await tester.pumpAndSettle();
  }

  testWidgets('salvar vazio mostra o que falta', (tester) async {
    await abrir(tester);

    await salvar(tester);

    expect(find.text('Selecione um paciente'), findsOneWidget);
    expect(find.text('Selecione mais 1 data'), findsOneWidget);
    expect(find.text('Selecione uma opção'), findsNWidgets(2));
    expect(agenda.agendados, isEmpty);
  });

  testWidgets('busca o paciente, seleciona, remove e troca', (tester) async {
    await abrir(tester);

    await tester.enterText(find.byType(TextField).first, 'anto');
    await tester.pump();
    // Só pacientes aparecem (a profissional e a recepção não).
    expect(find.text('Antônio Araújo'), findsOneWidget);
    expect(find.text('Fernanda Lima'), findsNothing);

    await tester.tap(find.text('Antônio Araújo'));
    await tester.pumpAndSettle();
    expect(find.text('Selecionado'), findsOneWidget);
    // A busca é limpa ao escolher.
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      isEmpty,
    );

    await tester.tap(find.byTooltip('Remover paciente'));
    await tester.pump();
    expect(find.text('Selecionado'), findsNothing);

    await tester.enterText(find.byType(TextField).first, 'ninguém');
    await tester.pump();
    expect(find.text('Nenhum paciente encontrado'), findsOneWidget);
  });

  testWidgets('sessões limitam as datas; cada data ganha uma linha', (
    tester,
  ) async {
    await abrir(tester);
    await irParaProximoMes(tester);

    await tester.tap(find.text('10'));
    await tester.pump();
    expect(find.text('DATAS SELECIONADAS'), findsOneWidget);
    expect(find.text('1 de 1 data selecionada'), findsOneWidget);

    // Já escolheu a única sessão: a segunda data não entra.
    await tester.tap(find.text('12'));
    await tester.pump();
    expect(find.textContaining('Você já escolheu a sessão'), findsOneWidget);
    expect(find.byTooltip('Remover data'), findsOneWidget);

    await tester.tap(find.byTooltip('Aumentar'));
    await tester.pump();
    await tester.tap(find.text('12'));
    await tester.pump();
    expect(find.byTooltip('Remover data'), findsNWidgets(2));

    await tester.tap(find.byTooltip('Remover data').first);
    await tester.pump();
    expect(find.byTooltip('Remover data'), findsOneWidget);
  });

  testWidgets('fluxo completo: agenda e volta para a Agenda', (tester) async {
    await abrir(tester);

    await tester.enterText(find.byType(TextField).first, 'antônio');
    await tester.pump();
    await tester.tap(find.text('Antônio Araújo'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Aumentar'));
    await tester.pump();
    await irParaProximoMes(tester);
    await tester.tap(find.text('10'));
    await tester.tap(find.text('12'));
    await tester.pump();

    // Horários vazios só viram erro ao tentar salvar.
    await salvar(tester);
    expect(find.text('Preencha início e fim'), findsNWidgets(2));

    // Cada horário é escolhido à mão. Início da 1ª data: confirma a
    // posição inicial do seletor (08:00). O fim continua vazio e a outra
    // data não muda.
    await confirmarHorario(tester, 'Início: não definido');
    expect(find.text('08:00'), findsOneWidget);
    expect(find.bySemanticsLabel('Fim: não definido'), findsNWidgets(2));
    expect(find.bySemanticsLabel('Início: não definido'), findsOneWidget);

    // Fim da 1ª data: o seletor abre 1h depois do início (09:00).
    await confirmarHorario(tester, 'Fim: não definido');
    expect(find.text('09:00'), findsOneWidget);

    // 2ª data: horário próprio, também escolhido à mão.
    await confirmarHorario(tester, 'Início: não definido');
    await confirmarHorario(tester, 'Fim: não definido');
    expect(find.text('08:00'), findsNWidgets(2));

    await escolher(tester, 'PROFISSIONAL', 'Arnaldo Ribeiro');
    await escolher(tester, 'TIPO DE ATENDIMENTO', 'Avaliação');
    await tester.enterText(
      find.descendant(
        of: find
            .ancestor(
              of: find.text('CASO CLÍNICO'),
              matching: find.byType(Column),
            )
            .first,
        matching: find.byType(TextFormField),
      ),
      'Dor lombar',
    );

    await salvar(tester);
    await tester.pumpAndSettle();

    final enviado = agenda.agendados.single;
    expect(enviado.patientId, '2');
    expect(enviado.professionalId, '1');
    expect(enviado.appointmentType, 'Avaliação');
    expect(enviado.clinicalCase, 'Dor lombar');
    expect(enviado.sessions, hasLength(2));
    expect(enviado.sessions.first.start.hour, 8);
    expect(enviado.sessions.first.end.hour, 9);
    expect(enviado.sessions.first.start.day, 10);
    expect(enviado.sessions.last.start.day, 12);

    // As sessões foram para o Financeiro: sem créditos, viram pré-fatura.
    final faturado = financeiro.vinculados.single;
    expect(faturado.patientName, 'Antônio Araújo');
    expect(faturado.professionalName, 'Arnaldo Ribeiro');
    expect(faturado.sessions, 2);

    expect(find.text('AGENDA'), findsOneWidget);
    expect(
      find.text(
        '2 sessões agendadas para Antônio Araújo. '
        'Gerada pré-fatura de 2 sessões no Financeiro',
      ),
      findsOneWidget,
    );
  });

  testWidgets('paciente com créditos de agendamento mostra o aviso', (
    tester,
  ) async {
    await abrir(tester, creditos: {'2': 3});

    await tester.enterText(find.byType(TextField).first, 'anto');
    await tester.pump();
    await tester.tap(find.text('Antônio Araújo'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('O paciente tem 3 créditos de agendamento'),
      findsOneWidget,
    );

    // Sem créditos, o aviso some.
    await tester.tap(find.byTooltip('Remover paciente'));
    await tester.pumpAndSettle();
    expect(find.textContaining('créditos de agendamento'), findsNothing);
  });

  testWidgets('a seta do cabeçalho volta para a Agenda', (tester) async {
    await abrir(tester);

    // Na ponta direita da linha do menu.
    final seta = tester.getCenter(find.byTooltip('Voltar'));
    final menu = tester.getCenter(find.byIcon(Symbols.menu));
    expect(seta.dy, moreOrLessEquals(menu.dy, epsilon: 1));
    expect(seta.dx, greaterThan(menu.dx));

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();

    expect(find.text('AGENDA'), findsOneWidget);
    expect(agenda.agendados, isEmpty);
  });
}
