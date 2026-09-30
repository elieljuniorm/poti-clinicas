import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/core/ui/widgets/app_bottom_nav.dart';
import 'package:poti_5f/src/features/users/application/users_controller.dart';
import 'package:poti_5f/src/features/users/ui/pages/users_screen.dart';
import 'package:poti_5f/src/features/users/ui/widgets/user_details_modal.dart';

import '../application/fake_users_repository.dart';

void main() {
  Future<void> abrirTela(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          usersRepositoryProvider.overrideWithValue(FakeUsersRepository()),
        ],
        child: const MaterialApp(home: UsersScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> abrirModal(WidgetTester tester) async {
    await tester.tap(find.text('Antônio Araújo'));
    await tester.pumpAndSettle();
  }

  testWidgets('abre ao tocar no card e mostra os detalhes', (tester) async {
    await abrirTela(tester);
    expect(find.byType(UserDetailsModal), findsNothing);

    await abrirModal(tester);

    expect(find.byType(UserDetailsModal), findsOneWidget);
    expect(find.text('RESUMO FINANCEIRO E CONSUMO'), findsOneWidget);
    expect(find.text('R\$ 180,00'), findsOneWidget);
  });

  testWidgets('fica por cima do menu inferior e deixa o título visível', (
    tester,
  ) async {
    await abrirTela(tester);
    await abrirModal(tester);

    final topoModal = tester.getTopLeft(find.byType(UserDetailsModal)).dy;
    final baseTitulo = tester.getBottomLeft(find.text('Usuários')).dy;
    expect(topoModal, greaterThan(baseTitulo));

    // O menu inferior fica atrás do modal: o toque não chega nele.
    final menu = tester.getCenter(find.byType(AppBottomNav));
    expect(
      tester
          .hitTestOnBinding(menu)
          .path
          .any(
            (e) => e.target == tester.renderObject(find.byType(AppBottomNav)),
          ),
      isFalse,
    );
  });

  testWidgets('arrastar a barra do topo para baixo fecha o modal', (
    tester,
  ) async {
    await abrirTela(tester);
    await abrirModal(tester);

    await tester.drag(
      find.bySemanticsLabel('Arraste para baixo para fechar'),
      const Offset(0, 500),
    );
    await tester.pumpAndSettle();

    expect(find.byType(UserDetailsModal), findsNothing);
  });

  testWidgets('arrastar o conteúdo rola por dentro e não fecha o modal', (
    tester,
  ) async {
    await abrirTela(tester);
    await abrirModal(tester);

    await tester.drag(
      find.text('RESUMO FINANCEIRO E CONSUMO'),
      const Offset(0, 300),
    );
    await tester.pumpAndSettle();

    expect(find.byType(UserDetailsModal), findsOneWidget);
  });
}
