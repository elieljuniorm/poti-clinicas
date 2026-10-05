/// Uma sessão agendada: dia com horário de início e de fim.
class AppointmentSessionModel {
  final DateTime start;
  final DateTime end;

  const AppointmentSessionModel({required this.start, required this.end});
}

/// Novo agendamento: um paciente, um profissional e as sessões escolhidas.
class NewAppointmentModel {
  final String patientId;

  /// Nomes vão junto para a agenda mostrar sem buscar o cadastro.
  final String patientName;
  final String professionalId;
  final String professionalName;
  final String appointmentType;

  /// Caso clínico (opcional).
  final String? clinicalCase;

  /// Em ordem de data.
  final List<AppointmentSessionModel> sessions;

  const NewAppointmentModel({
    required this.patientId,
    required this.patientName,
    required this.professionalId,
    required this.professionalName,
    required this.appointmentType,
    this.clinicalCase,
    required this.sessions,
  });
}
