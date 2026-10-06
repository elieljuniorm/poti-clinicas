/// Pré-fatura: sessões já agendadas para um paciente que ainda não foram
/// faturadas. Sempre nasce de um atendimento ("Novo Atendimento" da
/// Agenda) e vira fatura quando o lançamento é finalizado no Financeiro.
class PreInvoiceModel {
  final String id;
  final String patientId;
  final String patientName;
  final String professionalId;
  final String professionalName;

  /// Sessões agendadas sem crédito para cobrir (as que faltam faturar).
  final int sessions;
  final DateTime createdAt;

  const PreInvoiceModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.professionalId,
    required this.professionalName,
    required this.sessions,
    required this.createdAt,
  });
}
