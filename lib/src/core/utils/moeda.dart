/// Formatação de valores em reais (Dart puro, sem pacote de i18n).
abstract final class Moeda {
  /// 2450.0 → "R$ 2.450,00"; -10.5 → "-R$ 10,50".
  static String formatar(double valor) {
    final centavos = (valor.abs() * 100).round();
    final inteiro = (centavos ~/ 100).toString();
    final decimal = (centavos % 100).toString().padLeft(2, '0');

    // Ponto a cada 3 dígitos, da direita para a esquerda.
    final buffer = StringBuffer();
    for (var i = 0; i < inteiro.length; i++) {
      if (i > 0 && (inteiro.length - i) % 3 == 0) buffer.write('.');
      buffer.write(inteiro[i]);
    }

    final sinal = valor < 0 && centavos > 0 ? '-' : '';
    return '${sinal}R\$ $buffer,$decimal';
  }
}
