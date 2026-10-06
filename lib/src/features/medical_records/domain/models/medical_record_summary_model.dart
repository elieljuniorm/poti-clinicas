import 'medical_record_status.dart';

/// Linha da lista do prontuário: um paciente e a situação do registro dele.
///
/// O prontuário é a ficha completa do paciente, criada no primeiro
/// atendimento junto com a primeira evolução; cada sessão seguinte gera
/// uma nova evolução.
///
/// O [status] não vem pronto: é calculado a partir de [lastSession],
/// [hasRecord], [pendingEvolutionSince] e [discharged]. Quando as outras
/// telas mudarem esses dados (criar prontuário, registrar evolução, fechar
/// o prontuário), o status muda junto.
class MedicalRecordSummaryModel {
  /// Tempo para registrar a evolução de uma sessão realizada antes de o
  /// paciente ficar pendente.
  static const prazoEvolucao = Duration(hours: 24);

  final String patientId;
  final String patientName;

  /// Especialidade do atendimento (ex.: "Fisioterapia").
  final String specialty;

  /// Data e hora da última sessão realizada. `null` se nenhuma foi.
  final DateTime? lastSession;

  /// Prontuário já criado.
  final bool hasRecord;

  /// Data da sessão realizada mais antiga que ainda não tem evolução.
  /// `null` quando todas as sessões têm evolução registrada.
  final DateTime? pendingEvolutionSince;

  /// Prontuário fechado (alta médica ou outro motivo relatado nele).
  final bool discharged;

  const MedicalRecordSummaryModel({
    required this.patientId,
    required this.patientName,
    required this.specialty,
    this.lastSession,
    this.hasRecord = false,
    this.pendingEvolutionSince,
    this.discharged = false,
  });

  /// Status agora. Muda sozinho quando o prazo da evolução vence.
  MedicalRecordStatus get status => statusEm(DateTime.now());

  /// Regra, em ordem de prioridade:
  /// 1. Prontuário fechado → [MedicalRecordStatus.discharged].
  /// 2. Nenhuma sessão realizada → [MedicalRecordStatus.newPatient].
  /// 3. Sessão realizada sem prontuário → [MedicalRecordStatus.pending].
  /// 4. Sessão sem evolução há mais de [prazoEvolucao] →
  ///    [MedicalRecordStatus.pending].
  /// 5. Senão (prontuário e evoluções em dia) →
  ///    [MedicalRecordStatus.inTherapy]. Uma sessão de menos de 24h ainda
  ///    sem evolução está dentro do prazo.
  MedicalRecordStatus statusEm(DateTime agora) {
    if (discharged) return MedicalRecordStatus.discharged;
    if (lastSession == null) return MedicalRecordStatus.newPatient;
    if (!hasRecord) return MedicalRecordStatus.pending;

    final pendenteDesde = pendingEvolutionSince;
    if (pendenteDesde != null &&
        agora.difference(pendenteDesde) > prazoEvolucao) {
      return MedicalRecordStatus.pending;
    }
    return MedicalRecordStatus.inTherapy;
  }
}
