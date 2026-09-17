enum PaymentStatus { paid, pending }

class FinancialSummaryModel {
  final String date;
  final String time;
  final String patient;
  final String appointmentType;
  final String paymentMethod;
  final double amount;
  final PaymentStatus status;

  FinancialSummaryModel({
    required this.date,
    required this.time,
    required this.patient,
    required this.appointmentType,
    required this.paymentMethod,
    required this.amount,
    required this.status,
  });
}