import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/features/users/application/users_controller.dart';
import 'package:poti_5f/src/features/users/domain/models/user_filter.dart';
import 'package:poti_5f/src/features/users/domain/repositories/users_repository.dart';

import 'fake_users_repository.dart';

void main() {
  ProviderContainer criarContainer(UsersRepository repository) {
    return ProviderContainer.test(
      overrides: [usersRepositoryProvider.overrideWithValue(repository)],
    );
  }

  Future<ProviderContainer> carregado() async {
    final container = criarContainer(FakeUsersRepository());
    container.read(usersControllerProvider);
    await container.read(usersControllerProvider.notifier).carregar();
    return container;
  }

  List<String> nomesVisiveis(ProviderContainer container) {
    return container
        .read(usersControllerProvider)
        .filteredUsers
        .map((u) => u.name)
        .toList();
  }

  test('começa carregando com o filtro "Todos"', () {
    final container = criarContainer(FakeUsersRepository());

    final state = container.read(usersControllerProvider);
    expect(state.isLoading, isTrue);
    expect(state.filter, UserFilter.all);
  });

  test('sucesso: "Todos" mostra todos os perfis', () async {
    final container = await carregado();

    final state = container.read(usersControllerProvider);
    expect(state.isLoading, isFalse);
    expect(state.errorMessage, isNull);
    expect(state.filteredUsers, hasLength(3));
  });

  test('filtros de profissionais e pacientes', () async {
    final container = await carregado();
    final controller = container.read(usersControllerProvider.notifier);

    controller.selecionarFiltro(UserFilter.professionals);
    expect(nomesVisiveis(container), ['Dr. Arnaldo Ribeiro']);

    controller.selecionarFiltro(UserFilter.patients);
    expect(nomesVisiveis(container), ['Antônio Araújo']);
  });

  test('busca por nome ignora maiúsculas e acentos', () async {
    final container = await carregado();

    container.read(usersControllerProvider.notifier).buscar('ANTONIO ara');
    expect(nomesVisiveis(container), ['Antônio Araújo']);
  });

  test('busca por e-mail combina com o filtro', () async {
    final container = await carregado();
    final controller = container.read(usersControllerProvider.notifier);

    controller.buscar('@5f.com');
    expect(nomesVisiveis(container), hasLength(2));

    controller.selecionarFiltro(UserFilter.patients);
    expect(nomesVisiveis(container), isEmpty);
  });

  test('erro: encerra o loading com mensagem', () async {
    final container = criarContainer(FakeUsersRepository(deveFalhar: true));

    container.read(usersControllerProvider);
    await container.read(usersControllerProvider.notifier).carregar();

    final state = container.read(usersControllerProvider);
    expect(state.isLoading, isFalse);
    expect(state.errorMessage, contains('Erro ao carregar usuários'));
  });
}
