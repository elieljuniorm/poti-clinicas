import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiclinica_app/src/features/finance/application/finance_controller.dart';
import 'package:multiclinica_app/src/features/scheduling/application/new_appointment_controller.dart';
import 'package:multiclinica_app/src/features/scheduling/application/scheduling_controller.dart';
import 'package:multiclinica_app/src/features/scheduling/domain/models/new_appointment_model.dart';
import 'package:multiclinica_app/src/features/scheduling/ui/states/new_appointment_state.dart';

import '../../finance/application/fake_finance_repository.dart';
import 'fake_scheduling_repository.dart';

void main() {
  final agendamento = NewAppointmentModel(
    patientId: '2',
    patientName: 'Juliana Mendes Souza',
    professionalId: '1',
    professionalName: 'Dr. Arnaldo Ribeiro',
    appointmentType: 'Avaliação',
    sessions: [
      AppointmentSessionModel(
        start: DateTime(2030, 7, 15, 14, 30),
        end: DateTime(2030, 7, 15, 15, 30),
      ),
      AppointmentSessionModel(
        start: DateTime(2030, 7, 17, 14, 30),
        end: DateTime(2030, 7, 17, 15, 30),
      ),
    ],
  );

  ProviderContainer criarContainer(
    FakeSchedulingRepository repository, {
    FakeFinanceRepository? financeiro,
  }) {
    final container = ProviderContainer.test(
      overrides: [
        schedulingRepositoryProvider.overrideWithValue(repository),
        financeRepositoryProvider.overrideWithValue(
          financeiro ?? FakeFinanceRepository(),
        ),
      ],
    );
    // Mantém o autoDispose vivo durante o teste.
    container.listen(newAppointmentControllerProvider, (_, _) {});
    return container;
  }

  test('começa no estado inicial', () {
    final container = criarContainer(FakeSchedulingRepository());

    expect(
      container.read(newAppointmentControllerProvider),
      isA<NewAppointmentInitial>(),
    );
  });

  test('sucesso: envia e recarrega a Agenda', () async {
    final repository = FakeSchedulingRepository();
    final container = criarContainer(repository);
    final buscasAntes = repository.buscas;

    await container
        .read(newAppointmentControllerProvider.notifier)
        .agendar(agendamento);
    await Future<void>.delayed(Duration.zero);

    final state = container.read(newAppointmentControllerProvider);
    expect(state, isA<NewAppointmentSuccess>());
    expect((state as NewAppointmentSuccess).sessions, 2);
    expect(repository.agendados.single.patientId, '2');
    expect(repository.buscas, greaterThan(buscasAntes));
  });

  test('erro: mensagem sem o prefixo "Exception:"', () async {
    final container = criarContainer(
      FakeSchedulingRepository(erroAgendar: 'Profissional indisponível'),
    );

    await container
        .read(newAppointmentControllerProvider.notifier)
        .agendar(agendamento);

    final state = container.read(newAppointmentControllerProvider);
    expect(state, isA<NewAppointmentError>());
    expect((state as NewAppointmentError).message, 'Profissional indisponível');
  });

  group('faturamento das sessões', () {
    test('sem créditos: as 2 sessões vão para a pré-fatura', () async {
      final financeiro = FakeFinanceRepository();
      final container = criarContainer(
        FakeSchedulingRepository(),
        financeiro: financeiro,
      );

      await container
          .read(newAppointmentControllerProvider.notifier)
          .agendar(agendamento);

      final vinculado = financeiro.vinculados.single;
      expect(vinculado.patientId, '2');
      expect(vinculado.professionalId, '1');
      expect(vinculado.sessions, 2);
      final state = container.read(
        newAppointmentControllerProvider,
      ) as NewAppointmentSuccess;
      expect(state.billing!.creditsUsed, 0);
      expect(state.billing!.pendingSessions, 2);
    });

    test('com créditos: usa os créditos do paciente primeiro', () async {
      final financeiro = FakeFinanceRepository(creditos: {'2': 1});
      final container = criarContainer(
        FakeSchedulingRepository(),
        financeiro: financeiro,
      );

      await container
          .read(newAppointmentControllerProvider.notifier)
          .agendar(agendamento);

      final state = container.read(
        newAppointmentControllerProvider,
      ) as NewAppointmentSuccess;
      expect(state.billing!.creditsUsed, 1);
      expect(state.billing!.pendingSessions, 1);
    });

    test('falha no Financeiro não desfaz o agendamento', () async {
      final agenda = FakeSchedulingRepository();
      final container = criarContainer(
        agenda,
        financeiro: FakeFinanceRepository(erroVincular: 'sem conexão'),
      );

      await container
          .read(newAppointmentControllerProvider.notifier)
          .agendar(agendamento);

      final state = container.read(
        newAppointmentControllerProvider,
      ) as NewAppointmentSuccess;
      expect(agenda.agendados, hasLength(1));
      expect(state.billing, isNull);
      expect(state.billingError, 'sem conexão');
    });

    test('agendamento recusado não chega ao Financeiro', () async {
      final financeiro = FakeFinanceRepository();
      final container = criarContainer(
        FakeSchedulingRepository(erroAgendar: 'Profissional indisponível'),
        financeiro: financeiro,
      );

      await container
          .read(newAppointmentControllerProvider.notifier)
          .agendar(agendamento);

      expect(financeiro.vinculados, isEmpty);
    });
  });
}
