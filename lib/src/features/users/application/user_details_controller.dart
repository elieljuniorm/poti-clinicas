import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repositories/users_repository.dart';
import '../ui/states/user_details_state.dart';
import 'users_controller.dart';

/// Carrega os detalhes de um usuário para o modal (um controller por id).
class UserDetailsController extends Notifier<UserDetailsState> {
  final String userId;

  UserDetailsController(this.userId);

  UsersRepository get _repository => ref.read(usersRepositoryProvider);

  // Inicialização do estado vai no build().
  // O carregamento é agendado porque não se pode alterar `state` durante o build.
  @override
  UserDetailsState build() {
    Future.microtask(carregar);
    return const UserDetailsState(isLoading: true);
  }

  Future<void> carregar() async {
    state = state.copyWith(isLoading: true);

    try {
      final detalhes = await _repository.buscarDetalhes(userId);
      if (!ref.mounted) return;

      // Estado novo: garante que um erro anterior seja limpo.
      state = UserDetailsState(details: detalhes);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar dados do usuário: $e',
      );
    }
  }
}

// ============================================================
// Providers
// ============================================================

/// `autoDispose`: os dados são buscados de novo a cada abertura do modal.
final userDetailsControllerProvider = NotifierProvider.autoDispose
    .family<UserDetailsController, UserDetailsState, String>(
      UserDetailsController.new,
    );
