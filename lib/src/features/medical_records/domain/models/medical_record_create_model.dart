import 'medical_record_content.dart';

/// Criação do prontuário. No primeiro cadastro a evolução da última
/// sessão realizada pode ser registrada junto ([evolution]).
class MedicalRecordCreateModel {
  final MedicalRecordContent content;

  /// Texto da evolução da sessão. `null` quando não foi registrada agora.
  final String? evolution;

  const MedicalRecordCreateModel({required this.content, this.evolution});
}
