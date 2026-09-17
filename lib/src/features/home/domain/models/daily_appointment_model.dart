enum AppointmentStatus { confirmed, pending, canceled }

class DailyAppointmentModel {
  final String patient;
  final String time;
  final String appointmentType;
  final AppointmentStatus status;

  DailyAppointmentModel({
    required this.patient,
    required this.time,
    required this.appointmentType,
    required this.status,
  });
}