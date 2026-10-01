import '../models/medical_record_summary_model.dart';

/// Contrato do repositório do Prontuário.
/// A camada de aplicação depende desta abstração, não da implementação.
abstract class MedicalRecordsRepository {
  Future<List<MedicalRecordSummaryModel>> buscarProntuarios();
}
