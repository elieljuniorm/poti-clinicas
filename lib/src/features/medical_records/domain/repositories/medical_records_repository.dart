import '../models/discharge_model.dart';
import '../models/evolution_model.dart';
import '../models/medical_record_content.dart';
import '../models/medical_record_create_model.dart';
import '../models/medical_record_details_model.dart';
import '../models/medical_record_summary_model.dart';

/// Contrato do repositório do Prontuário.
/// A camada de aplicação depende desta abstração, não da implementação.
abstract class MedicalRecordsRepository {
  Future<List<MedicalRecordSummaryModel>> buscarProntuarios();

  /// Paciente, prontuário e evolução mais recente.
  Future<MedicalRecordDetailsModel> buscarProntuario(String patientId);
  Future<MedicalRecordDetailsModel> criarProntuario(
    String patientId,
    MedicalRecordCreateModel prontuario,
  );

  /// Edita a anamnese; a data de última modificação é atualizada.
  Future<MedicalRecordDetailsModel> atualizarProntuario(
    String patientId,
    MedicalRecordContent anamnese,
  );

  /// Nova evolução: passa a ser a mais recente e pode tirar a pendência.
  Future<MedicalRecordDetailsModel> registrarEvolucao(
    String patientId,
    EvolutionCreateModel evolucao,
  );

  /// Protocolo de alta: fecha o prontuário com o [motivo] relatado.
  Future<MedicalRecordDetailsModel> registrarAlta(
    String patientId, {
    required DischargeReason motivo,
    required String descricao,
  });
}
