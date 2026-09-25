import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/features/auth/application/auth_controller.dart';
import 'package:poti_5f/src/features/auth/domain/models/user.dart';
import 'package:poti_5f/src/features/profile/application/profile_controller.dart';
import 'package:poti_5f/src/features/profile/application/profile_edit_controller.dart';
import 'package:poti_5f/src/features/profile/ui/states/profile_edit_state.dart';

import 'fake_profile_repository.dart';

void main() {
  const usuario = User(id: '1', name: 'Ana', email: 'ana@x.com', token: 'tok');

  late FakeProfileRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeProfileRepository();
    container = ProviderContainer.test(
      overrides: [profileRepositoryProvider.overrideWithValue(repository)],
    );
    container.read(authControllerProvider.notifier).definirUsuario(usuario);
    // Mantém vivo o provider autoDispose durante o teste.
    container.listen(profileEditControllerProvider, (_, _) {});
  });

  ProfileEditController controller() =>
      container.read(profileEditControllerProvider.notifier);

  test('estado inicial é ProfileEditInitial', () {
    expect(
      container.read(profileEditControllerProvider),
      isA<ProfileEditInitial>(),
    );
  });

  test(
    'salvar sem nova senha: atualiza perfil e sessão, não troca senha',
    () async {
      final editado = repository.perfil.copyWith(
        name: 'Ana Maria',
        email: 'am@x.com',
      );

      final future = controller().salvar(perfil: editado);
      expect(
        container.read(profileEditControllerProvider),
        isA<ProfileEditSaving>(),
      );
      await future;

      expect(
        container.read(profileEditControllerProvider),
        isA<ProfileEditSuccess>(),
      );
      expect(repository.chamadasAlterarSenha, 0);
      expect(
        container.read(profileControllerProvider).profile?.name,
        'Ana Maria',
      );

      final sessao = container.read(authControllerProvider)!;
      expect(sessao.name, 'Ana Maria');
      expect(sessao.email, 'am@x.com');
      expect(sessao.token, 'tok'); // o token da sessão é preservado
    },
  );

  test('salvar com senha correta troca a senha', () async {
    await controller().salvar(
      perfil: repository.perfil,
      senhaAtual: '123456',
      novaSenha: 'nova123',
    );

    expect(
      container.read(profileEditControllerProvider),
      isA<ProfileEditSuccess>(),
    );
    expect(repository.senha, 'nova123');
  });

  test('senha atual errada: erro e nenhum dado é salvo', () async {
    await controller().salvar(
      perfil: repository.perfil.copyWith(name: 'Outro'),
      senhaAtual: 'errada',
      novaSenha: 'nova123',
    );

    final state = container.read(profileEditControllerProvider);
    expect(state, isA<ProfileEditError>());
    expect((state as ProfileEditError).message, 'Senha atual incorreta');
    expect(repository.chamadasAtualizar, 0);
    expect(container.read(authControllerProvider)!.name, 'Ana');
  });
}
