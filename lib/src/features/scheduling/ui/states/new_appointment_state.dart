sealed class NewAppointmentState {
  const NewAppointmentState();
}

class NewAppointmentInitial extends NewAppointmentState {
  const NewAppointmentInitial();
}

class NewAppointmentSaving extends NewAppointmentState {
  const NewAppointmentSaving();
}

class NewAppointmentSuccess extends NewAppointmentState {
  /// Quantas sessões foram agendadas (para a mensagem de sucesso).
  final int sessions;
  const NewAppointmentSuccess(this.sessions);
}

class NewAppointmentError extends NewAppointmentState {
  final String message;
  const NewAppointmentError(this.message);
}
