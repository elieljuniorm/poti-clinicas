import '../../domain/models/medical_record_summary_model.dart';

/// Representa os dados exatamente como a API envia
/// e sabe se converter para o model do domínio.
class MedicalRecordSummaryDto {
  final String patientId;
  final String patientName;
  final String specialty;

  /// ISO 8601 (ex.: "2026-10-01T13:30:00").
  final String? lastSessionAt;
  final bool hasRecord;

  /// ISO 8601: sessão realizada mais antiga ainda sem evolução.
  final String? pendingEvolutionSince;
  final bool discharged;

  MedicalRecordSummaryDto({
    required this.patientId,
    required this.patientName,
    required this.specialty,
    this.lastSessionAt,
    required this.hasRecord,
    this.pendingEvolutionSince,
    required this.discharged,
  });

  // JSON → DTO
  factory MedicalRecordSummaryDto.fromJson(Map<String, dynamic> json) {
    return MedicalRecordSummaryDto(
      patientId: json['patient_id'],
      patientName: json['patient_name'],
      specialty: json['specialty'],
      lastSessionAt: json['last_session_at'],
      hasRecord: json['has_record'] ?? false,
      pendingEvolutionSince: json['pending_evolution_since'],
      discharged: json['discharged'] ?? false,
    );
  }

  // DTO → Model de domínio
  MedicalRecordSummaryModel toDomain() {
    return MedicalRecordSummaryModel(
      patientId: patientId,
      patientName: patientName,
      specialty: specialty,
      lastSession: _data(lastSessionAt),
      hasRecord: hasRecord,
      pendingEvolutionSince: _data(pendingEvolutionSince),
      discharged: discharged,
    );
  }

  /// Data inválida vira `null` em vez de quebrar a lista.
  static DateTime? _data(String? iso) =>
      iso == null ? null : DateTime.tryParse(iso);
}
