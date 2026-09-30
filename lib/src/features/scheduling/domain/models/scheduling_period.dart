/// Período usado para filtrar a agenda (seletor Dia / Semana / Mês).
enum SchedulingPeriod {
  day('Dia'),
  week('Semana'),
  month('Mês');

  final String label;

  const SchedulingPeriod(this.label);
}
