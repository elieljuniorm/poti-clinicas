/// Regras de texto reutilizáveis (Dart puro).
abstract final class Texto {
  static const _comAcento = 'áàâãäéèêëíìîïóòôõöúùûüç';
  static const _semAcento = 'aaaaaeeeeiiiiooooouuuuc';

  /// Minúsculo e sem acentos, para buscas: "Antônio" → "antonio".
  static String normalizar(String texto) {
    final buffer = StringBuffer();
    for (final letra in texto.toLowerCase().split('')) {
      final i = _comAcento.indexOf(letra);
      buffer.write(i == -1 ? letra : _semAcento[i]);
    }
    return buffer.toString();
  }

  /// `true` se [texto] contém [termo], sem diferenciar maiúsculas e acentos.
  /// Termo vazio sempre combina.
  static bool contem(String texto, String termo) {
    final busca = normalizar(termo.trim());
    return busca.isEmpty || normalizar(texto).contains(busca);
  }
}
