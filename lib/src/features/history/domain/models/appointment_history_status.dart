/// Situação de um atendimento no histórico.
enum AppointmentHistoryStatus {
  confirmed('Confirmada'),
  performed('Realizada'),
  canceled('Cancelada');

  final String label;

  const AppointmentHistoryStatus(this.label);
}
