import '../../domain/models/daily_appointment_model.dart';
import '../../domain/models/evolution_model.dart';
import '../../domain/models/financial_summary_model.dart';
import '../../domain/repositories/home_repository.dart';
import '../data_sources/home_remote_data_source.dart';

/// Responsabilidade: fazer a ponte entre dados (DTO) e negócio (models).
/// Combina fontes, converte DTO → model. O domínio não conhece DTO.
class HomeRepositoryImpl implements HomeRepository {
  final HomeDataSource _dataSource;

  HomeRepositoryImpl(this._dataSource);

  @override
  Future<List<DailyAppointmentModel>> buscarAtendimentosDoDia() async {
    final dtos = await _dataSource.buscarAtendimentosDoDia();
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<List<EvolutionModel>> buscarEvolucoes() async {
    final dtos = await _dataSource.buscarEvolucoes();
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<List<FinancialSummaryModel>> buscarResumoFinanceiro() async {
    final dtos = await _dataSource.buscarResumoFinanceiro();
    return dtos.map((dto) => dto.toDomain()).toList();
  }
}
