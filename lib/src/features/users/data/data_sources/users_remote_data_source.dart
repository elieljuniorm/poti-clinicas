import '../../../../core/utils/documento.dart';
import '../dtos/user_details_dto.dart';
import '../dtos/user_dto.dart';
import '../dtos/user_registration_dto.dart';

/// Responsabilidade: fazer a chamada externa real (HTTP).
/// É o único lugar que "sabe" que existe uma API.
class UsersDataSource {
  static const _usuariosIniciais = [
    {
      'id': '1',
      'name': 'Arnaldo Ribeiro',
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
      'patient_category': 'adult',
      'status': 'active',
      'document': '52998224725',
      'photo_url': null,
    },
    {
      'id': '3',
      'name': 'Beatriz Nogueira',
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
      'patient_category': 'elderly',
      'status': 'inactive',
      'document': '11144477735',
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
    {
      'id': '8',
      'name': 'Lucas Freitas',
      'email': 'lucas.freitas@gmail.com',
      'phone': '(91) 9 8044-5566',
      'role': 'patient',
      'patient_category': 'pediatric',
      'status': 'active',
      'document': '39053344705',
      'photo_url': null,
    },
  ];

  /// Cadastro completo dos usuários de exemplo, no formato da API (o mesmo
  /// do [UserRegistrationDto]). Quem não está aqui tem o cadastro montado
  /// a partir dos dados da lista (ver [_cadastroBasico]).
  static const _cadastrosIniciais = <String, Map<String, dynamic>>{
    '1': {
      'name': 'Arnaldo Ribeiro',
      'email': 'arnaldo.ribeiro@5f.com',
      'phone': '91984551212',
      'birth_date': '01/10/1988',
      'role': 'professional',
      'document': '52998224725',
      'council_number': '123456-F',
      'description': 'Fisioterapeuta',
      'address': {
        'zip_code': '67030-000',
        'street': 'BR 316',
        'number': '1835',
        'complement': '',
        'neighborhood': 'Guanabara',
        'city': 'Ananindeua',
        'state': 'PA',
      },
      'bank_info': {
        'bank': '001 - Banco do Brasil',
        'agency': '1234-5',
        'account': '00012345-6',
        'account_type': 'checking',
        'pix_key_type': 'email',
        'pix_key': 'arnaldo.ribeiro@5f.com',
      },
    },
    '2': {
      'name': 'Juliana Mendes Souza',
      'email': 'juliana.mendes@gmail.com',
      'phone': '91992114566',
      'birth_date': '08/02/2000',
      'role': 'patient',
      'document': '52998224725',
      'patient_category': 'adult',
      'professional_id': '1',
      'address': {
        'zip_code': '67030-000',
        'street': 'BR 316',
        'number': '1835',
        'complement': 'Próximo ao Colégio Bom Pastor',
        'neighborhood': 'Guanabara',
        'city': 'Ananindeua',
        'state': 'PA',
      },
      'marital_status': 'single',
      'family_income': 'from7000To22000',
      'clinical_case':
          'Formigamento e dormência no pé direito ao permanecer sentado '
          'por mais de 30 minutos.',
      'self_responsible': false,
      'responsible': {
        'name': 'Luiz Marques Pontes',
        'email': 'luiz-marques@gmail.com',
        'phone': '91999999999',
        'birth_date': '18/12/1999',
      },
    },
  };

  /// Usuários da lista (simula o banco da API): os de exemplo mais os
  /// cadastrados nesta sessão. Edições e mudanças de status ficam aqui.
  final List<Map<String, dynamic>> _usuarios = [
    for (final usuario in _usuariosIniciais) {...usuario},
  ];

  /// Cadastro completo por id, já com as edições desta sessão.
  final Map<String, Map<String, dynamic>> _cadastros = {
    for (final MapEntry(:key, :value) in _cadastrosIniciais.entries)
      key: {...value},
  };

  int _novos = 0;

  // Simula a chamada de API com delay de 1 segundo e resposta em JSON.
  Future<List<UserDto>> buscarUsuarios() async {
    await Future.delayed(const Duration(seconds: 1));

    return _usuarios.map(UserDto.fromJson).toList();
  }

  // Simula POST /users. Recusa e-mail já cadastrado, como a API faria.
  Future<UserDto> cadastrarUsuario(UserRegistrationDto cadastro) async {
    await Future.delayed(const Duration(seconds: 1));

    final json = cadastro.toJson();
    _validarEmail(json['email'] as String);

    final id = 'novo-${++_novos}';
    final usuario = <String, dynamic>{
      'id': id,
      ..._dadosDaLista(json),
      'status': 'active',
      'photo_url': null,
    };
    _usuarios.add(usuario);
    _cadastros[id] = json;
    return UserDto.fromJson(usuario);
  }

  // Simula GET /users/{id}/registration.
  Future<({UserDto usuario, UserRegistrationDto cadastro})> buscarCadastro(
    String userId,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    final usuario = _usuario(userId);
    final cadastro = _cadastros[userId] ?? _cadastroBasico(usuario);
    return (
      usuario: UserDto.fromJson(usuario),
      cadastro: UserRegistrationDto.fromJson(cadastro),
    );
  }

  // Simula PUT /users/{id}. O e-mail não pode ser o de outro usuário.
  Future<UserDto> atualizarUsuario(
    String userId,
    UserRegistrationDto cadastro,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    final usuario = _usuario(userId);
    final json = cadastro.toJson();
    _validarEmail(json['email'] as String, ignorarId: userId);

    usuario.addAll(_dadosDaLista(json));
    _cadastros[userId] = json;
    return UserDto.fromJson(usuario);
  }

  // Simula PATCH /users/{id}/status.
  Future<UserDto> alterarStatus(String userId, {required bool ativo}) async {
    await Future.delayed(const Duration(seconds: 1));

    final usuario = _usuario(userId);
    usuario['status'] = ativo ? 'active' : 'inactive';
    return UserDto.fromJson(usuario);
  }

  // Simula POST /users/{id}/reset-password (a API envia o link por e-mail).
  Future<void> resetarSenha(String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    _usuario(userId);
  }

  Map<String, dynamic> _usuario(String userId) {
    for (final usuario in _usuarios) {
      if (usuario['id'] == userId) return usuario;
    }
    throw Exception('Usuário não encontrado');
  }

  void _validarEmail(String email, {String? ignorarId}) {
    final existe = _usuarios.any(
      (u) =>
          u['id'] != ignorarId &&
          (u['email'] as String).toLowerCase() == email.toLowerCase(),
    );
    if (existe) throw Exception('Já existe um usuário com este e-mail');
  }

  /// Campos do cadastro que aparecem na lista de usuários.
  static Map<String, dynamic> _dadosDaLista(Map<String, dynamic> cadastro) => {
    'name': cadastro['name'],
    'email': cadastro['email'],
    'phone': _mascararTelefone(cadastro['phone']),
    'role': cadastro['role'],
    'description': cadastro['description'],
    'patient_category': cadastro['patient_category'],
    'document': cadastro['document'],
  };

  /// Cadastro mínimo de quem não tem cadastro completo: os dados da lista.
  static Map<String, dynamic> _cadastroBasico(Map<String, dynamic> usuario) => {
    'name': usuario['name'],
    'email': usuario['email'],
    'phone': Documento.digitos(usuario['phone']),
    'role': usuario['role'],
    'document': usuario['document'] ?? '',
    'description': usuario['description'],
    'patient_category': usuario['patient_category'],
  };

  /// A lista exibe o telefone formatado: "91999999999" → "(91) 9 9999-9999".
  static String _mascararTelefone(String digitos) {
    if (digitos.length == 11) {
      return '(${digitos.substring(0, 2)}) ${digitos[2]} '
          '${digitos.substring(3, 7)}-${digitos.substring(7)}';
    }
    if (digitos.length == 10) {
      return '(${digitos.substring(0, 2)}) '
          '${digitos.substring(2, 6)}-${digitos.substring(6)}';
    }
    return digitos;
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
      '8': {
        'contract': {
          'name': 'Pacote Pediatria',
          'start_date': '01/08/2025',
          'end_date': '01/02/2026',
          'status': 'active',
          'file_name': 'Contrato de Serviços.pdf',
        },
        'recent_sessions': [
          {
            'title': 'Sessão de pediatria',
            'date': '10/09/2025',
            'note': 'Boa interação nas atividades',
          },
        ],
        'consumption': {
          'contracted': 12,
          'performed': 3,
          'session_value': 150.00,
          'payment_method': 'Cartão de Débito',
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
