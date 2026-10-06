import '../models/appointment_billing_model.dart';
import '../models/finance_dashboard_model.dart';
import '../models/new_invoice_model.dart';

/// Contrato do repositório do Financeiro.
/// A camada de aplicação depende desta abstração, não da implementação.
abstract class FinanceRepository {
  Future<FinanceDashboardModel> buscarPainel();

  /// Créditos de agendamento que o paciente ainda tem para usar.
  Future<int> buscarCreditos(String patientId);

  /// Fatura as sessões de um novo atendimento: usa os créditos do
  /// paciente e manda o restante para a pré-fatura.
  Future<AppointmentBillingResult> vincularAtendimento(
    AppointmentBillingModel atendimento,
  );

  /// Lança a fatura (finalizando a pré-fatura, se houver) e devolve
  /// quantos créditos de agendamento o paciente ganhou.
  Future<int> lancarFatura(NewInvoiceModel fatura);
}
