import 'package:poti_5f/src/features/medical_records/domain/models/medical_record_summary_model.dart';
import 'package:poti_5f/src/features/medical_records/domain/repositories/medical_records_repository.dart';

class FakeMedicalRecordsRepository implements MedicalRecordsRepository {
  bool deveFalhar;

  FakeMedicalRecordsRepository({this.deveFalhar = false});

  // Ano corrente: a data aparece sem o ano ("12/02, 13:30") em qualquer ano.
  static final _ano = DateTime.now().year;

  static final prontuarios = [
    MedicalRecordSummaryModel(
      patientId: '1',
      patientName: 'Jorge Silva',
      specialty: 'Fisioterapia',
      lastSession: DateTime(_ano, 2, 12, 13, 30),
      hasRecord: true,
    ),
    const MedicalRecordSummaryModel(
      patientId: '2',
      patientName: 'Antônio Araújo',
      specialty: 'Fisioterapia',
    ),
    MedicalRecordSummaryModel(
      patientId: '3',
      patientName: 'Lucas Freitas',
      specialty: 'Terapia Ocupacional',
      lastSession: DateTime(_ano, 2, 8, 18),
      hasRecord: true,
      pendingEvolutions: 1,
    ),
    MedicalRecordSummaryModel(
      patientId: '4',
      patientName: 'Helena Costa',
      specialty: 'Fisioterapia',
      lastSession: DateTime(_ano, 1, 20, 10),
      hasRecord: true,
      discharged: true,
    ),
  ];

  @override
  Future<List<MedicalRecordSummaryModel>> buscarProntuarios() async {
    if (deveFalhar) throw Exception('sem conexão');
    return prontuarios;
  }
}
