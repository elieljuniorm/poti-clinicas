import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:multiclinica_app/src/features/medical_records/application/medical_records_controller.dart';
import 'package:multiclinica_app/src/features/medical_records/ui/pages/medical_records_screen.dart';

import '../application/fake_medical_records_repository.dart';

void main() {
  late GoRouter router;

  Future<void> abrir(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    router = GoRouter(
      initialLocation: '/prontuario',
      routes: [
        GoRoute(
          path: '/prontuario',
          name: 'prontuario',
          builder: (context, state) => const MedicalRecordsScreen(),
          routes: [
            GoRoute(
              path: ':patientId/novo',
              name: 'prontuario-criar',
              builder: (context, state) =>
                  Text('CRIAR ${state.pathParameters['patientId']}'),
            ),
            GoRoute(
              path: ':patientId',
              name: 'prontuario-registro',
              builder: (context, state) =>
                  Text('REGISTRO ${state.pathParameters['patientId']}'),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          medicalRecordsRepositoryProvider.overrideWithValue(
            FakeMedicalRecordsRepository(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('lista os pacientes com status e a ação certa', (tester) async {
    await abrir(tester);

    expect(find.text('Prontuário'), findsOneWidget);
    expect(find.text('Jorge Silva'), findsOneWidget);
    expect(find.text('Última sessão: 12/02, 13:30'), findsOneWidget);
    expect(find.text('Nenhuma sessão realizada'), findsOneWidget);

    // Etiquetas (o chip do filtro também tem o texto, por isso 2).
    expect(find.text('Em Terapia'), findsNWidgets(2));
    expect(find.text('Novo'), findsNWidgets(2));
    expect(find.text('Pendente'), findsNWidgets(2));
    expect(find.text('Alta Médica'), findsNWidgets(2));

    // Só o paciente sem prontuário tem "Criar Registro".
    expect(find.text('Criar Registro'), findsOneWidget);
    expect(find.text('Ver / Editar Registro'), findsNWidgets(3));
  });

  testWidgets('chips filtram e a busca procura pelo nome', (tester) async {
    await abrir(tester);

    await tester.tap(find.text('Pendente').first);
    await tester.pumpAndSettle();
    expect(find.text('Lucas Freitas'), findsOneWidget);
    expect(find.text('Jorge Silva'), findsNothing);

    await tester.tap(find.text('Todos'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'helena');
    await tester.pumpAndSettle();
    expect(find.text('Helena Costa'), findsOneWidget);
    expect(find.text('Lucas Freitas'), findsNothing);

    await tester.enterText(find.byType(TextField), 'ninguém');
    await tester.pumpAndSettle();
    expect(find.text('Nenhum paciente encontrado'), findsOneWidget);
  });

  testWidgets(
    '"Criar Registro" e "Ver / Editar" abrem o registro do paciente',
    (tester) async {
      await abrir(tester);

      await tester.tap(find.text('Criar Registro'));
      await tester.pumpAndSettle();
      expect(find.text('CRIAR 2'), findsOneWidget);

      router.goNamed('prontuario');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ver / Editar Registro').first);
      await tester.pumpAndSettle();
      expect(find.text('REGISTRO 1'), findsOneWidget);
    },
  );
}
