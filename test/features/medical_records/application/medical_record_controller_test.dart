import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiclinica_app/src/features/medical_records/application/medical_record_controller.dart';
import 'package:multiclinica_app/src/features/medical_records/application/medical_records_controller.dart';
import 'package:multiclinica_app/src/features/medical_records/domain/models/evolution_model.dart';
import 'package:multiclinica_app/src/features/medical_records/domain/models/medical_record_content.dart';
import 'package:multiclinica_app/src/features/medical_records/domain/models/medical_record_create_model.dart';
import 'package:multiclinica_app/src/features/medical_records/domain/models/medical_record_status.dart';
import 'package:multiclinica_app/src/features/medical_records/domain/models/medical_record_summary_model.dart';
import 'package:multiclinica_app/src/features/medical_records/ui/states/medical_record_state.dart';

import 'fake_medical_records_repository.dart';

void main() {
  const patientId = '5';

  // Teve sessão há 3 dias e não tem prontuário: Pendente.
  final semProntuario = MedicalRecordSummaryModel(
    patientId: patientId,
    patientName: 'Antônio Araújo',
    specialty: 'Fisioterapia',
    lastSession: DateTime.now().subtract(const Duration(days: 3)),
    pendingEvolutionSince: DateTime.now().subtract(const Duration(days: 3)),
  );

  ProviderContainer criarContainer(FakeMedicalRecordsRepository repository) {
    final container = ProviderContainer.test(
      overrides: [
        medicalRecordsRepositoryProvider.overrideWithValue(repository),
      ],
    );
    // Mantém o autoDispose vivo durante o teste.
    container.listen(medicalRecordControllerProvider(patientId), (_, _) {});
    container.listen(medicalRecordFormControllerProvider(patientId), (_, _) {});
    return container;
  }

  Future<void> carregar(ProviderContainer container) async {
    container.read(medicalRecordControllerProvider(patientId));
    await Future<void>.delayed(Duration.zero);
  }

  const anamnese = MedicalRecordContent({
    MedicalRecordField.chiefComplaint: 'Dor no ombro.',
    MedicalRecordField.medicalDiagnosis: 'Tendinite.',
  });

  test('carrega o prontuário do paciente', () async {
    final container = criarContainer(
      FakeMedicalRecordsRepository(prontuarios: [semProntuario]),
    );
    await carregar(container);

    final details = container
        .read(medicalRecordControllerProvider(patientId))
        .details!;
    expect(details.record, isNull);
    expect(details.summary.status, MedicalRecordStatus.pending);
  });

  test('erro ao carregar vira mensagem', () async {
    final container = criarContainer(
      FakeMedicalRecordsRepository(deveFalhar: true),
    );
    await carregar(container);

    expect(
      container.read(medicalRecordControllerProvider(patientId)).errorMessage,
      contains('sem conexão'),
    );
  });

  test(
    'o status só muda ao salvar: criar com evolução vira Em Terapia',
    () async {
      final repository = FakeMedicalRecordsRepository(
        prontuarios: [semProntuario],
      );
      final container = criarContainer(repository);
      await carregar(container);
      container.read(medicalRecordsControllerProvider);
      await Future<void>.delayed(Duration.zero);

      await container
          .read(medicalRecordFormControllerProvider(patientId).notifier)
          .criar(
            MedicalRecordCreateModel(
              content: anamnese,
              evolution: EvolutionCreateModel(
                sessionNumber: 1,
                sessionDate: DateTime.now(),
                professionalId: '1',
                description: 'Primeira avaliação.',
                patientStatus: EvolutionPatientStatus.inTherapy,
              ),
            ),
          );
      await Future<void>.delayed(Duration.zero);

      final state = container.read(
        medicalRecordFormControllerProvider(patientId),
      );
      expect(state, isA<MedicalRecordFormSuccess>());
      expect((state as MedicalRecordFormSuccess).criado, isTrue);
      expect(
        repository.criados.single.evolution!.description,
        'Primeira avaliação.',
      );

      // Tela do prontuário e lista com o status novo.
      expect(
        container
            .read(medicalRecordControllerProvider(patientId))
            .details!
            .summary
            .status,
        MedicalRecordStatus.inTherapy,
      );
      expect(
        container.read(medicalRecordsControllerProvider).records.single.status,
        MedicalRecordStatus.inTherapy,
      );
    },
  );

  test('erro ao salvar vira mensagem sem "Exception:"', () async {
    final container = criarContainer(
      FakeMedicalRecordsRepository(
        prontuarios: [semProntuario],
        erroSalvar: 'Este paciente já tem prontuário',
      ),
    );
    await carregar(container);

    await container
        .read(medicalRecordFormControllerProvider(patientId).notifier)
        .atualizarProntuario(anamnese);

    final state = container.read(
      medicalRecordFormControllerProvider(patientId),
    );
    expect(state, isA<MedicalRecordFormError>());
    expect(
      (state as MedicalRecordFormError).message,
      'Este paciente já tem prontuário',
    );
  });
}
