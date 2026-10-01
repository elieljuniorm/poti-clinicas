import 'appointment_history_status.dart';

/// Um atendimento no histórico: quando, paciente, tipo e profissional.
class AppointmentHistoryModel {
  /// Data já formatada pela API (ex.: "24 Out, 2025"), como na Home.
  final String date;
  final String time;
  final String patient;
  final String appointmentType;
  final String professional;
  final AppointmentHistoryStatus status;

  const AppointmentHistoryModel({
    required this.date,
    required this.time,
    required this.patient,
    required this.appointmentType,
    required this.professional,
    required this.status,
  });
}
