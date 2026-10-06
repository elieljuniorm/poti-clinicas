import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:poti_5f/src/features/profile/application/address_map_controller.dart';
import 'package:poti_5f/src/features/profile/domain/models/address_model.dart';
import 'package:poti_5f/src/features/users/application/users_controller.dart';
import 'package:poti_5f/src/features/users/domain/models/family_income.dart';
import 'package:poti_5f/src/features/users/domain/models/marital_status.dart';
import 'package:poti_5f/src/features/users/domain/models/patient_category.dart';
import 'package:poti_5f/src/features/users/domain/models/patient_responsible_model.dart';
import 'package:poti_5f/src/features/users/domain/models/user_registration_model.dart';
import 'package:poti_5f/src/features/users/domain/models/user_role.dart';
import 'package:poti_5f/src/features/users/ui/pages/user_edit_screen.dart';
import 'package:poti_5f/src/features/users/ui/pages/users_screen.dart';
import 'package:poti_5f/src/features/users/ui/widgets/user_details_modal.dart';

import '../../profile/application/fake_geocoding_repository.dart';
import '../application/fake_users_repository.dart';

void main() {
  late FakeUsersRepository users;
  late FakeGeocodingRepository geocoding;

  const endereco = AddressModel(
    zipCode: '67030-000',
    street: 'BR 316',
    number: '1835',
    neighborhood: 'Guanabara',
    city: 'Ananindeua',
    state: 'PA',
  );

  const cadastroPaciente = UserRegistrationModel(
    name: 'Antônio Araújo',
    email: 'antonio@gmail.com',
    phone: '91991002020',
    birthDate: '08/02/1950',
    role: UserRole.patient,
    document: '52998224725',
    patientCategory: PatientCategory.elderly,
    professionalId: '1',
    address: endereco,
    maritalStatus: MaritalStatus.widowed,
    familyIncome: FamilyIncome.upTo2500,
    clinicalCase: 'Dor lombar.',
    responsible: PatientResponsibleModel(
      name: 'Luiz Marques Pontes',
      email: 'luiz@gmail.com',
      phone: '91999999999',
      birthDate: '18/12/1999',
    ),
  );

  const cadastroProfissional = UserRegistrationModel(
    name: 'Arnaldo Ribeiro',
    email: 'arnaldo@5f.com',
    phone: '91984551212',
    role: UserRole.professional,
    document: '52998224725',
    councilNumber: '123456-F',
    description: 'Fisioterapeuta',
    address: endereco,
  );

  Future<void> abrirLista(WidgetTester tester) async {
    // Tela alta: todos os campos cabem sem rolar.
    tester.view.physicalSize = const Size(1200, 9000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    users = FakeUsersRepository(
      cadastrosCompletos: {'1': cadastroProfissional, '2': cadastroPaciente},
    );
    geocoding = FakeGeocodingRepository();

    final router = GoRouter(
      initialLocation: '/usuario',
      routes: [
        GoRoute(
          path: '/usuario',
          name: 'usuario',
          builder: (context, state) => const UsersScreen(),
          routes: [
            GoRoute(
              path: ':userId/editar',
              name: 'usuario-editar',
              builder: (context, state) =>
                  UserEditScreen(userId: state.pathParameters['userId']!),
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

  Future<void> abrirEdicao(WidgetTester tester, String nome) async {
    await tester.tap(find.text(nome));
    await tester.pumpAndSettle();
    // Card do topo do modal, com a seta à direita.
    await tester.tap(
      find.descendant(
        of: find.byType(UserDetailsModal),
        matching: find.byIcon(Symbols.chevron_right),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Bloco "rótulo + campo" do formulário.
  Finder bloco(String rotulo) =>
      find.ancestor(of: find.text(rotulo), matching: find.byType(Column)).first;

  Finder campo(String rotulo) =>
      find.descendant(of: bloco(rotulo), matching: find.byType(TextFormField));

  testWidgets('a seta do card do modal abre a edição já preenchida', (
    tester,
  ) async {
    await abrirLista(tester);
    await abrirEdicao(tester, 'Antônio Araújo');

    // O modal fecha e a tela de edição abre.
    expect(find.byType(UserDetailsModal), findsNothing);
    expect(find.byType(UserEditScreen), findsOneWidget);
    expect(find.text('Editar Usuário'), findsOneWidget);
    expect(find.text('ADMINISTRAR USUÁRIO'), findsOneWidget);
    expect(find.text('Desativar Usuário'), findsOneWidget);
    expect(find.text('Resetar Senha'), findsOneWidget);

    // Mesmo formulário do cadastro de paciente, com máscaras aplicadas.
    expect(campo('NOME').evaluate(), isNotEmpty);
    expect(
      find.widgetWithText(TextFormField, 'Antônio Araújo'),
      findsOneWidget,
    );
    expect(find.text('(91) 9 9100-2020'), findsOneWidget);
    expect(find.text('529.982.247-25'), findsOneWidget);
    expect(find.text('Viúvo (a)'), findsOneWidget);
    expect(find.text('Arnaldo Ribeiro'), findsOneWidget); // profissional
    expect(find.text('Luiz Marques Pontes'), findsOneWidget); // responsável
    expect(find.byType(FlutterMap), findsOneWidget);
    // Só o botão de editar; o cancelar fica na seta do topo.
    expect(find.text('EDITAR CADASTRO'), findsOneWidget);
    expect(find.text('CANCELAR'), findsNothing);
  });

  testWidgets('editar cadastro salva e volta para a lista', (tester) async {
    await abrirLista(tester);
    await abrirEdicao(tester, 'Arnaldo Ribeiro');

    // Formulário da equipe, com os campos do profissional de saúde.
    expect(find.text('Profissional de saúde'), findsOneWidget);
    expect(find.text('123456-F'), findsOneWidget);
    expect(find.text('DADOS FINANCEIROS'), findsOneWidget);

    await tester.enterText(campo('NOME'), 'Arnaldo Ribeiro Filho');
    await tester.tap(find.text('EDITAR CADASTRO'));
    await tester.pumpAndSettle();

    final edicao = users.edicoes.single;
    expect(edicao.name, 'Arnaldo Ribeiro Filho');
    expect(edicao.role, UserRole.professional);
    expect(edicao.councilNumber, '123456-F');
    expect(edicao.address, endereco);

    expect(find.byType(UsersScreen), findsOneWidget);
    expect(
      find.text('Cadastro de Arnaldo Ribeiro Filho atualizado'),
      findsOneWidget,
    );
  });

  testWidgets('desativar pede confirmação e vira "Ativar Usuário"', (
    tester,
  ) async {
    await abrirLista(tester);
    await abrirEdicao(tester, 'Fernanda Lima');

    await tester.tap(find.text('Desativar Usuário'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    // Cancelar não muda nada.
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(users.statusAlterados, isEmpty);

    await tester.tap(find.text('Desativar Usuário'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Desativar'));
    await tester.pumpAndSettle();

    expect(users.statusAlterados, [false]);
    expect(find.text('Ativar Usuário'), findsOneWidget);
    expect(find.text('Fernanda Lima desativado(a)'), findsOneWidget);

    // Ativar não pede confirmação.
    await tester.tap(find.text('Ativar Usuário'));
    await tester.pumpAndSettle();
    expect(users.statusAlterados, [false, true]);
    expect(find.text('Desativar Usuário'), findsOneWidget);
    // Continua na edição.
    expect(find.byType(UserEditScreen), findsOneWidget);
  });

  testWidgets('resetar senha envia o link depois de confirmar', (tester) async {
    await abrirLista(tester);
    await abrirEdicao(tester, 'Fernanda Lima');

    await tester.tap(find.text('Resetar Senha'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.textContaining('fernanda@5f.com'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Enviar'));
    await tester.pumpAndSettle();

    expect(users.senhasResetadas, ['3']);
    expect(
      find.text('Link de nova senha enviado para fernanda@5f.com'),
      findsOneWidget,
    );
  });
}
