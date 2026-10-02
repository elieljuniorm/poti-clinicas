import '../models/finance_dashboard_model.dart';

/// Contrato do repositório do Financeiro.
/// A camada de aplicação depende desta abstração, não da implementação.
abstract class FinanceRepository {
  Future<FinanceDashboardModel> buscarPainel();
}
