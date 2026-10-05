import '../dtos/new_appointment_dto.dart';
import '../dtos/scheduling_appointment_dto.dart';

/// Responsabilidade: fazer a chamada externa real (HTTP, GraphQL, etc.).
/// É o único lugar que "sabe" que existe uma API.
///
/// Simula a API com uma lista em memória: os atendimentos criados e
/// editados nesta sessão aparecem nas próximas buscas.
class SchedulingDataSource {
  /// "Agora" da simulação (os testes fixam a data).
  final DateTime Function() _agora;

  SchedulingDataSource({DateTime Function()? agora})
    : _agora = agora ?? DateTime.now;

  late final List<Map<String, dynamic>> _atendimentos = _exemplos();
  int _proximoId = 100;

  DateTime get _hoje {
    final agora = _agora();
    return DateTime(agora.year, agora.month, agora.day);
  }

  /// Atendimentos de exemplo, com datas relativas a hoje.
  List<Map<String, dynamic>> _exemplos() {
    Map<String, dynamic> atendimento(
      String id,
      int diasDeHoje,
      int hora,
      int minuto, {
      required String pacienteId,
      required String paciente,
      required String profissionalId,
      required String profissional,
      required String tipo,
      required String status,
      String? caso,
    }) {
      final inicio = _hoje.add(
        Duration(days: diasDeHoje, hours: hora, minutes: minuto),
      );
      return {
        'id': id,
        'patient_id': pacienteId,
        'patient_name': paciente,
        'professional_id': profissionalId,
        'professional_name': profissional,
        'type': tipo,
        'clinical_case': ?caso,
        'start': inicio.toIso8601String(),
        'end': inicio.add(const Duration(hours: 1)).toIso8601String(),
        'status': status,
      };
    }

    const juliana = ('2', 'Juliana Mendes Souza');
    const antonio = ('6', 'Antônio Araújo');
    const lucas = ('8', 'Lucas Freitas');
    const arnaldo = ('1', 'Dr. Arnaldo Ribeiro');
    const beatriz = ('3', 'Dra. Beatriz Nogueira');

    return [
      atendimento(
        '1',
        0,
        8,
        30,
        pacienteId: juliana.$1,
        paciente: juliana.$2,
        profissionalId: arnaldo.$1,
        profissional: arnaldo.$2,
        tipo: 'Avaliação',
        status: 'canceled',
      ),
      atendimento(
        '2',
        0,
        10,
        0,
        pacienteId: antonio.$1,
        paciente: antonio.$2,
        profissionalId: arnaldo.$1,
        profissional: arnaldo.$2,
        tipo: 'Saúde do Idoso',
        status: 'pending',
      ),
      atendimento(
        '3',
        0,
        13,
        30,
        pacienteId: juliana.$1,
        paciente: juliana.$2,
        profissionalId: arnaldo.$1,
        profissional: arnaldo.$2,
        tipo: 'Tratamento da Dor',
        status: 'confirmed',
        caso: 'Reabilitação pós-operatória joelho direito',
      ),
      atendimento(
        '4',
        1,
        9,
        15,
        pacienteId: lucas.$1,
        paciente: lucas.$2,
        profissionalId: beatriz.$1,
        profissional: beatriz.$2,
        tipo: 'Pediatria',
        status: 'confirmed',
      ),
      atendimento(
        '5',
        2,
        15,
        0,
        pacienteId: juliana.$1,
        paciente: juliana.$2,
        profissionalId: arnaldo.$1,
        profissional: arnaldo.$2,
        tipo: 'Tratamento da Dor',
        status: 'pending',
      ),
      atendimento(
        '6',
        -1,
        16,
        20,
        pacienteId: antonio.$1,
        paciente: antonio.$2,
        profissionalId: arnaldo.$1,
        profissional: arnaldo.$2,
        tipo: 'Neuromodulação',
        status: 'confirmed',
      ),
      atendimento(
        '7',
        9,
        18,
        0,
        pacienteId: lucas.$1,
        paciente: lucas.$2,
        profissionalId: beatriz.$1,
        profissional: beatriz.$2,
        tipo: 'Pediatria',
        status: 'pending',
      ),
      atendimento(
        '8',
        16,
        10,
        30,
        pacienteId: antonio.$1,
        paciente: antonio.$2,
        profissionalId: arnaldo.$1,
        profissional: arnaldo.$2,
        tipo: 'Saúde do Idoso',
        status: 'canceled',
      ),
    ];
  }

  /// O atendimento entra no período? (dia, semana de domingo a sábado ou
  /// mês de hoje).
  bool _noPeriodo(DateTime inicio, String periodo) {
    final hoje = _hoje;
    final dia = DateTime(inicio.year, inicio.month, inicio.day);
    switch (periodo) {
      case 'week':
        // DateTime.weekday: segunda = 1 … domingo = 7.
        final domingo = hoje.subtract(Duration(days: hoje.weekday % 7));
        final proximoDomingo = domingo.add(const Duration(days: 7));
        return !dia.isBefore(domingo) && dia.isBefore(proximoDomingo);
      case 'month':
        return dia.year == hoje.year && dia.month == hoje.month;
      default:
        return dia == hoje;
    }
  }

  // Simula GET /appointments?period=... com delay de 1 segundo.
  // [periodo] seria o parâmetro da API: 'day', 'week' ou 'month'.
  Future<List<SchedulingAppointmentDto>> buscarAtendimentos(
    String periodo,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    final lista =
        _atendimentos
            .where((a) => _noPeriodo(DateTime.parse(a['start']), periodo))
            .map(SchedulingAppointmentDto.fromJson)
            .toList()
          ..sort((a, b) => a.start.compareTo(b.start));
    return lista;
  }

  // Simula POST /appointments: cada sessão vira um atendimento próprio,
  // sempre com status pendente. Recusa sessão que termina antes de começar.
  Future<void> agendar(NewAppointmentDto agendamento) async {
    await Future.delayed(const Duration(seconds: 1));

    final json = agendamento.toJson();
    final sessoes = json['sessions'] as List<Map<String, String>>;
    for (final sessao in sessoes) {
      if (!DateTime.parse(sessao['end']!)
          .isAfter(DateTime.parse(sessao['start']!))) {
        throw Exception('Sessão com horário inválido');
      }
    }

    for (final sessao in sessoes) {
      _atendimentos.add({
        'id': '${_proximoId++}',
        'patient_id': json['patient_id'],
        'patient_name': json['patient_name'],
        'professional_id': json['professional_id'],
        'professional_name': json['professional_name'],
        'type': json['type'],
        'clinical_case': ?json['clinical_case'],
        'start': sessao['start'],
        'end': sessao['end'],
        'status': 'pending',
      });
    }
  }

  // Simula PUT /appointments/{id}: substitui o atendimento.
  Future<SchedulingAppointmentDto> atualizarAtendimento(
    SchedulingAppointmentDto atendimento,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    final indice = _atendimentos.indexWhere((a) => a['id'] == atendimento.id);
    if (indice == -1) throw Exception('Agendamento não encontrado');
    if (!DateTime.parse(atendimento.end)
        .isAfter(DateTime.parse(atendimento.start))) {
      throw Exception('O fim deve ser depois do início');
    }

    _atendimentos[indice] = atendimento.toJson();
    return SchedulingAppointmentDto.fromJson(_atendimentos[indice]);
  }
}
