/// Situação do paciente no prontuário.
enum MedicalRecordStatus {
  /// Ainda sem prontuário criado (paciente recém-cadastrado).
  newPatient('Novo'),

  /// Prontuário criado e evolução do último atendimento feita.
  inTherapy('Em Terapia'),

  /// Um ou mais atendimentos com evolução pendente.
  pending('Pendente'),

  /// Paciente evoluiu para alta.
  discharged('Alta Médica');

  final String label;

  const MedicalRecordStatus(this.label);
}
