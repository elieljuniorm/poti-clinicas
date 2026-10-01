import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/core/ui/widgets/app_select_field.dart';

void main() {
  const opcoes = ['Administrador', 'Colaborador', 'Recepcionista'];

  Future<GlobalKey<FormState>> montar(
    WidgetTester tester, {
    bool habilitado = true,
    String? valor,
    List<String?>? escolhidos,
  }) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: Column(
              children: [
                AppSelectField<String>(
                  rotulo: 'PERFIL DE ACESSO',
                  opcoes: opcoes,
                  rotuloOpcao: (o) => o,
                  valor: valor,
                  habilitado: habilitado,
                  aoMudar: (v) => escolhidos?.add(v),
                  validator: (v) => v == null ? 'Selecione uma opção' : null,
                ),
                const Text('ABAIXO DO SELECT'),
              ],
            ),
          ),
        ),
      ),
    );
    return formKey;
  }

  Future<void> tocarNoCampo(WidgetTester tester) async {
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();
  }

  testWidgets('abre a lista dentro do campo, empurrando o conteúdo', (
    tester,
  ) async {
    await montar(tester);
    expect(find.text('Selecione'), findsOneWidget);
    expect(find.text('Colaborador'), findsNothing);
    final antes = tester.getTopLeft(find.text('ABAIXO DO SELECT')).dy;

    await tocarNoCampo(tester);

    // Opções na tela, sem rota de menu por cima (inline).
    for (final opcao in opcoes) {
      expect(find.text(opcao), findsOneWidget);
    }
    expect(find.byType(PopupMenuButton), findsNothing);
    final depois = tester.getTopLeft(find.text('ABAIXO DO SELECT')).dy;
    expect(depois, greaterThan(antes));
  });

  testWidgets('escolher mostra o valor e fecha a lista', (tester) async {
    final escolhidos = <String?>[];
    await montar(tester, escolhidos: escolhidos);

    await tocarNoCampo(tester);
    await tester.tap(find.text('Colaborador'));
    await tester.pumpAndSettle();

    expect(escolhidos, ['Colaborador']);
    expect(find.text('Colaborador'), findsOneWidget); // só no cabeçalho
    expect(find.text('Administrador'), findsNothing);
  });

  testWidgets('tocar fora fecha a lista', (tester) async {
    await montar(tester);
    await tocarNoCampo(tester);
    expect(find.text('Administrador'), findsOneWidget);

    await tester.tap(find.text('ABAIXO DO SELECT'));
    await tester.pumpAndSettle();

    expect(find.text('Administrador'), findsNothing);
  });

  testWidgets('desabilitado mostra o valor e não abre', (tester) async {
    await montar(tester, habilitado: false, valor: 'Recepcionista');

    await tocarNoCampo(tester);

    expect(find.text('Recepcionista'), findsOneWidget);
    expect(find.text('Administrador'), findsNothing);
  });

  testWidgets('validação mostra o erro abaixo e some ao escolher', (
    tester,
  ) async {
    final formKey = await montar(tester);

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Selecione uma opção'), findsOneWidget);

    await tocarNoCampo(tester);
    await tester.tap(find.text('Administrador'));
    await tester.pumpAndSettle();

    expect(formKey.currentState!.validate(), isTrue);
    await tester.pump();
    expect(find.text('Selecione uma opção'), findsNothing);
  });

  Future<void> montarSozinho(WidgetTester tester, Widget campo) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Column(children: [campo])),
      ),
    );
  }

  testWidgets('sem rótulo: só o campo, funcionando fora de um Form', (
    tester,
  ) async {
    String? escolhido;
    await montarSozinho(
      tester,
      AppSelectField<String>(
        opcoes: opcoes,
        rotuloOpcao: (o) => o,
        dica: 'Filtrar por perfil',
        aoMudar: (v) => escolhido = v,
      ),
    );

    expect(find.text('PERFIL DE ACESSO'), findsNothing);
    await tocarNoCampo(tester);
    await tester.tap(find.text('Recepcionista'));
    await tester.pumpAndSettle();

    expect(escolhido, 'Recepcionista');
  });

  testWidgets('com ícone: opções alinhadas com o texto do cabeçalho', (
    tester,
  ) async {
    await montarSozinho(
      tester,
      AppSelectField<String>(
        rotulo: 'PERFIL',
        icon: Symbols.badge,
        opcoes: opcoes,
        rotuloOpcao: (o) => o,
        aoMudar: (_) {},
      ),
    );

    expect(find.byIcon(Symbols.badge), findsOneWidget);
    await tocarNoCampo(tester);

    final cabecalho = tester.getTopLeft(find.text('Selecione')).dx;
    final opcao = tester.getTopLeft(find.text('Administrador')).dx;
    expect(opcao, cabecalho);
  });

  testWidgets('lista longa rola por dentro até a altura máxima', (
    tester,
  ) async {
    final muitas = [for (var i = 1; i <= 30; i++) 'Opção $i'];
    await montarSozinho(
      tester,
      AppSelectField<String>(
        opcoes: muitas,
        rotuloOpcao: (o) => o,
        alturaMaximaLista: 120,
        aoMudar: (_) {},
      ),
    );

    await tocarNoCampo(tester);

    expect(
      tester.getSize(find.byType(ListView)).height,
      lessThanOrEqualTo(120),
    );
    expect(find.text('Opção 30'), findsNothing);
    await tester.scrollUntilVisible(find.text('Opção 30'), 100);
    expect(find.text('Opção 30'), findsOneWidget);
  });
}
