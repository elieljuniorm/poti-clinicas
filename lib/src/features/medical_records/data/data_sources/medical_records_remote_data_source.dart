import '../dtos/medical_record_details_dto.dart';
import '../dtos/medical_record_summary_dto.dart';

/// Responsabilidade: fazer a chamada externa real (HTTP, GraphQL, etc.).
/// É o único lugar que "sabe" que existe uma API.
class MedicalRecordsDataSource {
  /// Pacientes com o prontuário (simula o banco da API). As datas são
  /// relativas à criação para o mock mostrar "Hoje" e "Ontem"; criar e
  /// editar prontuários mudam esta lista.
  late final List<Map<String, dynamic>> _pacientes = _pacientesIniciais(
    DateTime.now(),
  );

  // Simula GET /medical-records com delay de 1 segundo e resposta em JSON.
  Future<List<MedicalRecordSummaryDto>> buscarProntuarios() async {
    await Future.delayed(const Duration(seconds: 1));

    return _pacientes.map(MedicalRecordSummaryDto.fromJson).toList();
  }

  // Simula GET /medical-records/{patientId}.
  Future<MedicalRecordDetailsDto> buscarProntuario(String patientId) async {
    await Future.delayed(const Duration(seconds: 1));

    return MedicalRecordDetailsDto.fromJson(_paciente(patientId));
  }

  // Simula POST /medical-records/{patientId}. A evolução, quando vem,
  // é da última sessão realizada e tira a pendência de evolução.
  Future<MedicalRecordDetailsDto> criarProntuario(
    String patientId,
    Map<String, dynamic> json,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    final paciente = _paciente(patientId);
    if (paciente['record'] != null) {
      throw Exception('Este paciente já tem prontuário');
    }

    final evolucao = json['evolution'] as Map<String, dynamic>?;
    if (evolucao != null && paciente['last_session_at'] == null) {
      throw Exception('Nenhuma sessão realizada para registrar a evolução');
    }

    final agora = DateTime.now().toIso8601String();
    paciente['has_record'] = true;
    paciente['record'] = {
      'created_at': agora,
      'updated_at': agora,
      'content': json['content'],
    };
    if (evolucao != null) {
      paciente['latest_evolution'] = {
        'session_number': paciente['session_count'],
        'session_date': paciente['last_session_at'],
        'professional_name': paciente['professional_name'],
        'description': evolucao['description'],
      };
      paciente['pending_evolution_since'] = null;
    }
    return MedicalRecordDetailsDto.fromJson(paciente);
  }

  // Simula PUT /medical-records/{patientId}.
  Future<MedicalRecordDetailsDto> atualizarProntuario(
    String patientId,
    Map<String, dynamic> conteudo,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    final paciente = _paciente(patientId);
    final record = paciente['record'] as Map<String, dynamic>?;
    if (record == null) {
      throw Exception('Este paciente ainda não tem prontuário');
    }

    record['content'] = conteudo;
    record['updated_at'] = DateTime.now().toIso8601String();
    return MedicalRecordDetailsDto.fromJson(paciente);
  }

  // Simula POST /medical-records/{patientId}/discharge. Fecha o
  // prontuário: o status vira "Alta Médica".
  Future<MedicalRecordDetailsDto> registrarAlta(
    String patientId,
    Map<String, dynamic> json,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    final paciente = _paciente(patientId);
    if (paciente['record'] == null) {
      throw Exception('Crie o prontuário antes de registrar a alta');
    }
    if (paciente['discharged'] == true) {
      throw Exception('A alta deste paciente já foi registrada');
    }

    paciente['discharged'] = true;
    paciente['discharge'] = {
      'reason': json['reason'],
      'description': json['description'],
      'discharged_at': DateTime.now().toIso8601String(),
      'professional_name': paciente['professional_name'],
    };
    return MedicalRecordDetailsDto.fromJson(paciente);
  }

  Map<String, dynamic> _paciente(String patientId) {
    for (final paciente in _pacientes) {
      if (paciente['patient_id'] == patientId) return paciente;
    }
    throw Exception('Paciente não encontrado');
  }

