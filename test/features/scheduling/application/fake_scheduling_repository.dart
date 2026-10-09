import 'package:multiclinica_app/src/features/scheduling/domain/models/new_appointment_model.dart';
import 'package:multiclinica_app/src/features/scheduling/domain/models/scheduling_appointment_model.dart';
import 'package:multiclinica_app/src/features/scheduling/domain/models/scheduling_period.dart';
import 'package:multiclinica_app/src/features/scheduling/domain/repositories/scheduling_repository.dart';

class FakeSchedulingRepository implements SchedulingRepository {
  final String? erroAgendar;
  final String? erroAtualizar;
  final List<NewAppointmentModel> agendados = [];
  final List<SchedulingAppointmentModel> atualizados = [];

  /// O que a busca devolve (qualquer período).
  List<SchedulingAppointmentModel> atendimentos;
  int buscas = 0;

  FakeSchedulingRepository({
    this.erroAgendar,
    this.erroAtualizar,
    this.atendimentos = const [],
  });

  @override
  Future<List<SchedulingAppointmentModel>> buscarAtendimentos(
    SchedulingPeriod periodo,
  ) async {
    buscas++;
    return atendimentos;
  }

  @override
  Future<void> agendar(NewAppointmentModel agendamento) async {
    final erro = erroAgendar;
    if (erro != null) throw Exception(erro);
    agendados.add(agendamento);
  }

  @override
  Future<SchedulingAppointmentModel> atualizarAtendimento(
    SchedulingAppointmentModel atendimento,
  ) async {
    final erro = erroAtualizar;
    if (erro != null) throw Exception(erro);
    atualizados.add(atendimento);
    atendimentos = [
      for (final a in atendimentos) a.id == atendimento.id ? atendimento : a,
    ];
    return atendimento;
  }
}
