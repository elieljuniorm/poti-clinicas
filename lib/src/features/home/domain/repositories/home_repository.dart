import '../models/daily_appointment_model.dart';
import '../models/evolution_model.dart';
import '../models/financial_summary_model.dart';

/// Contrato do repositório da Home.
/// A camada de aplicação depende desta abstração, não da implementação.
abstract class HomeRepository {
  Future<List<DailyAppointmentModel>> buscarAtendimentosDoDia();
  Future<List<EvolutionModel>> buscarEvolucoes();
  Future<List<FinancialSummaryModel>> buscarResumoFinanceiro();
}
