import 'package:flutter_test/flutter_test.dart';
import 'package:multiclinica_app/src/features/history/domain/models/financial_overview_model.dart';
import 'package:multiclinica_app/src/features/home/domain/models/financial_summary_model.dart';

FinancialSummaryModel lancamento(double valor, PaymentStatus status) =>
    FinancialSummaryModel(
      date: '26 Out, 2025',
      time: '14:30',
      patient: 'Paciente',
      appointmentType: 'Pediatria',
      paymentMethod: 'PIX',
      amount: valor,
      status: status,
    );

void main() {
  test('separa recebido (pago) de pendente e soma o total', () {
    final overview = FinancialOverviewModel.fromEntries([
      lancamento(350, PaymentStatus.paid),
      lancamento(150, PaymentStatus.paid),
      lancamento(400, PaymentStatus.pending),
    ]);

    expect(overview.received, 500);
    expect(overview.pending, 400);
    expect(overview.total, 900);
  });

  test('sem lançamentos: tudo zero', () {
    final overview = FinancialOverviewModel.fromEntries(const []);

    expect(overview.total, 0);
  });
}
