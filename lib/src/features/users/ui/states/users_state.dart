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
    final termo = _normalizar(search.trim());

    return users.where((user) {
      if (!filter.aceita(user.role)) return false;
      if (termo.isEmpty) return true;
      return _normalizar(user.name).contains(termo) ||
          _normalizar(user.email).contains(termo);
    }).toList();
  }

  static String _normalizar(String texto) {
    const comAcento = 'áàâãäéèêëíìîïóòôõöúùûüç';
    const semAcento = 'aaaaaeeeeiiiiooooouuuuc';

    final minusculo = texto.toLowerCase();
    final buffer = StringBuffer();
    for (final letra in minusculo.split('')) {
      final i = comAcento.indexOf(letra);
      buffer.write(i == -1 ? letra : semAcento[i]);
    }
    return buffer.toString();
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
