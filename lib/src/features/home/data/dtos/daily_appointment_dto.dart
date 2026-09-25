import '../../domain/models/daily_appointment_model.dart';

/// Representa os dados exatamente como a API envia
/// e sabe se converter para o model do domínio.
class DailyAppointmentDto {
  final String patientName;
  final String time;
  final String type;
  final String status;

  DailyAppointmentDto({
    required this.patientName,
    required this.time,
    required this.type,
    required this.status,
  });

  // JSON → DTO
  factory DailyAppointmentDto.fromJson(Map<String, dynamic> json) {
    return DailyAppointmentDto(
      patientName: json['patient_name'],
      time: json['time'],
      type: json['type'],
      status: json['status'],
    );
  }

  // DTO → Model de domínio
  DailyAppointmentModel toDomain() {
    return DailyAppointmentModel(
      patient: patientName,
      time: time,
      appointmentType: type,
      status: switch (status) {
        'confirmed' => AppointmentStatus.confirmed,
        'canceled' => AppointmentStatus.canceled,
        _ => AppointmentStatus.pending,
      },
    );
  }
}
