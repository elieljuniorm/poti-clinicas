import '../dtos/scheduling_appointment_dto.dart';

/// Responsabilidade: fazer a chamada externa real (HTTP, GraphQL, etc.).
/// É o único lugar que "sabe" que existe uma API.
class SchedulingDataSource {
  // Simula a chamada de API com delay de 1 segundo e resposta em JSON.
  // [periodo] seria o parâmetro da API: 'day', 'week' ou 'month'.
  Future<List<SchedulingAppointmentDto>> buscarAtendimentos(
    String periodo,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    const dia = [
      {
        'date': '02/02',
        'time': '08:30',
        'patient_name': 'Jorge Silva',
        'type': 'Avaliação',
        'status': 'canceled',
      },
      {
        'date': '02/02',
        'time': '10:00',
        'patient_name': 'Antônio Marcos',
        'type': 'Saúde do Idoso',
        'status': 'pending',
      },
      {
        'date': '02/02',
        'time': '13:30',
        'patient_name': 'Raimundo Santos',
        'type': 'Avaliação',
        'status': 'confirmed',
      },
    ];

    const semana = [
      ...dia,
      {
        'date': '04/02',
        'time': '09:15',
        'patient_name': 'Maria Clara Rezende',
        'type': 'Pediatria',
        'status': 'confirmed',
      },
      {
        'date': '06/02',
        'time': '15:00',
        'patient_name': 'Jonas Santos',
        'type': 'Tratamento da dor',
        'status': 'pending',
      },
    ];

    const mes = [
      ...semana,
      {
        'date': '12/02',
        'time': '16:20',
        'patient_name': 'Antônio Araújo',
        'type': 'Neuromodulação',
        'status': 'confirmed',
      },
      {
        'date': '19/02',
        'time': '18:00',
        'patient_name': 'Lucas Freitas',
        'type': 'Pediatria',
        'status': 'canceled',
      },
      {
        'date': '26/02',
        'time': '19:30',
        'patient_name': 'Hery Nunes',
        'type': 'Saúde do Idoso',
        'status': 'pending',
      },
    ];

    final json = switch (periodo) {
      'week' => semana,
      'month' => mes,
      _ => dia,
    };

    return json.map(SchedulingAppointmentDto.fromJson).toList();
  }
}
