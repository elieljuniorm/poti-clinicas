import '../dtos/profile_dto.dart';

/// Responsabilidade: fazer a chamada externa real (HTTP, GraphQL, etc.).
/// É o único lugar que "sabe" que existe uma API.
class ProfileDataSource {
  // Simula o servidor guardando o perfil em memória.
  // Os dados seguem o usuário mockado em `LoginDataSource`.
  Map<String, dynamic> _perfil = {
    'user_id': '1',
    'full_name': 'Eliel Maia',
    'email': 'teste@teste.com',
    'phone': '(86) 99999-0000',
    'cpf': '123.456.789-00',
    'birth_date': '15/03/1990',
    'photo_url': null,
    'address': {
      'zip_code': '67010-000',
      'street': 'Rodovia BR-316',
      'number': '1835',
      'complement': '303A',
      'neighborhood': 'Guanabara',
      'city': 'Ananindeua',
      'state': 'PA',
    },
  };

  // Mesma senha do mock de login. A troca vale só para este mock:
  // o `LoginDataSource` continua aceitando '123456'.
  String _senha = '123456';

  Future<ProfileDto> buscarPerfil(String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    return ProfileDto.fromJson(_perfil);
  }

  Future<ProfileDto> atualizarPerfil(ProfileDto dto) async {
    await Future.delayed(const Duration(seconds: 1));
    _perfil = dto.toJson();
    return ProfileDto.fromJson(_perfil);
  }

  Future<void> alterarSenha({
    required String senhaAtual,
    required String novaSenha,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (senhaAtual != _senha) {
      throw Exception('Senha atual incorreta');
    }
    _senha = novaSenha;
  }
}
