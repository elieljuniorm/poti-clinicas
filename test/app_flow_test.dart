import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/main.dart';
import 'package:poti_5f/src/core/ui/widgets/app_bottom_nav.dart';
import 'package:poti_5f/src/features/finance/ui/pages/finance_screen.dart';
import 'package:poti_5f/src/features/finance/ui/pages/new_invoice_screen.dart';
import 'package:poti_5f/src/features/history/ui/pages/history_screen.dart';
import 'package:poti_5f/src/features/home/ui/pages/home_screen.dart';
import 'package:poti_5f/src/features/login/ui/pages/login_screen.dart';
import 'package:poti_5f/src/features/profile/ui/pages/profile_screen.dart';
import 'package:poti_5f/src/features/splash/ui/pages/splash_screen.dart';

/// Jornada completa usando o código real (data sources com mocks e delays).
///
/// Fica em um único teste porque o `appRouter` é global: a navegação de um
/// teste afetaria o próximo no mesmo arquivo.
void main() {
  testWidgets('splash → login → home → menu → perfil → logout', (tester) async {
    // Tela larga: a fonte de teste (Ahem) é mais larga que a Nunito
    // e causaria overflow falso em telas estreitas.
    tester.view.physicalSize = const Size(4000, 8000);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // ---------- Splash ----------
    expect(find.byType(SplashScreen), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 3500));
    await tester.pumpAndSettle();

    // ---------- Login com credenciais inválidas ----------
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(AppBottomNav), findsNothing);
    await tester.enterText(find.byType(TextField).at(0), 'teste@teste.com');
    await tester.enterText(find.byType(TextField).at(1), 'errada');
    await tester.tap(find.text('ENTRAR'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.byType(LoginScreen), findsOneWidget);
    // Mensagem aparece no formulário e no SnackBar.
    expect(find.text('Email ou senha inválidos'), findsNWidgets(2));

    // ---------- Login com credenciais válidas ----------
    await tester.enterText(find.byType(TextField).at(1), '123456');
    await tester.tap(find.text('ENTRAR'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // ---------- Home (carrega em 1s) ----------
    expect(find.byType(HomeScreen), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('ATENDIMENTOS DO DIA'), findsOneWidget);
    expect(find.text('Jorge Silva'), findsOneWidget);
    expect(find.text('Eduardo Marinho'), findsOneWidget);
    expect(find.text('R\$ 350,00'), findsOneWidget);

    // ---------- Menu inferior flutuante ----------
    // Login e splash não têm o menu; a Home tem, com "Início" ativo.
    expect(find.byType(AppBottomNav), findsOneWidget);
    await tester.tap(find.byTooltip('Histórico'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byType(HistoryScreen), findsOneWidget);
    expect(find.text('Lucas Meireles'), findsWidgets);

    await tester.tap(find.byTooltip('Início'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);

    // ---------- Menu lateral mostra o usuário logado ----------
    await tester.tap(find.byIcon(Symbols.menu));
    await tester.pumpAndSettle();
    expect(find.text('Olá, Eliel Maia'), findsOneWidget);

    // ---------- Item do menu abre o Financeiro ----------
    await tester.tap(find.text('Financeiro'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byType(FinanceScreen), findsOneWidget);
    expect(find.text('FATURAMENTO DO MÊS'), findsOneWidget);

    // ---------- Pré-faturas abaixo dos profissionais ----------
    expect(find.text('PRÉ-FATURAS'), findsOneWidget);
    expect(find.text('Juliana Mendes Souza'), findsOneWidget);

    // ---------- "Novo Lançamento" abre o formulário de fatura ----------
    await tester.tap(find.text('Novo Lançamento'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byType(NewInvoiceScreen), findsOneWidget);
    expect(
      find.text('PREENCHA OS DADOS PARA LANÇAR UMA NOVA FATURA'),
      findsOneWidget,
    );

    // ---------- Cabeçalho do menu abre "Meus dados" ----------
    await tester.tap(find.byIcon(Symbols.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver meus dados'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('EDITAR CADASTRO'), findsOneWidget);

    // ---------- Logout volta para o login ----------
    await tester.tap(find.byIcon(Symbols.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Symbols.logout));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
