import '../../../home/domain/models/financial_summary_model.dart';

/// Totais do card "TOTAL A RECEBER": soma dos lançamentos,
/// separada em recebido (pago) e pendente.
class FinancialOverviewModel {
  final double received;
  final double pending;

  const FinancialOverviewModel({this.received = 0, this.pending = 0});

  factory FinancialOverviewModel.fromEntries(
    List<FinancialSummaryModel> entries,
  ) {
    var received = 0.0;
    var pending = 0.0;
    for (final entry in entries) {
      if (entry.status == PaymentStatus.paid) {
        received += entry.amount;
      } else {
        pending += entry.amount;
      }
    }
    return FinancialOverviewModel(received: received, pending: pending);
  }

  double get total => received + pending;
}
