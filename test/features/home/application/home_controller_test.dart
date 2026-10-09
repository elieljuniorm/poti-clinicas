import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiclinica_app/src/features/home/application/home_controller.dart';
import 'package:multiclinica_app/src/features/home/domain/models/daily_appointment_model.dart';
import 'package:multiclinica_app/src/features/home/domain/models/evolution_model.dart';
import 'package:multiclinica_app/src/features/home/domain/models/financial_summary_model.dart';
import 'package:multiclinica_app/src/features/home/domain/repositories/home_repository.dart';

class _FakeHomeRepository implements HomeRepository {
  bool deveFalhar;

  _FakeHomeRepository({this.deveFalhar = false});

  @override
  Future<List<DailyAppointmentModel>> buscarAtendimentosDoDia() async {
    if (deveFalhar) throw Exception('sem conexão');
    return const [
      DailyAppointmentModel(
        patient: 'Jorge',
        time: '13:30',
        appointmentType: 'Avaliação',
        status: AppointmentStatus.confirmed,
      ),
    ];
  }

  @override
  Future<List<EvolutionModel>> buscarEvolucoes() async {
    return const [
      EvolutionModel(
        date: '13/02',
        time: '10:30',
        professional: 'Lucas',
        patient: 'Antonia',
        appointmentType: 'Avaliação',
        status: EvolutionStatus.open,
      ),
    ];
  }

  @override
  Future<List<FinancialSummaryModel>> buscarResumoFinanceiro() async {
    return const [];
  }
}

void main() {
  ProviderContainer criarContainer(HomeRepository repository) {
    return ProviderContainer.test(
      overrides: [homeRepositoryProvider.overrideWithValue(repository)],
    );
  }

  test('começa carregando', () {
    final container = criarContainer(_FakeHomeRepository());

    expect(container.read(homeControllerProvider).isLoading, isTrue);
  });

  test('sucesso: preenche as listas e encerra o loading', () async {
    final container = criarContainer(_FakeHomeRepository());

    container.read(homeControllerProvider);
    await container.read(homeControllerProvider.notifier).carregar();

    final state = container.read(homeControllerProvider);
    expect(state.isLoading, isFalse);
    expect(state.errorMessage, isNull);
    expect(state.dailyAppointments.single.patient, 'Jorge');
    expect(state.evolutions.single.patient, 'Antonia');
    expect(state.financialSummaries, isEmpty);
  });

  test('erro: encerra o loading com mensagem', () async {
    final container = criarContainer(_FakeHomeRepository(deveFalhar: true));

    container.read(homeControllerProvider);
    await container.read(homeControllerProvider.notifier).carregar();

    final state = container.read(homeControllerProvider);
    expect(state.isLoading, isFalse);
    expect(state.errorMessage, contains('Erro ao carregar dados'));
  });

  test('recarregar com sucesso depois de um erro limpa a mensagem', () async {
    final repository = _FakeHomeRepository(deveFalhar: true);
    final container = criarContainer(repository);
    final controller = container.read(homeControllerProvider.notifier);

    await controller.carregar();
    expect(container.read(homeControllerProvider).errorMessage, isNotNull);

    repository.deveFalhar = false;
    await controller.carregar();

    final state = container.read(homeControllerProvider);
    expect(state.errorMessage, isNull);
    expect(state.dailyAppointments, isNotEmpty);
  });
}
