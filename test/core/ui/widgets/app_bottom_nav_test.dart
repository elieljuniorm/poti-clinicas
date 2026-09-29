import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:poti_5f/src/core/ui/theme/app_colors.dart';
import 'package:poti_5f/src/core/ui/widgets/app_bottom_nav.dart';
import 'package:poti_5f/src/core/ui/widgets/app_bottom_spacer.dart';
import 'package:poti_5f/src/core/ui/widgets/app_scaffold.dart';

/// Página mínima que usa o [AppScaffold], como as telas reais.
class _Pagina extends StatelessWidget {
  final String titulo;
  final String rota;
  final bool mostrarMenuInferior;

  const _Pagina(this.titulo, this.rota, {this.mostrarMenuInferior = true});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      titulo: titulo,
      rotaAtual: rota,
      mostrarMenu: false,
      mostrarMenuInferior: mostrarMenuInferior,
      // Mesmo uso das páginas reais: spacer no fim do conteúdo rolável.
      body: SingleChildScrollView(
        child: Column(children: [Text(titulo), const AppBottomSpacer()]),
      ),
    );
  }
}

GoRouter _router(String inicial) => GoRouter(
  initialLocation: inicial,
  routes: [
    GoRoute(path: '/home', builder: (_, _) => const _Pagina('Home', '/home')),
    GoRoute(
      path: '/agenda',
      builder: (_, _) => const _Pagina('Agenda', '/agenda'),
      routes: [
        GoRoute(
          path: 'novo',
          builder: (_, _) => const _Pagina('Novo', '/agenda/novo'),
        ),
      ],
    ),
    GoRoute(
      path: '/prontuario',
      builder: (_, _) => const _Pagina('Prontuário', '/prontuario'),
    ),
    GoRoute(
      path: '/historico',
      builder: (_, _) => const _Pagina('Histórico', '/historico'),
    ),
    GoRoute(
      path: '/login',
      builder: (_, _) =>
          const _Pagina('Login', '/login', mostrarMenuInferior: false),
    ),
  ],
);

Future<GoRouter> _abrir(WidgetTester tester, String rota) async {
  final router = _router(rota);
  addTearDown(router.dispose);
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
  return router;
}

/// Opacidade do ícone de um item do menu.
double _opacidade(WidgetTester tester, IconData icone) {
  final icon = tester.widget<Icon>(
    find.descendant(
      of: find.byType(AppBottomNav),
      matching: find.byIcon(icone),
    ),
  );
  return icon.color!.a;
}

void main() {
  const icones = [
    Symbols.home,
    Symbols.calendar_clock,
    Symbols.conditions,
    Symbols.manage_history,
  ];

  testWidgets('mostra os 4 itens com os ícones e as cores definidas', (
    tester,
  ) async {
    await _abrir(tester, '/prontuario');

    for (final icone in icones) {
      expect(find.byIcon(icone), findsOneWidget);
    }
    for (final label in ['Início', 'Agenda', 'Prontuário', 'Histórico']) {
      expect(find.byTooltip(label), findsOneWidget);
    }

    final barra = tester.widget<BottomAppBar>(find.byType(BottomAppBar));
    expect(barra.color, const Color(0xFF197E90));

    final home = tester.widget<Icon>(find.byIcon(Symbols.home));
    expect(home.color!.withValues(alpha: 1), AppColors.bottomNavForeground);
  });

  testWidgets('item da página atual fica com 50% de opacidade', (tester) async {
    await _abrir(tester, '/home');

    expect(_opacidade(tester, Symbols.home), closeTo(0.5, 0.01));
    expect(_opacidade(tester, Symbols.calendar_clock), 1);
    expect(_opacidade(tester, Symbols.conditions), 1);
    expect(_opacidade(tester, Symbols.manage_history), 1);
  });

  testWidgets('sub-rota mantém o item do menu ativo', (tester) async {
    await _abrir(tester, '/agenda/novo');

    expect(_opacidade(tester, Symbols.calendar_clock), closeTo(0.5, 0.01));
    expect(_opacidade(tester, Symbols.home), 1);
  });

  testWidgets('tocar em um item navega e troca o item ativo', (tester) async {
    final router = await _abrir(tester, '/home');

    await tester.tap(find.byTooltip('Histórico'));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, '/historico');
    expect(_opacidade(tester, Symbols.manage_history), closeTo(0.5, 0.01));
    expect(_opacidade(tester, Symbols.home), 1);
  });

  testWidgets('tocar no item ativo não navega', (tester) async {
    final router = await _abrir(tester, '/agenda/novo');

    await tester.tap(find.byTooltip('Agenda'));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, '/agenda/novo');
  });

  testWidgets('mostrarMenuInferior: false esconde o menu', (tester) async {
    await _abrir(tester, '/login');

    expect(find.byType(AppBottomNav), findsNothing);
  });

  testWidgets('menu some com o teclado aberto', (tester) async {
    await _abrir(tester, '/home');
    expect(find.byType(AppBottomNav), findsOneWidget);

    tester.view.viewInsets = const FakeViewPadding(bottom: 900);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();

    expect(find.byType(AppBottomNav), findsNothing);
  });

  testWidgets('AppBottomSpacer reserva a altura do menu flutuante', (
    tester,
  ) async {
    tester.view.padding = const FakeViewPadding(bottom: 102); // iPhone: 34pt
    addTearDown(tester.view.resetPadding);
    await _abrir(tester, '/home');

    final altura = tester.getSize(find.byType(AppBottomSpacer)).height;
    final topoDoMenu = tester.getTopLeft(find.byType(BottomAppBar)).dy;
    final alturaTela =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;

    // área segura (34) + afastamento (12) + barra (64) + folga (24)
    expect(altura, 34 + 12 + AppBottomNav.altura + 24);
    // Ou seja: o fim do conteúdo fica 24px acima do topo do menu.
    expect(alturaTela - altura + 24, topoDoMenu);
  });

  testWidgets('AppBottomSpacer encolhe quando o menu some', (tester) async {
    await _abrir(tester, '/login'); // mostrarMenuInferior: false

    expect(tester.getSize(find.byType(AppBottomSpacer)).height, 24);
  });
}
