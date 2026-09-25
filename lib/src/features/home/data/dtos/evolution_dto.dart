import '../../domain/models/evolution_model.dart';

/// Representa os dados exatamente como a API envia
/// e sabe se converter para o model do domínio.
class EvolutionDto {
  final String date;
  final String time;
  final String professionalName;
  final String patientName;
  final String type;
  final String status;

  EvolutionDto({
    required this.date,
    required this.time,
    required this.professionalName,
    required this.patientName,
    required this.type,
    required this.status,
  });

  // JSON → DTO
  factory EvolutionDto.fromJson(Map<String, dynamic> json) {
    return EvolutionDto(
      date: json['date'],
      time: json['time'],
      professionalName: json['professional_name'],
      patientName: json['patient_name'],
      type: json['type'],
      status: json['status'],
    );
  }

  // DTO → Model de domínio
  EvolutionModel toDomain() {
    return EvolutionModel(
      date: date,
      time: time,
      professional: professionalName,
      patient: patientName,
      appointmentType: type,
      status: status == 'closed'
          ? EvolutionStatus.closed
          : EvolutionStatus.open,
    );
  }
}
