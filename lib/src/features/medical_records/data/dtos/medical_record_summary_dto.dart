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
  final int pendingEvolutions;
  final bool discharged;

  MedicalRecordSummaryDto({
    required this.patientId,
    required this.patientName,
    required this.specialty,
    this.lastSessionAt,
    required this.hasRecord,
    required this.pendingEvolutions,
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
      pendingEvolutions: json['pending_evolutions'] ?? 0,
      discharged: json['discharged'] ?? false,
    );
  }

  // DTO → Model de domínio
  MedicalRecordSummaryModel toDomain() {
    final lastSessionAt = this.lastSessionAt;
    return MedicalRecordSummaryModel(
      patientId: patientId,
      patientName: patientName,
      specialty: specialty,
      lastSession: lastSessionAt == null
          ? null
          : DateTime.tryParse(lastSessionAt),
      hasRecord: hasRecord,
      pendingEvolutions: pendingEvolutions,
      discharged: discharged,
    );
  }
}
