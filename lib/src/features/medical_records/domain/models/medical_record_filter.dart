import 'medical_record_status.dart';

/// Filtro da lista do prontuário (chips do topo).
enum MedicalRecordFilter {
  all('Todos', null),
  inTherapy('Em Terapia', MedicalRecordStatus.inTherapy),
  newPatient('Novo', MedicalRecordStatus.newPatient),
  pending('Pendente', MedicalRecordStatus.pending),
  discharged('Alta Médica', MedicalRecordStatus.discharged);

  final String label;

  /// Status que o filtro mostra. `null` em "Todos".
  final MedicalRecordStatus? status;

  const MedicalRecordFilter(this.label, this.status);

  bool aceita(MedicalRecordStatus valor) => status == null || status == valor;
}
