import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/core/ui/theme/app_colors.dart';
import 'package:poti_5f/src/core/ui/widgets/app_action_buttons.dart';

Widget _app(Widget child, {double largura = 800}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(width: largura, child: child),
      ),
    ),
  );
}

void main() {
  testWidgets(
    'salvar e cancelar: cores, maiúsculas, 185x45 e 30px entre eles',
    (tester) async {
      var salvou = false;
      var cancelou = false;
      await tester.pumpWidget(
        _app(
          AppSaveCancelButtons(
            aoSalvar: () => salvou = true,
            aoCancelar: () => cancelou = true,
          ),
        ),
      );

      final salvar = find.widgetWithText(ElevatedButton, 'SALVAR');
      final cancelar = find.widgetWithText(ElevatedButton, 'CANCELAR');
      expect(salvar, findsOneWidget);
      expect(cancelar, findsOneWidget);

      expect(tester.getSize(salvar), const Size(185, 45));
      expect(tester.getSize(cancelar), const Size(185, 45));
      expect(
        tester.getTopLeft(cancelar).dx - tester.getTopRight(salvar).dx,
        30,
      );
      // Centralizados na linha.
      final centroLinha = tester
          .getCenter(find.byType(AppSaveCancelButtons))
          .dx;
      final centroPar =
          (tester.getTopLeft(salvar).dx + tester.getTopRight(cancelar).dx) / 2;
      expect(centroPar, centroLinha);

      Color? fundo(Finder f) =>
          tester.widget<ElevatedButton>(f).style?.backgroundColor?.resolve({});
      expect(fundo(salvar), AppColors.buttonSave);
      expect(fundo(cancelar), AppColors.buttonCancel);

      await tester.tap(salvar);
      await tester.tap(cancelar);
      expect(salvou, isTrue);
      expect(cancelou, isTrue);
    },
  );

  testWidgets('em tela estreita os botões encolhem sem estourar', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        AppSaveCancelButtons(aoSalvar: () {}, aoCancelar: () {}),
        largura: 300,
      ),
    );

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.widgetWithText(ElevatedButton, 'SALVAR')).width,
      135,
    );
  });

  testWidgets('salvando: indicador no salvar e cancelar desativado', (
    tester,
  ) async {
    var cancelou = false;
    await tester.pumpWidget(
      _app(
        AppSaveCancelButtons(
          salvando: true,
          aoSalvar: () {},
          aoCancelar: () => cancelou = true,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.text('CANCELAR'));
    expect(cancelou, isFalse);
  });
}
