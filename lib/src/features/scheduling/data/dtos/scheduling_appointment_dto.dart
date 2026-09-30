import '../../domain/models/scheduling_appointment_model.dart';

/// Representa os dados exatamente como a API envia
/// e sabe se converter para o model do domínio.
class SchedulingAppointmentDto {
  final String date;
  final String time;
  final String patientName;
  final String type;
  final String status;

  SchedulingAppointmentDto({
    required this.date,
    required this.time,
    required this.patientName,
    required this.type,
    required this.status,
  });

  // JSON → DTO
  factory SchedulingAppointmentDto.fromJson(Map<String, dynamic> json) {
    return SchedulingAppointmentDto(
      date: json['date'],
      time: json['time'],
      patientName: json['patient_name'],
      type: json['type'],
      status: json['status'],
    );
  }

  // DTO → Model de domínio
  SchedulingAppointmentModel toDomain() {
    return SchedulingAppointmentModel(
      date: date,
      time: time,
      patient: patientName,
      appointmentType: type,
      status: switch (status) {
        'confirmed' => AppointmentStatus.confirmed,
        'canceled' => AppointmentStatus.canceled,
        _ => AppointmentStatus.pending,
      },
    );
  }
}
