/// Responsável pelo paciente. Quando o paciente é o próprio responsável,
/// leva os dados do próprio paciente.
class PatientResponsibleModel {
  final String name;
  final String email;
  final String phone;

  /// `DD/MM/AAAA`.
  final String birthDate;

  const PatientResponsibleModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.birthDate,
  });
}
