import '../models/user_details_model.dart';
import '../models/user_model.dart';
import '../models/user_registration_model.dart';

/// Contrato do repositório de Usuários.
/// A camada de aplicação depende desta abstração, não da implementação.
abstract class UsersRepository {
  Future<List<UserModel>> buscarUsuarios();
  Future<UserDetailsModel> buscarDetalhes(String userId);
  Future<UserModel> cadastrarUsuario(UserRegistrationModel cadastro);
}
