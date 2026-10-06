import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/features/finance/data/dtos/appointment_billing_dto.dart';
import 'package:poti_5f/src/features/finance/data/dtos/finance_dashboard_dto.dart';
import 'package:poti_5f/src/features/finance/data/dtos/new_invoice_dto.dart';
import 'package:poti_5f/src/features/finance/data/dtos/pre_invoice_dto.dart';
import 'package:poti_5f/src/features/finance/domain/models/new_invoice_model.dart';

void main() {
  const preFaturaJson = {
    'id': '7',
    'patient_id': '2',
    'patient_name': 'Juliana Mendes Souza',
    'professional_id': '1',
    'professional_name': 'Arnaldo Ribeiro',
    'sessions': 3,
    'created_at': '2026-07-15T09:00:00.000',
  };

  test('PreInvoiceDto: JSON → model', () {
    final model = PreInvoiceDto.fromJson(preFaturaJson).toDomain();

    expect(model.id, '7');
    expect(model.patientName, 'Juliana Mendes Souza');
    expect(model.professionalName, 'Arnaldo Ribeiro');
    expect(model.sessions, 3);
    expect(model.createdAt, DateTime(2026, 7, 15, 9));
  });

  test('painel: pré-faturas convertidas; sem o bloco, lista vazia', () {
    final comPreFaturas = FinanceDashboardDto.fromJson({
      'pre_invoices': [preFaturaJson],
    }).toDomain();
    final semPreFaturas = FinanceDashboardDto.fromJson({}).toDomain();

    expect(comPreFaturas.preInvoices.single.id, '7');
    expect(semPreFaturas.preInvoices, isEmpty);
  });

  group('NewInvoiceDto', () {
    NewInvoiceModel fatura({
      String? preInvoiceId,
      int? percentage,
      String? notes,
    }) {
      return NewInvoiceModel(
        preInvoiceId: preInvoiceId,
        patientId: '2',
        patientName: 'Juliana Mendes Souza',
        professionalId: '1',
        professionalName: 'Arnaldo Ribeiro',
        type: InvoiceType.homePackage,
        sessions: 4,
        sessionValue: 180,
        paymentMethod: PaymentMethod.creditCard,
        percentage: percentage,
        notes: notes,
      );
    }

    test('envia o total e os códigos da API', () {
      final json = NewInvoiceDto.fromDomain(
        fatura(preInvoiceId: '7', percentage: 40, notes: ' Pago em 2x '),
      ).toJson();

      expect(json, {
        'pre_invoice_id': '7',
        'patient_id': '2',
        'patient_name': 'Juliana Mendes Souza',
        'professional_id': '1',
        'professional_name': 'Arnaldo Ribeiro',
        'type': 'home_package',
        'sessions': 4,
        'session_value': 180.0,
        'total': 720.0,
        'payment_method': 'credit_card',
        'percentage': 40,
        'notes': 'Pago em 2x',
      });
    });

    test('opcionais vazios não são enviados', () {
      final json = NewInvoiceDto.fromDomain(fatura(notes: '   ')).toJson();

      expect(json.containsKey('pre_invoice_id'), isFalse);
      expect(json.containsKey('percentage'), isFalse);
      expect(json.containsKey('notes'), isFalse);
    });
  });

  test('AppointmentBillingResultDto: campos ausentes viram zero', () {
    final vazio = AppointmentBillingResultDto.fromJson({}).toDomain();
    final cheio = AppointmentBillingResultDto.fromJson({
      'credits_used': 2,
      'pending_sessions': 1,
    }).toDomain();

    expect(vazio.creditsUsed, 0);
    expect(vazio.pendingSessions, 0);
    expect(cheio.creditsUsed, 2);
    expect(cheio.pendingSessions, 1);
  });
}
