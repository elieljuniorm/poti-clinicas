/// Repasse de um profissional: atendimentos do período e quanto pagar.
class ProfessionalPayoutModel {
  final String professionalId;
  final String name;
  final String specialty;
  final String? photoUrl;

  /// Atendimentos realizados no mês.
  final int appointments;

  /// Valor gerado na semana atual.
  final double weekAmount;

  /// Total a pagar ao profissional (repasse do mês).
  final double amountToPay;

  const ProfessionalPayoutModel({
    required this.professionalId,
    required this.name,
    required this.specialty,
    this.photoUrl,
    required this.appointments,
    required this.weekAmount,
    required this.amountToPay,
  });
}
