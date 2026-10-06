import '../../../finance/domain/models/appointment_billing_model.dart';

sealed class NewAppointmentState {
  const NewAppointmentState();
}

class NewAppointmentInitial extends NewAppointmentState {
  const NewAppointmentInitial();
}

class NewAppointmentSaving extends NewAppointmentState {
  const NewAppointmentSaving();
}

class NewAppointmentSuccess extends NewAppointmentState {
  /// Quantas sessões foram agendadas (para a mensagem de sucesso).
  final int sessions;

  /// Como as sessões foram faturadas (créditos usados e pré-fatura).
  /// `null` quando o Financeiro falhou: veja [billingError].
  final AppointmentBillingResult? billing;

  /// O agendamento foi salvo, mas a pré-fatura não foi gerada.
  final String? billingError;

  const NewAppointmentSuccess(this.sessions, {this.billing, this.billingError});
}

class NewAppointmentError extends NewAppointmentState {
  final String message;
  const NewAppointmentError(this.message);
}
