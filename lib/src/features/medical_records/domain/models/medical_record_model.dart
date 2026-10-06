import 'medical_record_content.dart';

/// Prontuário: a ficha completa do paciente. Criado no primeiro
/// atendimento e modificado ao longo das sessões.
class MedicalRecordModel {
  final MedicalRecordContent content;
  final DateTime createdAt;

  /// Última modificação. Igual a [createdAt] enquanto não houver edição.
  final DateTime updatedAt;

  const MedicalRecordModel({
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get foiModificado => updatedAt.isAfter(createdAt);
}
