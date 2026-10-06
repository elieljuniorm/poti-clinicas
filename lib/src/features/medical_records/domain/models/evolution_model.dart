/// Evolução: o registro de uma sessão realizada no prontuário.
class EvolutionModel {
  final int sessionNumber;
  final DateTime sessionDate;
  final String professionalName;
  final String description;

  const EvolutionModel({
    required this.sessionNumber,
    required this.sessionDate,
    required this.professionalName,
    required this.description,
  });
}
