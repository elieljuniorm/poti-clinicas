import '../dtos/user_dto.dart';

/// Responsabilidade: fazer a chamada externa real (HTTP, GraphQL, etc.).
/// É o único lugar que "sabe" que existe uma API.
class LoginDataSource {
  // Simula uma chamada de API com delay de 2 segundos.
  Future<UserDto> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));

    if (email == 'teste@teste.com' && password == '123456') {
      return UserDto(
        userId: '1',
        fullName: 'Eliel Maia',
        email: email,
        accessToken: 'fake-token-abc123',
      );
    }

    throw Exception('Email ou senha inválidos');
  }
}