import '../../../home/domain/models/financial_summary_model.dart';
import '../../domain/models/appointment_history_model.dart';
import '../../domain/repositories/history_repository.dart';
import '../data_sources/history_remote_data_source.dart';

/// Responsabilidade: fazer a ponte entre dados (DTO) e negócio (models).
/// Converte DTO → model. O domínio não conhece DTO.
class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryDataSource _dataSource;

  HistoryRepositoryImpl(this._dataSource);

  @override
  Future<List<AppointmentHistoryModel>> buscarAtendimentos() async {
    final dtos = await _dataSource.buscarAtendimentos();
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<List<FinancialSummaryModel>> buscarLancamentos() async {
    final dtos = await _dataSource.buscarLancamentos();
    return dtos.map((dto) => dto.toDomain()).toList();
  }
}
