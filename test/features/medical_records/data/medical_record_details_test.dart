import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/features/medical_records/data/data_sources/medical_records_remote_data_source.dart';
import 'package:poti_5f/src/features/medical_records/data/dtos/medical_record_content_dto.dart';
import 'package:poti_5f/src/features/medical_records/data/dtos/medical_record_details_dto.dart';
import 'package:poti_5f/src/features/medical_records/data/repository/medical_records_repository_impl.dart';
import 'package:poti_5f/src/features/medical_records/domain/models/discharge_model.dart';
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

    test('evolução vazia não é enviada na criação', () {
      final json = MedicalRecordDetailsDto.createJson(
        const MedicalRecordCreateModel(
          content: MedicalRecordContent(),
          evolution: '  ',
        ),
      );
      expect(json.containsKey('evolution'), isFalse);
    });
  });

  group('prontuário no data source', () {
    late MedicalRecordsRepositoryImpl repository;

    setUp(
      () =>
          repository = MedicalRecordsRepositoryImpl(MedicalRecordsDataSource()),
    );

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
        const MedicalRecordCreateModel(
          content: anamnese,
          evolution: 'Primeira avaliação.',
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

    test(
      'sem sessão, não aceita evolução; prontuário duplicado também não',
      () {
        expect(
          repository.criarProntuario(
            '12',
            const MedicalRecordCreateModel(content: anamnese, evolution: 'x'),
          ),
          throwsA(isA<Exception>()),
        );
        expect(
          repository.criarProntuario(
            '2',
            const MedicalRecordCreateModel(content: anamnese),
          ),
          throwsA(isA<Exception>()),
        );
      },
    );

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
