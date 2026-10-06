import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:poti_5f/src/features/medical_records/application/medical_records_controller.dart';
import 'package:poti_5f/src/features/medical_records/domain/models/discharge_model.dart';
import 'package:poti_5f/src/features/medical_records/domain/models/medical_record_content.dart';
import 'package:poti_5f/src/features/medical_records/domain/models/medical_record_summary_model.dart';
import 'package:poti_5f/src/features/medical_records/ui/pages/medical_record_form_screen.dart';
import 'package:poti_5f/src/features/medical_records/ui/pages/medical_record_screen.dart';
import 'package:poti_5f/src/features/medical_records/ui/pages/medical_records_screen.dart';

import '../application/fake_medical_records_repository.dart';

void main() {
  late FakeMedicalRecordsRepository repository;
  late GoRouter router;

  final tresDiasAtras = DateTime.now().subtract(const Duration(days: 3));

  final pacientes = [
    // Teve sessão e não tem prontuário: Pendente.
    MedicalRecordSummaryModel(
      patientId: '5',
      patientName: 'Antônio Araújo',
      specialty: 'Fisioterapia',
      lastSession: tresDiasAtras,
      pendingEvolutionSince: tresDiasAtras,
    ),
    // Sem sessão: Novo (sem opção de evolução).
    const MedicalRecordSummaryModel(
      patientId: '6',
      patientName: 'Rita Moura',
      specialty: 'Fisioterapia',
    ),
    MedicalRecordSummaryModel(
      patientId: '7',
      patientName: 'Jorge Silva',
      specialty: 'Fisioterapia',
      lastSession: tresDiasAtras,
      hasRecord: true,
    ),
    MedicalRecordSummaryModel(
      patientId: '8',
      patientName: 'Helena Costa',
      specialty: 'Fisioterapia',
      lastSession: tresDiasAtras,
      hasRecord: true,
      discharged: true,
    ),
  ];

  Future<void> abrir(WidgetTester tester, String local) async {
    // Tela alta: todos os campos cabem sem rolar.
    tester.view.physicalSize = const Size(1200, 6000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    repository = FakeMedicalRecordsRepository(prontuarios: pacientes);
    router = GoRouter(
      initialLocation: local,
      routes: [
        GoRoute(
          path: '/prontuario',
          name: 'prontuario',
          builder: (context, state) => const MedicalRecordsScreen(),
          routes: [
            GoRoute(
              path: ':patientId/novo',
              name: 'prontuario-criar',
              builder: (context, state) => MedicalRecordFormScreen(
                patientId: state.pathParameters['patientId']!,
              ),
            ),
            GoRoute(
              path: ':patientId',
              name: 'prontuario-registro',
              builder: (context, state) => MedicalRecordScreen(
                patientId: state.pathParameters['patientId']!,
              ),
              // Sub-rota: o voltar da edição retorna à visualização.
              routes: [
                GoRoute(
                  path: 'editar',
                  name: 'prontuario-editar',
                  builder: (context, state) => MedicalRecordFormScreen(
                    patientId: state.pathParameters['patientId']!,
                    edicao: true,
                    secao: MedicalRecordSection.values
                        .asNameMap()[state.uri.queryParameters['secao']],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          medicalRecordsRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Bloco "rótulo + campo" do formulário.
  Finder campo(String rotulo) => find.descendant(
    of: find
        .ancestor(of: find.text(rotulo), matching: find.byType(Column))
        .first,
    matching: find.byType(TextFormField),
  );

  Future<void> salvar(WidgetTester tester) async {
    await tester.tap(find.text('SALVAR'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'cadastro: obrigatórios marcados, evolução junto e status muda ao salvar',
    (tester) async {
      await abrir(tester, '/prontuario');

      await tester.tap(find.text('Criar Registro').first);
      await tester.pumpAndSettle();

      expect(find.text('Cadastrar Prontuário'), findsOneWidget);
      expect(find.text('Antônio Araújo'), findsOneWidget);
      expect(
        find.textContaining('paciente5@email.com', findRichText: true),
        findsOneWidget,
      );
      // Antes de salvar, o status continua o de antes.
      expect(find.text('Pendente'), findsOneWidget);

      // Obrigatórios com asterisco e a legenda discreta.
      expect(find.text('* Campos obrigatórios'), findsOneWidget);
      expect(find.text('QUEIXA PRINCIPAL *'), findsOneWidget);
      expect(find.text('DIAGNÓSTICO MÉDICO *'), findsOneWidget);
      expect(find.text('QUEIXA SECUNDÁRIA'), findsOneWidget);
      expect(find.text('EXAMES'), findsOneWidget);

      // Evolução da sessão junto, marcada por padrão.
      expect(find.textContaining('Sessão #3 - '), findsOneWidget);

      await salvar(tester);
      // Queixa principal, diagnóstico e evolução.
      expect(find.text('Campo obrigatório'), findsNWidgets(3));
      expect(repository.criados, isEmpty);

      await tester.enterText(campo('QUEIXA PRINCIPAL *'), 'Dor no ombro.');
      await tester.enterText(campo('DIAGNÓSTICO MÉDICO *'), 'Tendinite.');
      await tester.enterText(campo('EXAMES'), 'Ultrassom.');
      await tester.enterText(
        campo('EVOLUÇÃO DA SESSÃO *'),
        'Primeira avaliação.',
      );
      await salvar(tester);

      final criado = repository.criados.single;
      expect(
        criado.content[MedicalRecordField.chiefComplaint],
        'Dor no ombro.',
      );
      expect(criado.content[MedicalRecordField.exams], 'Ultrassom.');
      expect(criado.content[MedicalRecordField.secondaryComplaint], '');
      expect(criado.evolution, 'Primeira avaliação.');

      // Vai para a visualização, já com o status novo.
      expect(find.text('Visualizar Prontuário'), findsOneWidget);
      expect(find.text('Prontuário criado'), findsOneWidget);
      expect(find.text('Em Terapia'), findsOneWidget);
      expect(find.text('Primeira avaliação.'), findsOneWidget);
      expect(find.text('Dor no ombro.'), findsOneWidget);
      expect(find.text('Não informado'), findsWidgets);
    },
  );

  testWidgets('desmarcar a evolução cria só o prontuário', (tester) async {
    await abrir(tester, '/prontuario/5/novo');

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(find.text('EVOLUÇÃO DA SESSÃO *'), findsNothing);

    await tester.enterText(campo('QUEIXA PRINCIPAL *'), 'Dor no ombro.');
    await tester.enterText(campo('DIAGNÓSTICO MÉDICO *'), 'Tendinite.');
    await salvar(tester);

    expect(repository.criados.single.evolution, isNull);
    // Sessão de 3 dias atrás sem evolução: continua pendente.
    expect(find.text('Pendente'), findsOneWidget);
    expect(find.text('Nenhuma evolução registrada'), findsOneWidget);
  });

  testWidgets('paciente sem sessão não tem a opção de evolução', (
    tester,
  ) async {
    await abrir(tester, '/prontuario/6/novo');

    expect(find.text('Novo'), findsOneWidget);
    expect(find.byType(Checkbox), findsNothing);
    expect(find.text('EVOLUÇÃO DA SESSÃO *'), findsNothing);
  });

  testWidgets('visualizar e editar: o lápis abre o formulário preenchido', (
    tester,
  ) async {
    await abrir(tester, '/prontuario/7');

    expect(find.text('EVOLUÇÕES'), findsOneWidget);
    expect(find.text('EVOLUÇÃO RECENTE'), findsOneWidget);
    expect(find.text('+ Nova Evolução'), findsOneWidget);
    // Data de criação em cada seção.
    expect(find.textContaining('Criação - 10/01/'), findsNWidgets(3));
    expect(find.textContaining('Última modificação'), findsNothing);

    // As três seções, cada uma com o seu lápis.
    expect(find.text('ANAMNESE'), findsOneWidget);
    expect(find.text('AVALIAÇÃO FÍSICA'), findsOneWidget);
    expect(find.text('PLANO TERAPÊUTICO'), findsOneWidget);
    expect(find.text('FORÇA MUSCULAR'), findsOneWidget);
    expect(find.text('OBS GERAIS'), findsOneWidget);
    expect(find.byIcon(Symbols.edit), findsNWidgets(3));

    await tester.tap(find.byTooltip('Editar anamnese'));
    await tester.pumpAndSettle();

    expect(find.text('Editar Prontuário'), findsOneWidget);
    expect(find.text('SALVAR'), findsOneWidget);
    expect(find.text('CANCELAR'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Dor lombar.'), findsOneWidget);
    // A evolução só aparece no primeiro cadastro.
    expect(find.byType(Checkbox), findsNothing);

    await tester.enterText(
      campo('QUEIXA PRINCIPAL *'),
      'Dor lombar irradiada.',
    );
    await salvar(tester);

    expect(
      repository.edicoes.single[MedicalRecordField.chiefComplaint],
      'Dor lombar irradiada.',
    );
    expect(find.text('Prontuário atualizado'), findsOneWidget);
    expect(find.text('Dor lombar irradiada.'), findsOneWidget);
    expect(
      find.textContaining('Última modificação - 20/02/'),
      findsNWidgets(3),
    );
  });

  testWidgets('editar: a seta e o cancelar voltam para a visualização', (
    tester,
  ) async {
    await abrir(tester, '/prontuario/7/editar');

    await tester.tap(find.byIcon(Symbols.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Visualizar Prontuário'), findsOneWidget);

    await tester.tap(find.byTooltip('Editar anamnese'));
    await tester.pumpAndSettle();
    await tester.enterText(campo('QUEIXA PRINCIPAL *'), 'Rascunho.');
    await tester.tap(find.text('CANCELAR'));
    await tester.pumpAndSettle();
    expect(find.text('Visualizar Prontuário'), findsOneWidget);
    expect(find.text('Rascunho.'), findsNothing);
    expect(repository.edicoes, isEmpty);
  });

  testWidgets('cadastro: cancelar volta para a lista sem criar', (
    tester,
  ) async {
    await abrir(tester, '/prontuario');
    await tester.tap(find.text('Criar Registro').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('CANCELAR'));
    await tester.pumpAndSettle();
    expect(find.text('Prontuário'), findsOneWidget);
    expect(repository.criados, isEmpty);
  });

  testWidgets('o lápis de uma seção abre a edição rolada até ela', (
    tester,
  ) async {
    await abrir(tester, '/prontuario/7');
    // Tela baixa: o plano terapêutico fica fora da tela no formulário.
    tester.view.physicalSize = const Size(1200, 1600);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byTooltip('Editar plano terapêutico'),
      300,
    );
    await tester.tap(find.byTooltip('Editar plano terapêutico'));
    await tester.pumpAndSettle();

    expect(find.text('Editar Prontuário'), findsOneWidget);
    final titulo = tester.getRect(find.text('PLANO TERAPÊUTICO'));
    expect(titulo.top, greaterThanOrEqualTo(0));
    expect(titulo.bottom, lessThanOrEqualTo(1600));
  });

  testWidgets('protocolo de alta: alerta, pede o motivo e fecha o prontuário', (
    tester,
  ) async {
    await abrir(tester, '/prontuario/7');

    expect(find.text('Em Terapia'), findsOneWidget);
    // O botão fica acima da área de evoluções.
    final botao = tester.getTopLeft(find.text('Registrar Alta')).dy;
    expect(botao, lessThan(tester.getTopLeft(find.text('EVOLUÇÕES')).dy));

    await tester.tap(find.text('Registrar Alta'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.textContaining('não pode ser desfeita'), findsOneWidget);

    // Cancelar não muda nada.
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(repository.altas, isEmpty);

    await tester.tap(find.text('Registrar Alta'));
    await tester.pumpAndSettle();

    // Motivo e descrição obrigatórios.
    await tester.tap(find.text('Confirmar alta'));
    await tester.pumpAndSettle();
    expect(find.text('Selecione uma opção'), findsOneWidget);
    expect(find.text('Campo obrigatório'), findsOneWidget);
    expect(repository.altas, isEmpty);

    await tester.tap(find.text('Selecione'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Objetivos do tratamento alcançados'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(TextFormField),
      ),
      'Sem dor nas atividades diárias.',
    );
    await tester.tap(find.text('Confirmar alta'));
    await tester.pumpAndSettle();

    final alta = repository.altas['7']!;
    expect(alta.reason, DischargeReason.goalsAchieved);
    expect(alta.description, 'Sem dor nas atividades diárias.');

    // Card da alta acima das evoluções, status novo e só leitura.
    expect(find.text('Alta registrada. Prontuário fechado'), findsOneWidget);
    expect(find.text('ALTA'), findsOneWidget);
    expect(find.textContaining('Alta - 01/03/'), findsOneWidget);
    expect(find.text('Sem dor nas atividades diárias.'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('ALTA')).dy,
      lessThan(tester.getTopLeft(find.text('EVOLUÇÕES')).dy),
    );
    expect(find.text('Alta Médica'), findsOneWidget);
    expect(find.text('Registrar Alta'), findsNothing);
    expect(find.text('+ Nova Evolução'), findsNothing);
    expect(find.byIcon(Symbols.edit), findsNothing);
  });

  testWidgets('prontuário fechado (alta) fica só para leitura', (tester) async {
    await abrir(tester, '/prontuario/8');

    expect(find.text('Alta Médica'), findsOneWidget);
    expect(find.text('Registrar Alta'), findsNothing);
    expect(find.byIcon(Symbols.edit), findsNothing);
    expect(find.text('+ Nova Evolução'), findsNothing);
  });
}
