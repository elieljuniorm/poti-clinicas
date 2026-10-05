import 'package:poti_5f/src/features/scheduling/domain/models/new_appointment_model.dart';
import 'package:poti_5f/src/features/scheduling/domain/models/scheduling_appointment_model.dart';
import 'package:poti_5f/src/features/scheduling/domain/models/scheduling_period.dart';
import 'package:poti_5f/src/features/scheduling/domain/repositories/scheduling_repository.dart';

class FakeSchedulingRepository implements SchedulingRepository {
  final String? erroAgendar;
  final List<NewAppointmentModel> agendados = [];
  int buscas = 0;

  FakeSchedulingRepository({this.erroAgendar});

  @override
  Future<List<SchedulingAppointmentModel>> buscarAtendimentos(
    SchedulingPeriod periodo,
  ) async {
    buscas++;
    return const [];
  }

  @override
  Future<void> agendar(NewAppointmentModel agendamento) async {
    final erro = erroAgendar;
    if (erro != null) throw Exception(erro);
    agendados.add(agendamento);
  }
}
