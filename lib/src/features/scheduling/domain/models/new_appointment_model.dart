/// Uma sessão agendada: dia com horário de início e de fim.
class AppointmentSessionModel {
  final DateTime start;
  final DateTime end;

  const AppointmentSessionModel({required this.start, required this.end});
}

/// Novo agendamento: um paciente, um profissional e as sessões escolhidas.
class NewAppointmentModel {
  final String patientId;
  final String professionalId;
  final String appointmentType;

  /// Caso clínico (opcional).
  final String? clinicalCase;

  /// Em ordem de data.
  final List<AppointmentSessionModel> sessions;

  const NewAppointmentModel({
    required this.patientId,
    required this.professionalId,
    required this.appointmentType,
    this.clinicalCase,
    required this.sessions,
  });
}
