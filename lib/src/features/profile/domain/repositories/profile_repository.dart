import '../models/profile_model.dart';

/// Contrato do repositório de perfil.
/// A camada de aplicação depende desta abstração, não da implementação.
abstract class ProfileRepository {
  Future<ProfileModel> buscarPerfil(String userId);

  /// Salva os dados editáveis e devolve o perfil como ficou no servidor.
  Future<ProfileModel> atualizarPerfil(ProfileModel perfil);

  Future<void> alterarSenha({
    required String senhaAtual,
    required String novaSenha,
  });
}
