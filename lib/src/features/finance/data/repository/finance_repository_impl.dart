import '../../domain/models/finance_dashboard_model.dart';
import '../../domain/repositories/finance_repository.dart';
import '../data_sources/finance_remote_data_source.dart';

/// Responsabilidade: fazer a ponte entre dados (DTO) e negócio (models).
/// Converte DTO → model. O domínio não conhece DTO.
class FinanceRepositoryImpl implements FinanceRepository {
  final FinanceDataSource _dataSource;

  FinanceRepositoryImpl(this._dataSource);

  @override
  Future<FinanceDashboardModel> buscarPainel() async {
    final dto = await _dataSource.buscarPainel();
    return dto.toDomain();
  }
}
