import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/features/medical_records/data/data_sources/medical_records_remote_data_source.dart';
import 'package:poti_5f/src/features/medical_records/data/dtos/medical_record_summary_dto.dart';
import 'package:poti_5f/src/features/medical_records/domain/models/medical_record_status.dart';

void main() {
  group('MedicalRecordSummaryDto', () {
    test('converte os campos e a data ISO', () {
      final model = MedicalRecordSummaryDto.fromJson({
        'patient_id': '2',
        'patient_name': 'Jorge Silva',
        'specialty': 'Fisioterapia',
        'last_session_at': '2026-10-01T13:30:00',
        'has_record': true,
        'pending_evolution_since': null,
        'discharged': false,
      }).toDomain();

      expect(model.patientId, '2');
      expect(model.patientName, 'Jorge Silva');
      expect(model.specialty, 'Fisioterapia');
      expect(model.lastSession, DateTime(2026, 10, 1, 13, 30));
      expect(model.status, MedicalRecordStatus.inTherapy);
    });

    test('campos ausentes: sem sessão, sem prontuário, sem pendência', () {
      final model = MedicalRecordSummaryDto.fromJson({
        'patient_id': '12',
        'patient_name': 'Rita',
        'specialty': 'Fisioterapia',
      }).toDomain();

      expect(model.lastSession, isNull);
      expect(model.status, MedicalRecordStatus.newPatient);
    });

    test('data inválida vira "sem sessão" em vez de quebrar', () {
      final model = MedicalRecordSummaryDto.fromJson({
        'patient_id': '1',
        'patient_name': 'X',
        'specialty': 'Y',
        'last_session_at': 'ontem',
      }).toDomain();

      expect(model.lastSession, isNull);
    });

    test('converte a sessão mais antiga sem evolução', () {
      final model = MedicalRecordSummaryDto.fromJson({
        'patient_id': '8',
        'patient_name': 'Lucas Freitas',
        'specialty': 'Terapia Ocupacional',
        'last_session_at': '2026-10-01T18:00:00',
        'has_record': true,
        'pending_evolution_since': '2026-09-28T18:00:00',
      }).toDomain();

      expect(model.pendingEvolutionSince, DateTime(2026, 9, 28, 18));
      expect(model.status, MedicalRecordStatus.pending);
    });
  });

  test('mock tem os quatro status', () async {
    final dtos = await MedicalRecordsDataSource().buscarProntuarios();
    final status = dtos.map((d) => d.toDomain().status).toSet();

    expect(status, MedicalRecordStatus.values.toSet());
  });
}
