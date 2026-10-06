import '../../domain/models/appointment_billing_model.dart';
import '../../domain/models/finance_dashboard_model.dart';
import '../../domain/models/new_invoice_model.dart';
import '../../domain/repositories/finance_repository.dart';
import '../data_sources/finance_remote_data_source.dart';
import '../dtos/appointment_billing_dto.dart';
import '../dtos/new_invoice_dto.dart';

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

  @override
  Future<int> buscarCreditos(String patientId) {
    return _dataSource.buscarCreditos(patientId);
  }

  @override
  Future<AppointmentBillingResult> vincularAtendimento(
    AppointmentBillingModel atendimento,
  ) async {
    final dto = await _dataSource.vincularAtendimento(
      AppointmentBillingDto.fromDomain(atendimento),
    );
    return dto.toDomain();
  }

  @override
  Future<int> lancarFatura(NewInvoiceModel fatura) {
    return _dataSource.lancarFatura(NewInvoiceDto.fromDomain(fatura));
  }
}
