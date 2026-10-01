import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/user_registration_model.dart';
import '../domain/repositories/users_repository.dart';
import '../ui/states/user_registration_state.dart';
import 'users_controller.dart';

/// Cadastra um usuário novo (feito pela clínica, na tela "Cadastrar Usuário").
class UserRegistrationController extends Notifier<UserRegistrationState> {
  UsersRepository get _repository => ref.read(usersRepositoryProvider);

  @override
  UserRegistrationState build() {
    return const UserRegistrationInitial();
  }

  Future<void> cadastrar(UserRegistrationModel cadastro) async {
    state = const UserRegistrationSaving();

    try {
      final usuario = await _repository.cadastrarUsuario(cadastro);
      if (!ref.mounted) return;

      // A lista de usuários já mostra o cadastrado quando a tela voltar.
      unawaited(ref.read(usersControllerProvider.notifier).carregar());

      state = UserRegistrationSuccess(usuario);
    } catch (e) {
      if (!ref.mounted) return;
      state = UserRegistrationError(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

// ============================================================
// Providers
// ============================================================

/// `autoDispose`: o estado volta a [UserRegistrationInitial] sempre que
/// a tela de cadastro é fechada e aberta de novo.
final userRegistrationControllerProvider =
    NotifierProvider.autoDispose<
      UserRegistrationController,
      UserRegistrationState
    >(UserRegistrationController.new);
