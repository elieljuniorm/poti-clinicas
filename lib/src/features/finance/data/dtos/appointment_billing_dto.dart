import '../../domain/models/appointment_billing_model.dart';

/// Sessões do atendimento como a API recebe para faturar.
class AppointmentBillingDto {
  final String patientId;
  final String patientName;
  final String professionalId;
  final String professionalName;
  final int sessions;

  AppointmentBillingDto({
    required this.patientId,
    required this.patientName,
    required this.professionalId,
    required this.professionalName,
    required this.sessions,
  });

  // Model de domínio → DTO
  factory AppointmentBillingDto.fromDomain(AppointmentBillingModel model) {
    return AppointmentBillingDto(
      patientId: model.patientId,
      patientName: model.patientName,
      professionalId: model.professionalId,
      professionalName: model.professionalName,
      sessions: model.sessions,
    );
  }

  // DTO → JSON
  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'patient_name': patientName,
      'professional_id': professionalId,
      'professional_name': professionalName,
      'sessions': sessions,
    };
  }
}

/// Resposta da API ao faturar as sessões do atendimento.
class AppointmentBillingResultDto {
  final int creditsUsed;
  final int pendingSessions;

  AppointmentBillingResultDto({
    required this.creditsUsed,
    required this.pendingSessions,
  });

  // JSON → DTO
  factory AppointmentBillingResultDto.fromJson(Map<String, dynamic> json) {
    return AppointmentBillingResultDto(
      creditsUsed: json['credits_used'] ?? 0,
      pendingSessions: json['pending_sessions'] ?? 0,
    );
  }

  // DTO → Model de domínio
  AppointmentBillingResult toDomain() {
    return AppointmentBillingResult(
      creditsUsed: creditsUsed,
      pendingSessions: pendingSessions,
    );
  }
}
