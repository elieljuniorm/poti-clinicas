/// Faturamento de um dia da semana (ponto do gráfico).
class DailyRevenueModel {
  /// Dia abreviado (ex.: "Seg").
  final String day;
  final double amount;

  const DailyRevenueModel({required this.day, required this.amount});
}
