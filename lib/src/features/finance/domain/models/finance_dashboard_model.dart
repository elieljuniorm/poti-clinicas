import 'daily_revenue_model.dart';
import 'professional_payout_model.dart';

/// Tudo o que a tela Financeiro mostra.
class FinanceDashboardModel {
  /// Faturamento do mês já recebido.
  final double monthReceived;

  /// Faturamento do mês ainda pendente.
  final double monthPending;

  /// Faturamento por dia da semana atual (Seg → Dom).
  final List<DailyRevenueModel> week;

  /// Repasse por profissional, do maior para o menor.
  final List<ProfessionalPayoutModel> professionals;

  const FinanceDashboardModel({
    this.monthReceived = 0,
    this.monthPending = 0,
    this.week = const [],
    this.professionals = const [],
  });

  double get monthTotal => monthReceived + monthPending;
}
