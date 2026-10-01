import '../../../home/domain/models/financial_summary_model.dart';
import '../models/appointment_history_model.dart';

/// Contrato do repositório do Histórico.
/// A camada de aplicação depende desta abstração, não da implementação.
abstract class HistoryRepository {
  Future<List<AppointmentHistoryModel>> buscarAtendimentos();

  /// Lançamentos financeiros, do mais recente para o mais antigo.
  Future<List<FinancialSummaryModel>> buscarLancamentos();
}
