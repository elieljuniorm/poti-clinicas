import '../../domain/models/discharge_model.dart';
import '../../domain/models/evolution_model.dart';
import '../../domain/models/medical_record_create_model.dart';
import '../../domain/models/medical_record_details_model.dart';
import '../../domain/models/medical_record_model.dart';
import 'medical_record_content_dto.dart';
import 'medical_record_summary_dto.dart';

/// Representa o prontuário de um paciente exatamente como a API envia
/// (GET /medical-records/{patientId}). Os campos do resumo (status) vêm
/// na raiz, iguais aos da lista.
class MedicalRecordDetailsDto {
  final MedicalRecordSummaryDto summary;
  final String email;
  final String professionalName;
  final int sessionCount;
  final Map<String, dynamic>? record;
  final Map<String, dynamic>? latestEvolution;
  final Map<String, dynamic>? discharge;

  MedicalRecordDetailsDto({
    required this.summary,
    required this.email,
    required this.professionalName,
    required this.sessionCount,
    this.record,
    this.latestEvolution,
    this.discharge,
  });

  // JSON → DTO
  factory MedicalRecordDetailsDto.fromJson(Map<String, dynamic> json) {
    return MedicalRecordDetailsDto(
      summary: MedicalRecordSummaryDto.fromJson(json),
      email: json['email'] ?? '',
      professionalName: json['professional_name'] ?? '',
      sessionCount: json['session_count'] ?? 0,
      record: json['record'],
      latestEvolution: json['latest_evolution'],
      discharge: json['discharge'],
    );
  }

  // DTO → Model de domínio
  MedicalRecordDetailsModel toDomain() {
    final record = this.record;
    final evolution = latestEvolution;
    final discharge = this.discharge;
    return MedicalRecordDetailsModel(
      summary: summary.toDomain(),
      email: email,
      professionalName: professionalName,
      sessionCount: sessionCount,
      record: record == null
          ? null
          : MedicalRecordModel(
              content: MedicalRecordContentDto.fromJson(
                record['content'] ?? const {},
              ).toDomain(),
              createdAt: DateTime.parse(record['created_at']),
              updatedAt: DateTime.parse(record['updated_at']),
            ),
      latestEvolution: evolution == null
          ? null
          : EvolutionModel(
              sessionNumber: evolution['session_number'],
              sessionDate: DateTime.parse(evolution['session_date']),
              professionalName: evolution['professional_name'] ?? '',
              description: evolution['description'] ?? '',
            ),
      discharge: discharge == null
          ? null
          : DischargeModel(
              reason:
                  DischargeReason.values.asNameMap()[discharge['reason']] ??
                  DischargeReason.other,
              description: discharge['description'] ?? '',
              date: DateTime.parse(discharge['discharged_at']),
              professionalName: discharge['professional_name'] ?? '',
            ),
    );
  }

  /// Corpo do POST /medical-records/{patientId}.
  static Map<String, dynamic> createJson(MedicalRecordCreateModel model) {
    final evolucao = model.evolution?.trim();
    return {
      'content': MedicalRecordContentDto.fromDomain(model.content).toJson(),
      if (evolucao != null && evolucao.isNotEmpty)
        'evolution': {'description': evolucao},
    };
  }

  /// Corpo do POST /medical-records/{patientId}/discharge.
  static Map<String, dynamic> dischargeJson(
    DischargeReason motivo,
    String descricao,
  ) => {'reason': motivo.name, 'description': descricao.trim()};
}
