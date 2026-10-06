import '../../domain/models/daily_revenue_model.dart';
import '../../domain/models/finance_dashboard_model.dart';
import '../../domain/models/professional_payout_model.dart';
import 'pre_invoice_dto.dart';

/// Representa os dados exatamente como a API envia
/// e sabe se converter para o model do domínio.
class FinanceDashboardDto {
  final double monthReceived;
  final double monthPending;
  final List<Map<String, dynamic>> week;
  final List<Map<String, dynamic>> professionals;
  final List<PreInvoiceDto> preInvoices;

  FinanceDashboardDto({
    required this.monthReceived,
    required this.monthPending,
    required this.week,
    required this.professionals,
    required this.preInvoices,
  });

  static double _valor(dynamic json) => (json as num? ?? 0).toDouble();

  static List<Map<String, dynamic>> _lista(dynamic json) =>
      (json as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

  // JSON → DTO
  factory FinanceDashboardDto.fromJson(Map<String, dynamic> json) {
    final mes = (json['month_revenue'] as Map<String, dynamic>?) ?? const {};
    return FinanceDashboardDto(
      monthReceived: _valor(mes['received']),
      monthPending: _valor(mes['pending']),
      week: _lista(json['week_revenue']),
      professionals: _lista(json['professionals']),
      preInvoices: _lista(json['pre_invoices'])
          .map(PreInvoiceDto.fromJson)
          .toList(),
    );
  }

  // DTO → Model de domínio
  FinanceDashboardModel toDomain() {
    return FinanceDashboardModel(
      monthReceived: monthReceived,
      monthPending: monthPending,
      week: week
          .map(
            (json) => DailyRevenueModel(
              day: json['day'],
              amount: _valor(json['amount']),
            ),
          )
          .toList(),
      professionals: professionals
          .map(
            (json) => ProfessionalPayoutModel(
              professionalId: json['professional_id'],
              name: json['name'],
              specialty: json['specialty'],
              photoUrl: json['photo_url'],
              appointments: json['appointments'] ?? 0,
              weekAmount: _valor(json['week_amount']),
              amountToPay: _valor(json['amount_to_pay']),
            ),
          )
          .toList(),
      preInvoices: preInvoices.map((dto) => dto.toDomain()).toList(),
    );
  }
}
