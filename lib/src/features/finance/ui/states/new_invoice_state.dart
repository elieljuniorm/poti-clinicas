sealed class NewInvoiceState {
  const NewInvoiceState();
}

class NewInvoiceInitial extends NewInvoiceState {
  const NewInvoiceInitial();
}

class NewInvoiceSaving extends NewInvoiceState {
  const NewInvoiceSaving();
}

class NewInvoiceSuccess extends NewInvoiceState {
  /// Créditos de agendamento que o paciente ganhou (para a mensagem).
  final int credits;
  const NewInvoiceSuccess(this.credits);
}

class NewInvoiceError extends NewInvoiceState {
  final String message;
  const NewInvoiceError(this.message);
}
