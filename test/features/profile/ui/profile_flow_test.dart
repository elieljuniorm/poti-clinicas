import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:poti_5f/src/features/auth/application/auth_controller.dart';
import 'package:poti_5f/src/features/auth/domain/models/user.dart';
import 'package:poti_5f/src/features/profile/ui/pages/profile_edit_screen.dart';
import 'package:poti_5f/src/features/profile/ui/pages/profile_screen.dart';

/// Visualização → edição → salvar, usando o data source real (mock em memória).
void main() {
  testWidgets('ver dados, editar, validar e salvar', (tester) async {
    tester.view.physicalSize = const Size(4000, 12000);
    addTearDown(tester.view.reset);

    final container = ProviderContainer.test();
    container
        .read(authControllerProvider.notifier)
        .definirUsuario(
          const User(
            id: '1',
            name: 'Eliel Maia',
            email: 'teste@teste.com',
            token: 't',
          ),
        );

    // Router local: o `appRouter` global começaria na splash.
    final router = GoRouter(
      initialLocation: '/profile',
      routes: [
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
          routes: [
            GoRoute(
              path: 'edit',
              name: 'profile-edit',
              builder: (context, state) => const ProfileEditScreen(),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    // ---------- Visualização ----------
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Meus dados'), findsOneWidget);
    expect(find.text('DADOS PESSOAIS'), findsOneWidget);
    expect(find.text('123.456.789-00'), findsOneWidget);
    // Endereço e senha só aparecem na edição.
    expect(find.text('ENDEREÇO'), findsNothing);
    expect(find.text('ALTERAR SENHA'), findsNothing);
    // Campos bloqueados.
    final nomeView = tester.widget<TextField>(find.byType(TextField).first);
    expect(nomeView.enabled, isFalse);

    // ---------- Edição ----------
    await tester.tap(find.text('EDITAR DADOS'));
    await tester.pumpAndSettle();

    expect(find.text('Editar dados'), findsOneWidget);
    expect(find.text('ENDEREÇO'), findsOneWidget);
    expect(find.text('ALTERAR SENHA'), findsOneWidget);
    expect(find.text('Rua das Flores'), findsOneWidget);

    Finder campo(String rotulo) => find.descendant(
      of: find
          .ancestor(of: find.text(rotulo), matching: find.byType(Column))
          .first,
      matching: find.byType(TextFormField),
    );

    // Validação: nome obrigatório e senhas diferentes.
    await tester.enterText(campo('NOME'), '');
    await tester.enterText(campo('NOVA SENHA'), 'nova123');
    await tester.enterText(campo('CONFIRMAR NOVA SENHA'), 'outra');
    await tester.tap(find.text('SALVAR'));
    await tester.pump();

    expect(find.text('Campo obrigatório'), findsOneWidget);
    expect(find.text('Informe a senha atual'), findsOneWidget);
    expect(find.text('As senhas não conferem'), findsOneWidget);

    // Senha atual errada: erro vindo do data source.
    await tester.enterText(campo('NOME'), 'Eliel M. Maia');
    await tester.enterText(campo('SENHA ATUAL'), 'errada');
    await tester.enterText(campo('CONFIRMAR NOVA SENHA'), 'nova123');
    await tester.tap(find.text('SALVAR'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(find.text('Senha atual incorreta'), findsOneWidget);
    expect(find.byType(ProfileEditScreen), findsOneWidget);

    // Tudo certo: salva e volta para a visualização.
    await tester.enterText(campo('SENHA ATUAL'), '123456');
    await tester.enterText(campo('CIDADE'), 'Parnaíba');
    await tester.tap(find.text('SALVAR'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('Dados atualizados com sucesso'), findsOneWidget);
    expect(find.text('Eliel M. Maia'), findsWidgets);
    // A sessão (usada pelo Drawer) também foi atualizada.
    expect(container.read(authControllerProvider)!.name, 'Eliel M. Maia');

    // Reabrindo a edição, o endereço salvo aparece.
    await tester.tap(find.text('EDITAR DADOS'));
    await tester.pumpAndSettle();
    expect(find.text('Parnaíba'), findsOneWidget);
    // E o formulário de senha volta vazio.
    expect(find.text('Senha atual incorreta'), findsNothing);
  });
}
