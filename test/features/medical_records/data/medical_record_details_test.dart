import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/features/medical_records/data/data_sources/medical_records_remote_data_source.dart';
import 'package:poti_5f/src/features/medical_records/data/dtos/medical_record_content_dto.dart';
import 'package:poti_5f/src/features/medical_records/data/dtos/evolution_dto.dart';
import 'package:poti_5f/src/features/medical_records/data/dtos/medical_record_details_dto.dart';
import 'package:poti_5f/src/features/medical_records/data/repository/medical_records_repository_impl.dart';
import 'package:poti_5f/src/features/medical_records/domain/models/discharge_model.dart';
import 'package:poti_5f/src/features/medical_records/domain/models/evolution_model.dart';
import 'package:poti_5f/src/features/medical_records/domain/models/medical_record_content.dart';
import 'package:poti_5f/src/features/medical_records/domain/models/medical_record_create_model.dart';
import 'package:poti_5f/src/features/medical_records/domain/models/medical_record_status.dart';

void main() {
  group('MedicalRecordContentDto', () {
    test('agrupa por seção com as chaves da API; vazios não são enviados', () {
      const conteudo = MedicalRecordContent({
        MedicalRecordField.chiefComplaint: ' Dor lombar. ',
        MedicalRecordField.exams: '   ',
        MedicalRecordField.muscleStrength: 'Grau 4.',
        MedicalRecordField.generalNotes: 'Boa adesão.',
      });

      final json = MedicalRecordContentDto.fromDomain(conteudo).toJson();
      expect(json, {
        'anamnesis': {'chief_complaint': 'Dor lombar.'},
        'physical_assessment': {'muscle_strength': 'Grau 4.'},
        'therapeutic_plan': {'general_notes': 'Boa adesão.'},
      });

      final volta = MedicalRecordContentDto.fromJson(json).toDomain();
      expect(volta[MedicalRecordField.chiefComplaint], 'Dor lombar.');
      expect(volta[MedicalRecordField.muscleStrength], 'Grau 4.');
      expect(volta[MedicalRecordField.exams], '');
    });

    test('cada seção tem os seus campos, na ordem do formulário', () {
      expect(MedicalRecordSection.anamnesis.campos, hasLength(10));
      expect(MedicalRecordSection.physicalAssessment.campos, [
        MedicalRecordField.activities,
        MedicalRecordField.posturalAssessment,
        MedicalRecordField.muscleStrength,
      ]);
      expect(MedicalRecordSection.therapeuticPlan.campos, [
        MedicalRecordField.scales,
        MedicalRecordField.goals,
        MedicalRecordField.generalNotes,
      ]);
    });
  });

  group('MedicalRecordDetailsDto', () {
    test('converte paciente, prontuário e evolução', () {
      final details = MedicalRecordDetailsDto.fromJson({
        'patient_id': '2',
        'patient_name': 'Jorge Silva',
        'specialty': 'Fisioterapia',
        'email': 'jorge@email.com',
        'professional_name': 'Arnaldo Ribeiro',
        'session_count': 12,
        'last_session_at': '2026-02-13T13:30:00',
        'has_record': true,
        'record': {
          'created_at': '2026-01-10T09:00:00',
          'updated_at': '2026-02-01T10:00:00',
          'content': {
            'anamnesis': {'chief_complaint': 'Formigamento.'},
          },
        },
        'latest_evolution': {
          'session_number': 12,
          'session_date': '2026-02-13T13:30:00',
          'professional_name': 'Arnaldo Ribeiro',
          'description': 'Melhora da dor.',
        },
      }).toDomain();

      expect(details.email, 'jorge@email.com');
      expect(details.sessionCount, 12);
      expect(details.record!.createdAt, DateTime(2026, 1, 10, 9));
      expect(details.record!.foiModificado, isTrue);
      expect(
        details.record!.content[MedicalRecordField.chiefComplaint],
        'Formigamento.',
      );
      expect(details.latestEvolution!.sessionNumber, 12);
    });

    test('sem evolução, a criação não envia "evolution"', () {
      final json = MedicalRecordDetailsDto.createJson(
        const MedicalRecordCreateModel(content: MedicalRecordContent()),
      );
      expect(json.containsKey('evolution'), isFalse);
    });
  });

  group('EvolutionDto', () {
    test('envia os campos da API; textos vazios ficam de fora', () {
      final json = EvolutionDto.createJson(
        EvolutionCreateModel(
          sessionNumber: 13,
          sessionDate: DateTime(2026, 2, 13, 15, 30),
          professionalId: '1',
          description: ' Mobilização passiva. ',
          observations: '  ',
          clinicalProgress: 'Ganho de amplitude.',
          patientStatus: EvolutionPatientStatus.improving,
          scale: const EvolutionScaleModel(
            scale: AssessmentScale.eva,
            result: '3/10',
          ),
        ),
      );

      expect(json, {
        'session_number': 13,
        'session_date': '2026-02-13T00:00:00.000',
        'professional_id': '1',
        'description': 'Mobilização passiva.',
        'clinical_progress': 'Ganho de amplitude.',
        'patient_status': 'improving',
        'scale': {'type': 'eva', 'result': '3/10'},
      });
    });

    test('evolução antiga, sem os campos novos, não quebra', () {
      final model = EvolutionDto({
        'session_number': 3,
        'session_date': '2026-02-01T10:00:00',
        'professional_name': 'Arnaldo Ribeiro',
        'description': 'Boa resposta.',
      }).toDomain();

      expect(model.observations, '');
      expect(model.patientStatus, isNull);
      expect(model.scale, isNull);
      // Sem quem registrou: o profissional, na data da sessão.
      expect(model.registeredBy, 'Arnaldo Ribeiro');
      expect(model.registeredAt, DateTime(2026, 2, 1, 10));
    });
  });

  group('prontuário no data source', () {
    late MedicalRecordsRepositoryImpl repository;

    setUp(
      () =>
          repository = MedicalRecordsRepositoryImpl(MedicalRecordsDataSource()),
    );

    EvolutionCreateModel evolucao(int numero, String descricao) =>
        EvolutionCreateModel(
          sessionNumber: numero,
          sessionDate: DateTime.now(),
          professionalId: '1',
          description: descricao,
          patientStatus: EvolutionPatientStatus.inTherapy,
        );

    test('nova evolução da sessão pendente: sai de Pendente', () async {
      // Lucas: 4 sessões, última evolução #3, sessão #4 sem evolução.
      final antes = await repository.buscarProntuario('8');
      expect(antes.summary.status, MedicalRecordStatus.pending);
      expect(antes.proximaSessao, 4);

      final details = await repository.registrarEvolucao(
        '8',
        evolucao(4, 'Melhora na preensão.'),
      );

      expect(details.summary.status, MedicalRecordStatus.inTherapy);
      expect(details.latestEvolution!.sessionNumber, 4);
      expect(details.latestEvolution!.professionalName, 'Arnaldo Ribeiro');
      expect(
        details.latestEvolution!.patientStatus,
        EvolutionPatientStatus.inTherapy,
      );
      expect(details.proximaSessao, 5);
    });

    test('evolução precisa de prontuário aberto', () {
      expect(
        repository.registrarEvolucao('12', evolucao(1, 'x')),
        throwsA(isA<Exception>()),
      );
      expect(
        repository.registrarEvolucao('11', evolucao(11, 'x')),
        throwsA(isA<Exception>()),
      );
    });

    const anamnese = MedicalRecordContent({
      MedicalRecordField.chiefComplaint: 'Dor no ombro.',
      MedicalRecordField.medicalDiagnosis: 'Tendinite.',
    });

    test('criar com evolução tira a pendência: Em Terapia', () async {
      // Antônio: teve sessão e não tem prontuário.
      expect(
        (await repository.buscarProntuario('6')).summary.status,
        MedicalRecordStatus.pending,
      );

      final details = await repository.criarProntuario(
        '6',
        MedicalRecordCreateModel(
          content: anamnese,
          evolution: evolucao(1, 'Primeira avaliação.'),
        ),
      );

      expect(details.summary.status, MedicalRecordStatus.inTherapy);
      expect(details.record!.foiModificado, isFalse);
      expect(details.latestEvolution!.sessionNumber, 1);
      expect(details.latestEvolution!.description, 'Primeira avaliação.');

      // A lista também mostra o status novo.
      final lista = await repository.buscarProntuarios();
      expect(
        lista.firstWhere((p) => p.patientId == '6').status,
        MedicalRecordStatus.inTherapy,
      );
    });

    test('criar sem evolução, com sessão antiga: continua Pendente', () async {
      final details = await repository.criarProntuario(
        '6',
        const MedicalRecordCreateModel(content: anamnese),
      );

      expect(details.record, isNotNull);
      expect(details.summary.status, MedicalRecordStatus.pending);
    });

    test('prontuário duplicado não é aceito', () {
      expect(
        repository.criarProntuario(
          '2',
          const MedicalRecordCreateModel(content: anamnese),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('editar troca a anamnese e registra a modificação', () async {
      final antes = await repository.buscarProntuario('9');
      final details = await repository.atualizarProntuario('9', anamnese);

      expect(
        details.record!.content[MedicalRecordField.chiefComplaint],
        'Dor no ombro.',
      );
      expect(details.record!.createdAt, antes.record!.createdAt);
      expect(details.record!.foiModificado, isTrue);
    });

    test('registrar alta fecha o prontuário: Alta Médica', () async {
      final details = await repository.registrarAlta(
        '9',
        motivo: DischargeReason.goalsAchieved,
        descricao: '  Objetivos alcançados.  ',
      );

      expect(details.summary.status, MedicalRecordStatus.discharged);
      expect(details.discharge!.reason, DischargeReason.goalsAchieved);
      expect(details.discharge!.description, 'Objetivos alcançados.');
      expect(details.discharge!.professionalName, 'Arnaldo Ribeiro');

      final lista = await repository.buscarProntuarios();
      expect(
        lista.firstWhere((p) => p.patientId == '9').status,
        MedicalRecordStatus.discharged,
      );
    });

    test('alta exige prontuário e não pode ser registrada duas vezes', () {
      expect(
        repository.registrarAlta(
          '12',
          motivo: DischargeReason.other,
          descricao: 'x',
        ),
        throwsA(isA<Exception>()),
      );
      expect(
        repository.registrarAlta(
          '11',
          motivo: DischargeReason.other,
          descricao: 'x',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('alta do mock vem com motivo e relato', () async {
      final details = await repository.buscarProntuario('11');
      expect(details.discharge!.reason, DischargeReason.goalsAchieved);
      expect(details.discharge!.description, isNotEmpty);
    });
  });
}
