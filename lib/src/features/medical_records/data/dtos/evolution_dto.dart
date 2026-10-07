import '../../../../core/utils/datas.dart';
import '../../domain/models/evolution_model.dart';

/// Representa a evolução exatamente como a API envia e recebe.
/// Datas em ISO 8601; textos vazios não são enviados.
class EvolutionDto {
  final Map<String, dynamic> json;

  EvolutionDto(this.json);

  // DTO → Model de domínio. Evoluções antigas podem vir sem os campos
  // novos: textos vazios, sem status e sem escala.
  EvolutionModel toDomain() {
    final escala = json['scale'] as Map<String, dynamic>?;
    final sessao = DateTime.parse(json['session_date']);
    final profissional = json['professional_name'] ?? '';
    final tipoEscala = AssessmentScale.values.asNameMap()[escala?['type']];

    return EvolutionModel(
      sessionNumber: json['session_number'],
      sessionDate: sessao,
      professionalName: profissional,
      description: json['description'] ?? '',
      observations: json['observations'] ?? '',
      clinicalProgress: json['clinical_progress'] ?? '',
      patientStatus: EvolutionPatientStatus.values
          .asNameMap()[json['patient_status']],
      scale: tipoEscala == null
          ? null
          : EvolutionScaleModel(
              scale: tipoEscala,
              result: escala?['result'] ?? '',
            ),
      registeredBy: json['registered_by'] ?? profissional,
      registeredAt: DateTime.tryParse(json['registered_at'] ?? '') ?? sessao,
    );
  }

  /// Corpo enviado ao registrar a evolução. A API completa quem
  /// registrou (usuário logado) e quando.
  static Map<String, dynamic> createJson(EvolutionCreateModel model) {
    String? texto(String valor) => valor.trim().isEmpty ? null : valor.trim();
    final escala = model.scale;

    return {
      'session_number': model.sessionNumber,
      'session_date': Datas.dia(model.sessionDate).toIso8601String(),
      'professional_id': model.professionalId,
      'description': model.description.trim(),
      'observations': ?texto(model.observations),
      'clinical_progress': ?texto(model.clinicalProgress),
      'patient_status': model.patientStatus.name,
      if (escala != null)
        'scale': {'type': escala.scale.name, 'result': escala.result.trim()},
    };
  }
}
