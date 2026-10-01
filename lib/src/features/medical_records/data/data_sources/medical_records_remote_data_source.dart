import '../dtos/medical_record_summary_dto.dart';

/// Responsabilidade: fazer a chamada externa real (HTTP, GraphQL, etc.).
/// É o único lugar que "sabe" que existe uma API.
class MedicalRecordsDataSource {
  // Simula GET /medical-records com delay de 1 segundo e resposta em JSON.
  // As datas são relativas a hoje para o mock mostrar "Hoje" e "Ontem".
  Future<List<MedicalRecordSummaryDto>> buscarProntuarios() async {
    await Future.delayed(const Duration(seconds: 1));

    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    String sessao(int diasAtras, int hora, int minuto) => hoje
        .subtract(Duration(days: diasAtras))
        .add(Duration(hours: hora, minutes: minuto))
        .toIso8601String();

    final json = [
      {
        'patient_id': '2',
        'patient_name': 'Jorge Silva',
        'specialty': 'Fisioterapia',
        'last_session_at': sessao(0, 13, 30),
        'has_record': true,
        'pending_evolutions': 0,
        'discharged': false,
      },
      {
        'patient_id': '9',
        'patient_name': 'Jonas Santos',
        'specialty': 'Fisioterapia',
        'last_session_at': sessao(1, 15, 0),
        'has_record': true,
        'pending_evolutions': 0,
        'discharged': false,
      },
      {
        'patient_id': '6',
        'patient_name': 'Antônio Araújo',
        'specialty': 'Fisioterapia',
        'last_session_at': sessao(7, 16, 20),
        'has_record': false,
        'pending_evolutions': 0,
        'discharged': false,
      },
      {
        'patient_id': '10',
        'patient_name': 'Maria Clara Rezende',
        'specialty': 'Fisioterapia',
        'last_session_at': sessao(9, 9, 15),
        'has_record': true,
        'pending_evolutions': 0,
        'discharged': false,
      },
      {
        'patient_id': '8',
        'patient_name': 'Lucas Freitas',
        'specialty': 'Terapia Ocupacional',
        'last_session_at': sessao(11, 18, 0),
        'has_record': true,
        'pending_evolutions': 2,
        'discharged': false,
      },
      {
        'patient_id': '11',
        'patient_name': 'Helena Costa',
        'specialty': 'Fisioterapia',
        'last_session_at': sessao(20, 10, 0),
        'has_record': true,
        'pending_evolutions': 0,
        'discharged': true,
      },
      {
        // Recém-cadastrado: sem sessão e sem prontuário.
        'patient_id': '12',
        'patient_name': 'Rita Moura',
        'specialty': 'Fisioterapia',
        'last_session_at': null,
        'has_record': false,
        'pending_evolutions': 0,
        'discharged': false,
      },
    ];

    return json.map(MedicalRecordSummaryDto.fromJson).toList();
  }
}
