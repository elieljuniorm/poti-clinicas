import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiclinica_app/src/features/scheduling/application/edit_appointment_controller.dart';
import 'package:multiclinica_app/src/features/scheduling/application/scheduling_controller.dart';
import 'package:multiclinica_app/src/features/scheduling/domain/models/scheduling_appointment_model.dart';
import 'package:multiclinica_app/src/features/scheduling/ui/states/edit_appointment_state.dart';

import 'appointment_fixture.dart';
import 'fake_scheduling_repository.dart';

void main() {
  ProviderContainer criarContainer(FakeSchedulingRepository repository) {
    final container = ProviderContainer.test(
      overrides: [schedulingRepositoryProvider.overrideWithValue(repository)],
    );
    // Mantém o autoDispose vivo durante o teste.
    container.listen(editAppointmentControllerProvider, (_, _) {});
    return container;
  }

  test('sucesso: salva e recarrega a Agenda', () async {
    final repository = FakeSchedulingRepository(
      atendimentos: [atendimentoDeTeste()],
    );
    final container = criarContainer(repository);
    final buscasAntes = repository.buscas;

    await container
        .read(editAppointmentControllerProvider.notifier)
        .salvar(atendimentoDeTeste(status: AppointmentStatus.confirmed));
    await Future<void>.delayed(Duration.zero);

    final state = container.read(editAppointmentControllerProvider);
    expect(state, isA<EditAppointmentSuccess>());
    expect(repository.atualizados.single.status, AppointmentStatus.confirmed);
    expect(repository.buscas, greaterThan(buscasAntes));
  });

  test('erro: mensagem sem o prefixo "Exception:"', () async {
    final container = criarContainer(
      FakeSchedulingRepository(erroAtualizar: 'Agendamento não encontrado'),
    );

    await container
        .read(editAppointmentControllerProvider.notifier)
        .salvar(atendimentoDeTeste());

    final state = container.read(editAppointmentControllerProvider);
    expect(state, isA<EditAppointmentError>());
    expect(
      (state as EditAppointmentError).message,
      'Agendamento não encontrado',
    );
  });
}
