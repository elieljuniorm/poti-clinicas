import '../../domain/models/new_appointment_model.dart';

/// Representa o agendamento exatamente como a API recebe.
/// Datas em ISO 8601 no horário local (ex.: "2025-07-15T14:30:00.000").
class NewAppointmentDto {
  final String patientId;
  final String patientName;
  final String professionalId;
  final String professionalName;
  final String type;
  final String? clinicalCase;
  final List<({String start, String end})> sessions;

  NewAppointmentDto({
    required this.patientId,
    required this.patientName,
    required this.professionalId,
    required this.professionalName,
    required this.type,
    this.clinicalCase,
    required this.sessions,
  });

  // Model de domínio → DTO
  factory NewAppointmentDto.fromDomain(NewAppointmentModel model) {
    final caso = model.clinicalCase?.trim();
    return NewAppointmentDto(
      patientId: model.patientId,
      patientName: model.patientName,
      professionalId: model.professionalId,
      professionalName: model.professionalName,
      type: model.appointmentType,
      clinicalCase: caso == null || caso.isEmpty ? null : caso,
      sessions: [
        for (final sessao in model.sessions)
          (
            start: sessao.start.toIso8601String(),
            end: sessao.end.toIso8601String(),
          ),
      ],
    );
  }

  // DTO → JSON (caso clínico vazio não é enviado)
  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'patient_name': patientName,
      'professional_id': professionalId,
      'professional_name': professionalName,
      'type': type,
      'clinical_case': ?clinicalCase,
      'sessions': [
        for (final sessao in sessions)
          {'start': sessao.start, 'end': sessao.end},
      ],
    };
  }
}
