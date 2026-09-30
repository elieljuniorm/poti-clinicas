/// Resumo de uma sessão recente do paciente.
class SessionSummaryModel {
  final String title;
  final String date;
  final String note;

  const SessionSummaryModel({
    required this.title,
    required this.date,
    required this.note,
  });
}
