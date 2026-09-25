import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/features/auth/application/auth_controller.dart';
import 'package:poti_5f/src/features/auth/domain/models/user.dart';
import 'package:poti_5f/src/features/login/application/login_controller.dart';
import 'package:poti_5f/src/features/login/domain/repositories/login_repository.dart';
import 'package:poti_5f/src/features/login/ui/states/login_state.dart';

class _FakeLoginRepository implements LoginRepository {
  final User? usuario;
  final Exception? erro;

  _FakeLoginRepository({this.usuario, this.erro});

  @override
  Future<User> login(String email, String password) async {
    if (erro != null) throw erro!;
    return usuario!;
  }
}

void main() {
  const usuario = User(id: '1', name: 'Ana', email: 'ana@x.com', token: 't');

  ProviderContainer criarContainer(LoginRepository repository) {
    return ProviderContainer.test(
      overrides: [loginRepositoryProvider.overrideWithValue(repository)],
    );
  }

  test('estado inicial é LoginInitial', () {
    final container = criarContainer(_FakeLoginRepository(usuario: usuario));

    expect(container.read(loginControllerProvider), isA<LoginInitial>());
  });

  test(
    'sucesso: passa por Loading, termina em Success e abre a sessão',
    () async {
      final container = criarContainer(_FakeLoginRepository(usuario: usuario));
      final controller = container.read(loginControllerProvider.notifier);

      final future = controller.entrar(email: 'ana@x.com', password: '123');
      expect(container.read(loginControllerProvider), isA<LoginLoading>());

      await future;

      final state = container.read(loginControllerProvider);
      expect(state, isA<LoginSuccess>());
      expect((state as LoginSuccess).user, usuario);
      expect(container.read(authControllerProvider), usuario);
    },
  );

  test('erro: termina em LoginError sem o prefixo "Exception: "', () async {
    final container = criarContainer(
      _FakeLoginRepository(erro: Exception('Email ou senha inválidos')),
    );

    await container
        .read(loginControllerProvider.notifier)
        .entrar(email: 'x', password: 'y');

    final state = container.read(loginControllerProvider);
    expect(state, isA<LoginError>());
    expect((state as LoginError).message, 'Email ou senha inválidos');
    expect(container.read(authControllerProvider), isNull);
  });

  test('resetar volta para LoginInitial', () async {
    final container = criarContainer(
      _FakeLoginRepository(erro: Exception('falha')),
    );
    final controller = container.read(loginControllerProvider.notifier);

    await controller.entrar(email: 'x', password: 'y');
    controller.resetar();

    expect(container.read(loginControllerProvider), isA<LoginInitial>());
  });
}
