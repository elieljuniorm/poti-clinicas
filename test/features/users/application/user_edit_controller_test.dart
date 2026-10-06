import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/features/users/application/user_edit_controller.dart';
import 'package:poti_5f/src/features/users/application/users_controller.dart';
import 'package:poti_5f/src/features/users/domain/models/user_registration_model.dart';
import 'package:poti_5f/src/features/users/domain/models/user_role.dart';
import 'package:poti_5f/src/features/users/ui/states/user_edit_state.dart';

import 'fake_users_repository.dart';

void main() {
  const userId = '1';

  ProviderContainer criarContainer(FakeUsersRepository repository) {
    final container = ProviderContainer.test(
      overrides: [usersRepositoryProvider.overrideWithValue(repository)],
    );
    // Mantém o autoDispose vivo durante o teste.
    container.listen(userEditDataControllerProvider(userId), (_, _) {});
    container.listen(userEditControllerProvider(userId), (_, _) {});
    return container;
  }

  Future<void> carregar(ProviderContainer container) async {
    container.read(userEditDataControllerProvider(userId));
    await Future<void>.delayed(Duration.zero);
  }

  test('carrega o cadastro do usuário', () async {
    final container = criarContainer(FakeUsersRepository());

    expect(
      container.read(userEditDataControllerProvider(userId)).isLoading,
      isTrue,
    );
    await carregar(container);

    final dados = container.read(userEditDataControllerProvider(userId)).dados!;
    expect(dados.user.name, 'Arnaldo Ribeiro');
    expect(dados.cadastro.role, UserRole.professional);
  });

  test('erro ao carregar vira mensagem', () async {
    final container = criarContainer(FakeUsersRepository(falharDetalhes: true));
    await carregar(container);

    final state = container.read(userEditDataControllerProvider(userId));
    expect(state.isLoading, isFalse);
    expect(state.errorMessage, contains('sem conexão'));
  });

  test('salvar envia o cadastro e recarrega a lista', () async {
    final repository = FakeUsersRepository();
    final container = criarContainer(repository);
    await carregar(container);
    final buscasAntes = repository.buscasUsuarios;

    await container
        .read(userEditControllerProvider(userId).notifier)
        .salvar(
          const UserRegistrationModel(
            name: 'Arnaldo R.',
            email: 'arnaldo@5f.com',
            phone: '(91) 9 8455-1212',
            role: UserRole.professional,
            document: '529.982.247-25',
          ),
        );
    await Future<void>.delayed(Duration.zero);

    final state = container.read(userEditControllerProvider(userId));
    expect(state, isA<UserEditSuccess>());
    expect((state as UserEditSuccess).acao, UserEditAction.salvar);
    expect(repository.edicoes.single.name, 'Arnaldo R.');
    expect(repository.buscasUsuarios, greaterThan(buscasAntes));
  });

  test('desativar atualiza o usuário exibido', () async {
    final repository = FakeUsersRepository();
    final container = criarContainer(repository);
    await carregar(container);

    await container
        .read(userEditControllerProvider(userId).notifier)
        .alterarStatus(ativo: false);

    expect(repository.statusAlterados, [false]);
    expect(
      container.read(userEditDataControllerProvider(userId)).dados!.user.active,
      isFalse,
    );
  });

  test('resetar senha não muda o usuário', () async {
    final repository = FakeUsersRepository();
    final container = criarContainer(repository);
    await carregar(container);

    await container
        .read(userEditControllerProvider(userId).notifier)
        .resetarSenha();

    final state = container.read(userEditControllerProvider(userId));
    expect(state, isA<UserEditSuccess>());
    expect((state as UserEditSuccess).acao, UserEditAction.resetarSenha);
    expect(repository.senhasResetadas, [userId]);
    expect(repository.statusAlterados, isEmpty);
  });

  test('erro na ação vira mensagem sem "Exception:"', () async {
    final container = criarContainer(
      FakeUsersRepository(erroEdicao: 'Já existe um usuário com este e-mail'),
    );
    await carregar(container);

    await container
        .read(userEditControllerProvider(userId).notifier)
        .alterarStatus(ativo: false);

    final state = container.read(userEditControllerProvider(userId));
    expect(state, isA<UserEditError>());
    expect(
      (state as UserEditError).message,
      'Já existe um usuário com este e-mail',
    );
  });
}
