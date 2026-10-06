/// Sessões de um novo atendimento enviadas ao Financeiro para faturar.
class AppointmentBillingModel {
  final String patientId;
  final String patientName;
  final String professionalId;
  final String professionalName;
  final int sessions;

  const AppointmentBillingModel({
    required this.patientId,
    required this.patientName,
    required this.professionalId,
    required this.professionalName,
    required this.sessions,
  });
}

/// Como as sessões do atendimento foram faturadas.
///
/// Os créditos de agendamento do paciente (de faturas lançadas antes do
/// atendimento) são usados primeiro; só o que sobra vai para a pré-fatura.
class AppointmentBillingResult {
  /// Sessões cobertas por créditos de agendamento.
  final int creditsUsed;

  /// Sessões que entraram na pré-fatura (0 quando os créditos cobriram tudo).
  final int pendingSessions;

  const AppointmentBillingResult({
    required this.creditsUsed,
    required this.pendingSessions,
  });
}
