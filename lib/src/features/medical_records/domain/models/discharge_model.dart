/// Motivo de fechamento do prontuário (protocolo de alta).
enum DischargeReason {
  medical('Alta médica'),
  goalsAchieved('Objetivos do tratamento alcançados'),
  patientRequest('A pedido do paciente'),
  abandonment('Abandono do tratamento'),
  transfer('Transferência para outro serviço'),
  other('Outro motivo');

  final String label;

  const DischargeReason(this.label);
}

/// Alta registrada: fecha o prontuário, que passa a ser só leitura e não
/// recebe novas evoluções. O status do paciente vira "Alta Médica".
class DischargeModel {
  final DischargeReason reason;

  /// Relato do motivo, escrito por quem registrou a alta.
  final String description;
  final DateTime date;
  final String professionalName;

  const DischargeModel({
    required this.reason,
    required this.description,
    required this.date,
    required this.professionalName,
  });
}
