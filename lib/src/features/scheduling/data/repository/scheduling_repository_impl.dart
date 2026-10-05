import '../../domain/models/new_appointment_model.dart';
import '../../domain/models/scheduling_appointment_model.dart';
import '../../domain/models/scheduling_period.dart';
import '../../domain/repositories/scheduling_repository.dart';
import '../data_sources/scheduling_remote_data_source.dart';
import '../dtos/new_appointment_dto.dart';

/// Responsabilidade: fazer a ponte entre dados (DTO) e negócio (models).
/// Converte o período para o parâmetro da API e DTO → model.
class SchedulingRepositoryImpl implements SchedulingRepository {
  final SchedulingDataSource _dataSource;

  SchedulingRepositoryImpl(this._dataSource);

  @override
  Future<List<SchedulingAppointmentModel>> buscarAtendimentos(
    SchedulingPeriod periodo,
  ) async {
    final dtos = await _dataSource.buscarAtendimentos(periodo.name);
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<void> agendar(NewAppointmentModel agendamento) {
    return _dataSource.agendar(NewAppointmentDto.fromDomain(agendamento));
  }
}
