import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../../auth/domain/models/user.dart';
import '../domain/models/profile_model.dart';
import '../domain/repositories/profile_repository.dart';
import '../ui/states/profile_edit_state.dart';
import 'profile_controller.dart';

/// Salva as alterações feitas na tela de edição do perfil.
class ProfileEditController extends Notifier<ProfileEditState> {
  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  @override
  ProfileEditState build() {
    return const ProfileEditInitial();
  }

  /// Salva os dados e, se [novaSenha] vier preenchida, troca a senha.
  Future<void> salvar({
    required ProfileModel perfil,
    String? senhaAtual,
    String? novaSenha,
  }) async {
    state = const ProfileEditSaving();

    try {
      // 1. Senha primeiro: se a senha atual estiver errada, nada é salvo.
      if (novaSenha != null && novaSenha.isNotEmpty) {
        await _repository.alterarSenha(
          senhaAtual: senhaAtual ?? '',
          novaSenha: novaSenha,
        );
      }

      // 2. Dados cadastrais
      final salvo = await _repository.atualizarPerfil(perfil);
      if (!ref.mounted) return;

      // 3. Atualiza o perfil em memória e a sessão (nome/e-mail do Drawer)
      ref.read(profileControllerProvider.notifier).definirPerfil(salvo);
      _sincronizarSessao(salvo);

      // 4. Avisa a tela para voltar
      state = const ProfileEditSuccess();
    } catch (e) {
      if (!ref.mounted) return;
      state = ProfileEditError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _sincronizarSessao(ProfileModel perfil) {
    final sessao = ref.read(authControllerProvider);
    if (sessao == null) return;

    ref
        .read(authControllerProvider.notifier)
        .definirUsuario(
          User(
            id: sessao.id,
            name: perfil.name,
            email: perfil.email,
            token: sessao.token,
            photoUrl: sessao.photoUrl,
          ),
        );
  }
}

// ============================================================
// Providers
// ============================================================

/// `autoDispose`: o estado volta a [ProfileEditInitial] sempre que
/// a tela de edição é fechada e aberta de novo.
final profileEditControllerProvider =
    NotifierProvider.autoDispose<ProfileEditController, ProfileEditState>(
      ProfileEditController.new,
    );
