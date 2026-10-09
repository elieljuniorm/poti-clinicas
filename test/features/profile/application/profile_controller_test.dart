import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multiclinica_app/src/features/auth/application/auth_controller.dart';
import 'package:multiclinica_app/src/features/auth/domain/models/user.dart';
import 'package:multiclinica_app/src/features/profile/application/profile_controller.dart';

import 'fake_profile_repository.dart';

void main() {
  const usuario = User(id: '1', name: 'Ana', email: 'ana@x.com', token: 't');

  ProviderContainer criarContainer(FakeProfileRepository repository) {
    return ProviderContainer.test(
      overrides: [profileRepositoryProvider.overrideWithValue(repository)],
    );
  }

  test('sem usuário logado: mostra erro e não carrega', () {
    final container = criarContainer(FakeProfileRepository());

    final state = container.read(profileControllerProvider);
    expect(state.isLoading, isFalse);
    expect(state.errorMessage, 'Nenhum usuário logado');
  });

  test('com usuário logado: carrega o perfil', () async {
    final container = criarContainer(FakeProfileRepository());
    container.read(authControllerProvider.notifier).definirUsuario(usuario);

    expect(container.read(profileControllerProvider).isLoading, isTrue);
    await container.read(profileControllerProvider.notifier).carregar();

    final state = container.read(profileControllerProvider);
    expect(state.isLoading, isFalse);
    expect(state.profile?.cpf, '111.222.333-44');
  });

  test('erro na busca: mensagem sem o prefixo "Exception: "', () async {
    final repository = FakeProfileRepository()..falharBusca = true;
    final container = criarContainer(repository);
    container.read(authControllerProvider.notifier).definirUsuario(usuario);

    container.read(profileControllerProvider);
    await container.read(profileControllerProvider.notifier).carregar();

    expect(
      container.read(profileControllerProvider).errorMessage,
      'sem conexão',
    );
  });

  test('logout descarta o perfil carregado', () async {
    final container = criarContainer(FakeProfileRepository());
    final auth = container.read(authControllerProvider.notifier);
    auth.definirUsuario(usuario);

    container.read(profileControllerProvider);
    await container.read(profileControllerProvider.notifier).carregar();
    expect(container.read(profileControllerProvider).profile, isNotNull);

    await auth.logout();

    final state = container.read(profileControllerProvider);
    expect(state.profile, isNull);
    expect(state.errorMessage, 'Nenhum usuário logado');
  });
}
