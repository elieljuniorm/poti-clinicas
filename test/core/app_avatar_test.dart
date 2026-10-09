import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:multiclinica_app/src/core/ui/widgets/app_avatar.dart';

void main() {
  test('iniciais: primeiro e último nome, sem títulos', () {
    expect(AppAvatar.iniciais('Lucas Morais'), 'LM');
    expect(AppAvatar.iniciais('Maria Clara Rezende'), 'MR');
    expect(AppAvatar.iniciais('Dr. Arnaldo Ribeiro'), 'AR');
    expect(AppAvatar.iniciais('  ana  '), 'A');
    expect(AppAvatar.iniciais(''), '');
  });

  testWidgets('sem foto: iniciais com nome, ícone sem nome', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Row(
          children: [
            AppAvatar(nome: 'Lucas Morais'),
            AppAvatar(),
          ],
        ),
      ),
    );

    expect(find.text('LM'), findsOneWidget);
    expect(find.byIcon(Symbols.person), findsOneWidget);
  });
}
