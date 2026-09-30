/// Dados profissionais (especialidade, registro no conselho, vínculo).
class ProfessionalInfoModel {
  final String specialty;
  final String registry;
  final String bond;
  final String since;

  const ProfessionalInfoModel({
    required this.specialty,
    required this.registry,
    required this.bond,
    required this.since,
  });
}
