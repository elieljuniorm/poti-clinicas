import '../../domain/models/new_appointment_model.dart';

/// Representa o agendamento exatamente como a API recebe.
/// Datas em ISO 8601 no horário local (ex.: "2025-07-15T14:30:00.000").
class NewAppointmentDto {
  final String patientId;
  final String professionalId;
  final String type;
  final String? clinicalCase;
  final List<({String start, String end})> sessions;

  NewAppointmentDto({
    required this.patientId,
    required this.professionalId,
    required this.type,
    this.clinicalCase,
    required this.sessions,
  });

  // Model de domínio → DTO
  factory NewAppointmentDto.fromDomain(NewAppointmentModel model) {
    final caso = model.clinicalCase?.trim();
    return NewAppointmentDto(
      patientId: model.patientId,
      professionalId: model.professionalId,
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
      'professional_id': professionalId,
      'type': type,
      'clinical_case': ?clinicalCase,
      'sessions': [
        for (final sessao in sessions)
          {'start': sessao.start, 'end': sessao.end},
      ],
    };
  }
}
