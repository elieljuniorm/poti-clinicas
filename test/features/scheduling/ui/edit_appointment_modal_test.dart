import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiclinica_app/src/features/scheduling/application/scheduling_controller.dart';
import 'package:multiclinica_app/src/features/scheduling/domain/models/scheduling_appointment_model.dart';
import 'package:multiclinica_app/src/features/scheduling/ui/pages/scheduling_screen.dart';
import 'package:multiclinica_app/src/features/scheduling/ui/widgets/edit_appointment/edit_appointment_modal.dart';
import 'package:multiclinica_app/src/features/users/application/users_controller.dart';
import 'package:multiclinica_app/src/features/users/domain/models/patient_category.dart';
import 'package:multiclinica_app/src/features/users/domain/models/user_model.dart';
import 'package:multiclinica_app/src/features/users/domain/models/user_role.dart';

import '../../users/application/fake_users_repository.dart';
import '../application/appointment_fixture.dart';
import '../application/fake_scheduling_repository.dart';

/// Usuários do fake + um paciente com CPF e categoria.
class _UsuariosComCategoria extends FakeUsersRepository {
  @override
  Future<List<UserModel>> buscarUsuarios() async => [
    ...await super.buscarUsuarios(),
    const UserModel(
      id: '20',
      name: 'Jorge Silva',
      email: 'jorge@gmail.com',
      phone: '(91) 9 9999-8888',
      role: UserRole.patient,
      patientCategory: PatientCategory.adult,
      document: '12345678900',
    ),
  ];
}

void main() {
  late FakeSchedulingRepository agenda;
  // Daqui a um ano: a data do atendimento é escolhível no calendário.
  final ano = DateTime.now().year + 1;
  final inicio = DateTime(ano, 7, 15, 14, 30);

  Future<void> abrirAgenda(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    agenda = FakeSchedulingRepository(
      atendimentos: [
        atendimentoDeTeste(
          patientId: '20',
          patient: 'Jorge Silva',
          start: inicio,
          clinicalCase: 'Reabilitação pós-operatória joelho direito',
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          usersRepositoryProvider.overrideWithValue(_UsuariosComCategoria()),
          schedulingRepositoryProvider.overrideWithValue(agenda),
        ],
        child: const MaterialApp(home: SchedulingScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> abrirAtendimento(WidgetTester tester) async {
    await tester.tap(find.text('Jorge Silva'));
    await tester.pumpAndSettle();
  }

  testWidgets('tocar no item da tabela abre o atendimento', (tester) async {
    await abrirAgenda(tester);
    expect(find.byType(EditAppointmentModal), findsNothing);

    await abrirAtendimento(tester);

    expect(find.byType(EditAppointmentModal), findsOneWidget);
    // Paciente com CPF e categoria do cadastro.
    expect(find.text('CPF: ***.***.789-00'), findsOneWidget);
    expect(find.text('Adulto'), findsOneWidget);
    // Dados atuais já preenchidos.
    expect(find.text('Julho $ano'), findsOneWidget);
    expect(find.text('14:30'), findsWidgets);
    expect(find.text('15:30'), findsOneWidget);
    expect(
      find.text('Reabilitação pós-operatória joelho direito'),
      findsOneWidget,
    );
    expect(find.text('Arnaldo Ribeiro'), findsOneWidget);
  });

  testWidgets('salvar grava status e data e fecha o modal', (tester) async {
    await abrirAgenda(tester);
    await abrirAtendimento(tester);

    await tester.tap(find.text('Confirmar'));
    await tester.pump();
    await tester.tap(
      find.descendant(
        of: find.byType(EditAppointmentModal),
        matching: find.text('20'),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('SALVAR ALTERAÇÕES'));
    await tester.pumpAndSettle();

    final salvo = agenda.atualizados.single;
    expect(salvo.status, AppointmentStatus.confirmed);
    expect(salvo.start, DateTime(ano, 7, 20, 14, 30)); // mesmo horário
    expect(salvo.clinicalCase, 'Reabilitação pós-operatória joelho direito');
    expect(find.byType(EditAppointmentModal), findsNothing);
    expect(find.text('Agendamento de Jorge Silva atualizado'), findsOneWidget);
  });

  testWidgets('descartar fecha sem salvar nada', (tester) async {
    await abrirAgenda(tester);
    await abrirAtendimento(tester);

    await tester.tap(find.text('Cancelar'));
    await tester.pump();
    await tester.tap(find.text('Descartar alterações'));
    await tester.pumpAndSettle();

    expect(find.byType(EditAppointmentModal), findsNothing);
    expect(agenda.atualizados, isEmpty);

    // Reabrindo, continua como estava (pendente).
    await abrirAtendimento(tester);
    final pendente = tester.getSemantics(
      find.descendant(
        of: find.byType(EditAppointmentModal),
        matching: find.bySemanticsLabel('Pendente'),
      ),
    );
    expect(pendente, isSemantics(isSelected: true));
  });
}
