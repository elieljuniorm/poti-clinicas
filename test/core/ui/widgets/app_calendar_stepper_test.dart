import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/core/ui/widgets/app_multi_date_calendar.dart';
import 'package:poti_5f/src/core/ui/widgets/app_quantity_stepper.dart';

void main() {
  group('AppMultiDateCalendar', () {
    final hoje = DateTime(2025, 7, 10);
    late List<DateTime> tocados;

    Future<void> montar(
      WidgetTester tester, {
      Set<DateTime> selecionadas = const {},
    }) async {
      tocados = [];
      tester.view.physicalSize = const Size(440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppMultiDateCalendar(
              hoje: hoje,
              selecionadas: selecionadas,
              aoAlternar: tocados.add,
            ),
          ),
        ),
      );
    }

    testWidgets('mostra o mês, os dias da semana e começa no dia certo', (
      tester,
    ) async {
      await montar(tester);

      expect(find.text('Julho 2025'), findsOneWidget);
      for (final dia in ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab']) {
        expect(find.text(dia), findsOneWidget);
      }
      // 01/07/2025 é terça: fica na mesma coluna do "Ter".
      expect(
        tester.getCenter(find.text('1')).dx,
        moreOrLessEquals(tester.getCenter(find.text('Ter')).dx, epsilon: 1),
      );
      expect(find.text('31'), findsOneWidget);
    });

    testWidgets('tocar em um dia futuro avisa; dia passado não responde', (
      tester,
    ) async {
      await montar(tester);

      await tester.tap(find.text('15'));
      await tester.tap(find.text('9')); // antes de hoje
      await tester.pump();

      expect(tocados, [DateTime(2025, 7, 15)]);
    });

    testWidgets('navega entre meses, sem voltar antes do mês de hoje', (
      tester,
    ) async {
      await montar(tester);

      await tester.tap(find.byTooltip('Mês anterior'));
      await tester.pump();
      expect(find.text('Julho 2025'), findsOneWidget);

      await tester.tap(find.byTooltip('Próximo mês'));
      await tester.pump();
      expect(find.text('Agosto 2025'), findsOneWidget);

      await tester.tap(find.byTooltip('Mês anterior'));
      await tester.pump();
      expect(find.text('Julho 2025'), findsOneWidget);
    });

    testWidgets('dia selecionado aparece marcado para leitores de tela', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await montar(tester, selecionadas: {DateTime(2025, 7, 15)});

      expect(
        tester.getSemantics(find.bySemanticsLabel('15/07/2025')),
        matchesSemantics(
          label: '15/07/2025',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          isEnabled: true,
          hasEnabledState: true,
          hasTapAction: true,
        ),
      );
      semantics.dispose();
    });
  });

  group('AppQuantityStepper', () {
    testWidgets('soma, subtrai e respeita os limites', (tester) async {
      var valor = 1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => AppQuantityStepper(
                rotulo: 'Sessões',
                valor: valor,
                maximo: 2,
                aoMudar: (v) => setState(() => valor = v),
              ),
            ),
          ),
        ),
      );

      // No mínimo: "diminuir" não faz nada.
      await tester.tap(find.byTooltip('Diminuir'));
      await tester.pump();
      expect(valor, 1);

      await tester.tap(find.byTooltip('Aumentar'));
      await tester.pump();
      expect(find.text('2'), findsOneWidget);

      // No máximo: "aumentar" não faz nada.
      await tester.tap(find.byTooltip('Aumentar'));
      await tester.pump();
      expect(valor, 2);

      await tester.tap(find.byTooltip('Diminuir'));
      await tester.pump();
      expect(valor, 1);
    });
  });
}
