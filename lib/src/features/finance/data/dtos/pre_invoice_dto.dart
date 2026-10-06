import '../../domain/models/pre_invoice_model.dart';

/// Representa a pré-fatura exatamente como a API envia
/// e sabe se converter para o model do domínio.
/// Data em ISO 8601 no horário local.
class PreInvoiceDto {
  final String id;
  final String patientId;
  final String patientName;
  final String professionalId;
  final String professionalName;
  final int sessions;
  final String createdAt;

  PreInvoiceDto({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.professionalId,
    required this.professionalName,
    required this.sessions,
    required this.createdAt,
  });

  // JSON → DTO
  factory PreInvoiceDto.fromJson(Map<String, dynamic> json) {
    return PreInvoiceDto(
      id: json['id'],
      patientId: json['patient_id'],
      patientName: json['patient_name'],
      professionalId: json['professional_id'],
      professionalName: json['professional_name'],
      sessions: json['sessions'] ?? 0,
      createdAt: json['created_at'],
    );
  }

  // DTO → Model de domínio
  PreInvoiceModel toDomain() {
    return PreInvoiceModel(
      id: id,
      patientId: patientId,
      patientName: patientName,
      professionalId: professionalId,
      professionalName: professionalName,
      sessions: sessions,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
