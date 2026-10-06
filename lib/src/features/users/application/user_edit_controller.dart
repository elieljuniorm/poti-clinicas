import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/user_edit_model.dart';
import '../domain/models/user_model.dart';
import '../domain/models/user_registration_model.dart';
import '../domain/repositories/users_repository.dart';
import '../ui/states/user_edit_state.dart';
import 'users_controller.dart';

/// Carrega o cadastro completo do usuário para a tela de edição
/// (um controller por id).
class UserEditDataController extends Notifier<UserEditDataState> {
  final String userId;

  UserEditDataController(this.userId);

  UsersRepository get _repository => ref.read(usersRepositoryProvider);

  // Inicialização do estado vai no build().
  // O carregamento é agendado porque não se pode alterar `state` durante o build.
  @override
  UserEditDataState build() {
    Future.microtask(carregar);
    return const UserEditDataState(isLoading: true);
  }

  Future<void> carregar() async {
    state = state.copyWith(isLoading: true);

    try {
      final dados = await _repository.buscarCadastro(userId);
      if (!ref.mounted) return;

      // Estado novo: garante que um erro anterior seja limpo.
      state = UserEditDataState(dados: dados);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar cadastro do usuário: $e',
      );
    }
  }

  /// Troca o usuário exibido (ex.: depois de ativar/desativar),
  /// mantendo o cadastro que está no formulário.
  void atualizarUsuario(UserModel user) {
    final dados = state.dados;
    if (dados == null) return;
    state = state.copyWith(
      dados: UserEditModel(user: user, cadastro: dados.cadastro),
    );
  }
}

/// Ações da tela de edição: salvar o cadastro, ativar/desativar e
/// resetar a senha. Uma de cada vez.
class UserEditController extends Notifier<UserEditState> {
  final String userId;

  UserEditController(this.userId);

  UsersRepository get _repository => ref.read(usersRepositoryProvider);

  @override
  UserEditState build() {
    return const UserEditInitial();
  }

  Future<void> salvar(UserRegistrationModel cadastro) {
    return _executar(
      UserEditAction.salvar,
      () => _repository.atualizarUsuario(userId, cadastro),
    );
  }

  Future<void> alterarStatus({required bool ativo}) {
    return _executar(
      UserEditAction.alterarStatus,
      () => _repository.alterarStatus(userId, ativo: ativo),
    );
  }

  Future<void> resetarSenha() {
    return _executar(UserEditAction.resetarSenha, () async {
      await _repository.resetarSenha(userId);
      // A senha não muda nada no usuário exibido.
      return ref.read(userEditDataControllerProvider(userId)).dados!.user;
    });
  }

  Future<void> _executar(
    UserEditAction acao,
    Future<UserModel> Function() chamada,
  ) async {
    if (state is UserEditInProgress) return;
    state = UserEditInProgress(acao);

    try {
      final usuario = await chamada();
      if (!ref.mounted) return;

      if (acao != UserEditAction.resetarSenha) {
        // A lista de usuários já mostra a mudança quando a tela voltar.
        unawaited(ref.read(usersControllerProvider.notifier).carregar());
        ref
            .read(userEditDataControllerProvider(userId).notifier)
            .atualizarUsuario(usuario);
      }

      state = UserEditSuccess(acao, usuario);
    } catch (e) {
      if (!ref.mounted) return;
      state = UserEditError(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}

// ============================================================
// Providers
// ============================================================

/// `autoDispose`: o cadastro é buscado de novo a cada abertura da tela.
final userEditDataControllerProvider = NotifierProvider.autoDispose
    .family<UserEditDataController, UserEditDataState, String>(
      UserEditDataController.new,
    );

final userEditControllerProvider = NotifierProvider.autoDispose
    .family<UserEditController, UserEditState, String>(UserEditController.new);
