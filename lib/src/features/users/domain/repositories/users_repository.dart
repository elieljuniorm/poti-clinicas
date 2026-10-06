import '../models/user_details_model.dart';
import '../models/user_edit_model.dart';
import '../models/user_model.dart';
import '../models/user_registration_model.dart';

/// Contrato do repositório de Usuários.
/// A camada de aplicação depende desta abstração, não da implementação.
abstract class UsersRepository {
  Future<List<UserModel>> buscarUsuarios();
  Future<UserDetailsModel> buscarDetalhes(String userId);
  Future<UserModel> cadastrarUsuario(UserRegistrationModel cadastro);

  /// Cadastro completo do usuário, para a tela de edição.
  Future<UserEditModel> buscarCadastro(String userId);
  Future<UserModel> atualizarUsuario(
    String userId,
    UserRegistrationModel cadastro,
  );

  /// Ativa ou desativa o acesso do usuário.
  Future<UserModel> alterarStatus(String userId, {required bool ativo});

  /// Envia ao usuário o link para criar uma nova senha.
  Future<void> resetarSenha(String userId);
}
