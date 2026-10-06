/// Situação do paciente no prontuário (regra em
/// [MedicalRecordSummaryModel.statusEm]).
enum MedicalRecordStatus {
  /// Nenhuma sessão realizada ainda.
  newPatient('Novo'),

  /// Prontuário criado e evoluções em dia.
  inTherapy('Em Terapia'),

  /// Sessão realizada sem prontuário, ou sessão realizada há mais de 24h
  /// sem evolução registrada.
  pending('Pendente'),

  /// Prontuário fechado: alta médica ou outro motivo relatado no prontuário.
  discharged('Alta Médica');

  final String label;

  const MedicalRecordStatus(this.label);
}