  static List<Map<String, dynamic>> _pacientesIniciais(DateTime agora) {
    final hoje = DateTime(agora.year, agora.month, agora.day);
    String data(int diasAtras, [int hora = 0, int minuto = 0]) => hoje
        .subtract(Duration(days: diasAtras))
        .add(Duration(hours: hora, minutes: minuto))
        .toIso8601String();

    Map<String, dynamic> prontuario(
      int criadoHaDias, {
      int? modificadoHaDias,
      required Map<String, Map<String, String>> conteudo,
    }) => {
      'created_at': data(criadoHaDias, 9),
      'updated_at': data(modificadoHaDias ?? criadoHaDias, 9),
      'content': conteudo,
    };

    Map<String, dynamic> evolucao(
      int numero,
      String sessao,
      String profissional,
      String descricao,
    ) => {
      'session_number': numero,
      'session_date': sessao,
      'professional_name': profissional,
      'description': descricao,
    };

    const lombar = {
      'anamnesis': {
        'chief_complaint':
            'Formigamento e dormência no pé direito ao permanecer sentado '
            'por mais de 30 minutos.',
        'secondary_complaint':
            'Dor lombar ao final do dia, pior após longos períodos em pé.',
        'medical_diagnosis':
            'Hérnia de disco L4-L5 extrusa com compressão radicular '
            'confirmada por ressonância magnética.',
        'disease_history':
            'Diabetes tipo 2 diagnosticada em 2018, hipertensão arterial '
            'controlada desde 2020, episódio de lombalgia aguda em 2021 '
            'tratado com fisioterapia.',
        'range_of_motion':
            'Flexão lombar limitada a 40° (normal 60°), extensão lombar 15° '
            '(normal 25°), elevação de perna reta direita positiva a 35°, '
            'esquerda 70°.',
        'exams':
            'Ressonância magnética lombar (15/03/2024), raio-X coluna lombar '
            'AP e perfil (10/01/2024), eletroneuromiografia de MMII '
            '(20/02/2024).',
        'surgeries':
            'Artroscopia de joelho direito em 2019 (meniscectomia parcial '
            'medial).',
        'medications':
            'Metformina 850mg 2x/dia, Losartana 50mg 1x/dia, Dipirona 500mg '
            'se dor (SOS).',
        'family_history':
            'Pai com histórico de hérnia de disco, mãe diabética tipo 2, avó '
            'materna com artrose de joelho bilateral.',
        'restrictions':
            'Evitar flexão de tronco com carga, movimentos de rotação brusca '
            'da coluna, impacto axial e corrida até liberação médica.',
      },
      'physical_assessment': {
        'activities':
            'Caminhada leve 3x/semana, trabalho administrativo com longos '
            'períodos sentado, academia 2x/semana (pausado desde o início '
            'dos sintomas).',
        'postural_assessment':
            'Hiperlordose lombar, anteriorização de cabeça, protrusão de '
            'ombros, rotação interna de quadril bilateral.',
        'muscle_strength':
            'Grau 4 em flexores de quadril bilateral, grau 3 em extensores '
            'lombares, grau 4+ em quadríceps bilateral, grau 3 em glúteo '
            'médio direito.',
      },
      'therapeutic_plan': {
        'scales':
            'EVA 6/10 na avaliação; Oswestry 38% (incapacidade moderada).',
        'goals':
            'Reduzir dor lombar, restaurar amplitude de movimento da coluna '
            'lombar, fortalecer musculatura estabilizadora do core e retorno '
            'às atividades laborais em 8 semanas.',
        'general_notes':
            'Paciente motivado, boa adesão ao tratamento. Relata piora dos '
            'sintomas ao final do dia de trabalho. Apresenta medo de '
            'movimento (cinesiofobia leve). Encaminhado pelo Dr. Ricardo '
            'Mendes - ortopedista.',
      },
    };

    const joelho = {
      'anamnesis': {
        'chief_complaint': 'Dor no joelho esquerdo ao subir escadas.',
        'medical_diagnosis': 'Condromalácia patelar grau II.',
        'range_of_motion': 'Flexão do joelho esquerdo 110° (normal 135°).',
      },
      'therapeutic_plan': {
        'goals': 'Fortalecer quadríceps e retornar à corrida em 10 semanas.',
      },
    };

    const melhora =
        'Paciente relata melhora expressiva da dor (EVA 3/10). Realizada '
        'mobilização articular passiva e exercícios ativos livres para '
        'fortalecimento de glúteos e abdômen. Boa tolerância às cargas.';

    return [
      {
        // Sessão de hoje ainda sem evolução: dentro do prazo de 24h.
        'patient_id': '2',
        'patient_name': 'Jorge Silva',
        'email': 'jorge.silva@email.com',
        'specialty': 'Fisioterapia',
        'professional_name': 'Arnaldo Ribeiro',
        'session_count': 12,
        'last_session_at': data(0, 13, 30),
        'has_record': true,
        'pending_evolution_since': data(0, 13, 30),
        'discharged': false,
        'record': prontuario(60, modificadoHaDias: 7, conteudo: lombar),
        'latest_evolution': evolucao(
          11,
          data(7, 13, 30),
          'Arnaldo Ribeiro',
          melhora,
        ),
      },
      {
        'patient_id': '9',
        'patient_name': 'Jonas Santos',
        'email': 'jonas.santos@email.com',
        'specialty': 'Fisioterapia',
        'professional_name': 'Arnaldo Ribeiro',
        'session_count': 5,
        'last_session_at': data(1, 15),
        'has_record': true,
        'pending_evolution_since': null,
        'discharged': false,
        'record': prontuario(30, conteudo: joelho),
        'latest_evolution': evolucao(
          5,
          data(1, 15),
          'Arnaldo Ribeiro',
          'Ganho de 10° na flexão do joelho. Mantidos exercícios em cadeia '
              'cinética fechada.',
        ),
      },
      {
        // Teve sessão, mas o prontuário não foi criado.
        'patient_id': '6',
        'patient_name': 'Antônio Araújo',
        'email': 'antonio.araujo@gmail.com',
        'specialty': 'Fisioterapia',
        'professional_name': 'Arnaldo Ribeiro',
        'session_count': 1,
        'last_session_at': data(7, 16, 20),
        'has_record': false,
        'pending_evolution_since': data(7, 16, 20),
        'discharged': false,
        'record': null,
        'latest_evolution': null,
      },
      {
        'patient_id': '10',
        'patient_name': 'Maria Clara Rezende',
        'email': 'mariaclara@email.com',
        'specialty': 'Fisioterapia',
        'professional_name': 'Arnaldo Ribeiro',
        'session_count': 8,
        'last_session_at': data(9, 9, 15),
        'has_record': true,
        'pending_evolution_since': null,
        'discharged': false,
        'record': prontuario(45, modificadoHaDias: 20, conteudo: lombar),
        'latest_evolution': evolucao(
          8,
          data(9, 9, 15),
          'Arnaldo Ribeiro',
          melhora,
        ),
      },
      {
        // Sessões sem evolução há mais de 24h.
        'patient_id': '8',
        'patient_name': 'Lucas Freitas',
        'email': 'lucas.freitas@gmail.com',
        'specialty': 'Terapia Ocupacional',
        'professional_name': 'Beatriz Nogueira',
        'session_count': 4,
        'last_session_at': data(11, 18),
        'has_record': true,
        'pending_evolution_since': data(11, 18),
        'discharged': false,
        'record': prontuario(
          40,
          conteudo: const {
            'anamnesis': {
              'chief_complaint':
                  'Dificuldade de coordenação motora fina nas atividades '
                  'escolares.',
              'medical_diagnosis':
                  'Transtorno do desenvolvimento da coordenação.',
            },
          },
        ),
        'latest_evolution': evolucao(
          3,
          data(15, 18),
          'Beatriz Nogueira',
          'Boa interação nas atividades de encaixe. Melhora na preensão.',
        ),
      },
      {
        // Prontuário fechado por alta.
        'patient_id': '11',
        'patient_name': 'Helena Costa',
        'email': 'helena.costa@email.com',
        'specialty': 'Fisioterapia',
        'professional_name': 'Arnaldo Ribeiro',
        'session_count': 10,
        'last_session_at': data(20, 10),
        'has_record': true,
        'pending_evolution_since': null,
        'discharged': true,
        'discharge': {
          'reason': 'goalsAchieved',
          'description':
              'Ganho completo de amplitude e força do joelho esquerdo. '
              'Paciente sem dor nas atividades diárias e orientado a manter '
              'os exercícios em casa.',
          'discharged_at': data(20, 11),
          'professional_name': 'Arnaldo Ribeiro',
        },
        'record': prontuario(90, modificadoHaDias: 20, conteudo: joelho),
        'latest_evolution': evolucao(
          10,
          data(20, 10),
          'Arnaldo Ribeiro',
          'Objetivos do tratamento alcançados. Alta fisioterapêutica.',
        ),
      },
      {
        // Recém-cadastrado: sem sessão e sem prontuário.
        'patient_id': '12',
        'patient_name': 'Rita Moura',
        'email': 'rita.moura@email.com',
        'specialty': 'Fisioterapia',
        'professional_name': 'Arnaldo Ribeiro',
        'session_count': 0,
        'last_session_at': null,
        'has_record': false,
        'pending_evolution_since': null,
        'discharged': false,
        'record': null,
        'latest_evolution': null,
      },
    ];
  }
}
