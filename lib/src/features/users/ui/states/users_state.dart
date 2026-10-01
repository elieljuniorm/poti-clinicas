import '../../../../core/utils/texto.dart';
import '../../domain/models/user_filter.dart';
import '../../domain/models/user_model.dart';

class UsersState {
  final bool isLoading;
  final String? errorMessage;

  /// Todos os usuários carregados (sem filtro).
  final List<UserModel> users;

  /// Filtro selecionado (Todos / Profissionais / Pacientes).
  final UserFilter filter;

  /// Texto digitado na busca (nome ou e-mail).
  final String search;

  const UsersState({
    this.isLoading = false,
    this.errorMessage,
    this.users = const [],
    this.filter = UserFilter.all,
    this.search = '',
  });

  /// Usuários exibidos: aplica o filtro e a busca (sem diferenciar acentos).
  List<UserModel> get filteredUsers {
    return users.where((user) {
      if (!filter.aceita(user.role)) return false;
      return Texto.contem(user.name, search) ||
          Texto.contem(user.email, search);
    }).toList();
  }

  UsersState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<UserModel>? users,
    UserFilter? filter,
    String? search,
  }) {
    return UsersState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      users: users ?? this.users,
      filter: filter ?? this.filter,
      search: search ?? this.search,
    );
  }
}
