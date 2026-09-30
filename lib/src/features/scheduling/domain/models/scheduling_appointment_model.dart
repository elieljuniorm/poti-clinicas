import '../../../home/domain/models/daily_appointment_model.dart';

export '../../../home/domain/models/daily_appointment_model.dart'
    show AppointmentStatus;

class SchedulingAppointmentModel {
  final String date;
  final String time;
  final String patient;
  final String appointmentType;
  final AppointmentStatus status;

  const SchedulingAppointmentModel({
    required this.date,
    required this.time,
    required this.patient,
    required this.appointmentType,
    required this.status,
  });
}
