import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/features/users/application/user_registration_controller.dart';
import 'package:poti_5f/src/features/users/application/users_controller.dart';
import 'package:poti_5f/src/features/users/domain/models/user_registration_model.dart';
import 'package:poti_5f/src/features/users/domain/models/user_role.dart';
import 'package:poti_5f/src/features/users/ui/states/user_registration_state.dart';

import 'fake_users_repository.dart';

void main() {
  const cadastro = UserRegistrationModel(
    name: 'Ana Lima',
    email: 'ana@5f.com',
    phone: '(91) 9 9999-8888',
    role: UserRole.reception,
    document: '529.982.247-25',
  );

  ProviderContainer criarContainer(FakeUsersRepository repository) {
    final container = ProviderContainer.test(
      overrides: [usersRepositoryProvider.overrideWithValue(repository)],
    );
    // Mantém o autoDispose vivo durante o teste.
    container.listen(userRegistrationControllerProvider, (_, _) {});
    return container;
  }

  test('começa no estado inicial', () {
    final container = criarContainer(FakeUsersRepository());

    expect(
      container.read(userRegistrationControllerProvider),
      isA<UserRegistrationInitial>(),
    );
  });

  test('sucesso: envia o cadastro e recarrega a lista de usuários', () async {
    final repository = FakeUsersRepository();
    final container = criarContainer(repository);
    final buscasAntes = repository.buscasUsuarios;

    await container
        .read(userRegistrationControllerProvider.notifier)
        .cadastrar(cadastro);
    await Future<void>.delayed(Duration.zero);

    final state = container.read(userRegistrationControllerProvider);
    expect(state, isA<UserRegistrationSuccess>());
    expect((state as UserRegistrationSuccess).user.name, 'Ana Lima');
    expect(repository.cadastros.single.role, UserRole.reception);
    expect(repository.buscasUsuarios, greaterThan(buscasAntes));
  });

  test('erro: mensagem sem o prefixo "Exception:"', () async {
    final container = criarContainer(
      FakeUsersRepository(erroCadastro: 'Já existe um usuário com este e-mail'),
    );

    await container
        .read(userRegistrationControllerProvider.notifier)
        .cadastrar(cadastro);

    final state = container.read(userRegistrationControllerProvider);
    expect(state, isA<UserRegistrationError>());
    expect(
      (state as UserRegistrationError).message,
      'Já existe um usuário com este e-mail',
    );
  });
}
