import 'package:flutter_riverpod/legacy.dart';

import '../domain/models/user.dart';

/// Guarda o usuário logado globalmente.
///
/// É a única fonte de verdade sobre "quem está logado" no app.
/// O login apenas delega para cá; o logout apenas limpa daqui.
class AuthController extends StateNotifier<User?> {
  AuthController() : super(null);

  /// Chamado após login bem-sucedido.
  void definirUsuario(User usuario) {
    state = usuario;
  }

  /// Limpa a sessão.
  ///
  /// Hoje só zera a memória. Quando houver persistência
  /// (secure storage / shared_preferences), limpe aqui também.
  Future<void> logout() async {
    // await _storage.limparSessao();
    state = null;
  }

  /// Atalho útil: verifica se há usuário logado.
  bool get estaLogado => state != null;
}

/// Provider global do usuário logado.
///
/// `ref.watch(authControllerProvider)` devolve `User?`.
/// `ref.read(authControllerProvider.notifier)` devolve o controller.
final authControllerProvider =
    StateNotifierProvider<AuthController, User?>((ref) {
  return AuthController();
});