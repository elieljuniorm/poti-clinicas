import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../data/data_sources/login_remote_data_source.dart';
import '../data/repository/login_repository_impl.dart';
import '../domain/repositories/login_repository.dart';
import '../ui/states/login_state.dart';

class LoginController extends Notifier<LoginState> {
  // Aqui podemos ler o repository do provider
  LoginRepository get _repository => ref.read(loginRepositoryProvider);

  // Inicialização do estado vai no build()
  @override
  LoginState build() {
    return const LoginInitial();
  }

  Future<void> entrar({
    required String email,
    required String password,
  }) async {
    state = const LoginLoading();

    try {
      // 1. Autentica (repository só converte DTO → User)
      final user = await _repository.login(email, password);

      // 2. Delega ao AuthController: ele passa a ser o dono da sessão
      //    `ref` já está disponível como propriedade herdada do Notifier
      ref.read(authControllerProvider.notifier).definirUsuario(user);

      // 3. Avisa a tela para navegar
      state = LoginSuccess(user);
    } catch (e) {
      state = LoginError(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Limpa o estado do formulário (útil ao voltar para a tela).
  void resetar() => state = const LoginInitial();
}

// ============================================================
// Providers
// ============================================================

final loginDataSourceProvider =
    Provider<LoginDataSource>((ref) => LoginDataSource());

final loginRepositoryProvider = Provider<LoginRepository>((ref) {
  return LoginRepositoryImpl(ref.watch(loginDataSourceProvider));
});

final loginControllerProvider =
    NotifierProvider<LoginController, LoginState>(LoginController.new);