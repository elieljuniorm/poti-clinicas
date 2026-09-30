/// Resumo do mês de um profissional.
class MonthSummaryModel {
  final int performed;
  final int scheduled;
  final int activePatients;

  const MonthSummaryModel({
    required this.performed,
    required this.scheduled,
    required this.activePatients,
  });
}
