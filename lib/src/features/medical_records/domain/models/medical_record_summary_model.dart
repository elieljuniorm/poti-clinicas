import 'medical_record_status.dart';

/// Linha da lista do prontuário: um paciente e a situação do registro dele.
///
/// O [status] não vem pronto: é calculado a partir de [hasRecord],
/// [pendingEvolutions] e [discharged]. Quando as outras telas mudarem esses
/// dados (criar prontuário, registrar evolução, dar alta), o status muda junto.
class MedicalRecordSummaryModel {
  final String patientId;
  final String patientName;

  /// Especialidade do atendimento (ex.: "Fisioterapia").
  final String specialty;

  /// Data e hora da última sessão. `null` se nenhuma foi realizada.
  final DateTime? lastSession;

  /// Prontuário já criado.
  final bool hasRecord;

  /// Atendimentos realizados sem evolução registrada.
  final int pendingEvolutions;

  /// Paciente recebeu alta.
  final bool discharged;

  const MedicalRecordSummaryModel({
    required this.patientId,
    required this.patientName,
    required this.specialty,
    this.lastSession,
    this.hasRecord = false,
    this.pendingEvolutions = 0,
    this.discharged = false,
  });

  /// Regra, em ordem de prioridade:
  /// 1. Evolução pendente → [MedicalRecordStatus.pending] (a restrição
  ///    aparece mesmo se o paciente estiver sem prontuário ou com alta).
  /// 2. Sem prontuário → [MedicalRecordStatus.newPatient].
  /// 3. Com alta → [MedicalRecordStatus.discharged].
  /// 4. Senão → [MedicalRecordStatus.inTherapy].
  MedicalRecordStatus get status {
    if (pendingEvolutions > 0) return MedicalRecordStatus.pending;
    if (!hasRecord) return MedicalRecordStatus.newPatient;
    if (discharged) return MedicalRecordStatus.discharged;
    return MedicalRecordStatus.inTherapy;
  }
}
