import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/user.dart';

/// Guarda o usuário logado globalmente usando a API moderna do Riverpod.
class AuthController extends Notifier<User?> {
  // 1. A inicialização do estado vai para o método build().
  @override
  User? build() {
    return null; // O estado inicial é nulo (ninguém logado).
  }

  /// Chamado após login bem-sucedido.
  void definirUsuario(User usuario) {
    state = usuario;
  }

  /// Limpa a sessão.
  Future<void> logout() async {
    // await _storage.limparSessao();
    state = null;
  }

  /// Atalho útil: verifica se há usuário logado.
  bool get estaLogado => state != null;
}

/// O provider agora usa NotifierProvider.
final authControllerProvider =
    NotifierProvider<AuthController, User?>(AuthController.new);