/// Formatação de datas para exibição (Dart puro, sem pacote de i18n).
abstract final class Datas {
  static String _doisDigitos(int valor) => valor.toString().padLeft(2, '0');

  static const meses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  /// Começa no domingo, como o calendário.
  static const diasDaSemana = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab'];

  /// Só a data, sem horário (meia-noite): serve para comparar dias.
  static DateTime dia(DateTime data) =>
      DateTime(data.year, data.month, data.day);

  /// "15/07/2025"
  static String data(DateTime data) =>
      '${_doisDigitos(data.day)}/${_doisDigitos(data.month)}/${data.year}';

  /// "Julho 2025"
  static String mesAno(DateTime data) =>
      '${meses[data.month - 1]} ${data.year}';

  /// "14:30"
  static String hora(int hora, int minuto) =>
      '${_doisDigitos(hora)}:${_doisDigitos(minuto)}';

  /// "Hoje, 13:30", "Ontem, 15:00", "12/02, 16:20" ou, de outro ano,
  /// "12/02/2025, 16:20". [agora] existe para os testes.
  static String relativa(DateTime data, {DateTime? agora}) {
    final referencia = agora ?? DateTime.now();
    final hoje = DateTime(referencia.year, referencia.month, referencia.day);
    final dia = DateTime(data.year, data.month, data.day);
    final hora = Datas.hora(data.hour, data.minute);

    final diferenca = hoje.difference(dia).inDays;
    if (diferenca == 0) return 'Hoje, $hora';
    if (diferenca == 1) return 'Ontem, $hora';

    final diaMes = '${_doisDigitos(data.day)}/${_doisDigitos(data.month)}';
    if (data.year == referencia.year) return '$diaMes, $hora';
    return '$diaMes/${data.year}, $hora';
  }
}
