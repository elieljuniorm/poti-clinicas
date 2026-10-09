import 'package:multiclinica_app/src/features/profile/domain/models/profile_model.dart';
import 'package:multiclinica_app/src/features/profile/domain/repositories/profile_repository.dart';

class FakeProfileRepository implements ProfileRepository {
  ProfileModel perfil = const ProfileModel(
    id: '1',
    name: 'Ana',
    email: 'ana@x.com',
    cpf: '111.222.333-44',
  );
  String senha = '123456';
  bool falharBusca = false;

  int chamadasAlterarSenha = 0;
  int chamadasAtualizar = 0;

  @override
  Future<ProfileModel> buscarPerfil(String userId) async {
    if (falharBusca) throw Exception('sem conexão');
    return perfil;
  }

  @override
  Future<ProfileModel> atualizarPerfil(ProfileModel perfil) async {
    chamadasAtualizar++;
    this.perfil = perfil;
    return perfil;
  }

  @override
  Future<void> alterarSenha({
    required String senhaAtual,
    required String novaSenha,
  }) async {
    chamadasAlterarSenha++;
    if (senhaAtual != senha) throw Exception('Senha atual incorreta');
    senha = novaSenha;
  }
}
