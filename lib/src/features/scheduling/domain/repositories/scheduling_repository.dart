import '../models/new_appointment_model.dart';
import '../models/scheduling_appointment_model.dart';
import '../models/scheduling_period.dart';

/// Contrato do repositório da Agenda.
/// A camada de aplicação depende desta abstração, não da implementação.
abstract class SchedulingRepository {
  Future<List<SchedulingAppointmentModel>> buscarAtendimentos(
    SchedulingPeriod periodo,
  );

  /// Agenda as sessões do paciente com o profissional.
  Future<void> agendar(NewAppointmentModel agendamento);
}
