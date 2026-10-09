import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiclinica_app/src/features/medical_records/application/medical_records_controller.dart';
import 'package:multiclinica_app/src/features/medical_records/domain/models/medical_record_filter.dart';

import 'fake_medical_records_repository.dart';

void main() {
  ProviderContainer criarContainer(FakeMedicalRecordsRepository repository) {
    return ProviderContainer.test(
      overrides: [
        medicalRecordsRepositoryProvider.overrideWithValue(repository),
      ],
    );
  }

  Future<ProviderContainer> carregado() async {
    final container = criarContainer(FakeMedicalRecordsRepository());
    container.read(medicalRecordsControllerProvider);
    await container.read(medicalRecordsControllerProvider.notifier).carregar();
    return container;
  }

  List<String> nomes(ProviderContainer container) => container
      .read(medicalRecordsControllerProvider)
      .filteredRecords
      .map((r) => r.patientName)
      .toList();

  test('começa carregando com o filtro "Todos"', () {
    final container = criarContainer(FakeMedicalRecordsRepository());

    final state = container.read(medicalRecordsControllerProvider);
    expect(state.isLoading, isTrue);
    expect(state.filter, MedicalRecordFilter.all);
  });

  test('sucesso: "Todos" mostra todos os pacientes', () async {
    final container = await carregado();

    expect(nomes(container), hasLength(4));
  });

  test('cada chip mostra só o seu status', () async {
    final container = await carregado();
    final controller = container.read(
      medicalRecordsControllerProvider.notifier,
    );

    controller.selecionarFiltro(MedicalRecordFilter.inTherapy);
    expect(nomes(container), ['Jorge Silva']);
    controller.selecionarFiltro(MedicalRecordFilter.newPatient);
    expect(nomes(container), ['Antônio Araújo']);
    controller.selecionarFiltro(MedicalRecordFilter.pending);
    expect(nomes(container), ['Lucas Freitas']);
    controller.selecionarFiltro(MedicalRecordFilter.discharged);
    expect(nomes(container), ['Helena Costa']);
  });

  test('busca pelo nome ignora acentos e combina com o filtro', () async {
    final container = await carregado();
    final controller = container.read(
      medicalRecordsControllerProvider.notifier,
    );

    controller.buscar('antonio');
    expect(nomes(container), ['Antônio Araújo']);

    controller.selecionarFiltro(MedicalRecordFilter.inTherapy);
    expect(nomes(container), isEmpty);
  });

  test('erro: encerra o loading com mensagem', () async {
    final container = criarContainer(
      FakeMedicalRecordsRepository(deveFalhar: true),
    );

    container.read(medicalRecordsControllerProvider);
    await container.read(medicalRecordsControllerProvider.notifier).carregar();

    final state = container.read(medicalRecordsControllerProvider);
    expect(state.isLoading, isFalse);
    expect(state.errorMessage, contains('Erro ao carregar prontuários'));
  });
}
