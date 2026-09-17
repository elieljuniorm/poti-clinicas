import '../../../auth/domain/models/user.dart';

/// Contrato do repositório de login.
/// A camada de aplicação depende desta abstração, não da implementação.
abstract class LoginRepository {
  Future<User> login(String email, String password);
}