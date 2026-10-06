import '../../domain/models/new_invoice_model.dart';

/// Representa a fatura exatamente como a API recebe.
class NewInvoiceDto {
  final String? preInvoiceId;
  final String patientId;
  final String patientName;
  final String professionalId;
  final String professionalName;
  final String type;
  final int sessions;
  final double sessionValue;
  final double total;
  final String paymentMethod;
  final int? percentage;
  final String? notes;

  NewInvoiceDto({
    this.preInvoiceId,
    required this.patientId,
    required this.patientName,
    required this.professionalId,
    required this.professionalName,
    required this.type,
    required this.sessions,
    required this.sessionValue,
    required this.total,
    required this.paymentMethod,
    this.percentage,
    this.notes,
  });

  // Model de domínio → DTO
  factory NewInvoiceDto.fromDomain(NewInvoiceModel model) {
    final observacoes = model.notes?.trim();
    return NewInvoiceDto(
      preInvoiceId: model.preInvoiceId,
      patientId: model.patientId,
      patientName: model.patientName,
      professionalId: model.professionalId,
      professionalName: model.professionalName,
      type: switch (model.type) {
        InvoiceType.homePackage => 'home_package',
        InvoiceType.clinicPackage => 'clinic_package',
        InvoiceType.single => 'single',
      },
      sessions: model.sessions,
      sessionValue: model.sessionValue,
      total: model.total,
      paymentMethod: switch (model.paymentMethod) {
        PaymentMethod.pix => 'pix',
        PaymentMethod.cash => 'cash',
        PaymentMethod.creditCard => 'credit_card',
        PaymentMethod.debitCard => 'debit_card',
        PaymentMethod.bankSlip => 'bank_slip',
      },
      percentage: model.percentage,
      notes: observacoes == null || observacoes.isEmpty ? null : observacoes,
    );
  }

  // DTO → JSON (campos opcionais vazios não são enviados)
  Map<String, dynamic> toJson() {
    return {
      'pre_invoice_id': ?preInvoiceId,
      'patient_id': patientId,
      'patient_name': patientName,
      'professional_id': professionalId,
      'professional_name': professionalName,
      'type': type,
      'sessions': sessions,
      'session_value': sessionValue,
      'total': total,
      'payment_method': paymentMethod,
      'percentage': ?percentage,
      'notes': ?notes,
    };
  }
}
