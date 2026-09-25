import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/features/auth/application/auth_controller.dart';
import 'package:poti_5f/src/features/auth/domain/models/user.dart';

void main() {
  const usuario = User(id: '1', name: 'Ana', email: 'ana@x.com', token: 't');

  test('começa sem usuário logado', () {
    final container = ProviderContainer.test();

    expect(container.read(authControllerProvider), isNull);
    expect(container.read(authControllerProvider.notifier).estaLogado, isFalse);
  });

  test('definirUsuario guarda a sessão e logout limpa', () async {
    final container = ProviderContainer.test();
    final controller = container.read(authControllerProvider.notifier);

    controller.definirUsuario(usuario);
    expect(container.read(authControllerProvider), usuario);
    expect(controller.estaLogado, isTrue);

    await controller.logout();
    expect(container.read(authControllerProvider), isNull);
  });
}
