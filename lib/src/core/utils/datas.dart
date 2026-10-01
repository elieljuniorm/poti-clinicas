/// Formatação de datas para exibição (Dart puro, sem pacote de i18n).
abstract final class Datas {
  static String _doisDigitos(int valor) => valor.toString().padLeft(2, '0');

  /// "Hoje, 13:30", "Ontem, 15:00", "12/02, 16:20" ou, de outro ano,
  /// "12/02/2025, 16:20". [agora] existe para os testes.
  static String relativa(DateTime data, {DateTime? agora}) {
    final referencia = agora ?? DateTime.now();
    final hoje = DateTime(referencia.year, referencia.month, referencia.day);
    final dia = DateTime(data.year, data.month, data.day);
    final hora = '${_doisDigitos(data.hour)}:${_doisDigitos(data.minute)}';

    final diferenca = hoje.difference(dia).inDays;
    if (diferenca == 0) return 'Hoje, $hora';
    if (diferenca == 1) return 'Ontem, $hora';

    final diaMes = '${_doisDigitos(data.day)}/${_doisDigitos(data.month)}';
    if (data.year == referencia.year) return '$diaMes, $hora';
    return '$diaMes/${data.year}, $hora';
  }
}
