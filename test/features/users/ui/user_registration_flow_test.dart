import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:poti_5f/src/core/ui/widgets/app_section_divider.dart';
import 'package:poti_5f/src/features/profile/application/address_map_controller.dart';
import 'package:poti_5f/src/features/users/application/users_controller.dart';
import 'package:poti_5f/src/features/users/domain/models/bank_info_model.dart';
import 'package:poti_5f/src/features/users/domain/models/family_income.dart';
import 'package:poti_5f/src/features/users/domain/models/marital_status.dart';
import 'package:poti_5f/src/features/users/domain/models/patient_category.dart';
import 'package:poti_5f/src/features/users/domain/models/user_role.dart';
import 'package:poti_5f/src/features/users/ui/pages/user_registration_screen.dart';
import 'package:poti_5f/src/features/users/ui/widgets/registration/patient_responsible_section.dart';

import '../../profile/application/fake_geocoding_repository.dart';
import '../application/fake_users_repository.dart';

void main() {
  late FakeUsersRepository users;
  late FakeGeocodingRepository geocoding;

  Future<void> abrirCadastro(WidgetTester tester) async {
    // Tela alta: todos os campos cabem sem rolar.
    tester.view.physicalSize = const Size(1200, 9000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    users = FakeUsersRepository();
    geocoding = FakeGeocodingRepository();

    final router = GoRouter(
      initialLocation: '/usuario/novo',
      routes: [
        GoRoute(
          path: '/usuario',
          name: 'usuario',
          builder: (context, state) =>
              const Scaffold(body: Text('LISTA DE USUÁRIOS')),
          routes: [
            GoRoute(
              path: 'novo',
              name: 'usuario-novo',
              builder: (context, state) => const UserRegistrationScreen(),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          usersRepositoryProvider.overrideWithValue(users),
          geocodingRepositoryProvider.overrideWithValue(geocoding),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Bloco "rótulo + campo" do formulário visível.
  Finder bloco(String rotulo) =>
      find.ancestor(of: find.text(rotulo), matching: find.byType(Column)).first;

  Finder campo(String rotulo) =>
      find.descendant(of: bloco(rotulo), matching: find.byType(TextFormField));

  Future<void> escolher(
    WidgetTester tester,
    String rotulo,
    String opcao,
  ) async {
    // O primeiro InkWell do bloco é o cabeçalho do select.
    await tester.tap(
      find.descendant(of: bloco(rotulo), matching: find.byType(InkWell)).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(opcao).last);
    await tester.pumpAndSettle();
  }

  Future<void> salvar(WidgetTester tester) async {
    await tester.tap(find.text('SALVAR'));
    await tester.pump();
  }

  testWidgets('profissional: valida, mostra campos do perfil e cadastra', (
    tester,
  ) async {
    await abrirCadastro(tester);

    expect(find.textContaining('CADASTRO DO PROFISSIONAL'), findsOneWidget);
    // Endereço básico (sem mapa) e dados financeiros, com divisor de área.
    expect(find.widgetWithText(AppSectionDivider, 'ENDEREÇO'), findsOneWidget);
    expect(
      find.widgetWithText(AppSectionDivider, 'DADOS FINANCEIROS'),
      findsOneWidget,
    );
    expect(find.byType(FlutterMap), findsNothing);

    // Tudo vazio: obrigatórios e select sem opção.
    await salvar(tester);
    expect(find.text('Campo obrigatório'), findsWidgets);
    expect(find.text('Selecione uma opção'), findsOneWidget);
    expect(users.cadastros, isEmpty);

    // Profissional de saúde: pede conselho e especialidade.
    await escolher(tester, 'PERFIL DE ACESSO', 'Profissional de saúde');
    expect(find.text('NÚMERO DE INSCRIÇÃO NO CONSELHO'), findsOneWidget);
    expect(find.text('ESPECIALIDADE'), findsOneWidget);
    expect(find.text('SETOR'), findsNothing);

    // Recepção: troca por "SETOR" (opcional).
    await escolher(tester, 'PERFIL DE ACESSO', 'Recepção');
    expect(find.text('NÚMERO DE INSCRIÇÃO NO CONSELHO'), findsNothing);
    expect(find.text('SETOR'), findsOneWidget);

    await tester.enterText(campo('NOME'), 'Ana Lima');
    await tester.enterText(campo('EMAIL'), 'ana@5f.com');
    await tester.enterText(campo('TELEFONE'), '91999998888');
    await tester.enterText(campo('CPF / CNPJ'), '52998224724');
    await salvar(tester);
    expect(find.text('CPF inválido'), findsOneWidget);

    // Máscaras aplicadas na digitação.
    expect(find.text('(91) 9 9999-8888'), findsOneWidget);

    await tester.enterText(campo('CPF / CNPJ'), '52998224725');

    // Endereço obrigatório. Digitar não busca no mapa (não há mapa).
    await tester.enterText(campo('CEP'), '66017000');
    await tester.enterText(campo('RUA'), 'Rua B');
    await tester.enterText(campo('NÚMERO'), '20');
    await tester.enterText(campo('BAIRRO'), 'Umarizal');
    await tester.enterText(campo('CIDADE'), 'Belém');
    await tester.enterText(campo('UF'), 'PA');
    await tester.pump(AddressMapController.atrasoBusca);
    expect(geocoding.buscas, isEmpty);

    // Conta bancária pela metade: completa os demais dados da conta.
    await tester.enterText(campo('BANCO'), '001 - Banco do Brasil');
    await salvar(tester);
    expect(find.text('Campo obrigatório'), findsNWidgets(2)); // agência, conta
    expect(find.text('Selecione uma opção'), findsOneWidget); // tipo de conta
    expect(users.cadastros, isEmpty);

    await tester.enterText(campo('AGÊNCIA'), '1234-5');
    await tester.enterText(campo('CONTA'), '67890-1');
    await escolher(tester, 'TIPO DE CONTA', 'Corrente');
    await salvar(tester);
    await tester.pumpAndSettle();

    final cadastro = users.cadastros.single;
    expect(cadastro.role, UserRole.reception);
    expect(cadastro.document, '529.982.247-25');
    expect(cadastro.councilNumber, isNull);
    expect(cadastro.address!.zipCode, '66017-000');
    expect(cadastro.address!.city, 'Belém');
    expect(cadastro.bankInfo!.agency, '1234-5');
    expect(cadastro.bankInfo!.accountType, AccountType.checking);
    // PIX não informado: fica de fora.
    expect(cadastro.bankInfo!.pixKeyType, isNull);
    // Sucesso: aviso e volta para a lista.
    expect(find.text('LISTA DE USUÁRIOS'), findsOneWidget);
    expect(find.text('Ana Lima cadastrado(a) com sucesso'), findsOneWidget);
  });

  testWidgets('paciente: perfil fixo, endereço com mapa e vínculo', (
    tester,
  ) async {
    await abrirCadastro(tester);

    // O que foi digitado no profissional continua ao trocar de aba.
    await tester.enterText(campo('NOME'), 'Rascunho do profissional');
    await tester.tap(find.text('Paciente'));
    await tester.pumpAndSettle();

    expect(find.textContaining('CADASTRO DO PACIENTE'), findsOneWidget);
    expect(find.widgetWithText(AppSectionDivider, 'ENDEREÇO'), findsOneWidget);
    // Paciente não tem dados financeiros.
    expect(find.text('DADOS FINANCEIROS'), findsNothing);
    expect(find.byType(FlutterMap), findsOneWidget);
    // Endereço vazio: o mapa não busca nada ao abrir.
    expect(geocoding.buscas, isEmpty);

    // Perfil de acesso fixo em "Paciente".
    // Tocar no select fixo não abre a lista.
    final paciente = find.text('Paciente').evaluate().length;
    await tester.tap(
      find
          .descendant(
            of: bloco('PERFIL DE ACESSO'),
            matching: find.byType(InkWell),
          )
          .first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Paciente').evaluate().length, paciente);
    expect(find.text('Fixo no cadastro de paciente'), findsOneWidget);

    // Vazio: obrigatórios do paciente e do endereço.
    await salvar(tester);
    // Profissional, categoria, estado civil e renda familiar.
    expect(find.text('Selecione uma opção'), findsNWidgets(4));
    expect(users.cadastros, isEmpty);

    await tester.enterText(campo('NOME'), 'Maria Souza');
    await tester.enterText(campo('EMAIL'), 'maria@gmail.com');
    await tester.enterText(campo('TELEFONE'), '91999998888');
    await tester.enterText(campo('DATA DE NASCIMENTO'), '15031990');
    await tester.enterText(campo('CPF'), '52998224725');
    await escolher(tester, 'PROFISSIONAL', 'Arnaldo Ribeiro');
    await escolher(tester, 'CATEGORIA', 'Adulto');
    await escolher(tester, 'ESTADO CIVIL', 'Solteiro (a)');
    await escolher(
      tester,
      'RENDA FAMILIAR',
      'Entre 7 mil reais e 22 mil reais por mês',
    );
    await tester.enterText(
      campo('CASO CLÍNICO'),
      'Formigamento no pé direito.',
    );

    // Endereço: digitar busca no mapa depois da pausa (igual ao perfil).
    await tester.enterText(campo('CEP'), '66017000');
    await tester.enterText(campo('RUA'), 'Rua A');
    await tester.pump(AddressMapController.atrasoBusca);
    expect(geocoding.buscas.last.street, 'Rua A');

    // Tocar no mapa preenche o endereço do ponto.
    await tester.tap(find.byType(FlutterMap));
    await tester.pump(kDoubleTapTimeout + const Duration(milliseconds: 50));
    await tester.pump();
    expect(find.text('Avenida Frei Serafim'), findsOneWidget);
    // O ponto não tem CEP: como no perfil, o campo fica vazio e é obrigatório.
    await salvar(tester);
    expect(find.text('Campo obrigatório'), findsNWidgets(2)); // CEP e número
    await tester.enterText(campo('CEP'), '64000020');
    await tester.enterText(campo('NÚMERO'), '10');

    // Responsável: marcado por padrão; desmarcado, abre o formulário.
    expect(
      find.widgetWithText(AppSectionDivider, 'RESPONSÁVEL'),
      findsOneWidget,
    );
    final responsavel = find.descendant(
      of: find.byType(PatientResponsibleSection),
      matching: find.byType(TextFormField),
    );
    expect(responsavel, findsNothing);
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(responsavel, findsNWidgets(4));

    await salvar(tester);
    expect(users.cadastros, isEmpty);

    await tester.enterText(responsavel.at(0), 'Luiz Marques Pontes');
    await tester.enterText(responsavel.at(1), 'luiz-marques@gmail.com');
    await tester.enterText(responsavel.at(2), '91999999999');
    await tester.enterText(responsavel.at(3), '18121999');

    await salvar(tester);
    await tester.pumpAndSettle();

    final cadastro = users.cadastros.single;
    expect(cadastro.role, UserRole.patient);
    expect(cadastro.name, 'Maria Souza');
    expect(cadastro.birthDate, '15/03/1990');
    expect(cadastro.professionalId, '1');
    expect(cadastro.patientCategory, PatientCategory.adult);
    expect(cadastro.address!.street, 'Avenida Frei Serafim');
    expect(cadastro.address!.number, '10');
    expect(cadastro.address!.city, 'Teresina');
    expect(cadastro.address!.zipCode, '64000-020');
    expect(cadastro.bankInfo, isNull);
    expect(cadastro.maritalStatus, MaritalStatus.single);
    expect(cadastro.familyIncome, FamilyIncome.from7000To22000);
    expect(cadastro.clinicalCase, 'Formigamento no pé direito.');
    expect(cadastro.selfResponsible, isFalse);
    expect(cadastro.responsible!.name, 'Luiz Marques Pontes');
    expect(cadastro.responsible!.birthDate, '18/12/1999');
    expect(find.text('LISTA DE USUÁRIOS'), findsOneWidget);
  });

  testWidgets('cancelar volta para a lista sem cadastrar', (tester) async {
    await abrirCadastro(tester);

    await tester.tap(find.text('CANCELAR'));
    await tester.pumpAndSettle();

    expect(find.text('LISTA DE USUÁRIOS'), findsOneWidget);
    expect(users.cadastros, isEmpty);
  });

  testWidgets('a seta do cabeçalho volta para a lista sem cadastrar', (
    tester,
  ) async {
    await abrirCadastro(tester);

    // Na ponta direita da linha do menu.
    final seta = tester.getCenter(find.byTooltip('Voltar'));
    final menu = tester.getCenter(find.byIcon(Symbols.menu));
    expect(seta.dy, moreOrLessEquals(menu.dy, epsilon: 1));
    expect(seta.dx, greaterThan(menu.dx));

    // Vale nas duas abas: troca para Paciente e volta por ela.
    await tester.tap(find.text('Paciente'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();

    expect(find.text('LISTA DE USUÁRIOS'), findsOneWidget);
    expect(users.cadastros, isEmpty);
  });
}
