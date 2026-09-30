import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/features/scheduling/application/scheduling_controller.dart';
import 'package:poti_5f/src/features/scheduling/domain/models/scheduling_appointment_model.dart';
import 'package:poti_5f/src/features/scheduling/domain/models/scheduling_period.dart';
import 'package:poti_5f/src/features/scheduling/domain/repositories/scheduling_repository.dart';

class _FakeSchedulingRepository implements SchedulingRepository {
  bool deveFalhar;
  final List<SchedulingPeriod> chamadas = [];

  /// Quando definido, segura a resposta do período até ser completado.
  final Map<SchedulingPeriod, Completer<void>> atrasos = {};

  _FakeSchedulingRepository({this.deveFalhar = false});

  @override
  Future<List<SchedulingAppointmentModel>> buscarAtendimentos(
    SchedulingPeriod periodo,
  ) async {
    chamadas.add(periodo);
    await atrasos[periodo]?.future;
    if (deveFalhar) throw Exception('sem conexão');
    return [
      SchedulingAppointmentModel(
        date: '02/02',
        time: '08:30',
        patient: 'Paciente ${periodo.name}',
        appointmentType: 'Avaliação',
        status: AppointmentStatus.confirmed,
      ),
    ];
  }
}

void main() {
  ProviderContainer criarContainer(SchedulingRepository repository) {
    return ProviderContainer.test(
      overrides: [schedulingRepositoryProvider.overrideWithValue(repository)],
    );
  }

  test('começa carregando no período "Dia"', () {
    final container = criarContainer(_FakeSchedulingRepository());

    final state = container.read(schedulingControllerProvider);
    expect(state.isLoading, isTrue);
    expect(state.period, SchedulingPeriod.day);
  });

  test('sucesso: preenche a lista e encerra o loading', () async {
    final container = criarContainer(_FakeSchedulingRepository());

    container.read(schedulingControllerProvider);
    await container.read(schedulingControllerProvider.notifier).carregar();

    final state = container.read(schedulingControllerProvider);
    expect(state.isLoading, isFalse);
    expect(state.errorMessage, isNull);
    expect(state.appointments.single.patient, 'Paciente day');
  });

  test('selecionar período busca os atendimentos do novo filtro', () async {
    final repository = _FakeSchedulingRepository();
    final container = criarContainer(repository);
    final controller = container.read(schedulingControllerProvider.notifier);

    await controller.selecionarPeriodo(SchedulingPeriod.month);

    final state = container.read(schedulingControllerProvider);
    expect(state.period, SchedulingPeriod.month);
    expect(state.appointments.single.patient, 'Paciente month');
    expect(repository.chamadas, contains(SchedulingPeriod.month));
  });

  test('resposta atrasada de um filtro antigo é ignorada', () async {
    final repository = _FakeSchedulingRepository();
    final container = criarContainer(repository);
    final controller = container.read(schedulingControllerProvider.notifier);
    await controller.carregar();

    final atrasoSemana = Completer<void>();
    repository.atrasos[SchedulingPeriod.week] = atrasoSemana;

    final buscaSemana = controller.selecionarPeriodo(SchedulingPeriod.week);
    await controller.selecionarPeriodo(SchedulingPeriod.month);
    atrasoSemana.complete();
    await buscaSemana;

    final state = container.read(schedulingControllerProvider);
    expect(state.period, SchedulingPeriod.month);
    expect(state.appointments.single.patient, 'Paciente month');
  });

  test('erro: encerra o loading com mensagem', () async {
    final container = criarContainer(
      _FakeSchedulingRepository(deveFalhar: true),
    );

    container.read(schedulingControllerProvider);
    await container.read(schedulingControllerProvider.notifier).carregar();

    final state = container.read(schedulingControllerProvider);
    expect(state.isLoading, isFalse);
    expect(state.errorMessage, contains('Erro ao carregar agenda'));
  });
}
