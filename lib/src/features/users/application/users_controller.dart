import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/data_sources/users_remote_data_source.dart';
import '../data/repository/users_repository_impl.dart';
import '../domain/models/user_filter.dart';
import '../domain/repositories/users_repository.dart';
import '../ui/states/users_state.dart';

class UsersController extends Notifier<UsersState> {
  UsersRepository get _repository => ref.read(usersRepositoryProvider);

  // Inicialização do estado vai no build().
  // O carregamento é agendado porque não se pode alterar `state` durante o build.
  @override
  UsersState build() {
    Future.microtask(carregar);
    return const UsersState(isLoading: true);
  }

  Future<void> carregar() async {
    state = state.copyWith(isLoading: true);

    try {
      final usuarios = await _repository.buscarUsuarios();
      if (!ref.mounted) return;

      // Estado novo: garante que um erro anterior seja limpo.
      // Filtro e busca são mantidos.
      state = UsersState(
        users: usuarios,
        filter: state.filter,
        search: state.search,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar usuários: $e',
      );
    }
  }

  /// Filtro e busca são aplicados em memória (ver [UsersState.filteredUsers]).
  void selecionarFiltro(UserFilter filtro) {
    state = state.copyWith(filter: filtro);
  }

  void buscar(String texto) {
    state = state.copyWith(search: texto);
  }
}

// ============================================================
// Providers
// ============================================================

final usersDataSourceProvider = Provider<UsersDataSource>(
  (ref) => UsersDataSource(),
);

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepositoryImpl(ref.watch(usersDataSourceProvider));
});

final usersControllerProvider = NotifierProvider<UsersController, UsersState>(
  UsersController.new,
);
