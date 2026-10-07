import 'evolution_model.dart';
import 'medical_record_content.dart';

/// Criação do prontuário. No primeiro cadastro a evolução da sessão pode
/// ser registrada junto ([evolution]).
class MedicalRecordCreateModel {
  final MedicalRecordContent content;

  /// `null` quando a evolução não foi registrada agora.
  final EvolutionCreateModel? evolution;

  const MedicalRecordCreateModel({required this.content, this.evolution});
}
