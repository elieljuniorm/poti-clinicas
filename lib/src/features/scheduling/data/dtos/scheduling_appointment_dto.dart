import '../../domain/models/scheduling_appointment_model.dart';

/// Representa os dados exatamente como a API envia (e recebe ao editar)
/// e sabe se converter para o model do domínio.
/// Datas em ISO 8601 no horário local.
class SchedulingAppointmentDto {
  final String id;
  final String patientId;
  final String patientName;
  final String professionalId;
  final String professionalName;
  final String type;
  final String? clinicalCase;
  final String start;
  final String end;
  final String status;

  SchedulingAppointmentDto({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.professionalId,
    required this.professionalName,
    required this.type,
    this.clinicalCase,
    required this.start,
    required this.end,
    required this.status,
  });

  // JSON → DTO
  factory SchedulingAppointmentDto.fromJson(Map<String, dynamic> json) {
    return SchedulingAppointmentDto(
      id: json['id'],
      patientId: json['patient_id'],
      patientName: json['patient_name'],
      professionalId: json['professional_id'],
      professionalName: json['professional_name'],
      type: json['type'],
      clinicalCase: json['clinical_case'],
      start: json['start'],
      end: json['end'],
      status: json['status'],
    );
  }

  // Model de domínio → DTO (usado ao editar)
  factory SchedulingAppointmentDto.fromDomain(SchedulingAppointmentModel m) {
    final caso = m.clinicalCase?.trim();
    return SchedulingAppointmentDto(
      id: m.id,
      patientId: m.patientId,
      patientName: m.patient,
      professionalId: m.professionalId,
      professionalName: m.professional,
      type: m.appointmentType,
      clinicalCase: caso == null || caso.isEmpty ? null : caso,
      start: m.start.toIso8601String(),
      end: m.end.toIso8601String(),
      status: m.status.name,
    );
  }

  // DTO → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'patient_name': patientName,
      'professional_id': professionalId,
      'professional_name': professionalName,
      'type': type,
      'clinical_case': ?clinicalCase,
      'start': start,
      'end': end,
      'status': status,
    };
  }

  // DTO → Model de domínio
  SchedulingAppointmentModel toDomain() {
    return SchedulingAppointmentModel(
      id: id,
      patientId: patientId,
      patient: patientName,
      professionalId: professionalId,
      professional: professionalName,
      appointmentType: type,
      clinicalCase: clinicalCase,
      start: DateTime.parse(start),
      end: DateTime.parse(end),
      status: switch (status) {
        'confirmed' => AppointmentStatus.confirmed,
        'canceled' => AppointmentStatus.canceled,
        _ => AppointmentStatus.pending,
      },
    );
  }
}
