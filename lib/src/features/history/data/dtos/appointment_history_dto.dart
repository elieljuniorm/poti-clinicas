import '../../domain/models/appointment_history_model.dart';
import '../../domain/models/appointment_history_status.dart';

/// Representa os dados exatamente como a API envia
/// e sabe se converter para o model do domínio.
class AppointmentHistoryDto {
  final String date;
  final String time;
  final String patientName;
  final String type;
  final String professionalName;
  final String status;

  AppointmentHistoryDto({
    required this.date,
    required this.time,
    required this.patientName,
    required this.type,
    required this.professionalName,
    required this.status,
  });

  // JSON → DTO
  factory AppointmentHistoryDto.fromJson(Map<String, dynamic> json) {
    return AppointmentHistoryDto(
      date: json['date'],
      time: json['time'],
      patientName: json['patient_name'],
      type: json['type'],
      professionalName: json['professional_name'],
      status: json['status'],
    );
  }

  // DTO → Model de domínio
  AppointmentHistoryModel toDomain() {
    return AppointmentHistoryModel(
      date: date,
      time: time,
      patient: patientName,
      appointmentType: type,
      professional: professionalName,
      status: switch (status) {
        'performed' => AppointmentHistoryStatus.performed,
        'canceled' => AppointmentHistoryStatus.canceled,
        _ => AppointmentHistoryStatus.confirmed,
      },
    );
  }
}
