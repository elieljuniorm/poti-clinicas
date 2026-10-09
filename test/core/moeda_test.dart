import 'package:flutter_test/flutter_test.dart';
import 'package:multiclinica_app/src/core/ui/formatters/moeda_input_formatter.dart';
import 'package:multiclinica_app/src/core/utils/moeda.dart';

void main() {
  test('centavos e separador de milhar', () {
    expect(Moeda.formatar(0), 'R\$ 0,00');
    expect(Moeda.formatar(180), 'R\$ 180,00');
    expect(Moeda.formatar(2450), 'R\$ 2.450,00');
    expect(Moeda.formatar(1234567.8), 'R\$ 1.234.567,80');
  });

  test('arredonda os centavos', () {
    expect(Moeda.formatar(10.005), 'R\$ 10,01');
    expect(Moeda.formatar(0.1 + 0.2), 'R\$ 0,30');
  });

  test('negativo com o sinal antes do símbolo', () {
    expect(Moeda.formatar(-10.5), '-R\$ 10,50');
  });

  test('ler: os dígitos são os centavos; sem dígitos é null', () {
    expect(Moeda.ler('R\$ 1.234,56'), 1234.56);
    expect(Moeda.ler('R\$ 0,05'), 0.05);
    expect(Moeda.ler(''), isNull);
    expect(Moeda.ler('R\$ '), isNull);
  });

  test('máscara de digitação: entra pela direita, cursor no fim', () {
    final mascara = MoedaInputFormatter();
    TextEditingValue digitar(String texto) => mascara.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: texto),
    );

    expect(digitar('1').text, 'R\$ 0,01');
    expect(digitar('R\$ 0,012').text, 'R\$ 0,12');
    expect(digitar('123456').text, 'R\$ 1.234,56');
    expect(digitar('R\$ 0,0').text, 'R\$ 0,00');
    expect(digitar('R\$ ').text, isEmpty);
    // Limite de dígitos.
    expect(digitar('12345678901').text, 'R\$ 1.234.567,89');

    final valor = digitar('150');
    expect(valor.selection.baseOffset, valor.text.length);
  });
}
