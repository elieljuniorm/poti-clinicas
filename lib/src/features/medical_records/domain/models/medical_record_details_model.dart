import 'discharge_model.dart';
import 'evolution_model.dart';
import 'medical_record_model.dart';
import 'medical_record_summary_model.dart';

/// Tudo o que as telas do prontuário de um paciente mostram: os dados do
/// paciente (com o status, calculado em [summary]), o prontuário e a
/// evolução mais recente.
class MedicalRecordDetailsModel {
  final MedicalRecordSummaryModel summary;
  final String email;

  /// Profissional responsável pelo paciente.
  final String professionalName;

  /// Sessões realizadas até agora (a última é a de número [sessionCount]).
  final int sessionCount;

  /// `null` enquanto o prontuário não foi criado.
  final MedicalRecordModel? record;
  final EvolutionModel? latestEvolution;

  /// Alta registrada no protocolo de alta. `null` com o prontuário aberto.
  final DischargeModel? discharge;

  const MedicalRecordDetailsModel({
    required this.summary,
    required this.email,
    required this.professionalName,
    this.sessionCount = 0,
    this.record,
    this.latestEvolution,
    this.discharge,
  });
}
