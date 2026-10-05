import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:poti_5f/src/core/ui/widgets/app_back_button.dart';

void main() {
  Future<GoRouter> abrir(WidgetTester tester, String inicio) async {
    final router = GoRouter(
      initialLocation: inicio,
      routes: [
        GoRoute(
          path: '/agenda',
          name: 'agenda',
          builder: (_, _) => const Scaffold(body: Text('AGENDA')),
          routes: [
            GoRoute(
              path: 'novo',
              builder: (_, _) =>
                  const Scaffold(body: AppBackButton(rotaAnterior: 'agenda')),
            ),
          ],
        ),
        // Sem tela anterior na pilha.
        GoRoute(
          path: '/sozinha',
          builder: (_, _) =>
              const Scaffold(body: AppBackButton(rotaAnterior: 'agenda')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('volta para a tela anterior', (tester) async {
    final router = await abrir(tester, '/agenda/novo');

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();

    expect(find.text('AGENDA'), findsOneWidget);
    expect(router.state.uri.path, '/agenda');
  });

  testWidgets('sem tela anterior, vai para a rota informada', (tester) async {
    final router = await abrir(tester, '/sozinha');

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();

    expect(find.text('AGENDA'), findsOneWidget);
    expect(router.state.uri.path, '/agenda');
  });
}
