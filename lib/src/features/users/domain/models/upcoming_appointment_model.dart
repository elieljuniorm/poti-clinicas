/// Próximo atendimento agendado de um profissional.
class UpcomingAppointmentModel {
  final String date;
  final String time;
  final String patient;
  final String appointmentType;

  const UpcomingAppointmentModel({
    required this.date,
    required this.time,
    required this.patient,
    required this.appointmentType,
  });
}
