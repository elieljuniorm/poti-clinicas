import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/core/ui/widgets/app_area_chart.dart';
import 'package:poti_5f/src/core/utils/moeda.dart';

void main() {
  group('escala do eixo Y', () {
    test('números redondos acima do maior valor', () {
      expect(AppAreaChart.escala(1330), (1500.0, 300.0));
      expect(AppAreaChart.escala(1000), (1000.0, 200.0));
      expect(AppAreaChart.escala(87), (100.0, 20.0));
      expect(AppAreaChart.escala(18750), (20000.0, 5000.0));
    });

    test('sem valores: escala mínima, sem dividir por zero', () {
      final (topo, passo) = AppAreaChart.escala(0);
      expect(topo, greaterThan(0));
      expect(passo, greaterThan(0));
    });
  });

  test('inteiro com ponto de milhar para o eixo', () {
    expect(Moeda.formatarInteiro(1500), '1.500');
    expect(Moeda.formatarInteiro(0), '0');
    expect(Moeda.formatarInteiro(1234567), '1.234.567');
  });

  const pontos = [
    AppChartPoint('Seg', 820),
    AppChartPoint('Ter', 930),
    AppChartPoint('Sab', 1330),
  ];

  final selecoes = <int?>[];

  Future<void> montar(WidgetTester tester) async {
    selecoes.clear();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: AppAreaChart(
              pontos: pontos,
              descricao: 'Faturamento da semana',
              aoSelecionar: selecoes.add,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('leitor de tela recebe a série e todos os valores', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await montar(tester);

    expect(
      find.bySemanticsLabel(
        'Faturamento da semana. Seg: R\$ 820,00, Ter: R\$ 930,00, '
        'Sab: R\$ 1.330,00',
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('tocar seleciona o ponto mais próximo; tocar fora limpa', (
    tester,
  ) async {
    await montar(tester);
    final grafico = tester.getRect(find.byType(AppAreaChart));

    // Perto da borda direita → último ponto (Sab).
    await tester.tapAt(Offset(grafico.right - 4, grafico.center.dy));
    await tester.pump();
    // Perto da esquerda → primeiro ponto (Seg).
    await tester.tapAt(Offset(grafico.left + 40, grafico.center.dy));
    await tester.pump();
    // Fora do gráfico.
    await tester.tapAt(Offset(grafico.right + 100, grafico.bottom + 100));
    await tester.pump();

    expect(selecoes, [2, 0, null]);
  });

  testWidgets('arrastar acompanha o dedo', (tester) async {
    await montar(tester);
    final grafico = tester.getRect(find.byType(AppAreaChart));

    await tester.dragFrom(
      Offset(grafico.left + 40, grafico.center.dy),
      Offset(grafico.width - 50, 0),
    );
    await tester.pump();

    expect(selecoes.first, 0);
    expect(selecoes.last, 2);
  });
}
