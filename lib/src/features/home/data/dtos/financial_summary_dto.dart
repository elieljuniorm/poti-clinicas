import '../../domain/models/financial_summary_model.dart';

/// Representa os dados exatamente como a API envia
/// e sabe se converter para o model do domínio.
class FinancialSummaryDto {
  final String date;
  final String time;
  final String patientName;
  final String type;
  final String paymentMethod;
  final double amount;
  final String status;

  FinancialSummaryDto({
    required this.date,
    required this.time,
    required this.patientName,
    required this.type,
    required this.paymentMethod,
    required this.amount,
    required this.status,
  });

  // JSON → DTO
  factory FinancialSummaryDto.fromJson(Map<String, dynamic> json) {
    return FinancialSummaryDto(
      date: json['date'],
      time: json['time'],
      patientName: json['patient_name'],
      type: json['type'],
      paymentMethod: json['payment_method'],
      amount: (json['amount'] as num).toDouble(),
      status: json['status'],
    );
  }

  // DTO → Model de domínio
  FinancialSummaryModel toDomain() {
    return FinancialSummaryModel(
      date: date,
      time: time,
      patient: patientName,
      appointmentType: type,
      paymentMethod: paymentMethod,
      amount: amount,
      status: status == 'paid' ? PaymentStatus.paid : PaymentStatus.pending,
    );
  }
}
