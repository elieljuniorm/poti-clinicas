/// Regras do CEP no formato único do app (e da API): `00000-000`.
///
/// Dart puro, para servir tanto à UI quanto aos DTOs.
abstract final class Cep {
  static const tamanho = 8;

  /// Só os dígitos: "66017-000" → "66017000".
  static String digitos(String valor) => valor.replaceAll(RegExp(r'\D'), '');

  /// Aplica a máscara ao que houver, mesmo incompleto (máx. 8 dígitos).
  /// "66017" → "66017", "660170" → "66017-0", "66017000" → "66017-000".
  static String mascarar(String valor) {
    var d = digitos(valor);
    if (d.length > tamanho) d = d.substring(0, tamanho);
    if (d.length <= 5) return d;
    return '${d.substring(0, 5)}-${d.substring(5)}';
  }

  /// CEP completo formatado ("66017-000"). `null` se não tiver 8 dígitos.
  static String? formatar(String valor) {
    final d = digitos(valor);
    if (d.length != tamanho) return null;
    return mascarar(d);
  }

  /// `true` se o texto já está exatamente no formato `00000-000`.
  static bool valido(String valor) => RegExp(r'^\d{5}-\d{3}$').hasMatch(valor);
}
