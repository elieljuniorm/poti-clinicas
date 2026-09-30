import '../dtos/user_details_dto.dart';
import '../dtos/user_dto.dart';

/// Responsabilidade: fazer a chamada externa real (HTTP, GraphQL, etc.).
/// É o único lugar que "sabe" que existe uma API.
class UsersDataSource {
  // Simula a chamada de API com delay de 1 segundo e resposta em JSON.
  Future<List<UserDto>> buscarUsuarios() async {
    await Future.delayed(const Duration(seconds: 1));

    const json = [
      {
        'id': '1',
        'name': 'Dr. Arnaldo Ribeiro',
        'email': 'arnaldo.ribeiro@5f.com',
        'phone': '(91) 9 8455-1212',
        'role': 'professional',
        'description': 'Fisioterapeuta',
        'status': 'active',
        'photo_url': null,
      },
      {
        'id': '2',
        'name': 'Juliana Mendes Souza',
        'email': 'juliana.mendes@gmail.com',
        'phone': '(91) 9 9211-4566',
        'role': 'patient',
        'description': 'Tratamento da Dor',
        'status': 'active',
        'photo_url': null,
      },
      {
        'id': '3',
        'name': 'Dra. Beatriz Nogueira',
        'email': 'beatriz.nogueira@5f.com',
        'phone': '(91) 9 8122-9900',
        'role': 'professional',
        'description': 'Terapia Ocupacional',
        'status': 'active',
        'photo_url': null,
      },
      {
        'id': '4',
        'name': 'Carlos Eduardo Silva',
        'email': 'carlos.silva@5f.com',
        'phone': '(91) 9 8800-3344',
        'role': 'admin',
        'description': null,
        'status': 'active',
        'photo_url': null,
      },
      {
        'id': '5',
        'name': 'Fernanda Lima',
        'email': 'fernanda.lima@5f.com',
        'phone': '(91) 9 8765-4321',
        'role': 'reception',
        'description': null,
        'status': 'active',
        'photo_url': null,
      },
      {
        'id': '6',
        'name': 'Antônio Araújo',
        'email': 'antonio.araujo@gmail.com',
        'phone': '(91) 9 9100-2020',
        'role': 'patient',
        'description': 'Neuromodulação',
        'status': 'inactive',
        'photo_url': null,
      },
      {
        'id': '7',
        'name': 'Rafael Costa',
        'email': 'rafael.costa@5f.com',
        'phone': '(91) 9 8333-7788',
        'role': 'collaborator',
        'description': 'Financeiro',
        'status': 'active',
        'photo_url': null,
      },
    ];

    return json.map(UserDto.fromJson).toList();
  }

  // Simula GET /users/{id}/details. Cada perfil recebe só os blocos dele.
  Future<UserDetailsDto> buscarDetalhes(String userId) async {
    await Future.delayed(const Duration(seconds: 1));

    const sessoesFisioterapia = [
      {
        'title': 'Sessão de fisioterapia',
        'date': '12/07/2025',
        'note': 'Ganho gradual de amplitude',
      },
      {
        'title': 'Sessão de fisioterapia',
        'date': '05/07/2025',
        'note': 'Evolução positiva',
      },
      {
        'title': 'Sessão de fisioterapia',
        'date': '28/06/2025',
        'note': 'Boa resposta ao tratamento',
      },
    ];

    const json = <String, Map<String, dynamic>>{
      // Profissionais
      '1': {
        'professional_info': {
          'specialty': 'Fisioterapeuta',
          'registry': 'CREFITO-12 123456-F',
          'bond': 'Contratado (CLT)',
          'since': '10/01/2023',
        },
        'upcoming_appointments': [
          {
            'date': '02/02',
            'time': '08:30',
            'patient_name': 'Jorge Silva',
            'type': 'Avaliação',
          },
          {
            'date': '02/02',
            'time': '13:30',
            'patient_name': 'Raimundo Santos',
            'type': 'Avaliação',
          },
          {
            'date': '04/02',
            'time': '09:15',
            'patient_name': 'Juliana Mendes Souza',
            'type': 'Tratamento da Dor',
          },
        ],
        'month_summary': {
          'performed': 42,
          'scheduled': 18,
          'active_patients': 23,
        },
      },
      '3': {
        'professional_info': {
          'specialty': 'Terapeuta Ocupacional',
          'registry': 'CREFITO-12 654321-TO',
          'bond': 'Autônoma',
          'since': '03/05/2024',
        },
        'upcoming_appointments': [
          {
            'date': '03/02',
            'time': '10:00',
            'patient_name': 'Lucas Freitas',
            'type': 'Pediatria',
          },
        ],
        'month_summary': {
          'performed': 27,
          'scheduled': 9,
          'active_patients': 14,
        },
      },
      // Pacientes
      '2': {
        'contract': {
          'name': 'Pacote Domiciliar',
          'start_date': '15/03/2025',
          'end_date': '15/09/2025',
          'status': 'active',
          'file_name': 'Contrato de Serviços.pdf',
        },
        'recent_sessions': sessoesFisioterapia,
        'consumption': {
          'contracted': 20,
          'performed': 12,
          'session_value': 180.00,
          'payment_method': 'PIX',
        },
      },
      '6': {
        'contract': {
          'name': 'Pacote Clínica',
          'start_date': '10/01/2025',
          'end_date': '10/04/2025',
          'status': 'expired',
          'file_name': 'Contrato de Serviços.pdf',
        },
        'recent_sessions': [
          {
            'title': 'Sessão de neuromodulação',
            'date': '08/04/2025',
            'note': 'Alta do tratamento',
          },
        ],
        'consumption': {
          'contracted': 10,
          'performed': 10,
          'session_value': 220.00,
          'payment_method': 'Cartão de Crédito',
        },
      },
      // Equipe interna
      '4': {
        'access_info': {
          'area': 'Administração',
          'since': '01/02/2022',
          'last_access': '30/09/2026 às 08:12',
        },
      },
      '5': {
        'access_info': {
          'area': 'Recepção',
          'since': '15/08/2023',
          'last_access': '30/09/2026 às 07:45',
        },
      },
      '7': {
        'access_info': {
          'area': 'Financeiro',
          'since': '20/11/2024',
          'last_access': '29/09/2026 às 17:30',
        },
      },
    };

    return UserDetailsDto.fromJson(json[userId] ?? const {});
  }
}
