/// Consumo do pacote de sessões do paciente.
class ConsumptionModel {
  final int contracted;
  final int performed;
  final double sessionValue;
  final String? paymentMethod;

  const ConsumptionModel({
    required this.contracted,
    required this.performed,
    required this.sessionValue,
    this.paymentMethod,
  });

  int get available => (contracted - performed).clamp(0, contracted);

  /// Progresso do tratamento de 0 a 1.
  double get progress =>
      contracted == 0 ? 0 : (performed / contracted).clamp(0, 1);

  double get totalValue => contracted * sessionValue;
}
