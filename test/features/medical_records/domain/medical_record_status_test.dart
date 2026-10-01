import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/features/medical_records/domain/models/medical_record_filter.dart';
import 'package:poti_5f/src/features/medical_records/domain/models/medical_record_status.dart';
import 'package:poti_5f/src/features/medical_records/domain/models/medical_record_summary_model.dart';

MedicalRecordStatus status({
  bool hasRecord = true,
  int pendingEvolutions = 0,
  bool discharged = false,
}) {
  return MedicalRecordSummaryModel(
    patientId: '1',
    patientName: 'Paciente',
    specialty: 'Fisioterapia',
    hasRecord: hasRecord,
    pendingEvolutions: pendingEvolutions,
    discharged: discharged,
  ).status;
}

void main() {
  group('status do prontuário', () {
    test('sem prontuário: Novo', () {
      expect(status(hasRecord: false), MedicalRecordStatus.newPatient);
    });

    test('com prontuário e evoluções em dia: Em Terapia', () {
      expect(status(), MedicalRecordStatus.inTherapy);
    });

    test('uma ou mais evoluções pendentes: Pendente', () {
      expect(status(pendingEvolutions: 1), MedicalRecordStatus.pending);
      expect(status(pendingEvolutions: 3), MedicalRecordStatus.pending);
    });

    test('com alta: Alta Médica', () {
      expect(status(discharged: true), MedicalRecordStatus.discharged);
    });

    test('pendência aparece mesmo sem prontuário ou com alta', () {
      expect(
        status(hasRecord: false, pendingEvolutions: 1),
        MedicalRecordStatus.pending,
      );
      expect(
        status(discharged: true, pendingEvolutions: 1),
        MedicalRecordStatus.pending,
      );
    });
  });

  test('filtro "Todos" aceita qualquer status; os outros, só o seu', () {
    for (final s in MedicalRecordStatus.values) {
      expect(MedicalRecordFilter.all.aceita(s), isTrue);
    }
    expect(
      MedicalRecordFilter.discharged.aceita(MedicalRecordStatus.discharged),
      isTrue,
    );
    expect(
      MedicalRecordFilter.discharged.aceita(MedicalRecordStatus.inTherapy),
      isFalse,
    );
  });
}
