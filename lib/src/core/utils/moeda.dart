/// Formatação de valores em reais (Dart puro, sem pacote de i18n).
abstract final class Moeda {
  /// 2450.0 → "R$ 2.450,00"; -10.5 → "-R$ 10,50".
  static String formatar(double valor) {
    final centavos = (valor.abs() * 100).round();
    final inteiro = (centavos ~/ 100).toString();
    final decimal = (centavos % 100).toString().padLeft(2, '0');

    final sinal = valor < 0 && centavos > 0 ? '-' : '';
    return '${sinal}R\$ ${_agrupar(inteiro)},$decimal';
  }

  /// Lê o valor de um campo com máscara de moeda: os dígitos são os
  /// centavos. "R$ 1.234,56" → 1234.56; sem dígitos → `null`.
  static double? ler(String texto) {
    final digitos = texto.replaceAll(RegExp(r'\D'), '');
    if (digitos.isEmpty) return null;
    return int.parse(digitos) / 100;
  }

  /// Número inteiro com ponto de milhar, sem símbolo: 1500 → "1.500".
  /// Usado nos eixos de gráficos.
  static String formatarInteiro(double valor) {
    final inteiro = valor.abs().round().toString();
    final sinal = valor < 0 && valor.round() != 0 ? '-' : '';
    return '$sinal${_agrupar(inteiro)}';
  }

  /// Ponto a cada 3 dígitos, da direita para a esquerda.
  static String _agrupar(String digitos) {
    final buffer = StringBuffer();
    for (var i = 0; i < digitos.length; i++) {
      if (i > 0 && (digitos.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digitos[i]);
    }
    return buffer.toString();
  }
}
