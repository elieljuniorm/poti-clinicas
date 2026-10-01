import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/core/utils/moeda.dart';

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
}
