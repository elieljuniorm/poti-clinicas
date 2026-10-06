/// "TIPO DE ATENDIMENTO" da fatura.
enum InvoiceType {
  homePackage('Pacote Domiciliar'),
  clinicPackage('Pacote Clínica'),
  single('Atendimento Avulso');

  final String label;

  const InvoiceType(this.label);
}

/// Forma de pagamento da fatura (select "PAGAMENTO").
enum PaymentMethod {
  pix('Pix'),
  cash('Dinheiro'),
  creditCard('Cartão de Crédito'),
  debitCard('Cartão de Débito'),
  bankSlip('Boleto');

  final String label;

  const PaymentMethod(this.label);
}

/// Fatura a lançar no Financeiro.
///
/// - Com [preInvoiceId]: finaliza a pré-fatura de um atendimento. As
///   sessões já estão agendadas; sessões a mais viram créditos.
/// - Sem [preInvoiceId] ("Novo Lançamento"): o paciente ainda não tem
///   atendimento, então todas as sessões viram créditos de agendamento,
///   usados quando o atendimento for criado na Agenda.
class NewInvoiceModel {
  final String? preInvoiceId;
  final String patientId;

  /// Nomes vão junto para o Financeiro mostrar sem buscar o cadastro.
  final String patientName;
  final String professionalId;
  final String professionalName;
  final InvoiceType type;
  final int sessions;
  final double sessionValue;
  final PaymentMethod paymentMethod;

  /// Percentual do profissional sobre o total (0 a 100). Opcional.
  final int? percentage;

  /// Observações sobre o pagamento ou o pacote. Opcional.
  final String? notes;

  const NewInvoiceModel({
    this.preInvoiceId,
    required this.patientId,
    required this.patientName,
    required this.professionalId,
    required this.professionalName,
    required this.type,
    required this.sessions,
    required this.sessionValue,
    required this.paymentMethod,
    this.percentage,
    this.notes,
  });

  double get total => sessionValue * sessions;
}
