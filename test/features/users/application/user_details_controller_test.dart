import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/features/users/application/user_details_controller.dart';
import 'package:poti_5f/src/features/users/application/users_controller.dart';

import 'fake_users_repository.dart';

void main() {
  ProviderContainer criarContainer(FakeUsersRepository repository) {
    return ProviderContainer.test(
      overrides: [usersRepositoryProvider.overrideWithValue(repository)],
    );
  }

  test('começa carregando', () {
    final container = criarContainer(FakeUsersRepository());

    expect(
      container.read(userDetailsControllerProvider('2')).isLoading,
      isTrue,
    );
  });

  test('sucesso: busca os detalhes do usuário do provider', () async {
    final repository = FakeUsersRepository();
    final container = criarContainer(repository);

    container.listen(userDetailsControllerProvider('2'), (_, _) {});
    await container
        .read(userDetailsControllerProvider('2').notifier)
        .carregar();

    final state = container.read(userDetailsControllerProvider('2'));
    expect(state.isLoading, isFalse);
    expect(state.errorMessage, isNull);
    expect(state.details!.consumption!.available, 8);
    expect(repository.detalhesBuscados, everyElement('2'));
  });

  test('erro: encerra o loading com mensagem', () async {
    final container = criarContainer(FakeUsersRepository(falharDetalhes: true));

    container.listen(userDetailsControllerProvider('2'), (_, _) {});
    await container
        .read(userDetailsControllerProvider('2').notifier)
        .carregar();

    final state = container.read(userDetailsControllerProvider('2'));
    expect(state.isLoading, isFalse);
    expect(state.errorMessage, contains('Erro ao carregar dados do usuário'));
  });
}
