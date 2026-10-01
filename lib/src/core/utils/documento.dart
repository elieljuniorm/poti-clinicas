/// Regras de CPF e CNPJ (dígitos verificadores).
///
/// Dart puro, para servir tanto à UI quanto aos DTOs.
abstract final class Documento {
  static const tamanhoCpf = 11;
  static const tamanhoCnpj = 14;

  /// Só os dígitos: "123.456.789-09" → "12345678909".
  static String digitos(String valor) => valor.replaceAll(RegExp(r'\D'), '');

  static bool cpfValido(String valor) {
    final d = digitos(valor);
    if (d.length != tamanhoCpf || _todosIguais(d)) return false;

    final numeros = d.split('').map(int.parse).toList();
    return _digito(numeros.sublist(0, 9), [10, 9, 8, 7, 6, 5, 4, 3, 2]) ==
            numeros[9] &&
        _digito(numeros.sublist(0, 10), [11, 10, 9, 8, 7, 6, 5, 4, 3, 2]) ==
            numeros[10];
  }

  static bool cnpjValido(String valor) {
    final d = digitos(valor);
    if (d.length != tamanhoCnpj || _todosIguais(d)) return false;

    final numeros = d.split('').map(int.parse).toList();
    return _digito(numeros.sublist(0, 12), [
              5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2, //
            ]) ==
            numeros[12] &&
        _digito(numeros.sublist(0, 13), [
              6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2, //
            ]) ==
            numeros[13];
  }

  // "111.111.111-11" passa no cálculo, mas não é um documento real.
  static bool _todosIguais(String d) => d.split('').toSet().length == 1;

  /// Dígito verificador (módulo 11), igual para CPF e CNPJ.
  static int _digito(List<int> numeros, List<int> pesos) {
    var soma = 0;
    for (var i = 0; i < numeros.length; i++) {
      soma += numeros[i] * pesos[i];
    }
    final resto = soma % 11;
    return resto < 2 ? 0 : 11 - resto;
  }
}
