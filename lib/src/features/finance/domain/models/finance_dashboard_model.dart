import 'daily_revenue_model.dart';
import 'pre_invoice_model.dart';
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

  /// Pré-faturas dos atendimentos aguardando lançamento, mais antigas primeiro.
  final List<PreInvoiceModel> preInvoices;

  const FinanceDashboardModel({
    this.monthReceived = 0,
    this.monthPending = 0,
    this.week = const [],
    this.professionals = const [],
    this.preInvoices = const [],
  });

  double get monthTotal => monthReceived + monthPending;
}
